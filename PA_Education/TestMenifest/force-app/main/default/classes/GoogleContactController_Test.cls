@isTest
private class GoogleContactController_Test {
    
    @isTest(SeeAllData=true)
    public static void isShould() {
        Test.startTest();
        
        GoogleAuthentication__c objGoogleAuthentication = new GoogleAuthentication__c();
        objGoogleAuthentication.User__c = UserInfo.getUserId();
        objGoogleAuthentication.AccessToken__c = 'testAccessToken';
        objGoogleAuthentication.AccessTokenUpdated__c = System.now();
        insert objGoogleAuthentication;
 
        Map<String, Object> paramMap = new Map<String, Object>();
        paramMap.put('name', 'testName TEST');
        paramMap.put('companyName', 'testCompanyName');
        paramMap.put('address', 'testAddress');
        paramMap.put('billingAddress_state', 'testState');
        paramMap.put('billingAddress_street', 'testStreet');
        paramMap.put('billingAddress_city', 'testCity');
        paramMap.put('phone', 'testPhone');
        paramMap.put('email', 'testEmail@test.com');
        paramMap.put('position', 'testPosition');
        paramMap.put('googleId', 'testGoogleId');

        GoogleContactController.getInitialData();
        GoogleContactController.doUpdateAuthentication('updateTestAccessToken');
        GoogleContactController.getContact(Datetime.now().format('yyyy-MM-dd'));
        GoogleContactController.createContact(System.JSON.serialize(paramMap));

        Test.stopTest();
    }
}