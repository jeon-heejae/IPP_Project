/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-07-01     hs.jung          Create
*************************************************************************************/
@IsTest
private class EformsignTemplateManager_Test {

    @IsTest
    static void testBehavior() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        EformsignToken__c objEformsignToken = new EformsignToken__c();
        objEformsignToken.Name = 'eftkName';
        objEformsignToken.AccessToken__c = 'et54345344535632sdfsdrt32';
        objEformsignToken.RefreshToken__c = 'et54345344535632sdfsdrt3223';
        objEformsignToken.User__c = UserInfo.getUserId();
        objEformsignToken.TokenIssuedDateTime__c = System.today() + 2 ;
        objEformsignToken.ExpireIn__c = 3600;
        insert objEformsignToken;


        EformsignTemplate__c objEformsignTemplate = new EformsignTemplate__c();
        objEformsignTemplate.Name = 'test';
        objEformsignTemplate.ObjectApiName__c = 'Account';
        objEformsignTemplate.TemplateId__c = 'TemplateId';
        insert objEformsignTemplate;



        test.startTest();
        EformsignTemplateManager.Deletion efDelete = new EformsignTemplateManager.Deletion(objEformsignTemplate.Id);

        efDelete.execute();
        efDelete.databaseLogic();
        efDelete.sendRequest();

        test.stopTest();
    }

    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            HTTPResponse res = new HTTPResponse();
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + 'accessToken');
            res.setBody('{"api_key": {"company": {"api_url": "' + 'https://kr-api.eformsign.com' + '"}}}');
            res.setStatusCode(200);
            return res;
        }
    }

    // Http response
    private static HttpResponse newResponse(Integer statusCode) {
        HttpResponse response = new HttpResponse();

        response.setStatusCode(statusCode);
        response.setBody('{}');

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