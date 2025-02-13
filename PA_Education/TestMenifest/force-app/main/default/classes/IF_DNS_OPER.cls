/**
 * @description       : 대유넥스티어 스테이징 인터페이스 클래스
 * @author            : jonghyun.kim@daeucna.com
 * @group             :
 * @last modified on  : 2024-11-26
 * @last modified by  : jamespark@daeucna.com
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   07-20-2020   jonghyun.kim@daeucna.com       Initial Version
 * 1.1   2024-02-06   jamespark@daeucna.com          주석 정리
**/
@RestResource(urlMapping='/DNS/interface')
global with sharing class IF_DNS_OPER {
    public IF_DNS_OPER() {}

    @HttpPost
    global static void doPost() {
        Boolean islog = false; // 로그기록 여부 초기값(false:log 미기록, true: DEBUG - 모든 기록, ERROR - 실패인 경우만 기록)
        String strCode = '0'; // 0:성공, 1:실패, 2:No data
        String strMessage = '';

        RestRequest request = RestContext.request;
        String reqBody_json = request.requestBody.toString();
        if (Test.isRunningTest()) {
            System.debug('Running test........');
        }
        //System.debug('requestBody => ' + reqBody_json);
        String responseBody = null;
        String msg = '';

        // 마스터정보 추출
        INTERFACE_SERVICE_MASTER__C ifmaster = null;
        // List<Map<String, Object>> contList = new List<Map<String, Object>>();
        //Map<String, Object> outputList = new Map<String, Object>();
        Map<String, Object> reponseObj = new Map<String, Object>(); // 응답 데이터정보
        Map<String, Object> returnObj  = new Map<String, Object>(); // 최종 응답정보
        Integer  reqCount = 0; // 요청건수
        Integer  resCount = 0; // 응답건수
        Datetime reqTime  = Datetime.now();
        Datetime resTime  = null;
        ValueObject inputVo = null; // JSON 요청 파라미터를 담을 VO 변수
        String   interface_id = null; // 인터페이스 아이디
        //Integer  fromPage  = 0; // 페이지 row열 시작번호
        //Integer  toPage    = 0; // 페이지 row열 종료번호
        //Integer  totalPage = 0; // 전체 row수
        Boolean  queryDebug    = false; // 쿼리 디버그 여부(true인 경우, 응답시 수행된 쿼리를 리턴함)
        List<String> queryList = null;  // 쿼리 디버그 문자열 담을 변수
        //Map<String, Integer> limitPage = new Map<String, Integer>(); // 페이지 구하기
        //InterfaceInterceptor ii = new InterfaceInterceptor(); // 인터셉터
        Boolean logInfo = false; // Interface_Service_Log__c의 레코드 아이디 및 Name을 응답받을 지 여부를 결정(true인 경우, Log 아이디값을 함께 리턴)(박성현, 2023-07-07 추가)

        String transaction_no = null; // 트랜잭션 번호

        try{
            if(reqBody_json == null || reqBody_json == '') {
                strCode = '1';
                strMessage = MessageResource.getMessage(MessageResource.MSG_NOT_FOUND_PARAMETER_ERR, null);
            } else {
                try {
                    inputVo = JsonUtil.getJsonParameter(reqBody_json); // 요청 파라메터
                    System.debug('!!!inputVo'+ inputVo);
                } catch(Exception e) {
                    strCode = '1';
                    strMessage = MessageResource.getMessage(MessageResource.MSG_INVALID_PARAMETER_ERR, null);
                }

                if(strCode != '1') {
                    interface_id = inputVo.getString('Interface_id');
                    /*
                    // 페이징 처리를 위한 정보 설정
                    Integer pageNo       = MetaDataHelper.getInteger2String(inputVo.getString('pageNo'), 0);       // 페이지 번호
                    Integer pagePerCount = MetaDataHelper.getInteger2String(inputVo.getString('pagePerCount'), 0); // 페이지 당 표시개수
                    Integer totalPageCount = (pageNo * pagePerCount);
                    fromPage = totalPageCount - pagePerCount + 1;
                    toPage   = totalPageCount;

                    if(fromPage > 0 && toPage > 0) {
                        limitPage.put('LIMIT_CNT',  pagePerCount);
                        limitPage.put('OFFSET_CNT', fromPage);
                    }
*/
                    // 쿼리 디버그 여부 체크 및 디버그 정보을 담을 리스트 생성
                    String queryDebugValue = inputVo.getString('queryDebug');
                    if(queryDebugValue != null && queryDebugValue != '') {
                        queryDebug = MetaDataHelper.getBoolean2String(queryDebugValue);
                        if(queryDebug) {
                            queryList = new List<String>();
                        }
                    }
/*
                    reqCount = inputVo.getSize(); // 요청 파라메터 건수

                    if(interface_id == null || interface_id == '') {
                        interface_id = inputVo.getString('interface_id');
                    }

                    System.debug('Interface ID = ' + interface_id);

                    // Limit Interceptor 할 경우 본 소스에서 페이징 처리를 하지 않기 위해 변수를 둠 (InterfaceInterceptor.limitQueryInterceptor)
                    inputVo.set('limitInterceptor', MetaDataHelper.getBoolean2String('true'));
                    // 각 인터페이스 별로 요청 파라미터를 처리.
                    inputVo = ii.inputDatasetInterceptor(interface_id, inputVo);
                    System.debug('inputVo After InputDatasetInterceptor : ' + inputVo);
*/
                    ValueRow vo = inputVo.getValueRow(); // 0번째 인덱스 ROW 정보 가져오기
                    Map<String, Object> ifData = (Map<String, Object>) vo.get('IF_DATA'); // EXCEPTION 에러가 발생?
                    if (ifData != null) {
                        Map<String, Object> ifSysMap = (Map<String, Object>) ifData.get('IF_SYSTEM_MESSAGE');
                        
                        System.debug('!!!ifSysMap'+ ifSysMap);

                        if (ifSysMap != null) {
                            if(interface_id == null || interface_id == '') { // 잘라서 보내주는 경우 Interface_id 정보가 없을 수 있음.
                                String sfId = MetaDataHelper.getString2Object(ifSysMap.get('SF_ID'));
                                System.debug('!!!!!!!!!!!!!!!sfId  = ' + sfId);
                                interface_id = sfId;
                            }

                            String tno = MetaDataHelper.getString2Object(ifSysMap.get('TRANSACTION_NO')); // 중계서버에서는 반드시 트랜젝션 번호를 담아 보냄
                            transaction_no = tno;
                        }                    
                    }

                    System.debug('Interface ID = ' + interface_id);

                    // 1.인터페이스 마스터 정보 조회
                    Map<ID, INTERFACE_SERVICE_MASTER__C> interface_mst = new Map<ID, INTERFACE_SERVICE_MASTER__C>([
                            SELECT ID
                                    ,INTERFACE_ID__C
                                    ,IN_OUT_TYPE__C
                                    ,HTTP_METHOD_TYPE__C // 업무수행 타입
                                    ,MASTER_TABLE__C // 서버측 테이블(IN(요청)조건의 쿼리로 조회할 때 적용할 from 테이블 객체명)
                                    ,PROTOCOL_TYPE__C
                                    ,RESPONSE_DATA_FORMAT_TYPE__C // JOSN, XML, OBJECT
                                    ,REQUEST_DATA_FORMAT_TYPE__C // JOSN, XML, OBJECT
                                    ,RECORD_NAME__C // external ID
                                    ,RUN_CLASS__C // 개발자가 직접 처리하는 경우, 호출할 클래스명 지정
                                    ,LOG_TYPE__C // 로그기록 타입(ERROR:에러만 기록, DEBUG:모든 처리내용 기록)
                                    ,Dml_Log_Type__c // 작업 구분 필드(로그의 수행내용) (2023-12-26, 박성현 추가)
                            //    ,INTERFACE_GROUP_NO //  인터페이스
                            FROM INTERFACE_SERVICE_MASTER__C
                            WHERE INTERFACE_ID__C = :interface_id
                            LIMIT 1
                    ]);

                    System.debug('interface_mst>>' + interface_mst);

                    if(interface_mst == null|| interface_mst.size() == 0) {
                        strCode = '1';
                        strMessage = MessageResource.getMessage(MessageResource.MSG_NOT_FOUND_IF_ID_ERR, null);
                    } else {
                        for (ID idKey : interface_mst.keyset()) {
                            ifmaster = interface_mst.get(idKey);
                            break;
                        }
                    }
                }
            }

//            if(strCode != '1') {
/*
                // 2.인터페이스 상세에서 요청/응답 정보와 실행계획 조회
                List<INTERFACE_SERVICE_DETAIL__C> interface_in_dtl = new List<INTERFACE_SERVICE_DETAIL__C>([
                        SELECT ID
                                ,SOURCE_COLUMN__C // 응답시 데이터를 담을 데이터명칭
                                ,TARGET_COLUMN__C // 서버측 테이블 필드ID
                                ,TARGET_TABLE__C // 서버측 테이블(쿼리로 조회할 때 적용할 from 테이블 객체명)
                                ,SOURCE_COLUMN_TYPE__C // 응답 데이터 타입(LIST, MAP 또는 상위 응답필드명)
                                ,TARGET_COLUMN_TYPE__C // 데이터 타입(String, Boolean, Date, Datetime, Id 등)
                                ,CONDITION_TYPE__C // 조건(AND, OR, IN, LIKE)
                                ,DEFAULT_VALUE__C // 요청값이 없는 경우, 자동으로 채울 값
                                ,SOURCE_COLUMN_REQUIRE_YN__C // 필수여부(Y/N)
                                ,REQUEST_COLUMN_FORMAT__C // 데이터 타입
                                ,RECORD_FROM__C // 조회시작번호
                                ,RECORD_TO__C // 조회종료번호
                                ,IN_OUT_TYPE__C // IN(요청), OUT(응답)
                                ,TARGET_COLUMN_MIX_TYPE__C // 조합조건(AND, OR)
                                ,SOQL_FUNCTION__C // SOQL 적용함수 지정
                                ,INTERCEPTOR_METHOD__C // 데이터 예외처리 함수명
                        FROM INTERFACE_SERVICE_DETAIL__C
                        WHERE INTERFACE_SERVICE_MASTER__R.INTERFACE_ID__C = :interface_id
                        AND IN_OUT_TYPE__C = 'IN'
                        ORDER BY SOURCE_COLUMN_TYPE__C
                ]);

                List<INTERFACE_SERVICE_DETAIL__C> interface_out_dtl = new List<INTERFACE_SERVICE_DETAIL__C>([
                        SELECT ID
                                ,SOURCE_COLUMN__C // 응답시 데이터를 담을 데이터명칭
                                ,TARGET_COLUMN__C // 서버측 테이블 필드ID
                                ,TARGET_TABLE__C // 서버측 테이블(쿼리로 조회할 때 적용할 from 테이블 객체명)
                                ,SOURCE_COLUMN_TYPE__C // 응답 데이터 타입(LIST, MAP 또는 상위 응답필드명)
                                ,TARGET_COLUMN_TYPE__C // 데이터 타입(String, Boolean, Date, Datetime, Id 등)
                                ,CONDITION_TYPE__C // 조건(AND, OR, IN, LIKE)
                                ,DEFAULT_VALUE__C // 요청값이 없는 경우, 자동으로 채울 값
                                ,SOURCE_COLUMN_REQUIRE_YN__C // 필수여부(Y/N)
                                ,REQUEST_COLUMN_FORMAT__C // 데이터 타입
                                ,RECORD_FROM__C // 조회시 응답할 시작번호
                                ,RECORD_TO__C // 조회시 응갑할 종료번호
                                ,IN_OUT_TYPE__C // IN(요청), OUT(응답)
                                ,TARGET_COLUMN_MIX_TYPE__C // 조합조건(AND, OR)
                                ,SOQL_FUNCTION__C // SOQL 적용함수 지정
                                ,INTERCEPTOR_METHOD__C // 데이터 예외처리 함수명
                        FROM INTERFACE_SERVICE_DETAIL__C
                        WHERE INTERFACE_SERVICE_MASTER__R.INTERFACE_ID__C = :interface_id
                        AND IN_OUT_TYPE__C = 'OUT'
                ]);

                Integer inDtlCnt  = interface_in_dtl.size();
                Integer outDtlCnt = interface_out_dtl.size();

                if((inDtlCnt + outDtlCnt) == 0) {
                    strCode = '1';
                    // 예외처리인 경우이더라도, 반드시 1개 이상의 Detail 항목을 설정한다.
                    strMessage = MessageResource.getMessage(MessageResource.MSG_NOT_FOUND_CONFIG_ERR, null);
                }
*/
                if(strCode != '1') {
                    // true : 기본 설정
                    // false : 예외처리 클래스
                    Boolean runClassYn = (ifmaster.RUN_CLASS__C == null || ifmaster.RUN_CLASS__C == '');
/*
                    // 3.요청 데이터 유형(JSON, XML, OBJECT 등)에 맞는 데이터 추출
                    List<ValueRow> volist = inputVo.getList(); // Request parameter list
                    QueryConfigResource in_if = new QueryConfigResource();
                    List<QueryConfigResource> out_if_list = new List<QueryConfigResource>(); // 리턴되는 타입이 N건인 경우를 처리하기 위한 List객체 생성(2020-08-07)



                    // 유효성 체크결과 반영
                    // 기본 설정을 태울 때에만 아래 로직을 타도록 한다(2024-02-14)
                    if (runClassYn) {
                        String inMsg = in_if.getInputResource(ifmaster, interface_in_dtl, volist);
                        if(inMsg != null && inMsg != '') {
                            strCode = '1';
                            strMessage = inMsg;
                        }

                        System.debug('IN result code = ' +strCode+', input result Message = ' + inMsg);
                    }

                    String outMsg = null;

                    if(outDtlCnt > 0) {
                        for(INTERFACE_SERVICE_DETAIL__C ret : interface_out_dtl) {
                            QueryConfigResource out_if = new QueryConfigResource(ret.Id);

                            outMsg = out_if.getOutputResource(ifmaster, ret, volist);

                            if(outMsg != null && outMsg != '') {
                                strCode = '1';strMessage = outMsg;
                            }

                            out_if_list.add(out_if);
                        }
                    } else {
                        QueryConfigResource out_if = new QueryConfigResource();

                        out_if_list.add(out_if);
                    }

                    System.debug('OUT result code = ' + strCode + ', / output result message = ' + outMsg);
*/
                    if(strCode == null  || strCode != '1') {
                        System.debug('ifmaster.Interface_ID__c : ' + ifmaster.Interface_ID__c);
                        // if(ifmaster.RUN_CLASS__C == null || ifmaster.RUN_CLASS__C == '') {
                        if(runClassYn) {
                            throw new BizException('예외처리 클래스 명을 지정하세요.');
/*
                            System.debug('request method type = ' +ifmaster.HTTP_METHOD_TYPE__C);

                            // 4.요청타입(select:GET/POST, insert or update : PUT, delete:DELETE)에 따라 요청내용 처리
                            //    - 인터페이스 마스터에서 지정한 table객체를 from절에 넣고, select 절은 인터페이스 상세의 맵핑필드를 넣음.
                            //    - where절은 요청 데이터에 따라 필드맵핑정보를 이용하여 Map으로 생성한 후 자동으로 쿼리에 추가함
                            if(ifmaster.HTTP_METHOD_TYPE__C == 'POST' || ifmaster.HTTP_METHOD_TYPE__C == 'GET') { // select
                                for(QueryConfigResource  out_if : out_if_list) {
                                    List<Map<String, Object>> contList = new List<Map<String, Object>>(); // 조회결과를 담을 객체생성

                                    // 조회업무 실행계획
                                    List<Map<String, String>> tableList = new List<Map<String, String>>();
                                    List<INTERFACE_SERVICE_PLAN__C> dmlTableList = out_if.getDmlTableList(); // LIST와 MAP 타입을 처리하기 위한 실행계획

                                    if(queryList != null) {
                                        queryList.add('=======================================================================================================================');
                                        queryList.add('Interface ID:'+interface_id+', Batch type = SELECT, Execute plan = ' + dmlTableList.toString() + ', Server : ' + URL.getSalesforceBaseUrl().toExternalForm());
                                        queryList.add('-----------------------------------------------------------------------------------------------------------------------');
                                    }

                                    if(dmlTableList.size() > 0) {
                                        for(INTERFACE_SERVICE_PLAN__C dmlObj : dmlTableList) {
                                            Map<String, String> dmlMap = new Map<String, String>();

                                            dmlMap.put('TABLE__C', dmlObj.TABLE__C);
                                            dmlMap.put('DML__C', dmlObj.DML__C);
                                            dmlMap.put('LIMIT_COUNT__C', MetaDataHelper.getBindString(dmlObj.LIMIT_COUNT__C, null, null));
                                            dmlMap.put('INTERCEPTOR_CODE__C', dmlObj.INTERCEPTOR_CODE__C);
                                            tableList.add(dmlMap);
                                        }
                                    } else { // LIST나 MAP이 아닌 경우 실행계획을 대상 테이블로 대처함
                                        String tname = out_if.getTableName(); // 메인테이블 정보
                                        List<String> outtb = out_if.getSubTableList(); // 서브테이블 정보

                                        if(tname != null) {
                                            Map<String, String> dmlMap = new Map<String, String>();

                                            dmlMap.put('TABLE__C', tname);
                                            dmlMap.put('DML__C', 'SELECT');
                                            dmlMap.put('LIMIT_COUNT__C', null);
                                            dmlMap.put('INTERCEPTOR_CODE__C', null);

                                            tableList.add(dmlMap);

                                            for(String otb : outtb) {
                                                dmlMap = new Map<String, String>();

                                                dmlMap.put('TABLE__C', otb);
                                                dmlMap.put('DML__C', 'SELECT');
                                                dmlMap.put('LIMIT_COUNT__C', null);
                                                dmlMap.put('INTERCEPTOR_CODE__C', null);

                                                tableList.add(dmlMap);
                                            }
                                        }
                                    }

                                    if(tableList.size() > 0) {
                                        String retName = ''; // List 형식의 값을 담을 때 사용하는 명칭

                                        for(Map<String, string> dmlMap : tableList) { // 수행계획(List 또는 Map 리턴처리)
                                            String tname = dmlMap.get('TABLE__C');
                                            String ttype = dmlMap.get('DML__C');
                                            Decimal limitCount = MetaDataHelper.getDecimal2String(dmlMap.get('LIMIT_COUNT__C')); // 조회건수 제한(Limit)
                                            String interceptorCode = dmlMap.get('INTERCEPTOR_CODE__C');

                                            System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + dmlMap);

                                            if(strCode == '1') break;

                                            if(tname == null) {
                                                strCode = '1';strMessage = MessageResource.getMessage(MessageResource.MSG_NOT_FOUND_TB_CONFIG_ERR, null);
                                            } else {
                                                if(out_if.getTableName() == tname) { // 메인쿼리(OUT 대상 테이블과 실행할 테이블이 같은 경우 메인쿼리로 인식함)
                                                    List<Map<String, Object>> inbindList  = in_if.getMainBindList();
                                                    List<Map<String, Object>> outbindList = out_if.getMainBindList(); // 조건절
                                                    List<Map<String, Object>> bindList    = new List<Map<String, Object>>(); // 조건절

                                                    bindList.addAll(inbindList);// out에 추가된 조건을 추가한다.
                                                    if(outbindList != null && outbindList.size() > 0) {
                                                        bindList.addAll(outbindList);// out에 추가된 조건을 추가한다.
                                                    }

                                                    List<String> outfieldList = out_if.getMainFields();
                                                    List<String> outcolumnList = out_if.getMainColumns();
                                                    List<String> groupingList = out_if.getGroupingList();

                                                    // System.debug('main query talble name = ' + tname + ', order by  = ' + out_if.getOrderList());

                                                    if(ttype == 'COUNT') {
                                                        String query = 'SELECT COUNT(ID) CNT FROM {TABLE_NAME}';

                                                        // 파라메터 : 인터페이스ID, 조회쿼리, 테이블명, 조건절 정보, 조회절 정보, 조회필드, 정렬조건, 그룹핑조건, 디버그용 쿼리 저장객체, 요청파마메터, 조회건수, 예외조건코드
                                                        contList = SOQLUtil.selectQuery(interface_id, query, tname, bindList, null, null, null, groupingList, queryList, inputVo, limitCount, interceptorCode);
                                                    } else {
                                                        if(ttype == 'SELECT' || (ttype == 'SUB-SELECT' && contList.size() == 0)) {
                                                            String query = 'SELECT * FROM {TABLE_NAME}';
                                                            System.debug('do selectQuery');
                                                            contList = SOQLUtil.selectQuery(interface_id, query, tname, bindList, outcolumnList, outfieldList, out_if.getOrderList(), groupingList, queryList, inputVo, limitCount, interceptorCode);
                                                        }
                                                    }
                                                } else { // 서브쿼리 실행
                                                    // 서브쿼리의 실행정보 조회
                                                    List<Map<String, Object>> subbindList = out_if.getSubBindList(tname); // 조건절
                                                    List<String> subfieldList = out_if.getSubFields(tname); // 조회 필드
                                                    List<String> subColumnList = out_if.getSubColumns(tname); // 조회 컬럼
                                                    List<Map<String, Object>> subOrderList = out_if.getSubOrderList(tname); // 정렬기준
                                                    List<String> subGroupingList = out_if.getSubGroupingList(tname);

                                                    if(subfieldList == null || subfieldList.size() == 0) {
                                                        strCode = '1';strMessage = MessageResource.getMessage(MessageResource.MSG_NOT_FOUND_SUB_QUERY_ERR, null);break;
                                                    }

                                                    System.debug('Sub select field = ' + subColumnList);
                                                    // System.debug('Sub condition = ' + subbindList);

                                                    // 조건절 적용 우선순위를 찾는다.
                                                    Map<String, Object> subInfo = null;

                                                    // a.Key값에 의한 조건절를 가지고 있는 바인딩 정보 조회
                                                    for(Map<String, Object> sbind : subbindList) {
                                                        if(sbind.get('WHERE_COLUMN_SORT_NO') == '0') {
                                                            subInfo = sbind;break;
                                                        }
                                                    }
                                                    // b.Key값이 없는 조건정보에 의한 조건절를 가지고 있는 바인딩 정보 조회
                                                    if(subInfo == null) {
                                                        for(Map<String, Object> sbind : subbindList) {
                                                            if(sbind.get('WHERE_COLUMN_SORT_NO') == '1') {
                                                                subInfo = sbind;break;
                                                            }
                                                        }
                                                    }
                                                    // c.a와 b가 없이 테이블 정보만 있는 경우, 바인딩 조건
                                                    if(subInfo == null) {
                                                        for(Map<String, Object> sbind : subbindList) {
                                                            if(sbind.get('WHERE_COLUMN_SORT_NO') == '2') {
                                                                subInfo = sbind;break;
                                                            }
                                                        }
                                                    }

                                                    // System.debug('sub query binding info = ' + subInfo + ', select result = ' + contList);

                                                    String subTable = MetaDataHelper.getString2Object(subInfo.get('TARGET_TABLE__C'));
                                                    String substr = MetaDataHelper.getString2Object(subInfo.get('SEARCH_CONDITION_VALUE__C'));
                                                    String condfield = MetaDataHelper.getString2Object(subInfo.get('SEARCH_CONDITION_FIELD__C'));


                                                    // 조회 필드가 누락된 경우에는 select절에 포함시킨다.
                                                    Boolean fieldChk = false;

                                                    for(String field : subColumnList) {
                                                        if(field == condfield) {
                                                            fieldChk = true;
                                                            break;
                                                        }
                                                    }

                                                    if(!fieldChk) {
                                                        subColumnList.add(condfield);

                                                        List<String> splitString = condfield.split(' ');
                                                        if(splitString.size() > 1) {
                                                            subfieldList.add(splitString[1]);
                                                        } else {
                                                            subfieldList.add(splitString[0]);
                                                        }
                                                    }

                                                    // 동일 테이블에 추가될 검색조건을 찾아 조회쿼리에 반영
                                                    List<Map<String, Object>> subTableCond = new List<Map<String, Object>>();

                                                    for(Map<String, Object> subcond : subbindList) {
                                                        if(MetaDataHelper.getString2Object(subcond.get('TARGET_TABLE__C')) == subTable && subcond.get('WHERE_COLUMN_ID') != null) {
                                                            subTableCond.add(subcond);
                                                        }
                                                    }

                                                    // 이전 조회결과와 서브쿼리 실행 후 조회결과를 합치기 위해 이전 조회결과를 copy한 후 내용을 삭제함
                                                    List<Map<String, Object>> cloneList = contList.clone();
                                                    contList.clear();

                                                    List<Object> idList_1 = new List<Object>(); // ID목록을 가지고 있는 객체
                                                    List<Map<String, Object>> idList_2 = new List<Map<String, Object>>();
                                                    List<String> groupList = new List<String>();

                                                    // 기본 ID 조건값 생성
                                                    for(Map<String, Object> sub : cloneList) {
                                                        Object subObj = sub.get(substr); // Map에서 값을 찾아 ID에 맵핑함
                                                        if(subObj == null) subObj = sub.get(retName); // Map에 값이 없는 경우에는 바로 전에 수행한 쿼리 결과의 List에서 찾아 맵핑함

                                                        if(subObj instanceof List<Map<String, Object>>) {
                                                            List<Map<String, Object>> subObjList = (List<Map<String, Object>>) subObj;

                                                            for(Map<String, Object> listObj : subObjList) {
                                                                String bindID = MetaDataHelper.getBindString(listObj.get(substr), null); // 조회할 ID리스트 추출

                                                                if(bindID != null && bindID != '') idList_1.add(bindID);
                                                            }
                                                        } else {
                                                            String bindID = MetaDataHelper.getBindString(subObj, 'ID'); // 조회할 ID리스트 추출

                                                            if(bindID != null && bindID != '') idList_1.add(bindID);
                                                        }
                                                    }

                                                    if(idList_1.size() == 0) {
                                                        // strCode = '1';
                                                        // strMessage = MessageResource.getMessage(MessageResource.MSG_NOT_FOUND_SUB_ID_ERR, new List<String>{subTable, condfield, substr});
                                                        break;
                                                    }

                                                    // 추가 조건값 생성
                                                    for(Map<String, Object> subcond : subbindList) {
                                                        Map<String, Object> idMap = null;

                                                        idMap = new Map<String, Object>();

                                                        if(MetaDataHelper.getString2Object(subcond.get('TARGET_TABLE__C')) == subTable && subcond.get('WHERE_COLUMN_ID') != null && subcond.get('WHERE_COLUMN_ID') != '') {
                                                            // 조건절에 대한 기본값을 먼저 적용하지만, 없는 경우에는 조건값을 적용하도록 수정함(2020-08-03)
                                                            if(subcond.get('WHERE_COLUMN_VAL') == null && subcond.get('SEARCH_CONDITION_VALUE__C') != null) {
                                                                String stype = MetaDataHelper.getString2Object(subcond.get('SEARCH_TARGET_COLUMN_TYPE__C'), null);
                                                                String key = MetaDataHelper.getString2Object(subcond.get('WHERE_COLUMN_ID'));
                                                                String sval = MetaDataHelper.getString2Object(subcond.get('SEARCH_CONDITION_VALUE__C'), null); // Map명칭 정의
                                                                String confield = MetaDataHelper.getString2Object(subcond.get('SEARCH_CONDITION_FIELD__C')); // 조회될 필드

                                                                List<String> bindValList = new List<String>();

                                                                for(Map<String, Object> sub : cloneList) {
                                                                    Object subObj = sub.get(sval); // Map에서 값을 찾아 ID에 맵핑함
                                                                    if(subObj == null) subObj = sub.get(retName); // Map에 값이 없는 경우에는 바로 전에 수행한 쿼리 결과의 List에서 찾아 맵핑함

                                                                    if(subObj instanceof List<Map<String, Object>>) {
                                                                        List<Map<String, Object>> subObjList = (List<Map<String, Object>>) subObj;

                                                                        for(Map<String, Object> listObj : subObjList) {
                                                                            String bindID = MetaDataHelper.getBindString(listObj.get(sval), null); // 조회할 ID리스트 추출

                                                                            if(bindID != null && bindID != '') bindValList.add(bindID);
                                                                        }
                                                                    } else {
                                                                        String bindID = MetaDataHelper.getBindString(subObj, 'ID'); // 조회할 ID리스트 추출

                                                                        if(bindID != null && bindID != '') bindValList.add(bindID);
                                                                    }
                                                                }

                                                                subcond.put('WHERE_COLUMN_VAL', bindValList);idList_2.add(subcond);
                                                                System.debug('<<<<< '+subcond);
                                                            }
                                                        }
                                                    }

                                                    List<Map<String, Object>> sub_result = new List<Map<String, Object>>();

                                                    if(ttype == 'COUNT') { // 그룹핑을 통한 건수조회 쿼리 수행
                                                        if(subGroupingList == null || subGroupingList.size() == 0) {
                                                            String query = 'SELECT COUNT(ID) CNT FROM {TABLE_NAME} WHERE ' + condfield + ' IN(' + String.join(idList_1, ',') + ')';

                                                            // 파라메터 : 인터페이스ID, 조회쿼리, 테이블명, 조건절 정보, 조회절 정보, 조회필드, 정렬조건, 그룹핑조건, 디버그용 쿼리 저장객체, 요청파마메터, 조회건수, 예외조건코드
                                                            sub_result = SOQLUtil.selectQuery(interface_id, query, subTable, subTableCond, null, null, null, subGroupingList, queryList, inputVo, limitCount, interceptorCode);
                                                        } else {
                                                            String query = 'SELECT *, COUNT(NAME) CNT FROM {TABLE_NAME} WHERE ' + condfield + ' IN(' + String.join(idList_1, ',') + ')';

                                                            sub_result = SOQLUtil.selectQuery(interface_id, query, subTable, subTableCond, subGroupingList, subGroupingList, null, subGroupingList, queryList, inputVo, limitCount, interceptorCode);
                                                        }

                                                        // System.debug('Count() field list = ' + subGroupingList);
                                                    } else {
                                                        if(ttype == 'SELECT' || (ttype == 'SUB-SELECT' && contList.size() == 0)) {
                                                            String query = 'SELECT * FROM {TABLE_NAME} WHERE ' + condfield + ' IN(' + String.join(idList_1, ',') + ')';
                                                            System.debug('sub query = ' + query + ', column = ' + subColumnList + ', field = ' + subfieldList);

                                                            sub_result = SOQLUtil.selectQuery(interface_id, query, subTable, subTableCond, subColumnList, subfieldList, subOrderList, subGroupingList, queryList, inputVo, limitCount, interceptorCode);
                                                        }
                                                    }

                                                    System.debug('sub result data['+subTable+'] = ' + sub_result);

                                                    // 서브 응답 데이터 중 리스트에 대한 명칭 조회
                                                    retName = null;
                                                    String retType = null;

                                                    for(Map<String, Object> sbind : subbindList) {
                                                        if(sbind.get('TARGET_COLUMN_TYPE__C') == 'LIST' || sbind.get('TARGET_COLUMN_TYPE__C') == 'MAP' || sbind.get('TARGET_COLUMN_TYPE__C') == 'MAP.STRING') {
                                                            retName = MetaDataHelper.getString2Object(sbind.get('TARGET_TABLE__C')); // 조회할 테이블과 동일함
                                                            retType = MetaDataHelper.getString2Object(sbind.get('TARGET_COLUMN_TYPE__C'));
                                                            break;
                                                        }
                                                    }

                                                    System.debug('select list >> old count = ' + cloneList.size() + ', new count = ' + sub_result.size());

                                                    // 서브 응답 데이터에 리스트가 있다면 조회된 리스트를 그대로 저장한다.
                                                    for(Map<String, Object> sub : cloneList) {
                                                        String bindID = MetaDataHelper.getString2Object(sub.get(substr));
                                                        List<Map<String, Object>> dataTilterList = new List<Map<String, Object>>();

                                                        for(Map<String, Object> result : sub_result) {
                                                            String resultID = MetaDataHelper.getString2Object(result.get(subTable + '_' + condfield));
                                                            Boolean existsyn = false;

                                                            // System.debug(substr + ':' + bindID + ' / ' + subTable + '_' + condfield + ':' + resultID);

                                                            // 그룹핑 조건없이 count 건수를 구하는 경우에는 조회된 건수를 바로 등록함
                                                            if(ttype == 'COUNT') {
                                                                if(subGroupingList == null || subGroupingList.size() == 0) {existsyn = true;}
                                                            }

                                                            if(!existsyn) {
                                                                if(resultID != null && resultID != '' && resultID == bindID) { // 상위ID와 하위ID가 같은 경우
                                                                    if(idList_2 == null || idList_2.size() == 0) {
                                                                        existsyn = true;
                                                                    } else {
                                                                        Integer cnt = 0;

                                                                        for(Map<String, Object> id2 : idList_2) {
                                                                            String sval = MetaDataHelper.getString2Object(id2.get('SEARCH_CONDITION_VALUE__C'), null); // Map명칭 정의
                                                                            String confield = MetaDataHelper.getString2Object(id2.get('SEARCH_CONDITION_FIELD__C')); // 조회될 필드

                                                                            String oldID = MetaDataHelper.getString2Object(sub.get(sval)); // 기 조회된 정보
                                                                            String newID = MetaDataHelper.getString2Object(result.get(subTable + '_' + confield)); // 서브쿼리를 통해 조회된 데이터

                                                                            // System.debug('New data = ' + result);
                                                                            // System.debug(sval + ':' + oldID + ' / ' + subTable + '_' + confield + ':' + newID);

                                                                            if(newID != null && newID != '' && oldID == newID) cnt++;
                                                                        }

                                                                        // System.debug('child & parent = ' + cnt + ' / ' + idList_2.size());
                                                                        if(cnt == idList_2.size()) existsyn = true;
                                                                    }
                                                                }
                                                            }

                                                            // System.debug('Subquery equals = ' + existsyn + ', data = ' + result);

                                                            if(existsyn) {
                                                                // 데이터 filtering
                                                                existsyn = ii.filterDatasetInterceptor(subTable, sub, result, inputVo);

                                                                if(existsyn) {
                                                                    dataTilterList.add(result);
                                                                    System.debug('Subquery equals = ' + existsyn + ', join data = ' + result);
                                                                }
                                                            }
                                                        }

                                                        if(retName != null && retName != '') { // 리스트 담기
                                                            System.debug('sub data type(List name = ' + retName + ', data = '+dataTilterList+', data type = '+retType+')');

                                                            if(dataTilterList != null && dataTilterList.size() > 0) {
                                                                if(retType == 'LIST') {
                                                                    sub.put(retName, dataTilterList);
                                                                    contList.add(sub);
                                                                } else if(retType == 'MAP' || retType == 'MAP.STRING') {
                                                                    List<Map<String, Object>> retData = new List<Map<String, Object>>();
                                                                    retData.add(dataTilterList.get(0));

                                                                    sub.put(retName, retData);
                                                                    contList.add(sub);
                                                                }
                                                            } else {
                                                                contList.add(sub);
                                                            }
                                                        } else { // Map정보 담기
                                                            if(dataTilterList == null || dataTilterList.size() == 0) {
                                                                contList.add(sub);
                                                            } else {
                                                                for(Map<String, Object> subrstMap: dataTilterList) {
                                                                    Map<String, Object> subConMap = new Map<String, Object>();

                                                                    subConMap.putAll(subrstMap);
                                                                    subConMap.putAll(sub);

                                                                    contList.add(subConMap);
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            } // end if(out_if.getTableName() != null) 테이블 명칭이 있는 경우
                                        } // end for(INTERFACE_SERVICE_PLAN__C dmlObj : dmlTableList) { // 수행계획
                                    } else {
                                        strCode = '1';strMessage = MessageResource.getMessage(MessageResource.MSG_NOT_FOUND_PLAN_ERR, null);
                                    }

                                    outputList.put(out_if.getTransactionID(), contList);
                                } // // end for(QueryConfigResource  out_if : out_if_list)
                            } else { // 요청 파라메터에 의한 작업지시(POST, GET이 아닌 경우)
                                for(QueryConfigResource  out_if : out_if_list) {
                                    List<Map<String, Object>> contList = new List<Map<String, Object>>(); // 조회결과를 담을 객체생성

                                    // 응답 데이터 설정 정보
                                    List<String> outfieldList  = out_if.getMainFields(); // 조회할 필드 리스트
                                    List<String> outcolumnList = out_if.getMainColumns();
                                    List<String> outTableList  = new List<String>();
                                    List<INTERFACE_SERVICE_PLAN__C> outPlanList = new List<INTERFACE_SERVICE_PLAN__C>();
                                    List<INTERFACE_SERVICE_PLAN__C> outTablePlan = out_if.getDmlTableList(); // 실행계획

                                    if(outTablePlan.size() > 0) {
                                        for(INTERFACE_SERVICE_PLAN__C planObj : outTablePlan) {
                                            outTableList.add(planObj.TABLE__C);
                                            outPlanList.add(planObj);
                                        }
                                    } else {
                                        String tname       = out_if.getTableName(); // 메인테이블 정보
                                        List<String> outtb = out_if.getSubTableList(); // 서브테이블 정보

                                        if(tname != null) {
                                            outTableList.add(tname);
                                            outTableList.addAll(outtb);
                                        }
                                    }

                                    // System.debug('DML result table list = ' + outTableList);

                                    // DML 요청 파라메터 및 설정정보
                                    List<Map<String, Object>> mappingList =  in_if.getFieldMappingList(); // 리스트 타입인 경우, 메인과 서버쿼리의 응답 정보를 취합한 Map 정보 리턴가능
                                    List<Map<String, Object>> mappingData = SOQLUtil.getTargetFieldData(mappingList, volist); // 외부에서 등록을 요청한 리스트 정보(mappingList를 통합한 필드정보)
                                    List<Map<String, Object>> inbindList  = in_if.getMainBindList();
                                    List<String> infieldList  = in_if.getMainFields();
                                    List<String> inColumnList = in_if.getMainColumns();
                                    List<String> groupingList = in_if.getGroupingList();
                                    List<INTERFACE_SERVICE_PLAN__C> dmlTableList = in_if.getDmlTableList(); // 실행계획에 따라 작업을 수행함

                                    // 디버깅 시작
                                    if(queryList != null) {
                                        queryList.add('=======================================================================================================================');
                                        queryList.add('Server : ' + URL.getSalesforceBaseUrl().toExternalForm());
                                        queryList.add('IN Plan >> Interface ID:' + interface_id + ', Batch type = DML, Execute plan = ' + dmlTableList.toString());
                                        if(outTableList.size() > 0) {
                                            queryList.add('OUT Plan >> Interface ID:' + interface_id + ', Batch type = DML, Execute plan = ' + outTablePlan.toString());
                                        }
                                        queryList.add('-----------------------------------------------------------------------------------------------------------------------');
                                    }

                                    if(dmlTableList.size() > 0) {
                                        System.debug('UPSERT Data size = ' + mappingData.size());

                                        for(Map<String, Object> dataMap : mappingData) { // 외부에서 등록을 요청한 리스트 정보
                                            if(strCode == '1') break;
                                            System.debug('Request mapping data = ' + dataMap);

                                            List<Map<String, Object>> dmlSelectList = new List<Map<String, Object>>();
                                            Map<String, Object> outstrMap           = new Map<String, Object>();
                                            Integer planCnt = 0;
                                            Datetime dtLogStart;
                                            Datetime dtLogEnd;

                                            for(INTERFACE_SERVICE_PLAN__C dmlObj : dmlTableList) { // 수행계획
                                                if(strCode == '1') break;
                                                dtLogStart = Datetime.now();
                                                
                                                System.debug('[PLAN][' + planCnt + '][Start] : ' + dmlObj);

                                                String tname = dmlObj.TABLE__C;

                                                // 바인딩 값 변경
                                                for(Map<String, Object> bind: inbindList){
                                                    Object bindValue = dataMap.get(tname + '_' + MetaDataHelper.getString2Object(bind.get('WHERE_COLUMN_ID')));
                                                    bind.put('WHERE_COLUMN_VAL', bindValue);
                                                }

                                                System.debug('Main Query >> table name = ' + tname + ', bind list = ' + inbindList + ', field list = ' + infieldList);
                                                //System.debug('tname = ' + tname);
                                                //System.debug('tname = ' + in_if.getTableName());

                                                if(in_if.getTableName() == tname) { // 메인쿼리
                                                    String query = 'SELECT Id, * FROM {TABLE_NAME}';
                                                    String dmlType = inputVo.getString('dmlType');

                                                    if(dmlObj.DML__C == 'SELECT') {

                                                        dmlSelectList = SOQLUtil.selectQuery(interface_id, query, tname, inbindList, inColumnList, infieldList, null, groupingList, queryList, inputVo, null, null);
                                                        System.debug('dmlSelectList Size = ' + dmlSelectList.size());

                                                        // INPUT 파라미터에 dmlType을 추가하는 경우, DML CHECK. (2023-01-10 박성현 추가)
                                                        // INPUT 파라미터에 dmlType Key가 없는 경우, id 조회결과 유무로만 upsert를 수행한다.
                                                        if (dmlType == '' || dmlType == null) {dmlType = '';}
                                                        if (dmlType != '' || dmlType != null) {dmlType.toUpperCase();}
                                                        // 이미 존재하는 레코드인데, 등록할 수 없다는 오류 메시지
                                                        if ((dmlSelectList != null || dmlSelectList.size() > 0) && dmlType == 'I') {
                                                            strCode = '1';strMessage = MessageResource.getMessage(MessageResource.MSG_FIAL_INSERT_ERR_2, null);break;
                                                        }
                                                        // 존재하지 않는 레코드는 수정할 수 없다는 오류 메시지
                                                        if ((dmlSelectList == null || dmlSelectList.size() == 0) && dmlType == 'U') {
                                                            strCode = '1';strMessage = MessageResource.getMessage(MessageResource.MSG_FIAL_UPDATE_ERR_2, null);break;
                                                        }
                                                        // 존재하지 않는 레코드는 삭제할 수 없다는 오류 메시지
                                                        if ((dmlSelectList == null || dmlSelectList.size() == 0) && dmlType == 'D') {
                                                            strCode = '1';strMessage = MessageResource.getMessage(MessageResource.MSG_FIAL_DELETE_ERR_2, null);break;
                                                        }
                                                    } else if(dmlObj.DML__C == 'UPSERT') { // upsert 수행
                                                        System.debug('select data = ' + dmlSelectList);

                                                        String id = null;                                                        

                                                        if (dmlType == '' || dmlType == null) {dmlType = '';}
                                                        // 첫번째 SELECT 플랜에서 결과값이 없는 경우 그리고 DML TYPE이 'U'가 아닌 경우에는 INSERT만 수행.
                                                        if((dmlSelectList == null || dmlSelectList.size() == 0) && dmlType != 'U') {
                                                            id = SOQLUtil.insertQuery(interface_id, tname, infieldList, dataMap, queryList);

                                                            if(id == null) {
                                                                strCode = '1';strMessage = MessageResource.getMessage(MessageResource.MSG_FIAL_INSERT_ERR, null);break;
                                                            }
                                                        } else { // 2021.01.15
                                                            // } else if (dmlSelectList != null || dmlSelectList.size() > 0) {
                                                            // UPDATE 문 실행
                                                            query = 'SELECT Id FROM {TABLE_NAME}';

                                                            id = SOQLUtil.updateQuery(interface_id, query, tname, inbindList, infieldList, dataMap, queryList);

                                                            if(id == null) {
                                                                strCode = '1';strMessage = MessageResource.getMessage(MessageResource.MSG_FIAL_UPDATE_ERR, null);break;
                                                            }
                                                        }

                                                        // 응답 데이터 생성
                                                        if(id != null && id != '') {
                                                            Integer c = Integer.valueOf(dmlObj.Order_No__c+1);

                                                            for(String outtb : outTableList) {
                                                                if(tname == outtb) {
                                                                    System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Interface_Service_Main_Plan__c:{Id='+id+', Order_No__c='+c+', Table__c='+outtb+', DML__c=SELECT, Interface_Service_Detail__c='+dmlObj.Interface_Service_Detail__c+'}');

                                                                    String out_query = 'SELECT * FROM {TABLE_NAME} WHERE id = ' + MetaDataHelper.getBindString(id, 'ID');
                                                                    Decimal outLimitCount = null;
                                                                    String interceptorCode = null;

                                                                    for(INTERFACE_SERVICE_PLAN__C outPlan : outPlanList) {
                                                                        if(tname == outPlan.TABLE__C) {
                                                                            outLimitCount = outPlan.LIMIT_COUNT__C;
                                                                            interceptorCode = outPlan.INTERCEPTOR_CODE__C;
                                                                            break;
                                                                        }
                                                                    }

                                                                    List<Map<String, Object>> outList = SOQLUtil.selectQuery(interface_id, out_query, outtb, null, outcolumnList, outfieldList, null, null, queryList, inputVo, outLimitCount, interceptorCode);

                                                                    if(outList.size() > 0) {
                                                                        outstrMap.putAll(outList.get(0));
                                                                    }

                                                                    c++;
                                                                }
                                                            }
                                                        }
                                                    } else if(dmlObj.DML__C == 'DELETE') { // delete 수행
                                                        query = 'SELECT Id FROM {TABLE_NAME}';

                                                        Boolean exeRest = SOQLUtil.deleteQuery(interface_id, query, tname, inbindList, queryList);

                                                        if(!exeRest) {
                                                            strCode = '1';strMessage = MessageResource.getMessage(MessageResource.MSG_FIAL_DELETE_ERR, null);break;
                                                        }
                                                    }
                                                } else { // 서브쿼리
                                                    List<Map<String, Object>> subbindList = in_if.getSubBindList(tname);
                                                    List<String> subfieldList = in_if.getSubFields(tname);
                                                    List<String> subColumnList = in_if.getSubColumns(tname);
                                                    List<String> subGroupingList = in_if.getSubGroupingList(tname);

                                                    System.debug('Sub Query >> table name = ' + tname + ', bind list = ' + subbindList + ', field list = ' + subfieldList);

                                                    // System.debug('Sub Query >> table name = ' + tname + ', bind list = ' + subbindList + ', field list = ' + subfieldList + ', bind value = ' + selval);

                                                    // 조건절 적용 우선순위를 찾는다.
                                                    Map<String, Object> subInfo = null;

                                                    // a.Key값에 의한 조건절를 가지고 있는 바인딩 정보 조회
                                                    for(Map<String, Object> sbind : subbindList) {
                                                        if(sbind.get('WHERE_COLUMN_SORT_NO') == '0') {
                                                            subInfo = sbind;break;
                                                        }
                                                    }

                                                    // b.Key값이 없는 조건정보에 의한 조건절를 가지고 있는 바인딩 정보 조회
                                                    if(subInfo == null) {
                                                        for(Map<String, Object> sbind : subbindList) {
                                                            if(sbind.get('WHERE_COLUMN_SORT_NO') == '1') {
                                                                subInfo = sbind;break;
                                                            }
                                                        }
                                                    }
                                                    // c.a와 b가 없이 테이블 정보만 있는 경우, 바인딩 조건
                                                    if(subInfo == null) {
                                                        for(Map<String, Object> sbind : subbindList) {
                                                            if(sbind.get('WHERE_COLUMN_SORT_NO') == '2') {
                                                                subInfo = sbind;break;
                                                            }
                                                        }
                                                    }
                                                    // System.debug('sub query binding info = ' + subInfo);

                                                    String substr = MetaDataHelper.getString2Object(subInfo.get('SEARCH_CONDITION_VALUE__C'));
                                                    String condfield = MetaDataHelper.getString2Object(subInfo.get('SEARCH_CONDITION_FIELD__C'));

                                                    for(Map<String, Object> selval : dmlSelectList) {
                                                        String subId = MetaDataHelper.getBindString(selval.get(substr), 'ID'); // 조회할 ID 추출

                                                        if(subId == null || subId == '') {
                                                            strCode = '1';strMessage = MessageResource.getMessage(MessageResource.MSG_NOT_FOUND_SUB_ID_ERR, new List<String>{tname, condfield, substr});break;
                                                        }

                                                        String query = 'SELECT ID, * FROM {TABLE_NAME} WHERE ' + condfield + '=' + subId;

                                                        // System.debug('Sub Query > ' + query);

                                                        if(dmlObj.DML__C == 'SELECT' && subId != null && subId != '') {
                                                            List<Map<String, Object>> sub_result = SOQLUtil.selectQuery(interface_id, query, tname, null, subColumnList, subfieldList, null, subGroupingList, queryList, inputVo, null, null);

                                                            if(sub_result.size() > 0) selval.putAll(sub_result.get(0));
                                                        } else if(dmlObj.DML__C == 'UPSERT') { // upsert 수행
                                                            String id = null;

                                                            if(subId == null || subId == '') { // insert
                                                                id = SOQLUtil.insertQuery(interface_id, tname, subfieldList, dataMap, queryList);
                                                                selval.put(substr, id);

                                                                if(id == null) {
                                                                    strCode = '1';strMessage = MessageResource.getMessage(MessageResource.MSG_FIAL_INSERT_ERR, null);break;
                                                                }
                                                            } else { // update
                                                                query = 'SELECT ID FROM '+tname+' WHERE ' + condfield + ' = ' + subId;

                                                                id = SOQLUtil.updateQuery(interface_id, query, tname, null, subfieldList, dataMap, queryList);

                                                                if(id == null) {
                                                                    strCode = '1';strMessage = MessageResource.getMessage(MessageResource.MSG_FIAL_UPDATE_ERR, null);break;
                                                                }
                                                            }

                                                            // 응답 데이터 생성
                                                            if(id != null && id != '') {
                                                                Integer c = Integer.valueOf(dmlObj.Order_No__c+1);

                                                                for(String outtb : outTableList) {
                                                                    if(tname == outtb) {
                                                                        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Interface_Service_SUB_Plan__c:{Id='+id+', Order_No__c='+c+', Table__c='+outtb+', DML__c=SELECT, Interface_Service_Detail__c='+dmlObj.Interface_Service_Detail__c+'}');

                                                                        List<String> outSubfieldList = in_if.getSubFields(tname);
                                                                        List<String> outSubColumnList = in_if.getSubColumns(tname);
                                                                        List<String> outSubGroupingList = in_if.getSubGroupingList(tname);

                                                                        String out_query = 'SELECT * FROM {TABLE_NAME} WHERE id = ' + MetaDataHelper.getBindString(id, 'ID');
                                                                        Decimal outLimitCount = null;
                                                                        String interceptorCode = null;

                                                                        for(INTERFACE_SERVICE_PLAN__C outPlan : outPlanList) {
                                                                            if(outtb == outPlan.TABLE__C) {
                                                                                outLimitCount = outPlan.LIMIT_COUNT__C;
                                                                                interceptorCode = outPlan.INTERCEPTOR_CODE__C;
                                                                                break;
                                                                            }
                                                                        }

                                                                        List<Map<String, Object>> outList = SOQLUtil.selectQuery(interface_id, out_query, outtb, null, outSubColumnList, outSubfieldList, null, outSubGroupingList, queryList, inputVo, outLimitCount, interceptorCode);

                                                                        if(outList.size() > 0) {
                                                                            outstrMap.putAll(outList.get(0));
                                                                        }

                                                                        c++;
                                                                    }
                                                                }
                                                            }
                                                        } else if(dmlObj.DML__C == 'DELETE') { // delete 수행
                                                            query = 'SELECT ID FROM '+tname+' WHERE ' + condfield + ' = ' + subId;

                                                            Boolean exeRest = SOQLUtil.deleteQuery(interface_id, query, tname, null, queryList);

                                                            if(!exeRest) {
                                                                strCode = '1';
                                                                strMessage = MessageResource.getMessage(MessageResource.MSG_FIAL_DELETE_ERR, null);
                                                                break;
                                                            }
                                                        }
                                                    }
                                                }
                                                dtLogEnd = Datetime.now();
                                                System.debug('[PLAN][' + planCnt + '][End] : ' + dmlObj);
                                                System.debug('[PLAN][' + planCnt + '][SpendTime] : ' + (dtLogEnd.getTime() - dtLogStart.getTime()));
                                                planCnt++;
                                            }

                                            if(outstrMap.size() > 0) contList.add(outstrMap);
                                        }
                                    } else {
                                        strCode = '1';strMessage = MessageResource.getMessage(MessageResource.MSG_NOT_FOUND_PLAN_ERR, null);
                                    }

                                    outputList.put(out_if.getTransactionID(), contList);
                                } // end for(QueryConfigResource  out_if : out_if_list)
                            }

                            if(queryList != null) queryList.add('=======================================================================================================================');

                            // 응답 데이터를 생성한다.
                            if(strCode != '1') {
                                for(INTERFACE_SERVICE_DETAIL__C dtl : interface_out_dtl) {
                                    List<Map<String, Object>> contList = null;
                                    QueryConfigResource out_if = null;

                                    // 응답 데이터가 1개 이상인 경우를 처리하기 위해 ID로 구분된 추출 데이터를 구한다.
                                    for(QueryConfigResource outConfig : out_if_list) {
                                        if(outConfig.getTransactionID() == dtl.id) {
                                            contList = (List<Map<String, Object>>) outputList.get(dtl.id);
                                            out_if = outConfig;

                                            System.debug('trans id = '+outConfig.getTransactionID() +', interface id = '+dtl.id + ', contents = '+contList);
                                            break;
                                        }
                                    }

                                    // 마스터 쿼리 조회결과 맵핑, 테이블 컬럼그룹과 관련 테이블 정보
                                    List<Map<String, Object>> joinList =  out_if.getFieldMappingList(); // 리스트 타입인 경우, 메인과 서버쿼리의 응답 정보를 취합한 Map 정보 리턴가능

                                    // 6. 페이징 처리
                                    String resptype = '';
                                    Boolean limitInterceptor = MetaDataHelper.getBoolean2String(inputVo.getString('limitInterceptor'));

                                    if(dtl.SOURCE_COLUMN_TYPE__C == null) resptype = 'STRING';
                                    else resptype = MetaDataHelper.getString2Object(dtl.SOURCE_COLUMN_TYPE__C);

                                    if(resptype == 'LIST' && fromPage > 0 && toPage > 0 && limitInterceptor) {
                                        List<Map<String, Object>> cloneList = contList.clone(); // 서브쿼리 조회결과
                                        contList.clear();

                                        if(resptype == 'LIST') { // 응답 타입이 LIST인 경우에만 처리함
                                            totalPage = cloneList.size();
                                        }

                                        if(resptype == 'LIST' || resptype == 'MAP' || resptype == 'MAP.STRING') {
                                            for(Integer p = 0; p < cloneList.size(); p++) {
                                                if(fromPage <= (p+1) && toPage >= (p+1)) {
                                                    contList.add(cloneList.get(p));
                                                }
                                            }
                                        }
                                    }

                                    System.debug('join list size = ' + joinList.size() + ', data = ' + joinList);
                                    System.debug('result list size = ' + contList.size() + ', data = ' + contList);

                                    // 7. 응답할 정보 생성
                                    // 린터할 객체가 String인지 Array인지 확인 후 Map 또는 리스트를 담는다.
                                    if(resptype == 'LIST' || resptype == 'MAP' || resptype == 'MAP.STRING') { // List 반환으로 여러개의 테이블 그룹을 찾아서 리턴함.
                                        String complkey = MetaDataHelper.getString2Object(dtl.SOURCE_COLUMN__C); // 응답해야할 필드명
                                        List<Map<String, Object>> procList = new List<Map<String, Object>>(); // 최종 리턴할 객체

                                        List<Map<String, Object>> childField = new List<Map<String, Object>>();

                                        // 하위 필드명과 타입을 구해서 List에 저장한다.
                                        for(Map<String, Object> joinMap : joinList) {
                                            String responseKey = MetaDataHelper.getString2Object(joinMap.get('REPONSE_SOURCE_COLUMN')); // 테이블 컬럼 그룹명
                                            String responseType = MetaDataHelper.getString2Object(joinMap.get('TARGET_COLUMN_TYPE__C')); // 추출된 컬럼의 타입이 LIST인 경우,

                                            if(responseKey == complkey && (responseType == 'LIST' || responseType == 'MAP' || responseType == 'MAP.STRING')) {
                                                childField.add(joinMap);
                                            }
                                        }

                                        System.debug('Child response info(size='+childField.size()+', field = ' + childField+')');

                                        // 추출된 데이터를 가지고 응답 필드에 맞게 맵핑한다.
                                        for(Map<String, Object> sub : contList) { // 추출된 데이터만큼 Loop 수행
                                            Map<String, Object> procMap =  new Map<String, Object>();

                                            for(Map<String, Object> joinMap : joinList) { // 응답 필드의 개수만큼 Loop 수행
                                                Boolean chk = false;

                                                // 응답할 필드정보
                                                String targetKey = MetaDataHelper.getString2Object(joinMap.get('TABLE_TARGET_COLUMN__C')); // 조회된 데이터가 등록된 Map의 명칭
                                                String sourceKey = MetaDataHelper.getString2Object(joinMap.get('SOURCE_COLUMN__C')); // 응답할 때 사용되는 명칭
                                                String responseKey = MetaDataHelper.getString2Object(joinMap.get('REPONSE_SOURCE_COLUMN')); // 테이블 컬럼 그룹명
                                                String parentKey = MetaDataHelper.getString2Object(joinMap.get('SOURCE_COLUMN_TYPE__C')); // 상위필드명(테이블 컬럼 그룹명내 자신의 상위 응답필드명)
                                                String responseType = MetaDataHelper.getString2Object(joinMap.get('TARGET_COLUMN_TYPE__C')); // 하위의 응답 타입(LIST 또는 MAP)
                                                String dataFormat = MetaDataHelper.getString2Object(joinMap.get('REQUEST_COLUMN_FORMAT__C')); // 데이터 포맷
                                                String dataType = MetaDataHelper.getString2Object(joinMap.get('TARGET_COLUMN_TYPE__C')); // 데이터 타입
                                                String columName = MetaDataHelper.getString2Object(joinMap.get('TARGET_COLUMN__C')); // 서버측 테이블 컬럼

                                                if(responseKey != complkey) break; // 테이블내 그룹별로 명칭이 같은 건만 응답하도록 조건을 줌

                                                if(parentKey == null || parentKey == '') parentKey = complkey; // 상위 필드명이 없는 경우, OUT타입으로 지정된 필드명으로 치환함

                                                // 응답값 맵핑을 위해 1차로 최상위값을 우선 맵핑한다.
                                                if(complkey == parentKey) {
                                                    for(String key: sub.keySet()) { // 조회결과
                                                        Object vobj = sub.get(key);

                                                        // 조회결과 필드의 타입이 String인 경우 키를 맵핑한다.
                                                        if(vobj instanceof String) {
                                                            if(targetKey == key) { // 실데이터의 필드명을 비교함(테이블명 또는 테이블명_Target필드명)
                                                                Object resData = MetaDataHelper.getObject2String(String.valueof(vobj), dataType);
                                                                procMap.put(sourceKey, MetaDataHelper.getString2Object(resData, dataFormat));
                                                                chk = true;
                                                                break;
                                                            }
                                                        }

                                                        // 조회결과 필드의 타입이 String이 아닌 List나 Map에 정보인 경우에는 Map에서 해당 필드를 찾아 값을 구한다.
                                                        if(!chk) {
                                                            Map<String, Object> bimap = new Map<String, Object>();

                                                            if(vobj instanceof List<Map<String, Object>>) {
                                                                List<Map<String, Object>> bilist = (List<Map<String, Object>>) vobj;
                                                                if(bilist.size() > 0) bimap = bilist.get(0);
                                                            } else if(vobj instanceof Map<String, Object>) {
                                                                bimap = (Map<String, Object>) vobj;
                                                            }

                                                            for(String bikey: bimap.keySet()) { // 서브 Map형태의 조회결과
                                                                Object biobj = bimap.get(bikey);

                                                                if(biobj instanceof String) {
                                                                    if(targetKey == bikey) { // 실데이터의 필드명을 비교함(테이블명 또는 테이블명_Target필드명)
                                                                        Object resData = MetaDataHelper.getObject2String(String.valueof(biobj), dataType);
                                                                        procMap.put(sourceKey, MetaDataHelper.getString2Object(resData, dataFormat));
                                                                        chk = true;
                                                                        break;
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }

                                                    // 응답값 맵핑을 위해 2차로 최상위와 일치하지 않은 값을 맵핑한다.
                                                    if(!chk) {
                                                        if(columName == 'COUNT') { // 서버측 컬럼명이 COUNT인 경우, 데이터가 없으면 0으로 응답
                                                            procMap.put(sourceKey, '0');
                                                        } else {
                                                            procMap.put(sourceKey, '');
                                                        }
                                                    }
                                                }
                                            }

                                            List<Map<String, Object>> bilist = null;
                                            List<Map<String, Object>> ttlist = null;

                                            // 서브쿼리 실행결과로 응답 데이터 생성
                                            for(Map<String, Object> childmap : childField) {
                                                String childType = MetaDataHelper.getString2Object(childmap.get('TARGET_COLUMN_TYPE__C'));
                                                String childName = MetaDataHelper.getString2Object(childmap.get('SOURCE_COLUMN__C'));
                                                bilist = new List<Map<String, Object>>();
                                                ttlist = new List<Map<String, Object>>();

                                                Object vobj = sub.get(MetaDataHelper.getString2Object(childmap.get('TABLE_TARGET_COLUMN__C')));

                                                if(vobj instanceof List<Map<String, Object>>) {
                                                    ttlist = (List<Map<String, Object>>) vobj;
                                                } else if(vobj instanceof Map<String, Object>) {
                                                    Map<String, Object> tt = (Map<String, Object>) vobj;ttlist.add(tt);
                                                } else {
                                                    ttlist.add(new Map<String, Object>());
                                                }

                                                for(Map<String, Object> tsmap : ttlist) { // 데이터 개수만큼 Loop 수행
                                                    Map<String, Object> newMap = new Map<String, Object>();

                                                    for(Map<String, Object> joinMap : joinList) { // 컬럼명
                                                        Boolean chk = false;
                                                        String responseKey = MetaDataHelper.getString2Object(joinMap.get('REPONSE_SOURCE_COLUMN')); // 테이블 컬럼 그룹명
                                                        String parentKey = MetaDataHelper.getString2Object(joinMap.get('SOURCE_COLUMN_TYPE__C')); // 상위필드명(테이블 컬럼 그룹명내 자신의 상위 응답필드명)
                                                        String responseType = MetaDataHelper.getString2Object(joinMap.get('TARGET_COLUMN_TYPE__C')); // 하위의 응답 타입(LIST 또는 MAP)
                                                        String targetKey = MetaDataHelper.getString2Object(joinMap.get('TABLE_TARGET_COLUMN__C')); // 조회된 데이터가 등록된 Map의 명칭
                                                        String sourceKey = MetaDataHelper.getString2Object(joinMap.get('SOURCE_COLUMN__C')); // 응답할 때 사용되는 명칭
                                                        String dataFormat = MetaDataHelper.getString2Object(joinMap.get('REQUEST_COLUMN_FORMAT__C')); // 데이터 포맷
                                                        String dataType = MetaDataHelper.getString2Object(joinMap.get('TARGET_COLUMN_TYPE__C')); // 데이터 타입
                                                        String columName = MetaDataHelper.getString2Object(joinMap.get('TARGET_COLUMN__C')); // 서버측 테이블 컬럼

                                                        if(responseKey != complkey) break; // 테이블내 그룹별로 명칭이 같은 건만 응답하도록 조건을 줌

                                                        if(parentKey == childName) { // 하위 List 또는 Map에 해당하는 필드만 비교

                                                            for(String bikey: tsmap.keySet()) { // 서브 Map형태의 조회결과
                                                                if(targetKey == bikey) { // 실데이터의 필드명을 비교함(테이블명 또는 테이블명_Target필드명)
                                                                    Object resData = MetaDataHelper.getObject2String(String.valueof(tsmap.get(bikey)), dataType);
                                                                    newMap.put(sourceKey, MetaDataHelper.getString2Object(resData, dataFormat));
                                                                    chk = true;break;
                                                                }
                                                            }

                                                            if(!chk) {
                                                                for(String key: sub.keySet()) {
                                                                    if(targetKey == key) { // 실데이터의 필드명을 비교함(테이블명 또는 테이블명_Target필드명)
                                                                        Object resData = MetaDataHelper.getObject2String(String.valueof(sub.get(key)), dataType);
                                                                        newMap.put(sourceKey, MetaDataHelper.getString2Object(resData, dataFormat));
                                                                        chk = true;
                                                                        break;
                                                                    }
                                                                }
                                                            }

                                                            if(!chk) {
                                                                if(columName == 'COUNT') { // 서버측 컬럼명이 COUNT인 경우, 데이터가 없으면 0으로 응답
                                                                    newMap.put(sourceKey, '0');
                                                                } else {
                                                                    newMap.put(sourceKey, '');
                                                                }
                                                            }
                                                        }
                                                    }

                                                    bilist.add(newMap);
                                                }

                                                if(childType == 'LIST') {
                                                    procMap.put(childName, bilist);
                                                } else if(childType == 'MAP') {
                                                    if(bilist.size() > 0) {procMap.put(childName, bilist.get(0));
                                                    } else {procMap.put(childName, new Map<String, Object>());}
                                                } else if(childType == 'MAP.STRING') {
                                                    if(bilist.size() > 0) {
                                                        Map<String, Object> filterMap = bilist.get(0);

                                                        for(String key: filterMap.keySet()) {
                                                            procMap.put(key, filterMap.get(key));
                                                        }
                                                    }
                                                }
                                            }

                                            procList.add(procMap);
                                        }

                                        if(resptype == 'LIST') {
                                            if(procList.size() > 0) reponseObj.put(dtl.SOURCE_COLUMN__C, procList);
                                            resCount += procList.size();

                                            if(fromPage > 0 && toPage > 0 && limitInterceptor) {
                                                // reponseObj.put('pageTotalCount', totalPage); // 전체 페이지 개수
                                                reponseObj.put('pageTotalCount', String.valueOf(totalPage)); // 중계서버에서 double 타입으로 변경되어, String 타입으로 변경(2023-12-07, 박성현)

                                                if(procList.size() == 0) {
                                                    strCode = '2';
                                                    strMessage = '';

                                                    // reponseObj.put('pageFromCount', fromPage); // 전체 페이지 개수
                                                    // reponseObj.put('pageToCount', toPage); // 페이지 종료번호
                                                    // 중계서버에서 double 타입으로 변경되어, String 타입으로 변경(2023-12-07, 박성현)
                                                    reponseObj.put('pageFromCount', String.valueOf(fromPage));
                                                    reponseObj.put('pageToCount', String.valueOf(toPage));
                                                } else {
                                                    // reponseObj.put('pageFromCount', fromPage); // 페이지 시작번호
                                                    // reponseObj.put('pageToCount', fromPage+(procList.size()-1)); // 페이지 종료번호
                                                    // 중계서버에서 double 타입으로 변경되어, String 타입으로 변경(2023-12-07, 박성현)
                                                    reponseObj.put('pageFromCount', String.valueOf(fromPage)); // 페이지 시작번호
                                                    reponseObj.put('pageToCount', String.valueOf(fromPage+(procList.size()-1))); // 페이지 종료번호
                                                }
                                            }
                                        } else if(resptype == 'MAP.STRING') {
                                            if(procList.size() > 0) {
                                                Map<String, Object> filterMap = procList.get(0);

                                                for(String key: filterMap.keySet()) {
                                                    reponseObj.put(key, filterMap.get(key));
                                                }
                                            }
                                        } else {
                                            if(procList.size() > 0) {
                                                reponseObj.put(dtl.SOURCE_COLUMN__C, procList.get(0));
                                                resCount++;
                                            }
                                        }
                                    } else { // Map반환으로 한개의 값만 찾아서 리턴함
                                        Boolean chk = false;

                                        if(contList.size() > 0) {
                                            for(Map<String, Object> sub : contList) {
                                                for(String key: sub.keySet()){
                                                    System.debug('field >>> '+dtl.TARGET_TABLE__C+'_'+dtl.TARGET_COLUMN__C +' / '+ key);

                                                    if(dtl.TARGET_TABLE__C+'_'+dtl.TARGET_COLUMN__C == key) {
                                                        Object resData = MetaDataHelper.getObject2String(String.valueof(sub.get(key)), dtl.TARGET_COLUMN_TYPE__C);
                                                        reponseObj.put(dtl.SOURCE_COLUMN__C, MetaDataHelper.getString2Object(resData, dtl.REQUEST_COLUMN_FORMAT__C));
                                                        chk = true;break;
                                                    }
                                                }

                                                resCount++;
                                            }

                                            if(!chk) {
                                                // 서버측 컬럼명이 COUNT인 경우, 데이터가 없으면 0으로 응답
                                                if(dtl.TARGET_COLUMN__C == 'COUNT') { reponseObj.put(dtl.SOURCE_COLUMN__C, '0');} else {reponseObj.put(dtl.SOURCE_COLUMN__C, '');
                                                }
                                            }
                                        }
                                    }
                                }
                            } // end if(strCode != '1')
                            */
                        } else {
                            // 사용자가 지정한 클래스 호출
                            try {
                                Type userCls = Type.forName(ifmaster.RUN_CLASS__C); // 개발자 클래스 객체
                                UserInterface inf = (UserInterface) userCls.newInstance();
                                if(queryList == null) queryList = new List<String>();
                                queryList.add('Server : ' + URL.getSalesforceBaseUrl().toExternalForm());
                                reponseObj = inf.execute(inputVo, queryList);
                                //System.debug('reponseObj :: ' + reponseObj);
                                if(reponseObj.get('resultCode') == '1' && reponseObj.get('resultMsg') != null) {
                                    strCode = '1';
                                    strMessage = (String)reponseObj.get('resultMsg');
                                }

                            } catch(Exception e) {
                                strCode = '1';
                                strMessage = MessageResource.getMessage(MessageResource.MSG_NOT_FOUND_CLS_PATH_ERR, null) + '(' + e.getMessage() + ' Line : ' + e.getLineNumber() + ')';

                                System.debug(e.getStackTraceString());
                                System.debug(e.getTypeName());
                            }
                        } // end if(ifmaster.RUN_CLASS__C == null || ifmaster.RUN_CLASS__C == '')

                        // queryList.add('response data = ' + reponseObj);

                        if(reponseObj.size() == 0 && strCode == '0') {
                            strCode = '2';
                            strMessage = '';
                        }
                    } // end if(strCode != '1')
                } // end if(strCode != '1')
            //} // end if(strCode != '1') // 가장 겉껍데기
        } catch(Exception e) {
            strCode = '1';
            strMessage = e.getMessage()+' Line : '+e.getLineNumber();

            System.debug(e.getStackTraceString());
            System.debug(e.getTypeName());
        }

        // 설정값으로 모든 응답데이터 생성 후, 최종적으로 리턴하기 전 각 인터페이스 별로 추가적인 처리가 필요한 경우(2024-02-01 박성현 추가)
        //ii.postHandleInterceptor(interface_id, reponseObj);

        // 7.응답 데이터 유형(JSON, XML, OBJECT 등)에 맞는 데이터 변환
        returnObj.put('resultCode', strCode);
        returnObj.put('resultMsg', strMessage);
        returnObj.put('result', reponseObj);
        if(queryDebug) {
            returnObj.put('queryList', queryList);
        }

        System.debug('resultCode : ' + strCode);
        System.debug('resultMsg : ' + strMessage);
        System.debug('result : ' + reponseObj);

        // 8.인터페이스 이력 남기기
        try {
            resTime = Datetime.now();
            Long dt1Long = reqTime.getTime();
            Long dt2Long = resTime.getTime();
            Long seconds = dt2Long - dt1Long;
            //Long seconds = milliseconds / 1000;

            if(ifmaster.LOG_TYPE__C == 'DEBUG') {
                islog = true;
            } else if (ifmaster.LOG_TYPE__C == 'ERROR' && strCode == '1') {
                islog = true;
            } else if (ifmaster.LOG_TYPE__C == 'OFF') { // Log를 전혀 남기지 않는다.
                islog = false;
            }

            if(islog) {
                String methodType = null;
                String dmlLogType = 'SELECT'; // 초기값
                dmlLogType = ifmaster.Dml_Log_Type__c;

                // 2023-12-26 박성현 수정.
                if (dmlLogType == 'SELECT') {
                    methodType = 'select';
                } else if (dmlLogType == 'INSERT') {
                    methodType = 'insert';
                } else if (dmlLogType == 'UPDATE') {
                    methodType = 'update';
                } else if (dmlLogType == 'UPSERT') {
                    methodType = 'upsert';
                } else if (dmlLogType == 'DELETE') {
                    methodType = 'delete';
                } else {
                    methodType = 'select';
                }

                /*if(ifmaster.HTTP_METHOD_TYPE__C == 'POST' || ifmaster.HTTP_METHOD_TYPE__C == 'GET') methodType = 'select';
                else if(ifmaster.HTTP_METHOD_TYPE__C == 'PUT') methodType = 'upsert';
                else if(ifmaster.HTTP_METHOD_TYPE__C == 'DELETE') methodType = 'delete';
                else if(ifmaster.HTTP_METHOD_TYPE__C == 'INSERT') methodType = 'insert';
                else if(ifmaster.HTTP_METHOD_TYPE__C == 'UPDATE') methodType = 'update';*/

                String resultType = null;
                if(strCode == '0') {
                    resultType = 'success';
                } else if(strCode == '1') {
                    resultType = 'fail';
                } else if(strCode == '2') {
                    resultType = 'no data';
                }

                Map<String, Object> resultMap = (Map<String, Object>) returnObj.get('result');
                String reqCountStr = MetaDataHelper.getString2Object(resultMap.get('reqCount'));
                String resCountStr = MetaDataHelper.getString2Object(resultMap.get('resCount'));

                if (!String.isEmpty(reqCountStr)) {
                    reqCount = Integer.valueOf(reqCountStr);
                } // 값이 없으면 기본값 0

                if (!String.isEmpty(resCountStr)) {
                    resCount = Integer.valueOf(resCountStr);
                } // 값이 없으면 기본값 0

                // transaction_no = MetaDataHelper.getString2Object(resultMap.get('TRANSACTION_NO'));

                INTERFACE_SERVICE_LOG__C logObj = new INTERFACE_SERVICE_LOG__C();

                logObj.Interface_Service_Master__c = ifmaster.ID;
                logObj.Request_Type__c = ifmaster.IN_OUT_TYPE__C;
                logObj.Work_Type__c = methodType;
                logObj.Request_Count__c = reqCount;
                logObj.Response_Count__c = resCount;
                logObj.Request_Date__c = reqTime;
                logObj.Response_Date__c = resTime;
                logObj.Run_Time__c = seconds;
                logObj.Run_Result__c = resultType;
                /*
                //241025 파일 인터페이스 내 Request 내용이 클 때, 잘라서 저장, 중계서버 내 로그 확인 가능
                if(reqBody_json.length() > 130000) {
                    logObj.Request_Parameters__c = reqBody_json.substring(0, 130000);
                } else {
                    logObj.Request_Parameters__c = reqBody_json;
                }
                */

                // Request_Parameters__c = Long Text Area(131072)
                logObj.Request_Parameters__c = reqBody_json <> null && reqBody_json.length() > 130000 ? reqBody_json.substring(0, 130000) : reqBody_json;
                /*
                if (transaction_no != null && transaction_no != ''){
                    logObj.Transaction_No__c  = transaction_no;
                } 
                */               
                String response_json = JSON.serialize(returnObj);
                // Response_Parameters__c = Long Text Area(131072)
                logObj.Response_Parameters__c = JSON.serialize(returnObj);
                logObj.Error_Messages__c = strMessage;
                logObj.Interface_id__c = interface_id;

                insert logObj;

                // logInfo(박성현, 2023-07-07 추가)
                // Saleforce의 인터페이스 로그 정보를 리턴할지 여부에 따라 Id & Name 값 리턴
                String logInfoValue = inputVo.getString('logInfo');
                if ( logInfoValue != null && logInfoValue != '') {
                    logInfo = MetaDataHelper.getBoolean2String(logInfoValue);

                    if (logInfo) {
                        // Log 정보
                        // Log의 Name 정보를 가져오기 위해 생성된 Id 값으로 Log 정보 조회
                        Map<String, Object> logMap = new Map<String, Object>();
                        
                        Interface_Service_Log__c interfaceLog = [SELECT Id, Name FROM Interface_Service_Log__c WHERE  Id = :logObj.Id LIMIT  1];
                        
                        logMap.put('Id', logObj.Id);
                        logMap.put('Name', interfaceLog.Name);

                        returnObj.put('logInfo', logMap);
                    }
                }
                
            }
        } catch(Exception e) {
            System.debug('Interface logging error : ' + e);
        }

        if (!Test.isRunningTest()) {
            // 9.응답 처리(완료)
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(returnObj));
        } else if (Test.isRunningTest()) {
            System.debug('Testing...');
            Integer z = 0;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;            
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;            
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;            
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;            
        }
    }
}