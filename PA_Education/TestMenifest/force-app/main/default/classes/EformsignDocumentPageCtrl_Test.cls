/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-06-27     hs.jung          Create
*************************************************************************************/
@IsTest
private class EformsignDocumentPageCtrl_Test {
    @isTest
    static void testConstructor() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        User objUser = TestObjectCreator.objUser;
        insert objUser;

        EformsignToken__c objEformsignToken = new EformsignToken__c();
        objEformsignToken.Name = 'test';
        objEformsignToken.AccessToken__c = 'test';
        objEformsignToken.RefreshToken__c = null;
        objEformsignToken.User__c = UserInfo.getUserId();
        objEformsignToken.TokenIssuedDateTime__c = System.today() + 2 ;
        objEformsignToken.ExpireIn__c = 3600;
        insert objEformsignToken;
        System.debug( 'objEformsignToken>>>> ' + objEformsignToken);

        EformsignEnvironment__c defaultConfig = new EformsignEnvironment__c();
        defaultConfig.ApiKey__c = 'apiKey';
        defaultConfig.Privatekey__c = 'privateKey';
        defaultConfig.CompanyId__c = 'companyId';
        defaultConfig.RepresentativeAdminEmail__c = 'https://kr-api.eformsign.com';
        defaultConfig.ApiBaseUrl__c = 'https://kr-api.eformsign.com';
        insert defaultConfig;

        EformsignTemplate__c objEformsignTemplate = new EformsignTemplate__c();
        objEformsignTemplate.Name = 'test';
        objEformsignTemplate.ObjectApiName__c = 'Account';
        objEformsignTemplate.TemplateId__c = 'TemplateId';
        insert objEformsignTemplate;

        Account objAccount = TestObjectCreator.objAccount;
        insert objAccount;

        PageReference pageRef = ApexPages.currentPage();
        ApexPages.currentPage().getParameters().put('objectApiName', 'Account');
        ApexPages.currentPage().getParameters().put('recordId', objAccount.Id);
        ApexPages.currentPage().getParameters().put('templateRecordId',objEformsignTemplate.Id);
        Test.setCurrentPage(pageRef);


        String templateRecordId = ApexPages.currentPage().getParameters().get('templateRecordId');
        EformsignTemplateField__c objeField = new EformsignTemplateField__c();
        objeField.Name = 'test';
        objeField.TargetFieldType__c = 'string';
        objeField.TargetFieldApiName__c = 'Name';
        objeField.EformsignTemplate__c = templateRecordId;
        insert objeField;


        String strJson = '{' +
                '"documentId": "12345",' +
                '"status": "completed",' +
                '"createdDate": "2024-06-27T00:00:00.000Z",' +
                '"details": "Document processing completed successfully."' +
                '}';
        Test.startTest();
        EformsignDocumentPageCtrl controller = new EformsignDocumentPageCtrl();
        System.assertNotEquals(null, controller.tokenUser);
        System.assertNotEquals(null, controller.tokenManager);
        controller.init();
        EformsignDocumentPageCtrl.insertDocumentId(strJson, 'templateRecordId', 'recordId', 'Account');
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