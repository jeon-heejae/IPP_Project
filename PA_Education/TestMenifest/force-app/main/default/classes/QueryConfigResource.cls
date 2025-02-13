/**
 * @description       : Query 리소스 생성 클래스
 * @author            : jonghyun.kim@daeunextier.com
 * @group             :
 * @last modified on  : 2023-11-15
 * @last modified by  : jonghyun.kim@daeunextier.com
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   07-03-2020   jonghyun.kim@daeunextier.com   Initial Version
 * 1.1   2023-11-15   jamespark@daeucna.com          getChildRelationShipName 메소드 외 추가
**/
public class QueryConfigResource {
    private String transaction_id; // 트랜젝션 구분ID

    private List<String> mainfields = new List<String>(); // 메인쿼리 필드 리스트
    private List<String> mainColumns = new List<String>(); // 메인쿼리 조회절 리스트
    // 조건절(Where)에 입력할 컬럼명과 값을 가지고 있는 변수 선언
    private List<Map<String, Object>> mainbindList = new List<Map<String, Object>>(); // 메인쿼리의 조건절 목록(컬럼 + 조건 + 값 정보)
    // upsert 또는 delete 시에만 적용하는 변수 선언
    private List<Map<String, Object>> fielddatas = new List<Map<String, Object>>(); // insert, update하기 위한 필드값 리스트
    // 마스터 테이블 명
    private String tableName = null;
    // 메인과 서버쿼리의 응답필드 맵핑 정보를 취합한 정보
    private List<Map<String, Object>> fieldMappingList =  new List<Map<String, Object>>();
    // 정렬방식 정보
    private List<Map<String, Object>> orderList =  new List<Map<String, Object>>();
    // 그룹핑 정보
    private List<String> groupingList =  new List<String>();
    // 서브쿼리 수행 정보
    private Map<String, List<Object>> bindInfoMap = new Map<String, List<Object>>();
    private List<String> subTableLsit = new List<String>();
    private Map<String, List<Object>> suborderList = new Map<String, List<Object>>();
    private List<INTERFACE_SERVICE_PLAN__C> dmlTableLsit = new List<INTERFACE_SERVICE_PLAN__C>();


    public QueryConfigResource() {}

    public QueryConfigResource(String id) {
        this.transaction_id = id;
    }

    public String getTransactionID() {
        return this.transaction_id;
    }

    public List<String> getMainFields() {
        return this.mainfields;
    }

    public List<String> getMainColumns() {
        return this.mainColumns;
    }

    public List<Map<String, Object>> getMainBindList() {
        return this.mainbindList;
    }

    public List<String> getGroupingList() {
        return this.groupingList;
    }

    public List<Map<String, Object>> getDataList() {
        return this.fielddatas;
    }

    public String getTableName() {
        return this.tableName;
    }

    /**
     * 서브쿼리 수행 시 조회될 대상 필드목록
     * @params tname = talbe name
     * @return query field list
     */
    public List<String> getSubColumns(String tname) {
        return (List<String>) this.bindInfoMap.get(tname+'_COLUMN');
    }

    /**
     * 서브쿼리 수행 시 조회된 필드목록
     * @params tname = talbe name
     * @return query field list
     */
    public List<String> getSubFields(String tname) {
        return (List<String>) this.bindInfoMap.get(tname+'_FIELD');
    }

    /**
     * 서브쿼리 수행 시 조건절에 바인딩할 목록
     * @params tname = talbe name
     * @return query binding list
     */
    public List<Map<String, Object>> getSubBindList(String tname) {
        return (List<Map<String, Object>>) this.bindInfoMap.get(tname+'_BIND');
    }

    /**
     * 서브쿼리 수행 시 정렬절에 위치할 목록
     * @params tname = talbe name
     * @return query order by list
     */
    public List<Map<String, Object>> getSubOrderList(String tname) {
        return (List<Map<String, Object>>) this.bindInfoMap.get(tname+'_ORDER');
    }

    /**
     * 서브쿼리 수행 시 조회될 대상 필드목록
     * @params tname = talbe name
     * @return query field list
     */
    public List<String> getSubGroupingList(String tname) {
        return (List<String>) this.bindInfoMap.get(tname+'_GROUP');
    }

    /**
     * 서브쿼리 수행 시 제한할 조회수
     * @params tname = talbe name
     * @return query field list
     */
    // public Decimal getSubLimitCount(String tname) {
    //     List<Decimal> countList = (List<Decimal>) this.bindInfoMap.get(tname+'_LIMIT');

    //     if(countList.size() == 0) return null;
    //     else {
    //         return countList.get(0);
    //     }
    // }

    /**
     * 서브쿼리로 수행할 테이블 리스트를 리턴함
     * @return 테이블 목록
     */
    public List<String> getSubTableList() {
        return this.subTableLsit;
    }

    /**
     * DML쿼리로 수행할 테이블 리스트를 리턴함
     * @return 수행계획 정보
     */
    public List<INTERFACE_SERVICE_PLAN__C> getDmlTableList() {
        return this.dmlTableLsit;
    }

    /**
     * 메인쿼리 수행 시 조회될 대상 필드목록
     * @return 필드 리스트
     */
    public List<Map<String, Object>> getFieldMappingList() {
        return this.fieldMappingList;
    }

    /**
     * 메인쿼리 수행 시 정렬절에 위치할 목록
     * @return 정렬리스트
     */
    public List<Map<String, Object>> getOrderList() {
        return orderList;
    }

    /**
     * Dynamic Query 생성을 위한 값을 set한다.
     *
     * @params interface_mst = 인터페이스 마스터 정보
     * @params interface_dtl = IN(요청)/OUT(응답) 인터페이스 필드 설정정보
     * @params volist = Request parameter 정보
     * @return 성공:"", 실패:메시지 리턴
     */
    public String getInputResource(INTERFACE_SERVICE_MASTER__C interface_mst, List<INTERFACE_SERVICE_DETAIL__C> interface_dtl, List<ValueRow> volist) {
        String rstmsg = null;

        for(INTERFACE_SERVICE_DETAIL__C ret : interface_dtl) {
            rstmsg = this.getQueryResource(interface_mst, ret, volist);

            if(rstmsg != null && rstmsg != '') {
                break;
            }
        }

        return rstmsg;
    }

