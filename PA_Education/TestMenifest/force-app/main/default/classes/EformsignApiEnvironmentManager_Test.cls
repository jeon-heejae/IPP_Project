/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-06-26     hs.jung          Create
*************************************************************************************/
@isTest
public with sharing class EformsignApiEnvironmentManager_Test {
    static final String BASE_URL = 'https://kr-api.eformsign.com';

    static void insertEformsignEnvironment() {

        EformsignEnvironment__c defaultConfig = new EformsignEnvironment__c();
        defaultConfig.ApiKey__c = 'apiKey';
        defaultConfig.Privatekey__c = 'privateKey';
        defaultConfig.CompanyId__c = 'companyId';
        defaultConfig.RepresentativeAdminEmail__c = BASE_URL;
        defaultConfig.ApiBaseUrl__c = 'https://kr-api.eformsign.com';

        insert defaultConfig;
    }

    @isTest
    static void testGetEmbadingEnvInfoJson() {
        insertEformsignEnvironment();

        String result = EformsignApiEnvironmentManager.getEmbadingEnvInfoJson();
        System.assertNotEquals(null, result, '정보 취득 실패');
    }

    @isTest
    static void testUpdateBaseUrlNoChange() {
        insertEformsignEnvironment();

        // Mock HttpResponse 객체 설정
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setBody('{"api_key": {"company": {"api_url": "' + BASE_URL + '"}}}');
        mockResponse.setStatusCode(200);

        // updateBaseUrl 메서드 테스트
        Test.startTest();
        EformsignApiEnvironmentManager.updateBaseUrl(mockResponse); // 여기서 YourClassName는 해당 메서드가 포함된 클래스 이름입니다.
        Test.stopTest();

        // 결과 검증
        EformsignEnvironment__c result = EformsignApiEnvironmentManager.getInfo();
        System.assertEquals(BASE_URL, result.ApiBaseUrl__c, '정보 저장 실패');
    }

    @isTest
    static void testUpdateBaseUrl() {
        insertEformsignEnvironment();

        String baseUrl = BASE_URL + 'test';
        // Mock HttpResponse 객체 설정
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setBody('{"api_key": {"company": {"api_url": "' + baseUrl + '"}}}');
        mockResponse.setStatusCode(200);

        // updateBaseUrl 메서드 테스트
        Test.startTest();
        EformsignApiEnvironmentManager.updateBaseUrl(mockResponse); // 여기서 YourClassName는 해당 메서드가 포함된 클래스 이름입니다.
        Test.stopTest();

        // 결과 검증
        EformsignEnvironment__c result = EformsignApiEnvironmentManager.getInfo();
        System.assertEquals(baseUrl, result.ApiBaseUrl__c, '정보 저장 실패');
    }

    @isTest
    static void testUpdateBaseUrl2() {
        EformsignApiEnvironmentManager.saveEnvironmentInfo('apiKey', 'privateKey' ,'companyId' ,'' );
    }

}