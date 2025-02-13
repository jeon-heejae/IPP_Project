/************************************************************************************
 * Description :  EformsignDocumentCtrl,EformsignTokenizedApiWorkflow
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-06-27     hs.jung          Create
*************************************************************************************/
@IsTest
private class EformsignDocumentCtrl_Test {


    @IsTest
    static void testBehavior() {
        Account objAcc = TestObjectCreator.objAccount;
        insert objAcc;

        EformsignToken__c objEformsignToken = new EformsignToken__c();
        objEformsignToken.Name = 'test';
        objEformsignToken.AccessToken__c = 'test';
        objEformsignToken.RefreshToken__c = null;
        objEformsignToken.User__c = UserInfo.getUserId();
        objEformsignToken.TokenIssuedDateTime__c = System.today() + 2 ;
        objEformsignToken.ExpireIn__c = 3600;
        insert objEformsignToken;

        EformsignDocument__c objEfsDoc = new EformsignDocument__c();
        objEfsDoc.Name =' test';
        objEfsDoc.TargetObjectRecordId__c = objAcc.Id;
        insert objEfsDoc;

        Test.startTest();
        EformsignDocumentCtrl.getRelatedTemplatesBySObject('Account');
        EformsignDocumentCtrl.getDocument(objEfsDoc.Id);
        EformsignDocumentCtrl.getRelatedDocs(objEfsDoc.TargetObjectRecordId__c);
        EformsignDocumentCtrl.downloadDocument(objEfsDoc.Id, true);
        EformsignDocumentCtrl.syncDocumentInfo(objEfsDoc.Id);
        EformsignDocumentCtrl.deleteDocument(objEfsDoc.Id);
        EformsignDocumentCtrl.cancelDocument(objEfsDoc.Id,'test');
        Test.stopTest();
    }
    @IsTest
    static void testBehavior2() {
        Account objAcc = TestObjectCreator.objAccount;
        insert objAcc;

        EformsignDocument__c objEfsDoc = new EformsignDocument__c();
        objEfsDoc.Name =' test';
        objEfsDoc.TargetObjectRecordId__c = objAcc.Id;
        insert objEfsDoc;

        Test.startTest();
        EformsignDocumentCtrl.downloadDocument(objEfsDoc.Id, true);

        Test.stopTest();
    }

}