/**
 * @description       : 데이터 유틸 클래스
 * @author            : jonghyun.kim@daeunextier.com
 * @group             :
 * @last modified on  : 07-03-2020
 * @last modified by  : jonghyun.kim@daeunextier.com
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   07-03-2020   jonghyun.kim@daeunextier.com   Initial Version
**/
public class MetaDataHelper {

    public MetaDataHelper() {}

    /**
     * Query에 바인드할 구문을 생성
     *   - Oject 타입에 따라 binding할 조건을 생성함
     *
     * @params obj value
     * @params frmstr 형식
     * @return String
     */
    public static String getBindString(Object obj, String frmstr) {

        return getBindString(obj, frmstr, '=');
    }

    /**
     * 조건절에 바인드할 쿼리 조건값을 생성
     *   - Oject 타입에 따라 binding할 조건을 생성함
     *
     * @params obj value
     * @params frmstr 형식(yyyy-MM-dd, count, sum 등)
     * @params condition 비교조건(=, >, <, LIKE, IN 등)
     * @return String
     */
    public static String getBindString(Object obj, String frmstr, String condition) {
        String param = null;

        //    System.debug('param = ' + param);

        if(obj == null || obj == '') param = null;
        else if(obj instanceof SObject)            param = '\''+((SObject)obj).getSObjectType().getDescribe().getName()+'\'';
        else if(obj instanceof Boolean)            param = String.valueOf(obj).toLowerCase(); // Completed
        else if(obj instanceof Id) {
            String str = String.valueOf(obj);

            if(str.toUpperCase() == 'NULL' && (frmstr == null || frmstr == '')) param = null;
            else {
                if(condition == 'LIKE') {
                    param = '\'%'+str+'%\'';
                } else if(condition == 'IN' || condition == 'NOT IN' || condition == 'INCLUDES') {
                    String[] strAry = str.split(',');

                    param = '(\''+String.join(strAry, '\',\'')+'\')';
                } else {
                    param = '\''+str+'\'';
                }
            }
        }
        else if(obj instanceof String) {
            String str = String.valueOf(obj);

            if(str.toUpperCase() == 'NULL' && (frmstr == null || frmstr == '')) {
                param = null;
            } else if(str.toUpperCase().startsWith('THIS_') && str.toUpperCase().endsWith('()')) { // SOQL 지원함수 적용을 위해 추가(2020.09.07)
                param = str.replace('(', '').replace(')', '');
            } else if (str.toUpperCase().startsWith('LAST_') && str.toUpperCase().endsWith('()')) { // 박성현 추가.(2022-04-18)
                param = str.replace('(', '').replace(')', '');
            } else if (str.toUpperCase().startsWith('NEXT_') && str.toUpperCase().endsWith('()')) { // 박성현 추가.(2022-04-18)
                param = str.replace('(', '').replace(')', '');
            } else {
                if(condition == 'LIKE') {
                    param = '\'%'+str+'%\'';
                } else if(condition == 'IN' || condition == 'NOT IN' || condition == 'INCLUDES') {
                    String[] strAry = str.split(',');

                    param = '(\''+String.join(strAry, '\',\'')+'\')';
                } else {
                    param = '\''+str+'\'';
                }
            }
        }
        else if(obj instanceof Blob)               param = ':'+String.valueOf(obj);
        else if(obj instanceof Date) { // Completed
            Datetime output = (Date) obj;

            if(frmstr == null) frmstr = 'yyyy-MM-dd';
            param = output.format(frmstr);
        }
        else if(obj instanceof Datetime) {
            Datetime output = (Datetime) obj;

            if(frmstr == null) frmstr = 'yyyy-MM-dd hh:mm:ss';
            param = output.format(frmstr);
        }
        else if(obj instanceof Time) {
            Datetime output = null;

            try {
                output = (Datetime) obj;
            } catch(Exception e) {
                output = Datetime.valueOf('2000-01-01 '+ String.valueof(obj));
            }

            if(frmstr == null) frmstr = 'hh:mm:ss';
            param = output.format(frmstr);
        }
        else if(obj instanceof Integer)            param = String.valueOf(obj);
        else if(obj instanceof Long)               param = String.valueOf(obj);
        else if(obj instanceof Decimal)            param = String.valueOf(obj);
        else if(obj instanceof Double)             param = String.valueOf(obj);
        else if(obj instanceof List<object>)       param = ':'+String.valueOf(obj);
        else param = '\''+String.valueOf(obj)+'\'';

        //    System.debug('param = ' + param);

        return param;
    }

