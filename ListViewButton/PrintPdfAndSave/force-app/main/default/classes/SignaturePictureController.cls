public with sharing class SignaturePictureController {

    @AuraEnabled
    public static ContentVersion getSignaturePicture(Id parentId) {

        //ContentDocumentLink에서 ContentDocumentId 가져오기
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :parentId
        ];

        if (links.isEmpty()) {
            return null; // 연결된 파일이 없는 경우
        }

        // ContentDocumentId만 추출
        List<Id> documentIds = new List<Id>();
        for (ContentDocumentLink link : links) {
            documentIds.add(link.ContentDocumentId);
        }

        //ContentVersion에서 ContentDocumentId 기반으로 최신 파일 가져오기
        List<ContentVersion> versions = [
            SELECT Id, Title, FileExtension, ContentDocumentId, LastModifiedDate 
            FROM ContentVersion 
            WHERE ContentDocumentId IN :documentIds
            AND Title LIKE '%Sig_%' 
            AND FileExtension IN ('png', 'jpeg', 'jpg', 'gif')
            ORDER BY LastModifiedDate DESC
            LIMIT 1
        ];

        if (!versions.isEmpty()) {
            return versions.get(0);
        }
        return null; // 사인 사진이 없는 경우
}


    @AuraEnabled
    public static String saveSignaturePicture(Id parentId, String fileName, String base64Data) {

        // ContentVersion 레코드 생성
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Sig_' + fileName; // 파일 이름
        contentVersion.PathOnClient = fileName;  // 클라이언트 경로 (임의로 파일 이름 사용)
        contentVersion.VersionData = EncodingUtil.base64Decode(base64Data); // Base64 디코딩한 파일 데이터
        contentVersion.FirstPublishLocationId = parentId; // 파일을 연결할 레코드

        insert contentVersion;

        // 저장된 ContentVersion에서 ContentDocumentId 반환
        ContentDocument contentDocument = [
            SELECT Id
            FROM ContentDocument
            WHERE LatestPublishedVersionId = :contentVersion.Id
            LIMIT 1
        ];

        Employee__c employee = [
            SELECT Id, Name, SignaturePhotoId__c
            FROM Employee__c
            WHERE Id = :parentId
        ];

        employee.SignaturePhotoId__c = contentVersion.Id;
        update employee;

        return contentDocument.Id;
    }

}
