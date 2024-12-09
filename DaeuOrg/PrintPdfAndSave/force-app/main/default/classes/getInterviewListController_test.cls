@isTest
public class getInterviewListController_test {
    @testSetup
    static void setupData(){
        List<Interview__c> listTestInterviews=new List<Interview__c>();

        for (Integer i = 0; i < 3; i++) {
            listTestInterviews.add(new Interview__c(
                Intv_Date__c = Date.today().addDays(-i)
            ));
        }
        insert listTestInterviews;
    }
    @isTest
    public static void testGetInterviewListController() {
        List<Interview__c> listInterviews = [SELECT Id FROM Interview__c LIMIT 2];
        ApexPages.currentPage().getParameters().put('recordId', listInterviews[0].Id + ',' + listInterviews[1].Id);

        Test.startTest();
        getInterviewListController controller = new getInterviewListController();
        Test.stopTest();
    }

    // public class MockPDFCallout implements HttpCalloutMock {
    //     public HTTPResponse respond(HTTPRequest req) {
    //         // Mock PDF content (Base64 encoded)
    //         Blob mockPdfBlob = Blob.valueOf('%PDF-1.4\n%Mock Content\n%%EOF');
    //         HTTPResponse res = new HTTPResponse();
    //         res.setStatusCode(200);
    //         res.setBody(mockPdfBlob.toString());
    //         return res;
    //     }
    // }

    @isTest
    public static void testGeneratePDF() {
        // setup data
        List<Interview__c> listInterviews = [SELECT Id FROM Interview__c LIMIT 2];
        PageReference testPage=Page.printInterviewList;
        Test.setCurrentPage(testPage);
        ApexPages.currentPage().getParameters().put('recordId', listInterviews[0].Id + ',' + listInterviews[1].Id);
        String testVfPageUrl = ApexPages.currentPage().getUrl();
        
        // //mock pdf
        // Test.setMock(HttpCalloutMock.class, new MockPDFCallout());

        Test.startTest();
        String pdfBase64 = getInterviewListController.generatePDF(testVfPageUrl);
        Test.stopTest();
    }

    @isTest
    public static void testCheckRecordType(){
        List<Interview__c> listInterviews = [SELECT Id FROM Interview__c LIMIT 2];
        String recordIds = listInterviews[0].Id + ',' + listInterviews[1].Id;
        
        Test.startTest();
        Boolean isValid = getInterviewListController.checkRecordType(recordIds);
        Test.stopTest();
    }

    @isTest
    public static void testCheckMonth(){
        List<Interview__c> listInterviews = [SELECT Id FROM Interview__c LIMIT 2];
        String recordIds = listInterviews[0].Id + ',' + listInterviews[1].Id;

        Test.startTest();
        Boolean isValid = getInterviewListController.checkMonth(recordIds);
        Test.stopTest();
    }

    
}
