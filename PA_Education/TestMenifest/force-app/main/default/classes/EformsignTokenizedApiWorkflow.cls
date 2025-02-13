/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-05-28     hs.jung          Create
*************************************************************************************/
public abstract class EformsignTokenizedApiWorkflow {
// 토큰 값을 저장할 변수
    protected EformsignToken__c token;
    protected EformsignApiRequestBuilder requestBuilder;
    protected HttpResponse response;

    // API 결과 반환 변수
    protected ApiResponse result;
    public class ApiResponse {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String message;
        @AuraEnabled public Object data;

        public ApiResponse(Boolean isSuccess, String message, Object data) {
            this.isSuccess = isSuccess;
            this.message = message;
            this.data = data;
        }

        // 성공 응답 생성 메소드
        public ApiResponse success(Object data) {
            return new ApiResponse(true, 'Success', data);
        }

        // 실패 응답 생성 메소드
        public ApiResponse failure(String message) {
            return new ApiResponse(false, message, null);
        }
    }

    // 템플릿 메소드
    public Object execute() {
        this.result = new ApiResponse(false, '', null);

        try {
            // 공통 초기 로직
            initiateLogic();
            System.debug('this.token' + this.token.AccessToken__c);
        } catch(Exception e) {
            System.debug('토큰 발급 실패');
            System.debug(e);
            this.result = this.result.failure('[' + e.getLineNumber() + ']' + e.getMessage());
        }

        if (this.token == null) {
            System.debug('토큰이 없으므로 종료');
            return result;
        }

        // 메인 로직
        System.debug('메인 로직 시작');
        try {
            this.response = sendRequest();
            if (shouldExecuteDatabaseLogic()) {
                databaseLogic();
            }

            if (shouldExecuteReserveLogic()) {
                reserveNextLogic();
            }

            // HttpResponse response = makeCallout();
            // if (isSuccess(response)) {
            //     if (isValidResponse(response)) {
            //         return ApiResponse.success(processSuccess(response));
            //     } else {
            //         return ApiResponse.failure(processInvalidResponse(response));
            //     }
            // } else {
            //     return ApiResponse.failure(handleFailure(response));
            // }
        } catch(Exception e) {
            System.debug('메인 로직 실패');
            System.debug(e);
            System.debug('Error: ' + e.getMessage());
            System.debug('Error: ' + e.getLineNumber());
            this.result = this.result.failure('[' + e.getLineNumber() + ']' + e.getMessage());
        } finally {
        }

        // 공통 마무리 로직
        finalLogic();
        System.debug('End All 부모' + this.result);

        return result;
    }

    // 공통 로직
    private void initiateLogic() {
        // 토큰 발급
        this.token = new EformsignTokenManager(createUserInfo()).getAccessTokenSObject();
        // Request Builder 생성
        this.requestBuilder = new EformsignApiRequestBuilder(this.token.AccessToken__c);
    }

    protected abstract EformsignUserInfoProvider.IUserInfoProvider createUserInfo();

    // 서브클래스에서 구현될 추상 메소드
    protected abstract HttpResponse sendRequest();
    // DML 실행 여부를 결정하는 메소드
    protected virtual Boolean shouldExecuteDatabaseLogic() {
        // 기본적으로 true 반환하거나, 특정 조건에 따라 false 반환할 수 있음
        return true;
    }
    protected abstract void databaseLogic();

    // reserveLogic 실행 여부를 결정하는 메소드
    protected virtual Boolean shouldExecuteReserveLogic() {
        // 기본적으로 false를 반환하거나, 특정 조건에 따라 true를 반환할 수 있음
        return false;
    }

    // 기본적으로 미실행이나, 특정 로직에 따라 실행될 수 있음
    protected virtual void reserveNextLogic() {}

    // 공통 마무리 로직
    private void finalLogic() {
        Map<String, Object> fieldMap = this.token.getPopulatedFieldsAsMap();
        // 토큰 신규발급 및 재발급 시에만 생성되는 필드로 upsert 수행을 판단
        Boolean sholdUpsert = fieldMap.containsKey('TokenIssuedDateTime__c');

        if (sholdUpsert) {
            // 토큰 저장 Future 메소드 실행
            EformsignTokenManager.upsertToken(JSON.serialize(this.token));
        }
    }
}