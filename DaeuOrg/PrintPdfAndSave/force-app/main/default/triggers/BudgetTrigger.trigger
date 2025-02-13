trigger BudgetTrigger on Budget__c (before insert,before update, before delete,after insert, after update, after delete) {
    new Budget2_tr().run(); 
}