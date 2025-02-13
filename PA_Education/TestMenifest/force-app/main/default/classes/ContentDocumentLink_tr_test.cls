/**
 * Created by 최지수 on 2022-12-28.
 */
@IsTest
private with sharing class ContentDocumentLink_tr_test {
    @IsTest
    static void doTest(){
        String myString = 'StringToBlob';
        Blob myBlob = Blob.valueOf(myString);

        Employee__c ep = new Employee__c();
        ep.Id = null;
        insert ep;

        Qualification__c Qlf = new Qualification__c();
        Qlf.Employee_Name__c = ep.Id;
        Qlf.ExpirationDate__c = Date.newInstance(2099, 12, 31);
        insert Qlf;

        ContentVersion cv = new ContentVersion();
        cv.Title = 'test';
        cv.PathOnClient = 'test';
        cv.VersionData = myBlob;
        insert cv;

        Test.startTest();
        ContentDocumentLink Cdl = new ContentDocumentLink(
                ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId,
                LinkedEntityId = Qlf.Id
        );
        insert Cdl;
        Test.stopTest();
    }
}