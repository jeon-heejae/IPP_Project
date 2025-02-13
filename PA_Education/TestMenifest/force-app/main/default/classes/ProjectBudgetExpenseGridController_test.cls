@isTest
private class ProjectBudgetExpenseGridController_test{

        
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
        ProjectBudget__c pb = new ProjectBudget__c();
        pb.Project__c = prj.Id;
        pb.Status__c = '승인완료';
        insert pb;
        ProjectBudgetDetail__c pe = new ProjectBudgetDetail__c();
        pe.ProjectBudget__c = pb.Id;
        pe.Category2__c = '식비';
        insert pe;
        String strYear = String.valueOf(System.today().year());
        String strMonth = String.valueOf(System.today().month());
        Expense__c exp = new Expense__c();
        //exp.Project__c = prj.Id;
        exp.OwnerId = user.Id;
        exp.FirstExpenseRequest__c = user2.Id;
        exp.ApprovalStatus__c = '승인완료';
        exp.UseYear__c = strYear;
        exp.UseMonth__c = strMonth;
        exp.BudgetType__c = '본사행정';
        exp.PaymentMethod__c = '법인카드';
        exp.Project__c = prj.Id;
        insert exp;

        ExpenseDetail__c ed = new ExpenseDetail__c();
        ed.Project_Name__c = prj.Id;
        ed.Category2__c = '도서인쇄비';
        ed.Type__c = '도서인쇄비';
        ed.Expense__c = exp.Id;
        ed.Amount__c = 1;
        ed.Date__c = Date.today();
        insert ed;

        ApexPages.StandardController ctrl = new ApexPages.StandardController(prj);
        ProjectBudgetExpenseGridController pbegc = new ProjectBudgetExpenseGridController(ctrl);
        pbegc.setList();
        //system.debug(pbegc.prjExpBgtList[0].remainAmount);
        Test.stopTest();
    } 
}