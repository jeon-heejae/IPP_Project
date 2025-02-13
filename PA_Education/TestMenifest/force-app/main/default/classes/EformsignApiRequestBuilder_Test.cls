/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-06-27     hs.jung          Create
*************************************************************************************/
@IsTest
private class EformsignApiRequestBuilder_Test {
    @IsTest
    static void testBehavior() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        EformsignEnvironment__c defaultConfig = new EformsignEnvironment__c();
        defaultConfig.ApiKey__c = 'apiKey';
        defaultConfig.Privatekey__c = 'privateKey';
        defaultConfig.CompanyId__c = 'companyId';
        defaultConfig.RepresentativeAdminEmail__c = 'https://kr-api.eformsign.com';
        defaultConfig.ApiBaseUrl__c = 'https://kr-api.eformsign.com';
        insert defaultConfig;

        test.startTest();
        EformsignApiRequestBuilder ct = new EformsignApiRequestBuilder('accessToken');
        ct.getDocumentDeleteRequest();
        ct.getDocumentCancelRequest();
        ct.getMembersRequest();
        ct.getEnrollMemberRequest('mnj@naver.com', 'nnm');
        ct.getDeleteMemberRequest('mnj@naver.com');
        ct.getTemplateDeleteRequest('templateId');
        ct.getDocumentDownloadRequest('documentId', 'templateId', true);

        test.stopTest();
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