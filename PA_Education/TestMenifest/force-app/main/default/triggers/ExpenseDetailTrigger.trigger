trigger ExpenseDetailTrigger on ExpenseDetail__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	new ExpenseDetail_tr().run();
}