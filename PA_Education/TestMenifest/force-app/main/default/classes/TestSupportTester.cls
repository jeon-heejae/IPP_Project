@isTest
private class TestSupportTester{
    static testMethod void myUnitTest() {
        test.startTest();
        
        TestSupport con = new TestSupport ();
        
        con.registerLead();
        con.username = 'name';
        con.email = 'sj.kim@daeunextier.com';
        con.subject = 'test';
        con.message = 'test2';
        con.interestProduct = 'Service Cloud';
        con.leadsource = '웹';
        con.company = 'test';

        con.registerLead();



		Lead__c LD = new Lead__c();
        //Lead LD = new Lead();
        Ld.Name = con.username;
        Ld.Company__c = con.Company;
        Ld.LeadSource__c = '웹';
        LD.Email__c = con.email;
        LD.InterestProduct__c = con.InterestProduct;
        LD.WebSubject__c = con.subject;
        LD.WebMessage__c = con.message;
        insert LD;



        
        
        test.stopTest();
    }
}