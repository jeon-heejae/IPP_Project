/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-06-27     hs.jung          Create
*************************************************************************************/
@isTest
public with sharing class EformsignTemplatePageCtrl_test {
    @isTest
    static void testConstructor() {
        // Test constructor initialization
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(new List<Account>());
        EformsignTemplatePageCtrl controller = new EformsignTemplatePageCtrl(stdController);
        System.assertNotEquals(null, controller.tokenUser);
        System.assertNotEquals(null, controller.tokenManager);
    }

    @isTest
    static void testtamplateMap() {
        Map<String, String> tamplateMap = new Map<String, String>();
        tamplateMap.put('objectApiName', 'Account');
        tamplateMap.put('templateId', 'templateId1234');
        tamplateMap.put('templateVersion', '1');
        tamplateMap.put('templateName', 'templateName22');

        List<Map<String, String>> fieldInofs = new List<Map<String, String>>();

        fieldInofs.add(tamplateMap);

        EformsignTemplate__c objEformsignTemplate = new EformsignTemplate__c();
        objEformsignTemplate.Name = tamplateMap.get('templateName');
        objEformsignTemplate.ObjectApiName__c =  tamplateMap.get('objectApiName');
        objEformsignTemplate.TemplateId__c = tamplateMap.get('templateId');
        objEformsignTemplate.TemplateVersion__c =  Integer.valueof(tamplateMap.get('templateVersion'));
        insert objEformsignTemplate;


        Test.startTest();
        EformsignTemplatePageCtrl.getSObjectInfo('Account');
        EformsignTemplatePageCtrl.upsertTemplate(true, tamplateMap, fieldInofs);
        Test.stopTest();

    }
//    // Mock UserInfoProvider
//    private class MockUserInfoProvider implements EformsignTemplatePageCtrl {
//        public String tokenUserEmail() { return 'mock@example.com'; }
//    }





}