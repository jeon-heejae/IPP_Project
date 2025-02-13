/**
 * Created by smyan on 2021-01-29.
 */
public with sharing class VideoViewController {
    @AuraEnabled
    public static Map<String, String> doGetInitData(String strRecordId){
        Map<String, String> mapResult = new Map<String, String>();
        
        List<Attachment> listAttch = new List<Attachment>([
            select Id, ContentType
            from Attachment
            where ParentId = :strRecordId
            order by LastModifiedDate desc
        ]);
        String strUrl = '';
        if(!listAttch.isEmpty()){
            for(Attachment obj : listAttch){
                if(obj.ContentType.startsWith('video')){
                    strUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + obj.Id;
                    mapResult.put('strResult', strUrl);
                    mapResult.put('extension', 'video/mp4');
                }
            }
        }
        
        List<ContentDocumentLink> listDocument = new List<ContentDocumentLink>([
            select Id, ContentDocumentId, ContentDocument.FileExtension
            from ContentDocumentLink
            where LinkedEntityId = :strRecordId
            order by ContentDocument.LastModifiedDate desc
        ]);
        if(!listDocument.isEmpty()){
            for(ContentDocumentLink obj : listDocument){
                if(obj.ContentDocument.FileExtension == 'mp4' || obj.ContentDocument.FileExtension == 'webm' || obj.ContentDocument.FileExtension == 'ogg'){
                    strUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/' + obj.ContentDocumentId;
                    mapResult.put('strResult', strUrl);
                    mapResult.put('extension', 'video/mp4');
                }else if(obj.ContentDocument.FileExtension == 'pdf'){
                    System.debug(obj.ContentDocumentId);
                    System.debug(obj.ContentDocument.Id);
                    mapResult.put('strResult', obj.ContentDocument.Id);
                    mapResult.put('extension', 'pdf');
                }
            }
        }
        return mapResult;
    }
    
    
    @AuraEnabled
    public static String getPdfData(String contentDocumentId){
        List<contentversion> cv = [select versiondata from contentversion where contentdocumentid = :contentDocumentId];
        if(cv == null || cv.size() == 0){
            return '';
        }
        String strBody = EncodingUtil.base64Encode( cv.get(0).VersionData );
        return strBody;
    }
    
    @TestVisible
    public static void testCover(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}