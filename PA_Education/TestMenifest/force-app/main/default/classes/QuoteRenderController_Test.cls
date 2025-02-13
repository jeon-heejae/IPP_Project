@isTest
public class QuoteRenderController_Test{
    static User testUser;
    static Quote__c q;
    static {
        Profile p = TestDataFactory.getProfile('System Admin');
        testUser = TestDataFactory.createUser(p);   
        Contact c = new Contact(LastName = 'TestContact');
        insert c;
        q = new Quote__c(Quote_Contact__c = c.Id);
        insert q;
        List<RecordType> rtLst = [SELECT Id FROM RecordType WHERE SobjectType = 'QuoteItem__c'];
        String conRt = rtLst[0].Id;
        String lnsRt = rtLst[1].Id;
        String trnRt = rtLst[2].Id;
        List<QuoteItem__c> qiLst = new List<QuoteItem__c>();
        qiLst.add(new QuoteItem__c(QuoteItem_Quote__c = q.Id, RecordTypeId = conRt));
        qiLst.add(new QuoteItem__c(QuoteItem_Quote__c = q.Id, RecordTypeId = lnsRt));
        qiLst.add(new QuoteItem__c(QuoteItem_Quote__c = q.Id, RecordTypeId = trnRt));
        insert qiLst;
    }
    static TestMethod void QuoteRenderController_Test(){
        Test.startTest();
		System.runAs(testUser){        
            ApexPages.StandardController ctrl = new ApexPages.StandardController(q);  
        	QuoteRenderController hel = new QuoteRenderController(ctrl);
        }
        Test.stopTest();
    }
}