/**
 * Created by JWJANG on 2023-10-04.
 */
trigger ExpenseApplicationTrigger on Expense__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new ExpenseApplicationTriggerHandler().run();
}