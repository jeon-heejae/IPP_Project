trigger ProjectMemberTrigger on ProjectMember__c (before insert,before update) {
    new ProjectMember_tr().run();
}