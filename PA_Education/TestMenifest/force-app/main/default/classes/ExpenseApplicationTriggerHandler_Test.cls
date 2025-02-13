/**
 * Created by JWJANG on 2023-10-04.
 */
@IsTest
private class ExpenseApplicationTriggerHandler_Test {
    @TestSetup
    static void doTestSetup() {
        List<Project__c> listProject = new List<Project__c>();
        listProject.add(new Project__c(Name = '본사공통', Salesforce_Product__c = 'Sales Cloud', Salesforce_Industry__c = '자동차'));
        listProject.add(new Project__c(Name = '마케팅', Salesforce_Product__c = 'Sales Cloud', Salesforce_Industry__c = '자동차'));
        listProject.add(new Project__c(Name = 'TEST Project', Salesforce_Product__c = 'Sales Cloud', Salesforce_Industry__c = '자동차'));
//        listProject.add(new Project__c(Name = 'TEST Project2', Salesforce_Product__c = 'Sales Cloud', Salesforce_Industry__c = '자동차'));
        insert listProject;

        Project__c objProject = [SELECT Id FROM Project__c WHERE Name = 'TEST Project' LIMIT 1];

        Budget__c obj = new Budget__c(
                Name = 'test',
                Year__c = string.valueOf(Date.today().year() -1),
                BudgetAmount__c = 10000000,
                BudgetType__c = '본사행정'
        );
        insert obj;

        Expense__c objExpense           = new Expense__c();
        objExpense.UseYear__c           = String.valueOf(Date.today().year());
        objExpense.UseMonth__c          = String.valueOf(Date.today().month());
        objExpense.ApprovalStatus__c    = 'Approved';
        objExpense.BudgetType__c        = '본사행정';
        objExpense.PaymentMethod__c     = '법인카드';
        insert objExpense;

        ExpenseDetail__c objExpenseDetail   = new ExpenseDetail__c();
        objExpenseDetail.Project_Name__c    = objProject.Id;
        objExpenseDetail.Expense__c         = objExpense.Id;
        objExpenseDetail.Category1__c       = '프로젝트';
        objExpenseDetail.Category2__c       = '식비';
        objExpenseDetail.Amount__c          = 1000;
        objExpenseDetail.Date__c            = Date.today();
        insert objExpenseDetail;

        Expense__c objExpense2           = new Expense__c();
        objExpense2.Project__c          = objProject.Id;
        objExpense2.UseYear__c           = String.valueOf(Date.today().year());
        objExpense2.UseMonth__c          = String.valueOf(Date.today().month());
        objExpense2.ApprovalStatus__c    = 'Approved';
        objExpense2.BudgetType__c        = '프로젝트';
        objExpense2.PaymentMethod__c     = '법인카드';
        insert objExpense2;

        ExpenseDetail__c objExpenseDetail2   = new ExpenseDetail__c();
        objExpenseDetail2.Expense__c         = objExpense2.Id;
        objExpenseDetail2.Category2__c       = '식비';
        objExpenseDetail2.Amount__c          = 1000;
        objExpenseDetail2.Date__c            = Date.today();
        insert objExpenseDetail2;
//
//        Project__c objProject2 = [SELECT Id FROM Project__c WHERE Name = 'TEST Project2' LIMIT 1];
//        Contract__c objContract = new Contract__c(
//                Name = 'Test Contract',
//                IsContract__c = true
//        );
//        insert objContract;
////
////        objProject2.Contract__c = objContract.Id;
////        update objProject2;
////
////        ProjectBudget__c objpBudget = new ProjectBudget__c(
////                Project__c = objProject2.Id,
////                Name = 'TestBudget'
////        );
////        insert objpBudget;
////
////        ProjectBudgetDetail__c objPBD = new ProjectBudgetDetail__c(
////                Category2__c = '식비',
////                Quantity__c = 1,
////                UnitPrice__c = 100,
////                ProjectBudget__c = objpBudget.Id
////        );
////        insert objPBD;
////
////        Expense__c objExpense3           = new Expense__c();
////        objExpense3.Project__c          = objProject2.Id;
////        objExpense3.UseYear__c           = String.valueOf(Date.today().year());
////        objExpense3.UseMonth__c          = String.valueOf(Date.today().month());
////        objExpense3.ApprovalStatus__c    = 'Approved';
////        objExpense3.BudgetType__c        = '프로젝트';
////        objExpense3.PaymentMethod__c     = '법인카드';
////        insert objExpense3;
////
////        ExpenseDetail__c objExpenseDetail3   = new ExpenseDetail__c();
////        objExpenseDetail3.Expense__c         = objExpense3.Id;
////        objExpenseDetail3.Category2__c       = '식비';
////        objExpenseDetail3.Amount__c          = 1000;
////        objExpenseDetail3.Date__c            = Date.today();
////        insert objExpenseDetail3;


    }

    @IsTest
    static void doTest() {
        List<Expense__c> listExpense = [SELECT Id, ApprovalStatus__c FROM Expense__c];
        System.debug(listExpense);
        for (Expense__c obj: listExpense){
            obj.ApprovalStatus__c = '승인완료';
        }

        Database.update(listExpense, false);
//        listExpense.get(0).ApprovalStatus__c = '승인완료';
//        update listExpense;
    }
}