    /**
     * 문자열을 Datatype에 맞게 변경한 객체를 리턴한다.
     *
     * @params str 변경할 문자열
     * @parmas type 변경할 타입
     * @return Object
     */
    public static Object getObject2String(String str, String type) {
        return getObject2String(str, type, null);
    }

    /**
     * 문자열을 Datatype에 맞게 변경한 객체를 리턴한다.
     *
     * @params str 변경할 문자열
     * @parmas type 변경할 타입
     * @params sojb Object api name
     * @return Object
     */
    public static Object getObject2String(String str, String type, String sojb) {
        Object obj = null;

        if(str == null || str == '') return null;

        if(type == null || type == '') obj = str; 
        else if(type.toUpperCase() == 'STRING')       obj = str;
        else if(type.toUpperCase() == 'BOOLEAN')      obj = getBoolean2String(str);
        else if(type.toUpperCase() == 'ID')           obj = getId2String(str); 
        else if(type.toUpperCase() == 'BLOB')         obj = getBlod2String(str);
        else if(type.toUpperCase() == 'INTEGER')      obj = getInteger2String(str);
        else if(type.toUpperCase() == 'LONG')         obj = getLong2String(str);
        else if(type.toUpperCase() == 'DECIMAL')      obj = getDecimal2String(str);
        else if(type.toUpperCase() == 'DECIMALGROUP') obj = getDecimalGroup2String(str);
        else if(type.toUpperCase() == 'NUMBER')       obj = getDecimal2String(str);
        else if(type.toUpperCase() == 'DOUBLE')       obj = getDouble2String(str);
        else if(type.toUpperCase() == 'RECORD')       obj = MetaDataHelper.recordTypeIdByDevName(sojb, str);
        else if(type.toUpperCase() == 'DATE') {
            // System.debug('str : ' + str + ' type : ' + type + ' sojb :' + sojb);
            if(str.toUpperCase().startsWith('THIS_') && str.toUpperCase().endsWith('()')) { // SOQL 지원함수 적용을 위해 추가(2020.09.07)
                obj = str;
            } else if (str.toUpperCase().startsWith('LAST_') && str.toUpperCase().endsWith('()')) { // 박성현 추가.(2022-04-18)
                obj = str;
            } else if (str.toUpperCase().startsWith('NEXT_') && str.toUpperCase().endsWith('()')) { // 박성현 추가.(2022-04-18)
                obj = str;
            } else {
                obj = getDate2String(str);
            }
        } else if(type.toUpperCase() == 'DATETIME') {
            if(str.toUpperCase().startsWith('THIS_') && str.toUpperCase().endsWith('()')) { // SOQL 지원함수 적용을 위해 추가(2020.09.07)
                obj = str.replace('(', '').replace(')', '');
            } else if (str.toUpperCase().startsWith('LAST_') && str.toUpperCase().endsWith('()')) { // 박성현 추가.(2022-04-18)
                obj = str.replace('(', '').replace(')', '');
            } else if (str.toUpperCase().startsWith('NEXT_') && str.toUpperCase().endsWith('()')) { // 박성현 추가.(2022-04-18)
                obj = str.replace('(', '').replace(')', '');
            } else {
                obj = getDatetime2String(str);
            }
        } else {
            obj = str;
        }

        return obj;
    }

    /**
     * 문자열을 Boolean으로 변경해서 리턴한다.
     *
     * @params str 변경할 문자열
     * @return Boolean Object
     */
    public static Boolean getBoolean2String(String str) {
        if (str == 'null') return null;
        return Boolean.valueOf(str);
    }

    /**
     * 문자열을 Id로 변경해서 리턴한다.
     *
     * @params str 변경할 문자열
     * @return Id Object
     */
    public static Id getId2String(String str) {
        return Id.valueOf(str);
    }

    /**
     * 문자열을 Blob으로 변경해서 리턴한다.
     *
     * @params str 변경할 문자열
     * @return Blob Object
     */
    public static Blob getBlod2String(String str) {
        return Blob.valueOf(str);
    }

