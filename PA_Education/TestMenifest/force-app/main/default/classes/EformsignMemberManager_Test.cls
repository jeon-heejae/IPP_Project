@isTest
public class EformsignMemberManager_Test {
    @isTest
    static void testListGetterSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        EformsignToken__c objEformsignToken = new EformsignToken__c();
        objEformsignToken.Name = 'eftkName';
        objEformsignToken.AccessToken__c = 'et54345344535632sdfsdrt32';
        objEformsignToken.RefreshToken__c = 'et54345344535632sdfsdrt3223';
        objEformsignToken.User__c = UserInfo.getUserId();
        objEformsignToken.TokenIssuedDateTime__c = System.today() + 2 ;
        objEformsignToken.ExpireIn__c = 3600;
        insert objEformsignToken;

        test.startTest();
        EformsignMemberManager.ListGetter efListGetter = new EformsignMemberManager.ListGetter();
        efListGetter.execute();
        test.stopTest();
    }

    @isTest
    static void testEnrollmentSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        EformsignToken__c objEformsignToken = new EformsignToken__c();
        objEformsignToken.Name = 'eftkName';
        objEformsignToken.AccessToken__c = 'et54345344535632sdfsdrt32';
        objEformsignToken.RefreshToken__c = 'et54345344535632sdfsdrt3223';
        objEformsignToken.User__c = UserInfo.getUserId();
        objEformsignToken.TokenIssuedDateTime__c = System.today() + 2 ;
        objEformsignToken.ExpireIn__c = 3600;
        insert objEformsignToken;


        test.startTest();
        EformsignMemberManager.Enrollment efEnrollment = new EformsignMemberManager.Enrollment('mn354534@naver.com', 'hsjung');
        efEnrollment.execute();
        test.stopTest();
    }

    @isTest
    static void testDeletionSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        EformsignToken__c objEformsignToken = new EformsignToken__c();
        objEformsignToken.Name = 'eftkName';
        objEformsignToken.AccessToken__c = 'et54345344535632sdfsdrt32';
        objEformsignToken.RefreshToken__c = 'et54345344535632sdfsdrt3223';
        objEformsignToken.User__c = UserInfo.getUserId();
        objEformsignToken.TokenIssuedDateTime__c = System.today() + 2 ;
        objEformsignToken.ExpireIn__c = 3600;
        insert objEformsignToken;


        test.startTest();
        EformsignMemberManager.Deletion efDeletion = new EformsignMemberManager.Deletion('mn354534@naver.com');
        efDeletion.execute();
        test.stopTest();
    }

    // Http response
    private static HttpResponse newResponse(Integer statusCode) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
//        response.setBody('[{}]');
        response.setBody('{"api_key": {"company": {"api_url": "' + 'https://kr-api.eformsign.com' + '"}}}');

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