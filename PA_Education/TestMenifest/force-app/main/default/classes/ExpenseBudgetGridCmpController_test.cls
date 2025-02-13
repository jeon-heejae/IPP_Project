@IsTest
public class ExpenseBudgetGridCmpController_test {

    @IsTest
    static void doTest() {
        Test.startTest();
        Expense__c exp = TestObjectCreator.objExpense;
        exp.BudgetType__c    = '프로젝트';
        exp.PaymentMethod__c = '법인카드';
        exp.UseMonth__c      = String.valueOf(Date.today().month());
        insert exp;

        ExpenseDetail__c objEx = TestObjectCreator.objExpenseDetail;
        objEx.Payment_Type__c = '법인카드';
        objEx.Type__c         = '기타';
        objEx.Expense__c      = exp.Id;
        objEx.Date__c         = Date.today();
        insert objEx;

        ExpenseBudgetGridCmpController ebgcc = new ExpenseBudgetGridCmpController();
        Map<String, Object> mapSO =  ExpenseBudgetGridCmpController.getInit(objEx.Expense__c);
        Map<String, String> mapSS =  ExpenseBudgetGridCmpController.getObjectFieldLabel('Project__c') ;

        Test.stopTest();
    }
}