    /**
     * 문자열을 Date로 변경해서 리턴한다.
     *
     * @params str 변경할 문자열
     * @return Date Object
     */
    public static Date getDate2String(String str) {
        System.debug('getDate2String str : ' + str);

        if(str.toUpperCase() == 'TODAY()') {
            str = getString2Object(Date.today(), null);
        } else if(str.toUpperCase() == 'YESTERDAY()') {
            str = getString2Object(Date.today().addDays(-1), null);
        } else if(str.toUpperCase() == 'TOMORROW()') {
            str = getString2Object(Date.today().addDays(1), null);
        } else if(str.toUpperCase() == 'TOSTARTOFWEEK()') {
            // 사용자의 LOCALE에 따라 호출한 날을 기준으로 그 주의 첫 일자를 가져온다.
            str = getString2Object(Date.today().toStartOfWeek(), null);
        } else if(str.toUpperCase() == 'TOENDOFWEEK()') {
            //  사용자의 LOCALE에 따라 호출한 날을 기준으로 그 주의 마지막 일자를 가져온다.
            str = getString2Object(Date.today().toStartOfWeek().addDays(6), null);
        } else if(str.toUpperCase() == 'TOSTARTOFMONTH()') {
            // 호출한 날을 기준으로 그 달의 첫 일자를 가져온다.
            str = getString2Object(Date.today().toStartOfMonth(), null);
        } else if(str.toUpperCase() == 'TOENDOFMONTH()') {
            //  호출한 날을 기준으로 그 달의 마지막 일자를 가져온다.
            str = getString2Object(Date.today().toStartOfMonth().addMonths(1).addDays(-1), null);
        } else if(str.toUpperCase().startsWith('LAST_N_DAYS')) {
            Date td = Date.today();
            Integer addDays = Integer.valueOf(str.substring(str.indexOf(':')+1));
            td = td.addDays(-addDays);
            str = getString2Object(td, null);
        } else if (str.length() == 8) {
            // 20231107 -> 2023-11-07
            String inputString = str;
            str = inputString.substring(0, 4) + '-' + inputString.substring(4, 6) + '-' + inputString.substring(6, 8);
        } else {
            // 2023.11.07 -> 2023-11-07
            str = str.replace('.', '-');
        }

        Date resultDate = null;
        resultDate = Date.valueOf(str);

        // Date 타입 최대 입력 날짜 : 4000-12-31 (2023-11-07)
        Date maxDate = Date.valueOf('4000-12-31');
        if (resultDate > maxDate) {
            resultDate = maxDate;
        }

        // Date 타입 최소 입력 날짜 : 1700-01-01 (2024-02-06)
        Date minDate = Date.valueOf('1700-01-01');
        if (resultDate < minDate) {
            resultDate = minDate;
        }

        return resultDate;
    }

    /**
     * 문자열을 Datetime으로 변경해서 리턴한다.
     *
     * @params str 변경할 문자열
     * @return Datetime Object
     */
    public static Datetime getDatetime2String(String str) {
        if(str.toUpperCase() == 'TODAY()') {
            Date td = Date.today();
            str = getString2Object(Datetime.newInstance(td.year(), td.month(), td.day()), null);
        } else if(str.toUpperCase() == 'NOW()') {
            Datetime td = Datetime.now();
            td = td.addHours(-9); // DB 일자(UTC)와 동일 시
            str = getString2Object(Datetime.newInstance(td.year(), td.month(), td.day(), td.hour(), td.minute(), td.second()), null);
        } else if(str.toUpperCase() == 'YESTERDAY()') { // 박성현 추가(2022-04-18)
            Date td = Date.today().addDays(-1);
            str = getString2Object(Datetime.newInstance(td.year(), td.month(), td.day()), null);
        } else if(str.toUpperCase() == 'TOMORROW()') { // 박성현 추가(2022-04-18)
            Date td = Date.today().addDays(1);
            str = getString2Object(Datetime.newInstance(td.year(), td.month(), td.day()), null);
        } else if(str.toUpperCase().startsWith('LAST_N_DAYS')) {
            Datetime td = Datetime.now();
            Integer addDays = Integer.valueOf(str.substring(str.indexOf(':')+1));
            //    System.debug('==========> ' + addDays);
            td = td.addDays(-addDays);
            //    System.debug('==========> ' + td);
            str = getString2Object(td, null);
        } else {
            str = str.replace('.', '-');
        }

        Datetime resultDatetime = null;
        resultDatetime = Datetime.valueOf(str);

        // Datetime 타입 최대 입력 날짜 : 4000-12-31T23:59:59.999Z (2023-11-07)
        Datetime maxDatetime = Datetime.newInstance(4000, 12, 31, 23, 59, 59);
        if (resultDatetime > maxDatetime) {
            resultDatetime = maxDatetime;
        }

        // Datetime 타입 최소 입력 날짜 : 1700-01-01T00:00:00Z (2024-02-06)
        Datetime minDatetime = Datetime.newInstance(1700, 01, 01, 00, 00, 00);
        if (resultDatetime < minDatetime) {
            resultDatetime = minDatetime;
        }

        return resultDatetime;
    }

