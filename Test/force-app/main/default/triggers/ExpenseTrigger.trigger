trigger ExpenseTrigger on Expense__c (after insert) {

    new Expense_tr().run();
}