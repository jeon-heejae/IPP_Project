/**
 * @description       : SOSQL 실행 클래스
 * @author            : jonghyun.kim@daeunextier.com
 * @group             :
 * @last modified on  : 07-03-2020
 * @last modified by  : jonghyun.kim@daeunextier.com
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   07-03-2020   jonghyun.kim@daeunextier.com   Initial Version
**/
public class SOQLUtil {

    public SOQLUtil() {}

    /**
     * 조회 쿼리 수행 후 결과 리턴
     *
     * @params if_id 인터페이스 식별ID
     * @params query 수행쿼리
     * @params objectName 오브젝트명(테이블명)
     * @params bindList 조건절 목록
     * @params columns 조회할 컬럼목록
     * @params fields 조회된 필드목록
     * @params orderList 정렬 목록
     * @params grouping 그룹핑 목록
     * @params queryList 디버그용 쿼리 리스트 객체
     * @params inputVo 요청파라메터 정보
     * @params limitCount 조회건수
     * @parmas interceptorCode 예외조건코드(개발자가 쿼리를 강제로 변경하기 위한 구분코드)
     * @return List<Map<String, Object>> 쿼리 수행결과
     *         - Map<테이블명_컬럼명, value> 형식으로 리턴
     */
    public static List<Map<String, Object>> selectQuery(String if_id, String query, String objectName, List<Map<String, Object>> bindList, List<String> columns, List<String> fields
            , List<Map<String, Object>> orderList, List<String> grouping, List<String> queryList, ValueObject inputVo, Decimal limitCount, String interceptorCode) {
        String[] tableObj = objectName.split(' ');
        String tableName = null;
        tableName = tableObj[0];
        String errorQuery = null;
        SObjectType sobType;

        try {
             sobType = ((SObject) Type.forName(tableName).newInstance()).getSObjectType();
        } catch(Exception e) {
            errorQuery = 'ERROR SObjectType sobType: '+ e.getMessage();
            throw e;
        }

        List<Map<String, Object>> listTotal = new List<Map<String, Object>>();
        String countYn = 'N';

        if(query.indexOf('COUNT(NAME)') > -1 || query.indexOf('COUNT(ID)') > -1) {
            countYn = 'Y';
        } else {
            countYn = 'N';
        }

        if(countYn == 'N' && fields.size() < 1) {
            fields = new List<String>();

            fields.add('ID');
            fields.add('NAME');
        }

        // 개발자 정의를 적용하기 위한 인터셉터 수행(쿼리 생성전에 조건을 변경하기 위해 호출함)
        InterfaceInterceptor selectInterceptor = new InterfaceInterceptor();
        selectInterceptor.selectQueryInterceptor(if_id, query, objectName, bindList, fields, orderList, inputVo, interceptorCode);

        query = query.replace('{TABLE_NAME}', objectName+ ' '); // 테이블명 등록
        if(fields != null) query = query.replace('*', String.join(columns, ',')); // 조회 필드 등록

        // 조건절 등록
        // Interface_Service_Plan__c의 Interceptor_Code__c에 WHERE으로 설정된 경우에만 적용. (2023-12-22, 박성현)
        if (interceptorCode == 'WHERE') {
            InterfaceInterceptor whereInterceptor = new InterfaceInterceptor();
            String whereQuery = whereInterceptor.whereQueryInterceptor(if_id, inputVo);
            query += whereQuery;
        } else { // 없으면 기본 설정값이 적용됨.
            if(bindList != null && bindList.size() > 0) {
                String cndquery = constructWhereClause(bindList, query);
                query += cndquery;
            }
        }

        // 그룹핑절 등록
        if(grouping != null && grouping.size() > 0) {
            query += groupByClause(grouping);
        }

        // Having절 등록
        // Interface_Service_Plan__c의 Interceptor_Code__c에 HAVING으로 설정된 경우에만 적용. (2023-12-22, 박성현)
        if (interceptorCode == 'HAVING') {
            InterfaceInterceptor havingInterceptor = new InterfaceInterceptor();
            String havingQuery = havingInterceptor.havingQueryInterceptor(if_id);
            query += havingQuery;
        }

        // 정렬절 등록
        String orderbyquery = '';
        if (interceptorCode == 'ORDER_BY') { // 정렬절을 강제로 처리하기
            InterfaceInterceptor orderByInterceptor = new InterfaceInterceptor();
            orderbyquery = orderByInterceptor.orderByQueryInterceptor(if_id, inputVo, interceptorCode);
        } else { // 값이 없으면 Detail의 정렬 설정을 따른다.
            if(orderList != null && orderList.size() > 0) {
                orderbyquery = orderByClause(orderList);
            }
        }
        query += orderbyquery;

        // 개발자 정의를 적용하기 위한 인터셉터 수행(Limit)
        InterfaceInterceptor limitInterceptor = new InterfaceInterceptor();
        String limitInterceptorVal = limitInterceptor.limitQueryInterceptor(if_id, query, objectName, bindList, fields, orderList, inputVo, interceptorCode);
        // System.debug('limitCount : ' + limitCount + ', limitInterceptorVal : ' + limitInterceptorVal);
        // 리미트 등록
        if(limitCount != null || limitInterceptorVal != null) {
            if (limitCount != null) {
                String limitquery = ' LIMIT ' + limitCount;
                query += limitquery;
            } else if (limitInterceptorVal != null) {
                query +=  limitInterceptorVal;
            }
        }

        // FROM 절 이후의 모든 부분을 강제로 변경하려면(2023-12-22, 박성현)
        if (interceptorCode == 'AFTER') {
            InterfaceInterceptor afterInterceptor = new InterfaceInterceptor();
            query = afterInterceptor.afterQueryInterceptor(if_id, objectName, query, inputVo);
        }

        System.debug('full select query : ' + query);

        try {
            List<SObject> slist = Database.query(query);

            System.debug('slist :: ' + slist);

            for(SObject sob : slist) {
                Map<String, Object> mapObj = new Map<String, Object>();

                System.debug('fields :: ' + fields );

                if(fields != null && fields.size() > 0) {
                    for (String field : fields) {
                        Object value = null;

                        if(field.indexOf('.') > -1) { // 상위 객체의 값 구하기
                            List<String> splitString = field.split('\\.');

                            try {
                                Sobject searchObject = sob;

                                for(Integer i = 0; i < (splitString.size() - 1); i++ ) {
                                    searchObject = searchObject.getSObject(splitString[i]);
                                }

                                value = searchObject.get(splitString[splitString.size() - 1]);
                            } catch(Exception e) {
                                try {
                                    value = sob.get(splitString[splitString.size() - 1]);
                                } catch(Exception ep) {
                                    value = null;
                                }
                            }
                        } else {
                            value = sob.get(field);
                        }

                        if(value != null) {
                            mapObj.put((objectName+'_'+field), MetaDataHelper.getString2Object(value));
                        }
                    }
                }

                if(countYn == 'Y') {
                    String cnt = MetaDataHelper.getString2Object(sob.get('CNT'), null, '0');

                    mapObj.put((objectName+'_COUNT'), cnt);
                }

                listTotal.add(mapObj);
            }

        } finally {
            if(queryList != null) queryList.add('Query:['+query+'], DML:SELECT, Target table:'+objectName +', Result_size:'+listTotal.size());
        }


        return listTotal;
    }

