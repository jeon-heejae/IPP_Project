/**
 * @description       : 사원 레코드 관련 프로필 사진 첨부 및 관리
 * @author            : 알 수 없음
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 2.0   2021.01.12   CJ.Sohn                   Modified(getProfilePicture 실행 시, SOQL이 Null을 반환하여 실행되는 QueryException을 방지)
**/
public with sharing class ProfilePictureController {
    
    @AuraEnabled
    public static Attachment getProfilePicture(Id parentId) {
        /*
        return [SELECT Id, Name, LastModifiedDate, ContentType FROM Attachment
        WHERE parentid=:ParentId AND ContentType IN ('image/png', 'image/jpeg', 'image/gif')
        ORDER BY LastModifiedDate DESC LIMIT 1];
         */
        /**
         * @author            : cj.sohn@daeunextier.com
         * @description       : SOQL이 Null을 반환하여 실행되는 QueryException을 방지
         * @last modified on  : 2021-01-12
        **/
        List<Attachment> listAttachments = [SELECT Id, Name, LastModifiedDate, ContentType FROM Attachment
        WHERE parentid=:ParentId AND ContentType IN ('image/png', 'image/jpeg', 'image/gif')
        ORDER BY LastModifiedDate DESC LIMIT 1];

        if(listAttachments.size() > 0){
            return listAttachments.get(0);
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static Id saveAttachment(Id parentId, String fileName, String base64Data, String contentType) { 
        Attachment attachment = new Attachment();
        attachment.parentId = parentId;
        attachment.body = EncodingUtil.base64Decode(base64Data);
        attachment.name = fileName;
		attachment.contentType = contentType;
        insert attachment;

        // 사원 프로필 다운로드 기능에서 이미지 외부 접근 허용을 위해 도큐멘트 저장 필요 > 20190111 sy.jung
        if(String.valueOf(parentId.getSObjectType()) == 'Employee__c') {
            doSaveDocument(attachment);
        }

        return attachment.id;
    }

    private static void doSaveDocument(Attachment objAttachment) {
        Employee__c objEmployee = [SELECT   Id, Name, DocumentPhotoId__c
                                   FROM     Employee__c 
                                   WHERE    Id = :objAttachment.parentId];

        Document objDocument = new Document();

        objDocument.Id                  = objEmployee.DocumentPhotoId__c;
        objDocument.Name                = objEmployee.Name + '_증명사진';
        objDocument.DeveloperName       = objEmployee.Id + '_' + objAttachment.Id;
        objDocument.ContentType         = objAttachment.ContentType;
        objDocument.Body                = objAttachment.Body;
        objDocument.FolderId            = [SELECT Id FROM Folder WHERE DeveloperName = 'EmployeeIdPhoto'].Id;
        objDocument.IsPublic            = true;
        upsert objDocument;

        objEmployee.DocumentPhotoId__c = objDocument.Id;
        update objEmployee;
    }
   
}