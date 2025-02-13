public with sharing class ContentDocumentLink_tr {
    Map<Id, Qualification__c> mapUpdate = new Map<Id, Qualification__c>();
    List<ContentDocumentLink> listNew { get; set; }
    List<ContentDocumentLink> listOld { get; set; }
    Map<Id, ContentDocumentLink> mapNew { get; set; }
    Map<Id, ContentDocumentLink> mapOld { get; set; }

    public ContentDocumentLink_tr() {
        listNew = Trigger.new;
        listOld = Trigger.old;
        mapNew = (Map<Id, ContentDocumentLink>) Trigger.newMap;
        mapOld = (Map<Id, ContentDocumentLink>) Trigger.oldMap;
    }

    public void run() {
        if(Trigger.isBefore && Trigger.isInsert) beforeInsert();
        else if(Trigger.isAfter && Trigger.isInsert) afterInsert();
    }

    private void beforeInsert() {}

    private void afterInsert() {
        doCheckFileUpload();

        if(!mapUpdate.isEmpty()) update mapUpdate.values();
    }

    public void doCheckFileUpload() {
        Set<Id> setId = new Set<Id>();

        for (ContentDocumentLink obj : listNew) {
            if (obj.LinkedEntityId != null ) {
                setId.add(obj.LinkedEntityId);
            }
        }

        if (!setId.isEmpty()) {
            for (Qualification__c obj : [
                    SELECT Id, IsFiles__c
                    FROM Qualification__c
                    WHERE Id IN :setId AND IsFiles__c =: false
            ]) {
                obj.IsFiles__c = true;
                mapUpdate.put(obj.Id, obj);
            }
        }
    }
}