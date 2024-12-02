@isTest
public class SignaturePictureController_test {
    @testSetup
    static void setupTestData() {
        // Employee 레코드 생성
        Employee__c objEmployee = new Employee__c(Name = 'Test Employee');
        insert objEmployee;

        // contentVersion 생성 
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Sig_TestSignature';
        contentVersion.PathOnClient = 'TestSignature.png';
        contentVersion.VersionData = Blob.valueOf('Test data');
        insert contentVersion;

        List<ContentVersion> listCv = [
            SELECT Id, Title, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :contentVersion.Id
        ];

        // Employee와 ContentVersion 연결
        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId = listCv[0].contentDocumentId;
        link.ShareType = 'V'; // Viewer
        link.LinkedEntityId = objEmployee.Id;
        insert link;
    }

    @isTest
    public static void testGetSignaturePicture(){
        
        Employee__c objEmployee = [SELECT Id FROM Employee__c LIMIT 1];

        Test.startTest();
        ContentVersion signature = SignaturePictureController.getSignaturePicture(objEmployee.Id);
        Test.stopTest();
    }

    @isTest
    public static void testSaveSignaturePicture(){
        
        Employee__c employee = [SELECT Id FROM Employee__c LIMIT 1];

        
        String fileName = 'NewSignature.png';
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('New Signature Data'));

        
        Test.startTest();
        String contentDocumentId = SignaturePictureController.saveSignaturePicture(employee.Id, fileName, base64Data);
        Test.stopTest();
    }
    
}