    /**
     * Dynamic Query 생성을 위한 값을 set한다.
     *
     * @params interface_mst = 인터페이스 마스터 정보
     * @params interface_dtl = IN(요청)/OUT(응답) 인터페이스 필드 설정정보
     * @params volist = Request parameter 정보
     * @return 성공:"", 실패:메시지 리턴
     */
    public String getOutputResource(INTERFACE_SERVICE_MASTER__C interface_mst, INTERFACE_SERVICE_DETAIL__C ret, List<ValueRow> volist) {
        return this.getQueryResource(interface_mst, ret, volist);
    }

    /**
     * Dynamic Query 생성을 위한 값을 set한다.
     *
     * @params interface_mst = 인터페이스 마스터 정보
     * @params interface_dtl = IN(요청)/OUT(응답) 인터페이스 필드 설정정보
     * @params volist = Request parameter 정보
     * @return 성공:"", 실패:메시지 리턴
     */
    public String getQueryResource(INTERFACE_SERVICE_MASTER__C interface_mst, INTERFACE_SERVICE_DETAIL__C ret, List<ValueRow> volist) {
        List<INTERFACE_SERVICE_DETAIL__C> interface_main_dtl = null; // 메인쿼리 설정 정보
        List<INTERFACE_SERVICE_DETAIL__C> interface_sub_dtl = null; // 서브쿼리 설정 정보
        String message = null;

        this.tableName = ret.TARGET_TABLE__C; // 요청테이블의 마스터 테이블명칭
        String in_out_type = ret.IN_OUT_TYPE__C;

        System.debug('tableName : ' + tableName + ', in_out_type : ' + in_out_type);

        //    System.debug('table name = ' + this.tableName + ', source type = ' + ret.SOURCE_COLUMN_TYPE__C + ', method type = ' + interface_mst.HTTP_METHOD_TYPE__C + ', Detail id = ' + ret.ID + ', IN/OUT ='+in_out_type);

        List<INTERFACE_SERVICE_PLAN__C> interface_out_plan = new List<INTERFACE_SERVICE_PLAN__C>([
            SELECT ID, ORDER_NO__C, TABLE__C, DML__C, LIMIT_COUNT__C, INTERCEPTOR_CODE__C
                FROM INTERFACE_SERVICE_PLAN__C
                WHERE INTERFACE_SERVICE_DETAIL__C = :ret.ID
                AND IN_OUT_TYPE__C = :in_out_type
                AND DML__C IN('SELECT', 'COUNT')
                ORDER BY ORDER_NO__C
        ]);

        // DML 실행계획 정보
        List<INTERFACE_SERVICE_PLAN__C> interface_dml_plan = new List<INTERFACE_SERVICE_PLAN__C>([
            SELECT ID, ORDER_NO__C, TABLE__C, DML__C, LIMIT_COUNT__C, INTERCEPTOR_CODE__C, INTERFACE_SERVICE_DETAIL__C
                FROM INTERFACE_SERVICE_PLAN__C
                WHERE INTERFACE_SERVICE_DETAIL__C = :ret.ID
                AND IN_OUT_TYPE__C = :in_out_type
                ORDER BY ORDER_NO__C
        ]);

        if(interface_dml_plan != null) {
            for(INTERFACE_SERVICE_PLAN__C dml : interface_dml_plan) {
                dmlTableLsit.add(dml);
            }
        }

        String sourceType = '';
        if(ret.SOURCE_COLUMN_TYPE__C != null && ret.SOURCE_COLUMN_TYPE__C != '') {
            sourceType = ret.SOURCE_COLUMN_TYPE__C;
        }

        if(interface_out_plan != null && interface_out_plan.size() > 0) { // 실행계획이 있으면 아래 구문을 수행
            for(INTERFACE_SERVICE_PLAN__C plan : interface_out_plan) {
                String plan_tablename = plan.TABLE__C;

                if(plan.ORDER_NO__C == 1) { // 메인쿼리 정보
                    // 메인 쿼리에서 지정한 테이블명에서 조회할 필드 조회
                    interface_main_dtl = new List<INTERFACE_SERVICE_DETAIL__C>([
                        SELECT ID
                            ,SOURCE_COLUMN__C // 요청 파라메터 컬럼
                            ,TARGET_COLUMN__C // 서버측 테이블 필드ID
                            ,TARGET_TABLE__C // 서버측 테이블
                            ,TARGET_COLUMN_TYPE__C // 데이터 타입
                            ,SOURCE_COLUMN_REQUIRE_YN__C // 필수여부(Y/N)
                            ,REQUEST_COLUMN_FORMAT__C // 데이터 포맷
                            ,SEARCH_CONDITION_FIELD__C // 서브쿼리용 조건 필드(메인쿼리와 연결된 ID를 가지고 있는 필드명)
                            ,SEARCH_CONDITION_VALUE__C // 서브쿼리용 조건 값(메인쿼리에서 ID를 가지고 있는 Map의 Name)
                            ,TARGET_COLUMN_KEY_YN__C // key값 여부(쿼리 생성시 조건이 되는 필드인지 여부)
                            ,DEFAULT_VALUE__C // 요청값이 없는 경우, 자동으로 채울 값
                            ,CONDITION_TYPE__C // 조건(=, IN, LIKE)
                            ,SOURCE_COLUMN_TYPE__C // 응답할 소스 타입(List or 응답 타입이 TABLE인 경우에는 상위 응답명)
                            ,ORDER_TYPE__C // ORDER BY 타입(ACE, DESC)
                            ,ORDER_BY_ORDER__C // 정렬순서
                            ,GROUPING_FIELD_YN__c // 그룹핑 필드 포함여부(Y/N)
                            ,SOQL_FUNCTION__C // SOQL 적용함수 지정
                            ,INTERCEPTOR_METHOD__C // 데이터 예외처리 함수명
                            ,UPSERT_INCLUDE_YN__C // Upsert Column 포함여부(2022-02-23)
                            ,UPDATE_COLUMN_VALUE__c // UPDATE_컬럼_파라메터명(2022-02-23)
                        FROM INTERFACE_SERVICE_DETAIL__C
                        WHERE INTERFACE_SERVICE_DETAIL__C = :ret.ID
                            AND IN_OUT_TYPE__C = 'TABLE'
                            AND TARGET_TABLE__C = :plan_tablename
                        ORDER BY ORDER_BY_ORDER__C
                    ]); // 마스터 테이블명

                    //    System.debug('interface_main_dtl - parameter > id = ' + ret.ID + ', target table = ' + plan_tablename + ', result count = ' + interface_main_dtl.size());

                    // 메인쿼리에서 조회할 필드 항목
                    for(INTERFACE_SERVICE_DETAIL__C dtl : interface_main_dtl) {
                        Object val = null;

                        try {
                            // System.debug('this.getFieldVale!');
                            val = this.getFieldValue(dtl, volist); // Request parameter에서 정보를 찾아 리턴함
                            // System.debug('main - binding value : '+dtl.TARGET_COLUMN__C+' = ' + val);
                        } catch(Exception e) {
                            System.debug(e.getMessage());
                            if(in_out_type == 'IN') return MessageResource.getMessage(MessageResource.MSG_DATA_FORMAT_1_ERR, new List<String>{dtl.SOURCE_COLUMN__C, dtl.TARGET_COLUMN_TYPE__C, dtl.REQUEST_COLUMN_FORMAT__C});
                        }

                        if(in_out_type == 'IN') {
                            String retMsg = InterfaceHelper.isRequired(val, dtl.SOURCE_COLUMN_REQUIRE_YN__C, dtl.SOURCE_COLUMN__C , in_out_type);

                            if(retMsg != null && retMsg != '') {
                                return retMsg;
                            }
                        }

                        if(dtl.TARGET_COLUMN__C != null && dtl.TARGET_COLUMN__C != '' && dtl.TARGET_TABLE__C != null && dtl.TARGET_TABLE__C != '') {
                            // 메인쿼리 조회 필드 추가
                            if(dtl.GROUPING_FIELD_YN__C == null || dtl.GROUPING_FIELD_YN__C == 'Y') { // 그룹핑 여부가 'N' 이면 SELECT 절에 추가되지 않는다.
                                mainfields.add(dtl.TARGET_COLUMN__C);
                                mainColumns.add(MetaDataHelper.changeFieldForFuntion(dtl.TARGET_COLUMN__C, dtl.TARGET_COLUMN_TYPE__C, dtl.SOQL_FUNCTION__C , 'select'));
                            }

                            // 응답 맵핑정보 생성
                            if(in_out_type == 'OUT' || in_out_type == 'IN') {
                                Map<String, Object> joinMap = new Map<String, Object>();

                                joinMap.put('TABLE_TARGET_COLUMN__C',   (dtl.TARGET_TABLE__C+'_'+dtl.TARGET_COLUMN__C)); // 서버측 유니크한 컬럼명
                                joinMap.put('TARGET_TABLE__C',          dtl.TARGET_TABLE__C);  // 서버측 테이블명
                                joinMap.put('TARGET_COLUMN__C',         dtl.TARGET_COLUMN__C); // 서버측 컬럼명
                                joinMap.put('SOURCE_COLUMN__C',         dtl.SOURCE_COLUMN__C); // 클라이언트측 컬럼명
                                joinMap.put('SOURCE_COLUMN_TYPE__C',    dtl.SOURCE_COLUMN_TYPE__C); // 클라이언트측 응답할 형식
                                joinMap.put('REPONSE_SOURCE_COLUMN',    ret.SOURCE_COLUMN__C); // 리스트 타입인 경우, 테이블 컬럼 그룹 구분
                                joinMap.put('DEFAULT_VALUE__C',         dtl.DEFAULT_VALUE__C); // 기본값
                                joinMap.put('TARGET_COLUMN_TYPE__C',    dtl.TARGET_COLUMN_TYPE__C); // 데이터 타입
                                joinMap.put('REQUEST_COLUMN_FORMAT__C', dtl.REQUEST_COLUMN_FORMAT__C); // 데이터 포맷

                                fieldMappingList.add(joinMap);
                            }
                        }

                        // 그룹핑 조건정보 추가
                        if(dtl.GROUPING_FIELD_YN__C == 'Y') {
                            // 대상필드가 null과 COUNT가 아닌 경우 그룹핑 필드에 추가함
                            if(dtl.TARGET_COLUMN__C != null && dtl.TARGET_COLUMN__C != '') {
                                if(dtl.TARGET_COLUMN__C != 'COUNT') {
                                    groupingList.add(MetaDataHelper.changeFieldForFuntion(dtl.TARGET_COLUMN__C, dtl.TARGET_COLUMN_TYPE__C, dtl.SOQL_FUNCTION__C , 'group'));
                                }
                            }

                            // 대상필드와 조건절의 필드가 다르고, 조건절 필드에 값이 있다면 그룹핑 필드에 추가함
                            if(dtl.TARGET_COLUMN__C != dtl.SEARCH_CONDITION_FIELD__C) {
                                if(dtl.SEARCH_CONDITION_FIELD__C != null && dtl.SEARCH_CONDITION_FIELD__C != '') {
                                    groupingList.add(MetaDataHelper.changeFieldForFuntion(dtl.SEARCH_CONDITION_FIELD__C, dtl.TARGET_COLUMN_TYPE__C, dtl.SOQL_FUNCTION__C , 'group'));
                                }
                            }
                        }

                        // 정렬조건정보 추가
                        if(dtl.ORDER_TYPE__C != null && dtl.ORDER_TYPE__C != '') {
                            Map<String, Object> obmap = new Map<String, Object>();

                            obmap.put('TARGET_COLUMN__C', MetaDataHelper.changeFieldForFuntion(dtl.TARGET_COLUMN__C, dtl.TARGET_COLUMN_TYPE__C, dtl.SOQL_FUNCTION__C , 'order')); // 서버측 컬럼명
                            obmap.put('ORDER_TYPE__C', dtl.ORDER_TYPE__C);

                            orderList.add(obmap);
                        }

                        // key에 포함되는 필드를 조건절에 추가함(upsert문 처리시 조건값을 구분하는 정보)
                        if(dtl.TARGET_COLUMN_KEY_YN__C == 'Y') {
                            Map<String, Object> cmap = new Map<String, Object>();

                            cmap.put('WHERE_COLUMN_ID',      MetaDataHelper.changeFieldForFuntion(dtl.TARGET_COLUMN__C, dtl.TARGET_COLUMN_TYPE__C, dtl.SOQL_FUNCTION__C , 'where'));
                            cmap.put('WHERE_COLUMN_VAL',     val);
                            cmap.put('WHERE_CONDITION_TYPE', dtl.CONDITION_TYPE__C);
                            cmap.put('WHERE_COLUMN_FORMAT',  dtl.REQUEST_COLUMN_FORMAT__C);
                            cmap.put('WHERE_COLUMN_TYPE',    dtl.TARGET_COLUMN_TYPE__C); // 데이터 타입
                            cmap.put('UPDATE_INCLUDE_YN',    dtl.UPSERT_INCLUDE_YN__C); // Upsert 시 조건절에 포함된 Column인 경우에도 업데이트 컬럼에 포함할지 여부(true/false)(2022-02-23)
                            cmap.put('UPDATE_COLUMN_VALUE',  dtl.UPDATE_COLUMN_VALUE__C);

                            //    System.debug('add search condition = ' + cmap);

                            mainbindList.add(cmap); // 조건절에 적용
                        }
                    }
                } // end if(plan.ORDER_NO__C == 1)
                else { // 서브쿼리 정보
                    // System.debug('sub query plan ===>>> ' + plan_tablename);
                    subTableLsit.add(plan_tablename);

                    List<String> subfields = new List<String>(); // 서브쿼리 필드 리스트
                    List<String> subColumns = new List<String>(); // 서브쿼리 조회컬럼 리스트
                    List<Map<String, Object>> subbindList = new List<Map<String, Object>>(); // 서브쿼리의 조건절 목록(컬럼 + 조건 + 값 정보)
                    List<Map<String, Object>> subOrders = new List<Map<String, Object>>(); // 서브쿼리 정렬필드 리스트
                    List<String> subGrouping = new List<String>(); // 서브쿼리 그룹필 필드 리스트

                    interface_sub_dtl = new List<INTERFACE_SERVICE_DETAIL__C>([
                            SELECT ID
                                ,SOURCE_COLUMN__C // 요청 파라메터 컬럼
                                ,TARGET_COLUMN__C // 서버측 테이블 필드ID
                                ,TARGET_COLUMN_MODIFY__C // ??
                                ,CONDITION_TYPE__C // 조건(AND, OR, IN, LIKE)
                                ,TARGET_TABLE__C // 서버측 테이블
                                ,TARGET_COLUMN_TYPE__C // 데이터 타입
                                ,SOURCE_COLUMN_REQUIRE_YN__C // 필수여부(Y/N)
                                ,REQUEST_COLUMN_FORMAT__C // 데이터 포맷
                                ,SEARCH_CONDITION_FIELD__C // 서브쿼리용 조건 필드(메인쿼리와 연결된 ID를 가지고 있는 필드명)
                                ,SEARCH_CONDITION_VALUE__C // 서브쿼리용 조건 값(메인쿼리에서 ID를 가지고 있는 Map의 Name)
                                ,TARGET_COLUMN_KEY_YN__C // key값 여부(쿼리생성시 조건이 되는 필드인지 여부)
                                ,DEFAULT_VALUE__C // 요청값이 없는 경우, 자동으로 채울 값
                                ,SOURCE_COLUMN_TYPE__C // 응답할 소스 타입(List or 응답 타입이 TABLE인 경우에는 상위 응답명)
                                ,ORDER_TYPE__C // ORDER BY 타입(ACE, DESC)
                                ,ORDER_BY_ORDER__C // 정렬순서
                                ,GROUPING_FIELD_YN__c // 그룹핑 필드 포함여부(Y/N)
                                ,SOQL_FUNCTION__C // SOQL 적용함수 지정
                                ,INTERCEPTOR_METHOD__C // 데이터 예외처리 함수명
                                ,UPSERT_INCLUDE_YN__C // Upsert Column 포함여부(2022-02-23)
                                ,UPDATE_COLUMN_VALUE__c // UPDATE_컬럼_파라메터명(2022-02-23)
                            FROM INTERFACE_SERVICE_DETAIL__C
                            WHERE INTERFACE_SERVICE_DETAIL__C = :ret.ID
                            AND IN_OUT_TYPE__C = 'TABLE'
                            AND TARGET_TABLE__C = :plan_tablename
                            ORDER BY ORDER_BY_ORDER__C
                    ]);

                    //    System.debug('interface_sub_dtl - parameter > id = ' + ret.ID + ', target table = ' + plan_tablename + ', result count = ' + interface_sub_dtl.size());

                    // 서브쿼리에서 조회할 필드 항목
                    for(INTERFACE_SERVICE_DETAIL__C dtl : interface_sub_dtl) {
                        Object val = null;

                        try {
                            val = this.getFieldValue(dtl, volist); // Request parameter에서 정보를 찾아 리턴함
                            //    System.debug('sub - binding value : '+dtl.TARGET_COLUMN__C+' = ' + val);
                        } catch(Exception e) {
                            if(in_out_type == 'IN') return MessageResource.getMessage(MessageResource.MSG_DATA_FORMAT_1_ERR, new List<String>{dtl.SOURCE_COLUMN__C, dtl.TARGET_COLUMN_TYPE__C, dtl.REQUEST_COLUMN_FORMAT__C});
                        }

                        if(in_out_type == 'IN') {
                            String retMsg = InterfaceHelper.isRequired(val, dtl.SOURCE_COLUMN_REQUIRE_YN__C, dtl.SOURCE_COLUMN__C , in_out_type);

                            if(retMsg != null && retMsg != '') {
                                return retMsg;
                            }
                        }

                        // 서브쿼리 조회 필드 추가
                        if(dtl.TARGET_COLUMN__C != null && dtl.TARGET_COLUMN__C != '' && dtl.TARGET_TABLE__C != null && dtl.TARGET_TABLE__C != '') {
                            if(dtl.GROUPING_FIELD_YN__C == null || dtl.GROUPING_FIELD_YN__C == 'Y') {
                                subfields.add(dtl.TARGET_COLUMN__C);
                                subColumns.add(MetaDataHelper.changeFieldForFuntion(dtl.TARGET_COLUMN__C, dtl.TARGET_COLUMN_TYPE__C, dtl.SOQL_FUNCTION__C , 'select'));
                            }
                        }

                        // 응답맵핑정보 생성
                        if(dtl.TARGET_TABLE__C != null && dtl.TARGET_TABLE__C != '') { // 서브 데이터의 응답형식이 List인 경우를 처리하기 위해 테이블 정보가 있는지 체크함
                            if(in_out_type == 'OUT' || in_out_type == 'IN') {
                                Map<String, Object> joinMap = new Map<String, Object>();

                                if(dtl.TARGET_COLUMN__C != null) joinMap.put('TABLE_TARGET_COLUMN__C', (dtl.TARGET_TABLE__C+'_'+dtl.TARGET_COLUMN__C)); // 서버측 유니크한 컬럼명
                                else joinMap.put('TABLE_TARGET_COLUMN__C', dtl.TARGET_TABLE__C);
                                joinMap.put('TARGET_TABLE__C',             dtl.TARGET_TABLE__C); // 서버측 테이블명
                                joinMap.put('TARGET_COLUMN__C',            dtl.TARGET_COLUMN__C); // 서버측 컬럼명
                                joinMap.put('SOURCE_COLUMN__C',            dtl.SOURCE_COLUMN__C); // 클라이언트측 컬럼명
                                joinMap.put('SOURCE_COLUMN_TYPE__C',       dtl.SOURCE_COLUMN_TYPE__C); // 클라이언트측 응답할 형식(자신의 상위 LIST나 MAP의 응답필드명)
                                joinMap.put('REPONSE_SOURCE_COLUMN',       ret.SOURCE_COLUMN__C); // 리스트 타입인 경우, 테이블 컬럼 그룹 구분
                                joinMap.put('DEFAULT_VALUE__C',            dtl.DEFAULT_VALUE__C); // 기본값
                                joinMap.put('TARGET_COLUMN_TYPE__C',       dtl.TARGET_COLUMN_TYPE__C); // 데이터 타입
                                joinMap.put('REQUEST_COLUMN_FORMAT__C',    dtl.REQUEST_COLUMN_FORMAT__C); // 데이터 타입

                                fieldMappingList.add(joinMap);
                            }
                        }

                        // 그룹핑 조건정보 추가
                        if(dtl.GROUPING_FIELD_YN__C == 'Y') {
                            // 대상필드가 null과 COUNT가 아닌 경우 그룹핑 필드에 추가함
                            if(dtl.TARGET_COLUMN__C != null && dtl.TARGET_COLUMN__C != '') {
                                if(dtl.TARGET_COLUMN__C != 'COUNT') {
                                    subGrouping.add(MetaDataHelper.changeFieldForFuntion(dtl.TARGET_COLUMN__C, dtl.TARGET_COLUMN_TYPE__C, dtl.SOQL_FUNCTION__C , 'group'));
                                }
                            }

                            // 대상필드와 조건절의 필드가 다르고, 조건절 필드에 값이 있다면 그룹핑 필드에 추가함
                            if(dtl.TARGET_COLUMN__C != dtl.SEARCH_CONDITION_FIELD__C) {
                                if(dtl.SEARCH_CONDITION_FIELD__C != null && dtl.SEARCH_CONDITION_FIELD__C != '') {
                                    subGrouping.add(MetaDataHelper.changeFieldForFuntion(dtl.SEARCH_CONDITION_FIELD__C, dtl.TARGET_COLUMN_TYPE__C, dtl.SOQL_FUNCTION__C , 'group'));
                                }
                            }
                        }

                        // 정렬조건정보 추가
                        if(dtl.ORDER_TYPE__C != null && dtl.ORDER_TYPE__C != '') {
                            Map<String, Object> obmap = new Map<String, Object>();

                            obmap.put('TARGET_COLUMN__C', MetaDataHelper.changeFieldForFuntion(dtl.TARGET_COLUMN__C, dtl.TARGET_COLUMN_TYPE__C, dtl.SOQL_FUNCTION__C , 'order')); // 서버측 컬럼명
                            obmap.put('ORDER_TYPE__C', dtl.ORDER_TYPE__C);

                            subOrders.add(obmap);
                        }

                        Map<String, Object> cmap = new Map<String, Object>();

                        // 조건절 추가 정보 생성
                        cmap.put('TARGET_TABLE__C',              dtl.TARGET_TABLE__C);
                        cmap.put('SEARCH_CONDITION_FIELD__C',    MetaDataHelper.changeFieldForFuntion(dtl.SEARCH_CONDITION_FIELD__C, dtl.TARGET_COLUMN_TYPE__C, dtl.SOQL_FUNCTION__C , 'where'));
                        cmap.put('SEARCH_CONDITION_VALUE__C',    dtl.SEARCH_CONDITION_VALUE__C); // 실행수행결과 Map에 담긴 명칭를 의미함.
                        cmap.put('SEARCH_TARGET_COLUMN_TYPE__C', dtl.TARGET_COLUMN_TYPE__C);
                        String rstType = MetaDataHelper.getString2Object(dtl.TARGET_COLUMN_TYPE__C, null);
                        if(rstType.toUpperCase() == 'LIST' || rstType.toUpperCase() == 'MAP' || rstType.toUpperCase() == 'MAP.STRING') { // 서브쿼리 수행결과를 List로 응답할 경우
                            cmap.put('TARGET_COLUMN_TYPE__C', rstType.toUpperCase()); // 응답타입
                            cmap.put('TARGET_TABLE__C', dtl.TARGET_TABLE__C); // 응답명(실 테이블 명)
                        }

                        // key에 포함되는 필드를 조건절에 추가함(ID 비교조건)
                        if(dtl.TARGET_COLUMN_KEY_YN__C == 'Y') {
                            cmap.put('WHERE_COLUMN_ID',      MetaDataHelper.changeFieldForFuntion(dtl.TARGET_COLUMN__C, dtl.TARGET_COLUMN_TYPE__C, dtl.SOQL_FUNCTION__C , 'where'));
                            cmap.put('WHERE_COLUMN_VAL',     val);
                            cmap.put('WHERE_CONDITION_TYPE', dtl.CONDITION_TYPE__C);
                            cmap.put('WHERE_COLUMN_FORMAT',  dtl.REQUEST_COLUMN_FORMAT__C);
                            cmap.put('WHERE_COLUMN_TYPE',    dtl.TARGET_COLUMN_TYPE__C); // 데이터 타입
                            cmap.put('UPDATE_INCLUDE_YN',    dtl.UPSERT_INCLUDE_YN__C); // Upsert 시 조건절에 포함된 Column인 경우에도 업데이트 컬럼에 포함할지 여부(true/false)(2022-02-23)
                            cmap.put('UPDATE_COLUMN_VALUE',  dtl.UPDATE_COLUMN_VALUE__C);
                        }

                        if(dtl.SEARCH_CONDITION_FIELD__C != null) {
                            cmap.put('WHERE_COLUMN_SORT_NO', '0'); // 조건절 적용 우선 순위 지정
                        } else if(dtl.TARGET_COLUMN_KEY_YN__C == 'Y') {
                            cmap.put('WHERE_COLUMN_SORT_NO', '1'); // 조건절 적용 우선 순위 지정
                        } else {
                            cmap.put('WHERE_COLUMN_SORT_NO', '2'); // 조건절 적용 우선 순위 지정
                        }

                        subbindList.add(cmap); // 조건절에 적용
                    }

                    bindInfoMap.put(plan_tablename+'_FIELD',  subfields);
                    bindInfoMap.put(plan_tablename+'_COLUMN', subColumns);
                    bindInfoMap.put(plan_tablename+'_BIND',   subbindList);
                    bindInfoMap.put(plan_tablename+'_ORDER',  subOrders);
                    bindInfoMap.put(plan_tablename+'_GROUP',  subGrouping);
                } // end if(plan.ORDER_NO__C == 1) > else
            }
        } // end if(interface_out_plan != null && interface_out_plan.size() > 0)
        else { // 실행계획이 없으면 일반 파라메터로 구분하여 아래 구문을 수행함
            if(ret.TARGET_COLUMN__C != null && ret.TARGET_COLUMN__C != '' && ret.TARGET_TABLE__C != null && ret.TARGET_TABLE__C != '') {
                Object val = null;

                try {
                    val = this.getFieldValue(ret, volist); // Request parameter에서 정보를 찾아 리턴함
                    //    System.debug('where value = '+ val);
                } catch(Exception e) {
                    if(in_out_type == 'IN') return MessageResource.getMessage(MessageResource.MSG_DATA_FORMAT_1_ERR, new List<String>{ret.SOURCE_COLUMN__C, ret.TARGET_COLUMN_TYPE__C, ret.REQUEST_COLUMN_FORMAT__C});
                }

                if(in_out_type == 'IN') {
                    String retMsg = InterfaceHelper.isRequired(val, ret.SOURCE_COLUMN_REQUIRE_YN__C, ret.SOURCE_COLUMN__C , in_out_type);

                    if(retMsg != null && retMsg != '') {
                        return retMsg;
                    }
                }

                mainfields.add(ret.TARGET_COLUMN__C);
                mainColumns.add(MetaDataHelper.changeFieldForFuntion(ret.TARGET_COLUMN__C, ret.TARGET_COLUMN_TYPE__C, ret.SOQL_FUNCTION__C , 'select'));

                // 응답 맵핑정보 추가
                if(in_out_type == 'OUT' || in_out_type == 'IN') {
                    Map<String, Object> joinMap = new Map<String, Object>();

                    joinMap.put('TABLE_TARGET_COLUMN__C', (ret.TARGET_TABLE__C+'_'+ret.TARGET_COLUMN__C)); // 서버측 유니크한 컬럼명
                    joinMap.put('TARGET_TABLE__C',        ret.TARGET_TABLE__C); // 서버측 테이블명
                    joinMap.put('TARGET_COLUMN__C',       ret.TARGET_COLUMN__C); // 서버측 컬럼명
                    joinMap.put('SOURCE_COLUMN__C',       ret.SOURCE_COLUMN__C); // 클라이언트측 컬럼명
                    // 클라이언트측 응답할 형식(LIST, MAP, STRING)
                    if(sourceType == 'LIST' || sourceType == 'MAP' || sourceType == 'MAP.STRING') {
                        joinMap.put('SOURCE_COLUMN_TYPE__C', sourceType);
                    } else {
                        joinMap.put('SOURCE_COLUMN_TYPE__C', '');
                    }
                    joinMap.put('REPONSE_SOURCE_COLUMN',    ret.SOURCE_COLUMN__C); // 리스트 타입인 경우, 테이블 컬럼 그룹 구분
                    joinMap.put('DEFAULT_VALUE__C',         ret.DEFAULT_VALUE__C); // 기본값
                    joinMap.put('TARGET_COLUMN_TYPE__C',    ret.TARGET_COLUMN_TYPE__C); // 데이터 타입
                    joinMap.put('REQUEST_COLUMN_FORMAT__C', ret.REQUEST_COLUMN_FORMAT__C); // 데이터 포맷

                    fieldMappingList.add(joinMap);
                }

                // 조건절 정보 생성
                Map<String, Object> cmap = new Map<String, Object>();

                cmap.put('WHERE_COLUMN_ID',      MetaDataHelper.changeFieldForFuntion(ret.TARGET_COLUMN__C, ret.TARGET_COLUMN_TYPE__C, ret.SOQL_FUNCTION__C , 'where'));
                cmap.put('WHERE_COLUMN_VAL',     val);
                cmap.put('WHERE_CONDITION_TYPE', ret.CONDITION_TYPE__C);
                cmap.put('WHERE_COLUMN_FORMAT',  ret.REQUEST_COLUMN_FORMAT__C);
                cmap.put('WHERE_MIX_TYPE',       ret.TARGET_COLUMN_MIX_TYPE__C); // 조합조건(AND, OR)
                cmap.put('WHERE_COLUMN_TYPE',    ret.TARGET_COLUMN_TYPE__C); // 데이터 타입
                // 조합조건 상위소스필드명(LIST, MAP, STRING이 아닌 경우 적용)
                if(sourceType != 'LIST' && sourceType != 'MAP' && sourceType != 'MAP.STRING') {
                    cmap.put('WHERE_PARENT_CLOUMN', sourceType);
                } else {
                    cmap.put('WHERE_PARENT_CLOUMN', '');
                }

                if(val != null && val != '') mainbindList.add(cmap); // 조건절에 적용(요청시 데이터 없으면 자동으로 조건절에서 제외시킴)
            }
        } // end if(interface_out_plan.size() > 0) > else

        return message;
    }

