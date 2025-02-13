/**
 * Created by Kwanwoo.Jeon on 2024-01-16.
 */

@IsTest
private class BudgetExpenseGridController_test {
    @TestSetup
    static void setUp(){

    }
    @IsTest
    static void doTest() {
        Test.startTest();
        Budget__c obj = new Budget__c(
                Name = 'test',
                Year__c = string.valueOf(Date.today().year() -1),
                BudgetAmount__c = 10000000,
                BudgetType__c = '본사행정'
        );
        insert obj;
        BudgetExpenseGridController.doInit(obj.Id);

        Test.stopTest();
    }
}