    /**
     * 문자열을 Datetime으로 변경해서 리턴한다.
     *
     * @params str 변경할 문자열
     * @return Integer 변경할 문자가 null인 경우 0으로 리턴
     */
    public static Integer getInteger2String(String str) {
        if(str == null || str == '') return null;
        return Integer.valueOf(str);
    }

    /**
     * 문자열을 Datetime으로 변경해서 리턴한다.
     *
     * @params str 변경할 문자열
     * @return Integer 변경할 문자가 null인 경우 0으로 리턴
     */
    public static Integer getInteger2String(String str, Integer def) {
        if(str == null || str == '') return def;
        return Integer.valueOf(str);
    }

    /**
     * 문자열을 Long으로 변경해서 리턴한다.
     *
     * @params str 변경할 문자열
     * @return Long 변경할 문자가 null인 경우 0으로 리턴
     */
    public static Long getLong2String(String str) {
        if(str == null || str == '') return null;
        return Long.valueOf(str);
    }

    /**
     * 문자열을 Long으로 변경해서 리턴한다.
     *
     * @params str 변경할 문자열
     * @return Long 변경할 문자가 null인 경우 0으로 리턴
     */
    public static Long getLong2String(String str, Long def) {
        if(str == null || str == '') return def;
        return Long.valueOf(str);
    }

    /**
     * 문자열을 Decimal로 변경해서 리턴한다.
     *
     * @params str 변경할 문자열
     * @return Decimal 변경할 문자가 null인 경우 0으로 리턴
     */
    public static Decimal getDecimal2String(String str) {
        if(str == null || str == '') return null;
        return Decimal.valueOf(str);
    }

    /**
     * 문자열을 Decimal로 변경해서 리턴한다.
     *
     * @params str 변경할 문자열
     * @return Decimal 변경할 문자가 null인 경우 0으로 리턴
     */
    public static Decimal getDecimal2String(String str, Decimal def) {
        if(str == null || str == '') return def;
        return Decimal.valueOf(str);
    }

    /**
     * 문자열을 DecimalGroup로 변경해서 리턴한다.
     * GROUP BY 절의 SUM 값이 8자리 이상인 경우 지수로 출력 되는 경우 사용
     * @params str 변경할 문자열
     * @return Decimal 변경할 문자가 null인 경우 0으로 리턴
     */
    public static Decimal getDecimalGroup2String(String str) {
        if(str == null || str == '') return null;
        return Decimal.valueOf(str) + 1 -1;
    }

    /**
     * 문자열을 Decimal로 변경해서 리턴한다.
     *
     * @params str 변경할 문자열
     * @return Decimal 변경할 문자가 null인 경우 0으로 리턴
     */
    public static Decimal getDecimalGroup2String(String str, Decimal def) {
        if(str == null || str == '') return def;
        return Decimal.valueOf(str) + 1 -1;
    }

    /**
     * 문자열을 Double로 변경해서 리턴한다.
     *
     * @params str 변경할 문자열
     * @return Double 변경할 문자가 null인 경우 0으로 리턴
     */
    public static Double getDouble2String(String str) {
        if (str == 'null') return null; // 파라미터에 "null"로 넣을 경우, double 타입 필드도 null 처리(2023-11-07 박성현 추가)
        if(str == null || str == '') return null;
        return Double.valueOf(str);
    }

    /**
     * 문자열을 Double로 변경해서 리턴한다.
     *
     * @params str 변경할 문자열
     * @return Double 변경할 문자가 null인 경우 0으로 리턴
     */
    public static Double getDouble2String(String str, Double def) {
        if(str == null || str == '') return def;
        return Double.valueOf(str);
    }

