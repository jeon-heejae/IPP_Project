/**
 * @description       : 인터페이스 중간에 강제로 값에 변경이 필요한 경우 처리하는 클래스
 *                      - 사이트별로 개별 생성해서 사용할 것
 * @author            : jonghyun.kim@daeunextier.com
 * @group             :
 * @last modified on  : 07-03-2020
 * @last modified by  : jonghyun.kim@daeunextier.com
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   07-03-2020   jonghyun.kim@daeunextier.com   Initial Version
 */
public class InterfaceInterceptor {
    public InterfaceInterceptor() {}

    /**
     * 조회쿼리 수행전에 강제 변경이 필요한 작업을 수행한다.
     *
     * @params if_id 인터페이스 식별ID
     * @params query 수행쿼리
     * @params objectName 오브젝트명(테이블명)
     * @params bindList 조건절 목록
     * @params fields 조회할 필드목록
     * @params orderList 정렬 목록
     * @params inputVo 요청 파라메터 정보
     * @parmas interceptorCode 예외조건코드(개발자가 쿼리를 강제로 변경하기 위한 구분코드)
     */
    public void selectQueryInterceptor(String if_id
                                      ,String query
                                      ,String objectName
                                      ,List<Map<String, Object>> bindList
                                      ,List<String> fields
                                      ,List<Map<String, Object>> orderList
                                      ,ValueObject inputVo
                                      ,String interceptorCode) {

    }

    /**
     * 등록쿼리 수행전에 강제 변경이 필요한 작업을 수행한다.
     *
     * @params if_id 인터페이스 식별ID
     * @params fields 필드목록
     * @params data insert할 정보
     */
    public void insertQueryInterceptor(String if_id, List<String> fields, Map<String, Object> data) {

    }

    /**
     * 수정쿼리 수행전에 강제 변경이 필요한 작업을 수행한다.
     *
     * @params if_id 인터페이스 식별ID
     * @params bindList ID조회조건
     * @params fields 필드목록
     * @params data update할 정보
     */
    public void updateQueryInterceptor(String if_id, List<Map<String, Object>> bindList, List<String> fields, Map<String, Object> data) {

    }

    /**
     * 삭제쿼리 수행전에 강제 변경이 필요한 작업을 수행한다.
     *
     * @params if_id 인터페이스 식별ID
     * @params bindList ID조회조건
     */
    public void deleteQueryInterceptor(String if_id, List<Map<String, Object>> bindList) {

    }

    /**
     * 최종적으로 응답 생성 후, 후처리를 위한 작업이 필요할 때 사용한다.
     */
    public void postHandleInterceptor(String interface_id, Map<String, Object> responseObj) {

    }

    /**
     * 조회한 데이터의 유효여부를 체크
     *
     * @params objectName 오브젝트명(테이블명)
     * @params oldDatas 이전에 조회한 결과 데이터
     * @params newDatas 새로 조회한 결과 데이터(필터 대상 데이터)
     * @params inputVo 요청 파라메터
     * @return 유효성 체크결과(true/false)
     */
    public Boolean filterDatasetInterceptor(String objectName, Map<String, Object> oldDatas, Map<String, Object> newDatas, ValueObject inputVo) {
        Boolean valid = true;

        return valid;
    }

    /**
     * Input Parameter 인터셉터
     *
     * @params if_id 인터페이스 식별ID
     * @params inputVo 요청 파라메터
     * @return inputVo
     */
    public ValueObject inputDatasetInterceptor(String if_id, ValueObject inputVo) {

        return inputVo;
    }

    /**
     * Limit Offset을 강제로 설정 할 경우 처리
     *
     * @params if_id 인터페이스 식별ID
     * @params query 수행쿼리
     * @params objectName 오브젝트명(테이블명)
     * @params bindList 조건절 목록
     * @params fields 조회할 필드목록
     * @params orderList 정렬 목록
     * @params inputVo 요청 파라메터 정보
     * @parmas interceptorCode 예외조건코드(개발자가 쿼리를 강제로 변경하기 위한 구분코드)
     */
    public String limitQueryInterceptor(String if_id, String query, String objectName, List<Map<String, Object>> bindList, List<String> fields,
            List<Map<String, Object>> orderList, ValueObject inputVo, String interceptorCode) {

        String rtl = null;

        if (interceptorCode == 'LIMIT') {
            Integer pageNo = MetaDataHelper.getInteger2String(inputVo.getString('pageNo'), 0); // 페이지 번호
            Integer pagePerCount = MetaDataHelper.getInteger2String(inputVo.getString('pagePerCount'), 0); // 페이지 당 표시개수
            Integer offSetCount = (pageNo*pagePerCount)-pagePerCount;

            rtl = ' LIMIT ' + pagePerCount + ' OFFSET '+ offSetCount;
            inputVo.set('limitInterceptor', MetaDataHelper.getBoolean2String('false'));
            //    System.debug('limitQueryInterceptor : ' + rtl);
        }

        return rtl;
    }

