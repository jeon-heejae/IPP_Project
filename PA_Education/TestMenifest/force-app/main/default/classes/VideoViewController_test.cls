/*************************************************************************************
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2021-04-19         smyan             Create
*************************************************************************************/

@IsTest
private class VideoViewController_test {
    @IsTest
    static void testBehavior() {
        Test.startTest();
        Education__c objEdu = new Education__c();
        objEdu.Subject__c = 'TEST';
        objEdu.Type__c = 'ALL';
        insert objEdu;
        
        
        
        String fBase64Data = '<!--  ----------------------------------------------------------------------  -->';
        fBase64Data = '<!--  NOTE: Please add the following <META> element to your page <HEAD>.      --> ';
        fBase64Data = '<!--  If necessary, please modify the charset parameter to specify the        -->';
        fBase64Data = '<!--  character set of your HTML page.                                        -->';
        Blob b = Blob.valueOf(fBase64Data);
        fBase64Data = EncodingUtil.base64Encode(b);
    
        //fBase64Data = EncodingUtil.urlDecode(fBase64Data, 'UTF-8');
    
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        //cv.ContentDocumentId = contentDocumentId;
        cv.VersionData = EncodingUtil.base64Decode(fBase64Data);
        cv.Title = 'test.txt';
        cv.PathOnClient = 'test.txt';
    
        insert cv;
    
    
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = objEdu.Id;
        cdl.ShareType = 'V';
        insert cdl;
    
        VideoViewController.doGetInitData(objEdu.Id);
        VideoViewController.getPdfData(cdl.ContentDocumentId);
        VideoViewController.testCover();
        Test.stopTest();
    }
}