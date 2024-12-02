public with sharing class MediaPlayerCtrl {
    @AuraEnabled
    public static List<ContentVersion> getFirstFile(Id recordId) {
        List<ContentVersion> listCV = new List<ContentVersion>();
        List<ContentDocumentLink> listCDL = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId =:recordId
        ];
        Set<Id> setContentDocumnetId = new Set<Id>();
        List<ContentVersion> listCD = new List<ContentVersion>();
        
        // String baseURL = '/sfc/servlet.shepherd/version/download/';
        String baseURL = URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/';
        if(!listCDL.isEmpty()){
            for(ContentDocumentLink objCDL : listCDL){
                setContentDocumnetId.add(objCDL.ContentDocumentId);
            }
            for(ContentVersion objCD : [SELECT Id, Title, FileType, ContentUrl, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =:setContentDocumnetId]){
                objCD.put('ContentUrl', baseURL + objCD.ContentDocumentId);
                listCD.add(objCD);
            }
            System.debug('listCD >>' + listCD);
            return listCD;
        }
        return null;


        // // ContentDocumentLink에서 관련된 첫 번째 파일을 가져옴
        // ContentDocumentLink[] fileLinks = [
        //     SELECT ContentDocumentId, Id 
        //     FROM ContentDocumentLink 
        //     WHERE LinkedEntityId = :recordId 
        //     LIMIT 1
        // ];
        // if (!fileLinks.isEmpty()) {
        //     // ContentVersion을 가져와서 전체 파일 URL 생성
        //     ContentVersion[] fileVersions = [SELECT Id, Title, FileType, ContentUrl 
        //                                      FROM ContentVersion 
        //                                      WHERE ContentDocumentId = :fileLinks[0].ContentDocumentId 
        //                                      LIMIT 1];

            
        //     if (!fileVersions.isEmpty()) {
        //         ContentVersion file = fileVersions[0];
        //         // PDF 전체를 미리 보기 위한 URL 구성
        //         file.put('ContentUrl', '/sfc/servlet.shepherd/version/download/' + fileVersions[0].Id);
        //         // file.put('ContentUrl', '/sfc/servlet.shepherd/version/download/068NS00000HRByTYAX');

                
        //         System.debug('file >>' + file);
        //         return file;
        //     }
        // }
        // return null;
        

    }
}