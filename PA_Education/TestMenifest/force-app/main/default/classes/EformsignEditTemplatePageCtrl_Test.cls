/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-07-04     hs.jung          Create
*************************************************************************************/
@isTest
public with sharing class EformsignEditTemplatePageCtrl_Test {
    @isTest
    static void testConstructor() {
        // Test constructor initialization
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(new List<Account>());
        EformsignEditTemplatePageCtrl controller = new EformsignEditTemplatePageCtrl(stdController);
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
        EformsignEditTemplatePageCtrl.getSObjectInfo('Account');
        EformsignEditTemplatePageCtrl.upsertTemplate(true, tamplateMap, fieldInofs);
        Test.stopTest();

    }
}