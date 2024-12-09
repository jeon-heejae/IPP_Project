trigger InterviewNameTrigger on Interview__c (before insert,before update, before delete,after insert, after update, after delete) {
    new InterviewName_tr().run(); 
}