    /**
     * 객체를 지정된 타입에 맞게 문자열로 변경한 후 리턴한다.
     *
     * @params obj 변경할 객체
     * @return String 문자열
     */
    public static String getString2Object(Object obj) {
        return getString2Object(obj, null);
    }

    /**
     * 객체를 지정된 타입에 맞게 문자열로 변경한 후 리턴한다.
     *
     * @params obj 변경할 객체
     * @params frmstr 포맷
     * @return String 문자열
     */
    public static String getString2Object(Object obj, String frmstr) {
        return getString2Object(obj, frmstr, null);
    }

    /**
     * 객체를 지정된 타입에 맞게 문자열로 변경한 후 리턴한다.
     *
     * @params obj 변경할 객체
     * @params frmstr 포맷
     * @params defaultVal obj 값이 없는 경우 리터할 객체값
     * @return String 문자열
     */
    public static String getString2Object(Object obj, String frmstr, Object defaultVal) {
        String param = null;
        // System.debug('obj : ' + obj + ', frmstr : ' + frmstr + ', defaultVal : ' + defaultVal);

        if(obj == null && defaultVal != null) obj = defaultVal;

        try {
            if(obj == null) param = '';
            else if(obj instanceof String)       param = String.valueOf(obj); // Completed
            else if(obj instanceof SObject)      param = ((SObject)obj).getSObjectType().getDescribe().getName();
            else if(obj instanceof Boolean)      param = String.valueOf(obj).toLowerCase();
            else if(obj instanceof Id)           param = String.valueOf(obj);
            else if(obj instanceof Integer)      param = String.valueOf(obj);
            else if(obj instanceof Long)         param = String.valueOf(obj);
            else if(obj instanceof Decimal)      param = String.valueOf(obj);
            else if(obj instanceof Double)       param = String.valueOf(obj);
            else if(obj instanceof List<object>) param = String.valueOf(obj);
            else if(obj instanceof Blob)         param = String.valueOf(obj);
            else if(obj instanceof Date) {
                Datetime output = (Date) obj;
                if(frmstr == null || frmstr == '') frmstr = 'yyyy-MM-dd';
                param = output.format(frmstr);
            }
            else if(obj instanceof Datetime) {
                Datetime output = (Datetime) obj;
                if(frmstr == null || frmstr == '') frmstr = 'yyyy-MM-dd HH:mm:ss';
                param = output.format(frmstr);
            }
            else if(obj instanceof Time) {
                Datetime output = null;

                try {
                    output = (Datetime) obj;
                } catch(Exception e) {
                    output = Datetime.valueOf('2000-01-01 '+ String.valueof(obj));
                }

                if(frmstr == null || frmstr == '') frmstr = 'HH:mm:ss';
                param = output.format(frmstr);
            }
            else param = String.valueOf(obj);
        } catch(Exception e) {
            param = e.getMessage();
            System.debug('param : ' + param);
        }

        return param;
    }


    /**
     * 문자열과 데이터 타입이 일치하는지 확인 한후 오류가 있는 경우에 에러를 리턴한다.
     *
     * @params obj 확인할 문자열
     * @params type 확인할 데이터 타입
     * @return String 에러 또는 null
     */
    public static String isValidaton2Object(String str, String type) {
        String param = null;

        try {
            if(type.toUpperCase() == 'BOOLEAN')       Boolean.valueOf(str);
            else if(type.toUpperCase() == 'ID')       Id.valueOf(str);
            else if(type.toUpperCase() == 'BLOB')     Blob.valueOf(str);
            else if(type.toUpperCase() == 'DATE')     Date.valueOf(str);
            else if(type.toUpperCase() == 'DATETIME') Datetime.valueOf(str);
            else if(type.toUpperCase() == 'INTEGER')  Integer.valueOf(str);
            else if(type.toUpperCase() == 'LONG')     Long.valueOf(str);
            else if(type.toUpperCase() == 'DECIMAL')  Decimal.valueOf(str);
            else if(type.toUpperCase() == 'DOUBLE')   Double.valueOf(str);
        } catch(Exception e) {
            param = e.getMessage();
        }

        return param;
    }

    /**
     * 레코드 타입의 ID를 구해서 리턴
     *
     * @params objAPIName 오브젝트명(테이블명)
     * @params recTypeName 레코드 타입명(조회할 값)
     * @return 레코드 ID
     */
    public static Id recordTypeIdByName(string objAPIName, string recTypeName) {
        Id recTypeId;

        if(String.isNotBlank(objAPIName) && String.isNotBlank(recTypeName)) {
            recTypeId= Schema.getGlobalDescribe().get(objAPIName).getDescribe().getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
        }

        return recTypeId;
    }