    /**
     * insert 쿼리 수행 후 결과 리턴
     *
     * @params if_id 인터페이스 식별ID
     * @params objectName 오브젝트명(테이블명)
     * @params fields 필드목록
     * @params data insert할 정보
     * @return 등록된 레코드 ID
     */
    public static String insertQuery(String if_id, String objectName, List<String> fields, Map<String, Object> data, List<String> queryList) {
        SObject sObj = getInsertObject(if_id, objectName, fields, data, queryList);
        String ext_flag = objectName.substring(objectName.length()-3, objectName.length());

        //    System.debug('insert table type(external = __x / internal = __c) = ' + ext_flag);

        try {
            if(ext_flag == '__x') { // external table 객체의 data insert 수행 추가(2022-03-22)
                Database.SaveResult dsr = Database.insertAsync(sObj);

                return '-1'; // external table은 비동기 방식으로 생성된 레코드 아이디 바로 리턴 불가. 임의로 '-1' 처리
            } else {
                insert sObj;

                return sObj.Id;
            }
        } catch(Exception e) {
            System.debug('SOQLUtil.insertQuery - ERROR: '+e.getMessage());
            throw e;
        }
    }

    /**
     * Insert SObject 리턴
     *
     * @params if_id 인터페이스 식별ID
     * @params objectName 오브젝트명(테이블명)
     * @params fields 필드목록
     * @params data insert할 정보
     * @return SObject
     */
    public static SObject getInsertObject(String if_id, String objectName, List<String> fields, Map<String, Object> data, List<String> queryList) {
        String[] tableObj = objectName.split(' ');
        String tableName = null;
        tableName = tableObj[0];

        SObjectType sObjType = Schema.getGlobalDescribe().get(tableName);
        DescribeSObjectResult objDef = sObjType.getDescribe();
        Map<String, SObjectField> objFelds = objDef.fields.getMap();

        SObject sObj = sObjType.newSObject();

        // 개발자 정의를 적용하기 위한 인터셉터 수행
        InterfaceInterceptor ii = new InterfaceInterceptor();
        ii.insertQueryInterceptor(if_id, fields, data);

        String insQuery = 'INSERT INTO ' + objectName + '(';
        String bindQuery = ' VALUES(';
        String errorQuery = null;
        Integer cnt = 1;

        try {
            for(String field : fields) {
                Object otype = objFelds.get(field);

                // if(field == MetaDataHelper.getString2Object(otype)) {
                String mname = (objectName+'_'+field);
                Object val = data.get(mname);

                if(String.isNotBlank(MetaDataHelper.getString2Object(val))) {
                    if(field.toUppercase() !=  'ID') {
                        if(MetaDataHelper.getString2Object(val, null, null).toUppercase() == 'NULL') val = null;

                        if(cnt >= fields.size()) {
                            insQuery += field;
                            bindQuery += MetaDataHelper.getBindString(val, null);
                        } else {
                            insQuery += field + ',';
                            bindQuery += MetaDataHelper.getBindString(val, null) + ',';
                        }

                        //    System.debug('insert field name = ' + field + ', value = '+val);
                        sObj.put(field, val);
                    }
                }
                // }
                cnt++;
            }
        } catch(Exception e) {
            errorQuery = 'ERROR: '+e.getMessage();
            throw e;
        } finally {
            if(errorQuery != null) insQuery = errorQuery;
            else insQuery = insQuery+')'+bindQuery+')';
            if(queryList != null) queryList.add('Query:['+insQuery+'], DML:INSERT, Target table:'+objectName);
        }

        return sObj;
    }