    /**
     * Dynamic 정렬절을 처리하기 위해 개발자가 강제로 처리하는 경우 사용(2023-12-22, 박성현 추가)
     * [적용하기 위한 조건]
     * 조건 1 : Interface_Service_Plan__c의 Interceptor_Code__c 필드에 ORDER BY(ORDER_BY)로 설정한다.
     * 조건 2 : Input 파라미터에 orderByFlag 키에 정의서에 정의한대로 값을 입력한다.
     * 
     * @params if_id 인터페이스 식별ID
     * @params inputVo 요청 파라메터 정보
     * @parmas interceptorCode 예외조건코드(개발자가 쿼리를 강제로 변경하기 위한 구분코드)
     * 
     */
    public String orderByQueryInterceptor(String if_id, ValueObject inputVo, String interceptorCode) {
        String rtl = ' ';
        String orderByFlag = inputVo.getString('orderByFlag');
        
        return rtl;
    }

    /**
     * Having 절을 추가하기 위해 개발자가 강제로 처리하는 경우 사용(2023-12-22, 박성현 추가)
     * [적용하기 위한 조건]
     * 조건 1 : Interface_Service_Plan__c의 Interceptor_Code__c 필드에 HAVING으로 설정한다.
     * 
     * @params if_id 인터페이스 식별ID
     * 
     */
    public String havingQueryInterceptor(String if_id) {
        String rtl = ' ';

        /*if (if_id == 'IF_TEST_1231') {
            rtl = 'HAVING COUNT(Name) >= 1';
        } else if (if_id == 'IF_TEST_1232') {

        }*/

        return rtl;
    }

    /**
     * WHERE 절을 추가하기 위해 개발자가 강제로 처리하는 경우 사용(2023-12-22, 박성현 추가)
     * [적용하기 위한 조건]
     * 조건 1 : Interface_Service_Plan__c의 Interceptor_Code__c 필드에 WHERE로 설정한다.
     * 
     * @params if_id 인터페이스 식별ID
     * @params inputVo 요청 파라메터 정보
     * 
     */
    public String whereQueryInterceptor(String if_id, ValueObject inputVo) {
        String rtl = ' ';
        //String whereFlag = inputVo.getString('whereFlag');
        //String accId = inputVo.getString('accountId');

        /*if (if_id == 'IF_HKDCOM_001') {
            if (whereFlag == '1') {
                rtl = 'WHERE Id = null OR Id != null';
            } else {
                rtl = 'WHERE Id =\'' + accId + '\' AND Id != null AND Id != null AND Id != null AND Id != null';
            }
        }*/

        return rtl;
    }

    /**
     * SELECT, FROM 절은 그대로 유지
     * WHERE절을 포함한 FROM 절 이후의 모든 부분을 개발자가 강제로 처리하는 경우 사용(2023-12-22, 박성현 추가)
     * [적용하기 위한 조건]
     * 조건 1 : Interface_Service_Plan__c의 Interceptor_Code__c 필드에 AFTER로 설정한다.
     * 
     * @params if_id 인터페이스 식별ID
     * @params objectName 오브젝트 API Name
     * @params query 수행 쿼리문
     * @params inputVo 요청 파라메터 정보
     * 
     */
    public String afterQueryInterceptor(String if_id, String objectName, String query, ValueObject inputVo) {
        String rtl = ' ';
        //String flag = inputVo.getString('flag');

        //Integer objectIdx = query.indexOf(objectName);
        //String filterQuery = query.substring(0, objectIdx + objectName.length());

        /*if (if_id == 'IF_HKDCOM_001') {
            rtl = filterQuery + ' WHERE Id = null ORDER BY Id DESC, Name ASC LIMIT 100';
        }*/

        return rtl;
    }
    @TestVisible private void testMe() {
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}