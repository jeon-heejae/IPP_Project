/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-06-27     hs.jung          Create
*************************************************************************************/
@IsTest
private class EformsignTokenManager_Test {
    @isTest
    static void testRecentTokenNotNull() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        EformsignToken__c objEformsignToken = new EformsignToken__c();
        objEformsignToken.Name = 'eftkName';
        objEformsignToken.AccessToken__c = 'et54345344535632sdfsdrt32';
        objEformsignToken.RefreshToken__c = 'et54345344535632sdfsdrt3223';
        objEformsignToken.User__c = UserInfo.getUserId();
        objEformsignToken.TokenIssuedDateTime__c = System.today() + 2 ;
        objEformsignToken.ExpireIn__c = 3600;
        insert objEformsignToken;

        EformsignEnvironment__c defaultConfig = new EformsignEnvironment__c();
        defaultConfig.ApiKey__c = 'apiKey';
        defaultConfig.Privatekey__c = 'privateKey';
        defaultConfig.CompanyId__c = 'companyId';
        defaultConfig.RepresentativeAdminEmail__c = 'https://kr-api.eformsign.com';
        defaultConfig.ApiBaseUrl__c = 'https://kr-api.eformsign.com';
        insert defaultConfig;

        test.startTest();
        EformsignTokenManager efTokenMg  = new EformsignTokenManager();
        efTokenMg.getAccessTokenSObject();
        efTokenMg.getAccessTokenForEmbeddeingJson();
        efTokenMg.requestNewToken();
        test.stopTest();
    }

    @isTest
    static void testRecentTokenNull2() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        EformsignToken__c objEformsignToken = new EformsignToken__c();
        objEformsignToken.Name = 'eftkName';
        objEformsignToken.AccessToken__c = 'et54345344535632sdfsdrt32';
        objEformsignToken.RefreshToken__c = 'et54345344535632sdfsdrt3223';
        objEformsignToken.User__c = UserInfo.getUserId();
//        objEformsignToken.TokenIssuedDateTime__c = System.today() - 2 ;
        objEformsignToken.ExpireIn__c = 3600;
        insert objEformsignToken;

        EformsignEnvironment__c defaultConfig = new EformsignEnvironment__c();
        defaultConfig.ApiKey__c = 'apiKey';
        defaultConfig.Privatekey__c = 'privateKey';
        defaultConfig.CompanyId__c = 'companyId';
        defaultConfig.RepresentativeAdminEmail__c = 'https://kr-api.eformsign.com';
        defaultConfig.ApiBaseUrl__c = 'https://kr-api.eformsign.com';
        insert defaultConfig;

        test.startTest();
        EformsignTokenManager efTokenMg  = new EformsignTokenManager();
        efTokenMg.getAccessTokenSObject();
        efTokenMg.getAccessTokenForEmbeddeingJson();
        efTokenMg.requestNewToken();
        test.stopTest();
    }

    @isTest
    static void testRecentTokenNull3() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        EformsignToken__c objEformsignToken = new EformsignToken__c();
        objEformsignToken.Name = 'eftkName';
        objEformsignToken.AccessToken__c = 'et54345344535632sdfsdrt32';
        objEformsignToken.RefreshToken__c = 'et54345344535632sdfsdrt3223';
        objEformsignToken.User__c = UserInfo.getUserId();
        objEformsignToken.TokenIssuedDateTime__c = System.today() - 2 ;
        objEformsignToken.ExpireIn__c = 3600;
        insert objEformsignToken;

        EformsignEnvironment__c defaultConfig = new EformsignEnvironment__c();
        defaultConfig.ApiKey__c = 'apiKey';
        defaultConfig.Privatekey__c = 'privateKey';
        defaultConfig.CompanyId__c = 'companyId';
        defaultConfig.RepresentativeAdminEmail__c = 'https://kr-api.eformsign.com';
        defaultConfig.ApiBaseUrl__c = 'https://kr-api.eformsign.com';
        insert defaultConfig;

        test.startTest();
        EformsignTokenManager efTokenMg  = new EformsignTokenManager();
        efTokenMg.getAccessTokenSObject();
        efTokenMg.getAccessTokenForEmbeddeingJson();
        efTokenMg.requestNewToken();
        test.stopTest();
    }

    // Http response
    private static HttpResponse newResponse(Integer statusCode) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        String json = '{\n' +
                '                "api_key": {\n' +
                '                    "name": "salesforce",\n' +
                '                    "alias": "app",\n' +
                '                    "company": {\n' +
                '                        "company_id": "f752333198f24c46ae2085e04169da1a",\n' +
                '                        "name": "메가존클라우드",\n' +
                '                        "api_url": "https://kr-api.eformsign.com"\n' +
                '                    }\n' +
                '                },\n' +
                '                "oauth_token": {\n' +
                '                    "expires_in": 3600,\n' +
                '                    "token_type": "JWT",\n' +
                '                    "refresh_token": "aaa",\n' +
                '                    "access_token": "aaaY"\n' +
                '                }\n' +
                '            }';
//        response.setBody('{"access_token":"test"}');
        response.setBody(json);

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