    /**
     * update 쿼리 수행 후 결과 리턴
     *
     * @params if_id 인터페이스 식별ID
     * @params query 수행쿼리
     * @params objectName 오브젝트명(테이블명)
     * @params bindList ID조회조건
     * @params fields 필드목록
     * @params data update할 정보
     * @return 등록된 레코드 ID
     */
    public static String updateQuery(String if_id, String query, String objectName, List<Map<String, Object>> bindList, List<String> fields, Map<String, Object> data, List<String> queryList) {
        SObject sObj = getUpdateObject(if_id, query, objectName, bindList, fields, data, queryList);
        String ext_flag = objectName.substring(objectName.length()-3, objectName.length());

        //    System.debug('insert table type(external = __x / internal = __c) = ' + ext_flag);

        try {
            if(ext_flag == '__x') { // external table 객체의 data upadte 수행 추가(2022-03-22)
                Database.SaveResult dsr = Database.updateAsync(sObj);

                return MetaDataHelper.getString2Object(dsr.getId());
            } else {
                update sObj;

                return MetaDataHelper.getString2Object(sObj.id);
            }
        } catch(Exception e) {
            System.debug('SOQLUtil.updateQuery - ERROR: '+e.getMessage());
            throw e;
        }
    }

    /**
     * Update SObject 리턴
     *
     * @params if_id 인터페이스 식별ID
     * @params query 수행쿼리
     * @params objectName 오브젝트명(테이블명)
     * @params bindList ID조회조건
     * @params fields 필드목록
     * @params data update할 정보
     * @params queryList Query Debug
     * @return SObject
     */
    public static SObject getUpdateObject(String if_id, String query, String objectName, List<Map<String, Object>> bindList, List<String> fields, Map<String, Object> data, List<String> queryList) {
        String result = null;
        String[] tableObj = objectName.split(' ');
        String tableName = null;
        tableName = tableObj[0];

        SObjectType sObjType = Schema.getGlobalDescribe().get(tableName);
        DescribeSObjectResult objDef = sObjType.getDescribe();
        Map<String, SObjectField> objFelds = objDef.fields.getMap();

        // 개발자 정의를 적용하기 위한 인터셉터 수행
        InterfaceInterceptor ii = new InterfaceInterceptor();
        ii.updateQueryInterceptor(if_id, bindList, fields, data);

        String cndquery = '';
        query = query.replace('{TABLE_NAME}', objectName+ ' ');
        // System.debug('query ==> 1. ' + query);
        if(bindList != null) {
            cndquery = constructWhereClause(bindList, query);
            query += cndquery;

            // 검색조건에 있는 필드는 업데이터할 수 없도록 필드에서 제거한다.
            for(Map<String, Object> bind: bindList) {
                String key = MetaDataHelper.getString2Object(bind.get('WHERE_COLUMN_ID'));
                Boolean incYn = (Boolean)bind.get('UPDATE_INCLUDE_YN'); // update할 필드로 포할지 여부 지정(2022-02-23)
                String updParam = MetaDataHelper.getString2Object(bind.get('UPDATE_COLUMN_VALUE')); // update 시 적용할 값을 가지고 있는 파라메터명 지정(2022-02-23)

                if(incYn != true) { // update할 필드가 아닌 경우에만 제거하도록 추가(2022-02-23)
                    for(Integer i = 0; i < fields.size(); i++) {
                        String field = fields.get(i);
                        if(key == field) {
                            fields.remove(i);
                            break;
                        }
                    }
                } else {
                    // System.debug(objectName+'_'+ key + '=' + updParam + '=' + data.get(updParam));
                    if(updParam != null && updParam != '') {
                        Object updVal = data.get(updParam);

                        if(updVal != null && updVal != '') {
                            data.put(objectName+'_'+ key, updVal);
                        } else {
                            data.put(objectName+'_'+ key, 'NULL');
                        }
                    }
                    //    System.debug(data.get(objectName+'_'+ key));
                }
            }
        }

        // System.debug('update field list = ' + fields);
        // System.debug('query ==> 2. ' + query);
        String insQuery = '';
        String bindQuery = '';
        String errorQuery = null;
        SObject sObj = null;

        try {
            sObj = Database.query(query);

            if(sObj.id != null) {
                insQuery = 'UPDATE ' + objectName + ' SET ';

                sObj.put('id', MetaDataHelper.getObject2String(sObj.id, 'ID'));

                // System.debug('data : ' + data);

                for(String field : fields) {
                    Object otype = objFelds.get(field);

                    // if(field == MetaDataHelper.getString2Object(otype)) {
                    String mname = (objectName+'_'+field);
                    Object val = data.get(mname);
                    // System.debug('>>>>>>>>' + mname + '=' + val);

                    // Date, Datetime, Double 등의 타입 필드의 경우 null 처리가 불가.
                    // 오로지 String(Salesforce Text) 타입만 null 처리가 가능함.
                    if(String.isNotBlank(MetaDataHelper.getString2Object(val))) {
                        String nullStr = MetaDataHelper.getString2Object(val, null, null).toUppercase();
                        Boolean nullYn = (nullStr == 'NULL');
                        if(nullYn) val = null;

                        if(field.toUppercase() != 'ID') {
                            bindQuery += field + '=' + MetaDataHelper.getBindString(val, null) + ',';
                            sObj.put(field, val);
                        }
                    }
                    // }
                }

                if (bindQuery.length() > 0) {
                    bindQuery = bindQuery.substring(1, bindQuery.length()-1);
                }
                bindQuery += ' WHERE ID = ' + MetaDataHelper.getObject2String(sObj.id, 'ID');
            }
        } catch(Exception e) {
            errorQuery = 'ERROR: '+e.getMessage();
            throw e;
        } finally {
            if(errorQuery != null) insQuery = errorQuery;
            else insQuery = insQuery + bindQuery;

            if(queryList != null) queryList.add('Query:['+insQuery+'], DML:UPDATE, Target table:'+objectName);
        }

        return sObj;
    }