    /**
     * 사용자 요청정보의 값 또는 인터페이스 상세정보에 기본으로 설정된 값을 리턴
     *
     * @params dtl 인터페이스 상세 설정정보
     * @params volist 사용자 요청정보
     * @return 요청정보와 설정정보을 맵핑한 값
     */
    @TestVisible
    private Object getFieldValue(INTERFACE_SERVICE_DETAIL__C dtl, List<ValueRow> volist) {
        String val = null;
        String defaultValue = dtl.DEFAULT_VALUE__C;
        if(defaultValue == null) defaultValue = '';

        // 요청 파라메터에 해당되는 값이 있는지 찾아 맵핑 수행
        for(ValueRow row : volist) {
            Map<String, Object> vrmap = row.getMap();

            for(String key: vrmap.keySet()) {
                
                if(key == dtl.SOURCE_COLUMN__C) {
                    // System.debug('key : ' + key + ', dtl.SOURCE_COLUMN__C : ' + dtl.SOURCE_COLUMN__C + ', dtl.TARGET_COLUMN__C : ' + dtl.TARGET_COLUMN__C);
                    // System.debug('vrmap : ' + vrmap);
                    // System.debug('dtl.REQUEST_COLUMN_FORMAT__C : ' + dtl.REQUEST_COLUMN_FORMAT__C);

                    // 기본값이 TODAY이면 현재일자로 반영
                    // LAST_N_DAYS:n, LAST_N_MONTHS:n, LAST_N_YEARS:n를 그대로 조건절에 포함하려면 n부분에 숫자를 넣고 마지막에 ()을 추가(2022-04-18, 박성현)
                    // 마찬가지로 LAST_90_DAYS()로 입력하면, LAST_90_DAYS 함수도 적용 가능(2022-04-18, 박성현)
                    if(defaultValue == 'TODAY()') {
                        String tdate = MetaDataHelper.getString2Object(Date.today(), dtl.REQUEST_COLUMN_FORMAT__C);
                        vrmap.put(key, tdate);
                        val = tdate;
                    } else if(defaultValue == 'NOW()') {
                        String tdate = MetaDataHelper.getString2Object(Datetime.now(), dtl.REQUEST_COLUMN_FORMAT__C);
                        vrmap.put(key, tdate);
                        val = tdate;
                    } else if(defaultValue == 'YESTERDAY()') { // 박성현 추가(2022-04-18)
                        String tdate = MetaDataHelper.getString2Object(Date.today().addDays(-1), dtl.REQUEST_COLUMN_FORMAT__C);
                        vrmap.put(key, tdate);
                        val = tdate;
                    } else if(defaultValue == 'TOMORROW()') { // 박성현 추가(2022-04-18)
                        String tdate = MetaDataHelper.getString2Object(Date.today().addDays(1), dtl.REQUEST_COLUMN_FORMAT__C);
                        vrmap.put(key, tdate);
                        val = tdate;
                    } else if(defaultValue == 'TOSTARTOFWEEK()') { // 박성현 추가(2022-04-18). 사용자의 LOCALE에 따라 호출한 날을 기준으로 그 주의 첫 일자를 가져온다.
                        String tdate = MetaDataHelper.getString2Object(Date.today().toStartOfWeek(), dtl.REQUEST_COLUMN_FORMAT__C);
                        vrmap.put(key, tdate);
                        val = tdate;
                    } else if(defaultValue == 'TOENDOFWEEK()') { // 박성현 추가(2022-04-18). 사용자의 LOCALE에 따라 호출한 날을 기준으로 그 주의 마지막 일자를 가져온다.
                        String tdate = MetaDataHelper.getString2Object(Date.today().toStartOfWeek().addDays(6), dtl.REQUEST_COLUMN_FORMAT__C);
                        vrmap.put(key, tdate);
                        val = tdate;
                    } else if(defaultValue == 'TOSTARTOFMONTH()') { // 박성현 추가(2022-04-18). 호출한 날을 기준으로 그 달의 첫 일자를 가져온다.
                        String tdate = MetaDataHelper.getString2Object(Date.today().toStartOfMonth(), dtl.REQUEST_COLUMN_FORMAT__C);
                        vrmap.put(key, tdate);
                        val = tdate;
                    } else if(defaultValue == 'TOENDOFMONTH()') { // 박성현 추가(2022-04-18). 호출한 날을 기준으로 그 달의 마지막 일자를 가져온다.
                        String tdate = MetaDataHelper.getString2Object(Date.today().toStartOfMonth().addMonths(1).addDays(-1), dtl.REQUEST_COLUMN_FORMAT__C);
                        vrmap.put(key, tdate);
                        val = tdate;
                    } else if(defaultValue.startsWith('THIS_') && defaultValue.endsWith('()')) {
                        val = defaultValue;
                    } else if(defaultValue.startsWith('LAST_') && defaultValue.endsWith('()')) { // 박성현 추가.(2022-04-18)
                        val = defaultValue;
                    } else if(defaultValue.startsWith('NEXT_') && defaultValue.endsWith('()')) { // 박성현 추가.(2022-04-18)
                        val = defaultValue;
                    } else if(defaultValue.startsWith('LAST_N_DAYS')) {
                        val = defaultValue;
                    } else {
                        val =  MetaDataHelper.getString2Object(vrmap.get(key));
                    }
                    break;
                }
                // 기본값에 요청 파라메터 key와 맵핑된 정보가 있다면 치환함(2020-08-24)
                if(key == defaultValue) {
                    val =  MetaDataHelper.getString2Object(vrmap.get(key));
                    break;
                }
            }

            if(val != null && val != '') {
                break;
            }
        }

        if(val == null || val == '') {
            val = defaultValue;
        }

        if(val == null || val == '') {
            return null;
        } else {
            //System.debug('val : ' + val);
            //System.debug('dtl.TARGET_COLUMN_TYPE__C : ' + dtl.TARGET_COLUMN_TYPE__C);
            //System.debug('dtl.TARGET_TABLE__C : ' + dtl.TARGET_TABLE__C);
            return MetaDataHelper.getObject2String(val, dtl.TARGET_COLUMN_TYPE__C, dtl.TARGET_TABLE__C);
        }
    }

