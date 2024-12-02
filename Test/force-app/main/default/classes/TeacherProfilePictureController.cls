public with sharing class TeacherProfilePictureController {
    
    @AuraEnabled
    public static Attachment getProfilePicture(Id recordId) {

        // Attachment permissions are set in parent object (Contact)
        if (!Schema.sObjectType.Contact.isAccessible()) {
            throw new System.NoAccessException();
        }
 
        return [SELECT Id, LastModifiedDate, ContentType FROM Attachment 
            WHERE  parentid=:recordId AND ContentType IN ('image/png', 'image/jpeg', 'image/gif') 
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
    public static Teacher__c getTeacherInfo(Id teacherId) {
        System.debug('getContactInfo called with contactId: ' + teacherId);
        try {
            Teacher__c teacher = [SELECT Id, Name, Mobile__c, Address__c
                               FROM Teacher__c 
                               WHERE Id = :teacherId];
            System.debug('Teacher found: ' + teacher);
            return teacher;
        } catch (Exception e) {
            System.debug('Error in getContactInfo: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving contact info: ' + e.getMessage());
        }
    }
}