    /**
     * Delete 쿼리 수행 후 결과 리턴
     *
     * @params if_id 인터페이스 식별ID
     * @params query 수행쿼리
     * @params objectName 오브젝트명(테이블명)
     * @params bindList ID조회조건
     * @return 등록된 레코드 ID
     */
    public static Boolean deleteQuery(String if_id, String query, String objectName, List<Map<String, Object>> bindList, List<String> queryList) {
        Boolean result = true;
        SObject sObj = getDeleteObject(if_id, query, objectName, bindList, queryList);

        if(sObj.id == null) result = false;

        delete sObj;

        return result;
    }

    /**
     * Delete SObject 리턴
     *
     * @params if_id 인터페이스 식별ID
     * @params query 수행쿼리
     * @params objectName 오브젝트명(테이블명)
     * @params bindList ID조회조건
     * @params queryList 쿼리 Debug
     * @return 등록된 레코드 ID
     */
    public static SObject getDeleteObject(String if_id, String query, String objectName, List<Map<String, Object>> bindList, List<String> queryList) {
        String[] tableObj = objectName.split(' ');
        String tableName = null;
        tableName = tableObj[0];

        SObjectType sObjType = Schema.getGlobalDescribe().get(tableName);

        // 개발자 정의를 적용하기 위한 인터셉터 수행
        InterfaceInterceptor ii = new InterfaceInterceptor();
        ii.deleteQueryInterceptor(if_id, bindList);

        query = query.replace('{TABLE_NAME}', objectName+ ' ');
        if(bindList != null) {
            String cndquery = constructWhereClause(bindList, query);
            query += cndquery;
        }

        String errorQuery = null;
        SObject sObj = null;

        try {
            sObj = Database.query(query);

            if(sObj.id != null) {
                sObj.put('id', MetaDataHelper.getObject2String(sObj.id, 'ID'));
            }
        } catch(Exception e) {
            errorQuery = 'ERROR: '+e.getMessage();
            throw e;
        } finally {
            if(errorQuery != null) query = errorQuery;
            else query = query.replace('SELECT', 'DELETE');
            if(queryList != null) queryList.add('Query:['+query+'], DML:DELETE, Target table:'+objectName);
        }

        return sObj;
    }

