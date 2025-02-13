@isTest
private class ExpenseBudgetGridController_test{
    static TestMethod void itShould(){
        Test.startTest();
        Profile p = [select id from Profile where Name='System Administrator'];
        User user = new User(Alias = 'testUser'
                            , Email='SysAdminTestuser@earth.org'
                            , EmailEncodingKey='UTF-8'
                            , LastName='Testing'
                            , LanguageLocaleKey='en_US'
                            , LocaleSidKey='en_US'
                            , EmployeeNumber='AC100000'
                            , ProfileId = p.Id
                            , TimeZoneSidKey='Asia/Seoul'
                            , UserName='SysAdminTestuser@earth.org');

        insert user;
        User user2 = new User(Alias = 'testUser'
                            , Email='SysAdminTestuser@earth.org2'
                            , EmailEncodingKey='UTF-8'
                            , LastName='Testing'
                            , LanguageLocaleKey='en_US'
                            , LocaleSidKey='en_US'
                            , EmployeeNumber='AC100000'
                            , ProfileId = p.Id
                            , TimeZoneSidKey='Asia/Seoul'
                            , UserName='SysAdminTestuser@earth.org2');

        insert user2;

        Project__c prj = new Project__c();
        insert prj;
        String strYear = String.valueOf(System.today().year());
        String strMonth = String.valueOf(System.today().month());
        Expense__c exp = new Expense__c();
        //exp.Project__c = prj.Id;
        exp.OwnerId = user.Id;
        exp.FirstExpenseRequest__c = user2.Id;
        exp.UseYear__c = strYear;
        exp.UseMonth__c = strMonth;
        insert exp;
        ExpenseDetail__c ed = new ExpenseDetail__c();
        ed.Project_Name__c = prj.Id;
        ed.Category2__c = '교통비';
        ed.Payment_Type__c = '개인카드';
        ed.Expense__c = exp.Id;
        ed.Amount__c = 1;
        ed.Date__c = Date.today();
        insert ed;

        ApexPages.StandardController ctrl = new ApexPages.StandardController(exp);
        ExpenseBudgetGridController pbegc = new ExpenseBudgetGridController(ctrl);
        pbegc.setList();
        Test.stopTest();
    } 
}