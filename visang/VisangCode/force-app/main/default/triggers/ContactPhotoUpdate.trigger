trigger ContactPhotoUpdate on ContentVersion (after insert, after update) {
    Set<Id> contactIds = new Set<Id>();
    Map<Id, Id> contentDocumentIdMap = new Map<Id, Id>();
    
    for (ContentVersion cv : Trigger.new) {
        if (cv.FirstPublishLocationId != null && String.valueOf(cv.FirstPublishLocationId).startsWith('003')) {
            contactIds.add(cv.FirstPublishLocationId);
            contentDocumentIdMap.put(cv.FirstPublishLocationId, cv.Id);
        }
    }
    
    if (!contactIds.isEmpty()) {
        List<Contact> contactsToUpdate = new List<Contact>();
        for (Contact con : [SELECT Id, Photo_Document_ID__c FROM Contact WHERE Id IN :contactIds]) {
            if (contentDocumentIdMap.containsKey(con.Id)) {
                con.Photo_Document_ID__c = contentDocumentIdMap.get(con.Id);
                contactsToUpdate.add(con);
            }
        }
        
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }
}