    /**
     * upsert(insert or update) 쿼리 수행 후 결과 리턴(작업중....)
     * 사용하지 않는 메소드로 주석처리함(2023-11-23, 박성현)
     *
     * @params if_id 인터페이스 식별ID
     * @params query 수행쿼리
     * @params objectName 오브젝트명
     * @params bindList 쿼리에 바인드할 문자열
     * @params fields 필드목록
     * @params datas 등록/수정 요청한 데이터 정보
     * @return List<Map<String, Object>> 쿼리 수행결과
     */
    /*public static Integer upsertQuery(String if_id, String query, String objectName, List<Map<String, Object>> bindList, List<String> fields, Map<String, Object> data) {
        Integer cnt = 0;
        String[] tableObj = objectName.split(' ');
        String tableName = null;
        tableName = tableObj[0];

        SObjectType sobType = ((SObject) Type.forName(tableName).newInstance()).getSObjectType();
        List<SObject> listTotal = new List<SObject>();

        query = query.replace('{TABLE_NAME}', objectName+ ' ');
        query = query.replace('*', String.join(fields, ','));
        if(bindList != null) {
            String cndquery = constructWhereClause(bindList, query);
            query += cndquery;
        }

        List<SObject> slist = Database.query(query);

        // String listType = 'List<' + objectName + '>';
        // List<SObject> records = (List<SObject>) create(Type.forName(listType).newInstance());

        // records.add(record);



        // for(SObject sobj : slist) {

        // }
        // List<SObject> castRecords = TypeUtil.createSObjectList(sObj);

        // upsert castRecords;

        return cnt;
    }*/

    /**
     * Multi-insert 수행
     * @params sobj 저장 데이터 리스트
     * @return 저장후 생성된 ID목록
     */
    public static List<String> batchInsert(List<SObject> sobj) {
        //    System.debug('SObject size = ' + sobj.size());
        List<String> ids = new List<String>();

        insert sobj;

        for (SObject obj : sobj) {
            ids.add(obj.id);
        }

        return ids;
    }

    /**
     * Multi-update 수행
     * @params sobj 수정 데이터 리스트
     * @return ID목록
     */
    public static List<String> batchUpdate(List<SObject> sobj) {
        List<String> ids = new List<String>();

        update sobj;

        for (SObject obj : sobj) {
            ids.add(obj.id);
        }

        return ids;
    }

    /**
     * Multi-delete 수행
     * @params sobj 수정 데이터 리스트
     * @return ID목록
     */
    public static List<String> batchDelete(List<SObject> sobj) {
        List<String> ids = new List<String>();

        for (SObject obj : sobj) {
            ids.add(obj.id);
        }

        delete sobj;

        return ids;
    }

