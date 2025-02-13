public with sharing class imageUploadController {
    @AuraEnabled
    public static Boolean saveImage(Id parentId, String fileName, String base64Data) {
        try {
            //String fileName='pngwing.com.png';
            String strTitle='SAMPLE';
            if(String.isNotBlank(fileName)){
                strTitle=fileName.substring(0,fileName.lastIndexOf('.'));
                //System.debug('strTitle: '+strTitle);
            }
            
            
            ContentVersion cv = new ContentVersion(
                Title = strTitle,
                PathOnClient = fileName,
                VersionData = EncodingUtil.base64Decode(base64Data),
                FirstPublishLocationId = parentId
            );
            System.debug('encoding: '+ EncodingUtil.base64Decode(base64Data));
            insert cv;
            return true;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            return false;
        }
    }

}