trigger OfflineClassTrigger on OfflineClass__c (after insert) {
    new OfflineClass_tr().run();
}