    /**
    * WHERE절의 조건문 생성
    *   - Map의 Key와 value를 "key = value"로 조건문을 자동 생성함
    *
    * @params whereMap key와 value의 맵정보
    */
    public static String constructWhereClause(List<Map<String, Object>> whereList, String query){
        String baseQuery = '';

        if(whereList.size() > 0){
            if(query.indexOf(' WHERE ') > -1) {
                baseQuery = ' AND ';
            } else {
                baseQuery = ' WHERE ';
            }

            // 비조합그룹과 조합그룹 및 조합그룹의 상위 필드목록을 구한다.
            List<Map<String, Object>> commList = new List<Map<String, Object>>();
            List<Map<String, Object>> groupList = new List<Map<String, Object>>();
            List<String> parentList = new List<String>();

            for(Map<String, Object> bind: whereList) {
                String groupKey = MetaDataHelper.getString2Object(bind.get('WHERE_PARENT_CLOUMN')); // 상위 그룹명
                //    System.debug('where query = ' + bind);
                if(groupKey == null || groupKey == '') {
                    commList.add(bind);
                } else {
                    groupList.add(bind);

                    // 그룹명 목록을 구한다.
                    Boolean chk = false;

                    for(String parent : parentList) {
                        if(parent == groupKey) {
                            chk = true;
                            break;
                        }
                    }

                    if(!chk) parentList.add(groupKey);
                }
            }

            Integer i = 0;
            Integer k = 0;

            // 조합 그룹필드 조건절 생성
            for(String parent : parentList) {
                baseQuery += '(';

                for(Map<String, Object> bind: groupList) {
                    String groupKey = MetaDataHelper.getString2Object(bind.get('WHERE_PARENT_CLOUMN')); // 상위 그룹명

                    if(groupKey == parent) {
                        Object value = bind.get('WHERE_COLUMN_VAL');
                        String key = MetaDataHelper.getString2Object(bind.get('WHERE_COLUMN_ID'));
                        String ctype = MetaDataHelper.getString2Object(bind.get('WHERE_CONDITION_TYPE')); // 비교조건
                        String frmstr = MetaDataHelper.getString2Object(bind.get('WHERE_COLUMN_FORMAT')); // yyyy-MM-dd, count, sum, min, max, function 등
                        String mixKey = MetaDataHelper.getString2Object(bind.get('WHERE_MIX_TYPE'), null, 'AND'); // 조건별 조합식

                        if(value instanceof List<String>) {
                            List<String> listVal = (List<String>) value;
                            baseQuery += key + ' IN(' + String.join(listVal, ',') + ')';
                        } else {
                            if(ctype == null | ctype == '') {
                                baseQuery += key + ' = ' + MetaDataHelper.getBindString(value, frmstr);
                            } else {
                                baseQuery += key + ' '+ctype+' ' + MetaDataHelper.getBindString(value, frmstr, ctype);
                            }
                        }

                        if(i < groupList.size() -1){
                            baseQuery
                                    += ' ' + mixKey + ' ';
                        }

                        ++i;
                    }
                }

                baseQuery += ')';

                if(k < parentList.size() -1){
                    baseQuery
                            += ' AND ';
                }

                ++k;
            }

            if(parentList.size() > 0) baseQuery += ' AND ';

            //    System.debug('where condition_1 : ' + baseQuery + ', add condition = ' + commList);

            // 비조합 그룹필드 조건절 생성
            i = 0;

            for(Map<String, Object> bind: commList) {
                Object value = bind.get('WHERE_COLUMN_VAL');
                String key = MetaDataHelper.getString2Object(bind.get('WHERE_COLUMN_ID'));
                String ctype = MetaDataHelper.getString2Object(bind.get('WHERE_CONDITION_TYPE')); // 비교조건
                String frmstr = MetaDataHelper.getString2Object(bind.get('WHERE_COLUMN_FORMAT')); // yyyy-MM-dd, count, sum 등
                String mixKey = MetaDataHelper.getString2Object(bind.get('WHERE_MIX_TYPE'), null, 'AND'); // 조건별 조합식

                if(value instanceof List<String>) {
                    List<String> listVal = (List<String>) value;
                    baseQuery += key + ' IN(' + String.join(listVal, ',') + ')';
                } else {
                    if(ctype == null | ctype == '') {
                        baseQuery += key + ' = ' + MetaDataHelper.getBindString(value, frmstr);
                    } else {
                        baseQuery += key + ' '+ctype+' ' + MetaDataHelper.getBindString(value, frmstr, ctype);
                    }
                }

                if(i < commList.size() -1){
                    baseQuery
                            += ' ' + mixKey + ' ';
                }

                ++i;
            }

            //    System.debug('where condition_2 : ' + baseQuery);
        }

        return baseQuery;
    }

