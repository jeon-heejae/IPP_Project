public with sharing class ProfilePictureController {
    
    @AuraEnabled
    public static Attachment getProfilePicture(Id parentId) {

        // Attachment permissions are set in parent object (Contact)
        if (!Schema.sObjectType.Contact.isAccessible()) {
            throw new System.NoAccessException();
        }
 
        return [SELECT Id, Name, LastModifiedDate, ContentType FROM Attachment 
            WHERE parentid=:ParentId AND ContentType IN ('image/png', 'image/jpeg', 'image/gif') 
            ORDER BY LastModifiedDate DESC LIMIT 1];
    }
    
    @AuraEnabled
    public static Id saveAttachment(Id parentId, String fileName, String base64Data, String contentType) { 

        // Edit permission on parent object (Contact) is required to add attachments
        if (!Schema.sObjectType.Contact.isUpdateable()) {
            throw new System.NoAccessException();   
        }

        Attachment attachment = new Attachment();
        attachment.parentId = parentId;
        attachment.body = EncodingUtil.base64Decode(base64Data);
        attachment.name = fileName;
		attachment.contentType = contentType;
        insert attachment;
        return attachment.id;
    }

    @AuraEnabled
    public static Contact getContactInfo(Id contactId) {
        System.debug('getContactInfo called with contactId: ' + contactId);
        try {
            Contact contact = [SELECT Id, Name, BirthdayDate__c, Parent__c, Parent__r.Name
                               FROM Contact 
                               WHERE Id = :contactId];
            System.debug('Contact found: ' + contact);
            return contact;
        } catch (Exception e) {
            System.debug('Error in getContactInfo: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving contact info: ' + e.getMessage());
        }
    }
}