    /**
     * 상위-하위 Dynamic SOQL 구문 생성 시 필요한, Child RelationShip Name 정보를 가져온다.
     * 2023-11-15 박성현 추가
     */
    public String getChildRelationShipName(String childObj, String parentObj) {
        String result = null;
        
        /*
        (ex) select Id, DurableId, ChildSobjectId, FieldId, RelationshipInfoId, RelationshipName
                    , IsCascadeDelete, IsDeprecatedAndHidden, IsRestrictedDelete, JunctionIdListNames
                    , ParentSobjectId, ParentSobject.DeveloperName, ParentSobject.QualifiedApiName
            from RelationshipDomain 
            where ChildSobjectId = 'Contact' and ParentSobject.QualifiedApiName = 'Branch__c'
        */

        RelationshipDomain rd = [SELECT Id
                                    ,DurableId
                                    ,ChildSobjectId
                                    ,FieldId
                                    ,RelationshipInfoId
                                    ,RelationshipName
                                    ,IsCascadeDelete
                                    ,IsDeprecatedAndHidden
                                    ,IsRestrictedDelete
                                    ,JunctionIdListNames
                                    ,ParentSobjectId
                                    ,ParentSobject.DeveloperName
                                    ,ParentSobject.QualifiedApiName
                                FROM  RelationshipDomain
                                WHERE RelationshipName != null
                                AND   ChildSobjectId = :childObj
                                AND   ParentSobject.QualifiedApiName = :parentObj];

        if (rd != null) {
            result = rd.RelationshipName;
        }

        System.debug('rd : ' + rd);
        System.debug('result : ' + result);

        return result;
    }