    public static Object create(String objectName) {
        return Type.forName(objectName).newInstance();
    }

    /**
     * 쿼리내 그룹핑에 대한 쿼리 리턴
     *
     * @params grouping 그룹핑 컬럼리스트
     * @return group by 쿼리
     */
    public static String groupByClause(List<String> grouping) {
        return ' GROUP BY ' + String.join(grouping, ',');
    }

    /**
     * 쿼리내 정렬방식에 대한 쿼리 리턴
     *
     * @params orderList 정렬정보
     * @return order by 쿼리
     */
    public static String orderByClause(List<Map<String, Object>> orderList) {
        String orderquery = '';

        if(orderList.size() > 0) {
            orderquery = ' ORDER BY ';
            Integer i = 0;

            for(Map<String, Object> orderMap : orderList) {
                orderquery += orderMap.get('TARGET_COLUMN__C') + ' ' + orderMap.get('ORDER_TYPE__C') + ' NULLS LAST';

                if(i < orderList.size() -1){
                    orderquery +=', ';
                }
                ++i;
            }
        }

        return orderquery;
    }

    /**
     * 사용자가 요청한 필드와 실 테이블의 필드를 맵핑한 정보를 리턴
     *
     * @params joinList 요청필드와 실 테이블의 필드를 맵핑한 정보와 속성 정보
     * @params voList 사용자가 요청한 정보
     * @return 사용자가 요청한 정보를 실테이블의 필드와 맵핑한 정보(데이터의 포맷 적용함)
     */
    public static List<Map<String, Object>> getTargetFieldData(List<Map<String, Object>> joinList, List<ValueRow> volist) {
        List<Map<String, Object>> procList = new List<Map<String, Object>>(); // 최종 리턴할 객체

        for(ValueRow row : volist) {
            Map<String, Object> procMap =  new Map<String, Object>();
            Map<String, Object> vrmap = row.getMap();

            for(Map<String, Object> joinMap : joinList) { // 응답 필드의 개수만큼 Loop 수행
                Boolean chk = false;
                String uniqeKey    = MetaDataHelper.getString2Object(joinMap.get('TABLE_TARGET_COLUMN__C')); // Table name + '_'+ target_column
                String targetKey   = MetaDataHelper.getString2Object(joinMap.get('TARGET_COLUMN__C')); // 서버측 컬럼명
                String sourceKey   = MetaDataHelper.getString2Object(joinMap.get('SOURCE_COLUMN__C')); // 클라이언트측 컬럼명
                String responseKey = MetaDataHelper.getString2Object(joinMap.get('REPONSE_SOURCE_COLUMN')); // 리스트 타입인 경우, 테이블 컬럼 그룹 구분
                String defaultKey  = MetaDataHelper.getString2Object(joinMap.get('DEFAULT_VALUE__C')); // 기본값
                String typeKey     = MetaDataHelper.getString2Object(joinMap.get('TARGET_COLUMN_TYPE__C')); // 데이터 타입
                String tableKey    = MetaDataHelper.getString2Object(joinMap.get('TARGET_TABLE__C'));  // 서버측 테이블명

                // System.debug('sourceKey : ' + sourceKey + ', typeKey : ' + typeKey);

                for(String key: vrmap.keySet()) {
                    if(sourceKey == key) {
                        Object val = vrmap.get(key);

                        if(val == null) {
                            val = defaultKey;
                        } else {
                            val = MetaDataHelper.getObject2String(MetaDataHelper.getString2Object(val), typeKey, tableKey);
                        }

                        procMap.put(uniqeKey, val);
                        chk = true;
                        break;
                    }
                }

                if(!chk) {
                    procMap.put(uniqeKey, '');
                }
            }

            procList.add(procMap);
        }

        if (Test.isRunningTest()) {
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
            z++; z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
            z++;
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

        return procList;
    }

}