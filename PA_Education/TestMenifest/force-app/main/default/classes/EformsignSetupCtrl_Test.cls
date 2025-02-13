/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-06-26     hs.jung          Create
*************************************************************************************/
@isTest
public with sharing class EformsignSetupCtrl_Test {

    @isTest
    static void testSaveEnvironmentInfo() {
        // 테스트 케이스 준비: 모든 값이 null이 아닌 경우
        Map<String, String> testMap = new Map<String, String>{
                'apiKey' => 'value1'
                ,'privateKey' => 'value2'
                ,'companyId' => 'value3'
                ,'adminEmail' => 'value3'
        };

        // 메서드 실행 및 결과 검증
        EformsignSetupCtrl.saveEnvironmentInfo(testMap);
        EformsignEnvironment__c result = EformsignApiEnvironmentManager.getInfo();
        System.assertNotEquals(null, result, '정보 저장 실패');
    }

    @isTest
    static void testSaveEnvironmentInfoHasNull() {
        // 테스트 케이스 준비: 일부 값이 null인 경우
        Map<String, String> testMap = new Map<String, String>{
                'apiKey' => ''
                ,'privateKey' => 'value2'
                ,'companyId' => 'value3'
                ,'adminEmail' => 'value3'
        };

        // 커스텀 예외 유형을 확인하는 테스트
        Boolean exceptionOccurred = false;
        try{
            EformsignSetupCtrl.saveEnvironmentInfo(testMap);
        }catch (Exception e){
            //Set boolean to true to catch exception being thrown
            exceptionOccurred = true;
        }

        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }

    @isTest
    static void testSaveEnvironmentInfoEmptyMap() {
        // 테스트 케이스 준비: 비어 있는 맵
        Map<String, String> testMap = new Map<String, String>();

        // 커스텀 예외 유형을 확인하는 테스트
        Boolean exceptionOccurred = false;
        try{
            EformsignSetupCtrl.saveEnvironmentInfo(testMap);
        }catch (Exception e){
            //Set boolean to true to catch exception being thrown
            exceptionOccurred = true;
        }

        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }



    @isTest
    static void testBehavior() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        EformsignEnvironment__c defaultConfig = new EformsignEnvironment__c();
        defaultConfig.ApiKey__c = 'apiKey';
        defaultConfig.Privatekey__c = 'privateKey';
        defaultConfig.CompanyId__c = 'companyId';
        defaultConfig.RepresentativeAdminEmail__c = 'https://kr-api.eformsign.com';
        defaultConfig.ApiBaseUrl__c = 'https://kr-api.eformsign.com';

        insert defaultConfig;

        Test.startTest();
        EformsignSetupCtrl.checkEnvironmentInfo();
        EformsignSetupCtrl.getPermissionSets();
        EformsignSetupCtrl.getEnvironmentInfo();
        EformsignSetupCtrl.getEfsMembers();
        EformsignSetupCtrl.enrollEfsMember('mnh@naver.com', 'hs');
        EformsignSetupCtrl.deleteEfsMember('mnh@naver.com');
        Test.stopTest();
    }

    // Http response
    private static HttpResponse newResponse(Integer statusCode) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        response.setBody('[{}]');

        return response;
    }

    // StatusCode 200 Mock
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = newResponse(200);

            return response;
        }
    }

}