    /*
    * 인터페이스 마스터 맵 정보 가져오기
    * 2023-11-15 박성현 추가
    */
    public static INTERFACE_SERVICE_MASTER__C getInterfaceServiceMstInfo(String interfaceId) {
        INTERFACE_SERVICE_MASTER__C mstInfo = [SELECT Id
                                                        ,IsDeleted
                                                        ,Name
                                                        ,Communication_Link_Type__c
                                                        ,DML_Plan__c
                                                        ,HTTP_Method_Type__c
                                                        ,IN_OUT_Type__c
                                                        ,Interface_Description__c
                                                        ,Interface_ID__c
                                                        ,Interface_Name__c
                                                        ,Log_Type__c
                                                        ,Master_Table__c
                                                        ,Protocol_Type__c
                                                        ,Request_Data_Format_Type__c
                                                        ,Response_Data_Format_Type__c
                                                        ,Run_Class__c 
                                                    FROM Interface_Service_Master__c
                                                   WHERE Interface_ID__c = :interfaceId
                                                     AND IsDeleted = false
                                                    LIMIT 1];

        System.debug('mstInfo : ' + mstInfo);
        return mstInfo;
    }

    /*
    * 인터페이스 디테일 리스트 정보 가져오기
    * 2023-11-15 박성현 추가
    */
    public static List<INTERFACE_SERVICE_DETAIL__C> getInterfaceServiceDtlList(String interfaceId) {
        List<INTERFACE_SERVICE_DETAIL__C> dtlList = [SELECT Id
                                                            ,IsDeleted
                                                            ,Name
                                                            ,Child_No__c
                                                            ,Condition_Type__c
                                                            ,Default_Value__c
                                                            ,Detail_Key__c
                                                            ,Grouping_Field_YN__c
                                                            ,IN_OUT_Type__c
                                                            ,Interceptor_Method__c
                                                            ,Interface_ID__c
                                                            ,Interface_Service_Detail__c
                                                            ,Interface_Service_Master__c
                                                            ,Order_By_Order__c
                                                            ,Order_Type__c
                                                            ,Parent_No__c
                                                            ,Request_Column_Format__c
                                                            ,Search_Condition_Field__c
                                                            ,Search_Condition_Value__c
                                                            ,Soql_Function__c
                                                            ,Source_Column_Name__c
                                                            ,Source_Column_Require_YN__c
                                                            ,Source_Column_Type__c
                                                            ,Source_Column__c
                                                            ,Target_Column_Key_YN__c
                                                            ,Target_Column_Mix_Type__c
                                                            ,Target_Column_Modify__c
                                                            ,Target_Column_Name__c
                                                            ,Target_Column_Type__c
                                                            ,Target_Column__c
                                                            ,Target_Table__c
                                                            ,UPDATE_COLUMN_VALUE__c
                                                            ,UPSERT_INCLUDE_YN__c
                                                            ,Sort_No__c
                                                    FROM  Interface_Service_Detail__c 
                                                    WHERE Interface_ID__c = :interfaceId
                                                    AND   IsDeleted = false
                                                    ORDER BY Target_Table__c ASC, Order_By_Order__c ASC];

        System.debug('dtlList : ' + dtlList);
        return dtlList;
    }

    /*
    * 인터페이스 플랜 리스트 정보 가져오기
    * 2023-11-15 박성현 추가
    */
    public static List<INTERFACE_SERVICE_PLAN__C> getInterfaceServicePlanList(String interfaceId) {
        List<INTERFACE_SERVICE_PLAN__C> planList = [SELECT Id
                                                            ,IsDeleted
                                                            ,Name
                                                            ,DML__c
                                                            ,Detail_Key__c
                                                            ,In_Out_Type__c
                                                            ,Interceptor_Code__c
                                                            ,Interface_Service_Detail__c
                                                            ,Limit_Count__c
                                                            ,Order_No__c
                                                            ,Plan_Key__c
                                                            ,Table__c
                                                            ,Interface_Id__c 
                                                        FROM Interface_Service_Plan__c
                                                       WHERE Interface_Id__c = :interfaceId
                                                         AND IsDeleted = false];

        System.debug('planList : ' + planList);
        return planList;                                                
    }

}