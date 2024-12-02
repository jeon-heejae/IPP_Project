public with sharing class SignaturePictureController {

    @AuraEnabled
    public static String saveContentDocument(Id parentId, String fileName, String base64Data, String contentType, String documentType) {
        if (!Schema.sObjectType.Employee__c.isUpdateable()) {
            throw new System.NoAccessException();
        }

        // ContentVersion 생성
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = documentType + '_' + fileName; // Prefix로 파일 구분
        contentVersion.PathOnClient = fileName;
        contentVersion.VersionData = EncodingUtil.base64Decode(base64Data);
        contentVersion.ContentLocation = 'S'; // Stored in Salesforce
        contentVersion.FirstPublishLocationId = parentId; // Record to link the file
        contentVersion.FileType = contentType;
        insert contentVersion;

        // ContentVersion의 ContentDocumentId 반환
        ContentDocument contentDocument = [SELECT Id FROM ContentDocument WHERE Id = :contentVersion.ContentDocumentId];
        return contentDocument.Id;
    }

    @AuraEnabled
    public static ContentVersion getContentDocumentByType(Id parentId, String documentType) {
        if (!Schema.sObjectType.Employee__c.isAccessible()) {
            throw new System.NoAccessException();
        }

        return [
            SELECT Id, Title, ContentDocumentId, FileExtension, VersionData
            FROM ContentVersion
            WHERE FirstPublishLocationId = :parentId AND Title LIKE :documentType + '_%'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
    }
}