    /**
     * 레코드 개발 타입의 ID를 구해서 리턴
     *
     * @params objAPIName 오브젝트명(테이블명)
     * @params recTypeDevName 레코드 타입 개발명(조회할 값)
     * @return 레코드 ID
     */
    public static Id recordTypeIdByDevName(string objAPIName, string recTypeDevName) {
        Id recTypeId;

        if(String.isNotBlank(objAPIName) && String.isNotBlank(recTypeDevName)) {
            recTypeId= Schema.getGlobalDescribe().get(objAPIName).getDescribe().getRecordTypeInfosByDeveloperName().get(recTypeDevName).getRecordTypeId();
        }

        return recTypeId;
    }

    /**
     * 모든 레코드 타입을 구해서 리턴
     *
     * @params objAPIName 오브젝트명(테이블명)
     * @return 레코드 명과 키을 포함한 Map정보
     */
    public static Map<String,Id> recordTypeMap(string objAPIName) {
        Map<String, Id> recTypeNameIdMap = new Map<String,Id>();

        if(String.isNotBlank(objAPIName)){
            for(Schema.RecordTypeInfo recInfo : Schema.getGlobalDescribe().get(objAPIName).getDescribe().getRecordTypeInfosByName().values()){
                recTypeNameIdMap.put(recInfo.getName(),recInfo.getRecordTypeId());
            }
        }

        return recTypeNameIdMap;
    }

    /**
     * 레코드 타입 또는 레코드 개발 타입을 가지고 있는 문자열 리턴
     *
     * @params recordType 레코드 타입명(조회할 값)
     * @return 문자열
     */
    public static string getRecordTypeInfoByIdOrDeveloperName(String recordType) {
        string returnValue = '';
        Boolean isValidId = recordType instanceOf Id;

        for(Schema.SObjectType objType : Schema.getGlobalDescribe().Values()){
            Schema.DescribeSObjectResult doResult = objType.getDescribe(SObjectDescribeOptions.DEFERRED);

            if(isValidId){
                if(doResult.getRecordTypeInfosById().get(recordType) != null){
                    returnValue = doResult.getRecordTypeInfosById().get(recordType).getDeveloperName();
                    break;
                }
            }else{
                if(doResult.getRecordTypeInfosByDeveloperName().get(recordType) != null){
                    returnValue = doResult.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
                    break;
                }
            }
        }

        return returnValue;
    }

    /**
     * Map내에서 대소문자 구분없이 Key명칭에 해당하는 Object를 리턴
     * @params map 검색할 Map
     * @params key 비교할 key 정보
     * @return key와 매칭된 Object
     */
    public static Object getUpperKeyToMap(Map<String, Object> data, String key) {
        Object rstObj = null;

        for(String mkey: data.keySet()) { // 조회결과
            if(key.toUpperCase() == mkey.toUpperCase()) {
                rstObj = data.get(mkey);

                break;
            }
        }

        return rstObj;
    }

    /**
     * SOQL 함수를 적용한 필드인 경우, 함수를 포함한 필드명을 보냄
     * @params field 필드명
     * @params type 필드 데이터 타입
     * @params format SOQL 적용 함수(MIN, MAX, COUNT, SUM 등)
     * @params soqlType 쿼리문 타입(select, where, group, order)
     * @return 필드명
     */
    public static String changeFieldForFuntion(String field, String type, String format, String soqlType) {
        String qyfield = null;

        if(format != null && format != '') {
            if(format.endsWith('()')) { // 함수을 걸 대상 필드 적용해야 하는 것으로 인식
                if(soqlType == 'field') {
                    qyfield = field;
                } else if(soqlType == 'select') {
                    qyfield = format.replace('()', '')+'('+field+') '+field;
                } else {
                    qyfield = format.replace('()', '')+'('+field+')';
                }
            } else { // 함수내 대상 필드를 미리 지정한 경우로 인식
                if(soqlType == 'field') {
                    qyfield = format;
                } else if(soqlType == 'select') {
                    qyfield = format+' '+field;
                } else {
                    qyfield = format;
                }
            }
        } else {
            qyfield = field;
        }

        return qyfield;
    }

}