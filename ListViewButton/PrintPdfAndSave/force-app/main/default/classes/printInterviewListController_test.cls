@isTest
public class printInterviewListController_test {
    @isTest
    public static void testPrintInterviewListController() {
        //setup
        List<Interview__c> listInterviews = new List<Interview__c>();
        for (Integer i = 0; i < 3; i++) {
            listInterviews.add(new Interview__c(
                Intv_Date__c = Date.today().addDays(-i)
            ));
        }
        insert listInterviews;

        // StandardSetController 생성
        List<Interview__c> listSelectedInterviews = [SELECT Id FROM Interview__c LIMIT 2];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listSelectedInterviews);

        
        Test.startTest();
        printInterviewListController controller = new printInterviewListController(stdSetController);
        Test.stopTest();
    }
}
