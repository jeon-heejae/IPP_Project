@isTest
private class ProjectBudget_test {
    
    @isTest static void test_method_one() {
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
        exp.UseYear__c = strYear;
        exp.UseMonth__c = strMonth;
        insert exp;
        ExpenseDetail__c ed = new ExpenseDetail__c();
        ed.Project_Name__c = prj.Id;
        ed.Category2__c = '교통비';
        ed.Type__c = '복리후생비-식대';
        ed.Expense__c = exp.Id;
        ed.Amount__c = 1;
        ed.Date__c = Date.today();
        insert ed;

        ProjectBudgetController pbc = new ProjectBudgetController();
        ProjectBudgetController.getPicklistValue('ProjectBudgetDetail__c', 'Category2__c');
        ProjectBudgetController.getInitData(pb.Id, prj.Id);
        ProjectBudgetController.getInitData(null, prj.Id);
        ProjectBudgetController.doSave(pb, new List<ProjectBudgetDetail__c>{pe}, pb.Id);
        ProjectBudgetController.doSave(pb, null, pb.Id);
        Test.stopTest();   
    }   
}