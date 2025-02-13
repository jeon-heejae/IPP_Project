/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-06-26     hs.jung          Create
*************************************************************************************/
@IsTest
private class EformsignTemplateCtrl_Test {
    @IsTest
    static void testBehavior() {

        EformsignTemplate__c objEformsignTemplate = new EformsignTemplate__c();
        objEformsignTemplate.Name = 'test';
        objEformsignTemplate.ObjectApiName__c = 'Account';
        objEformsignTemplate.TemplateId__c = 'TemplateId';
        insert objEformsignTemplate;

        test.startTest();

        EformsignTemplateCtrl.deleteTemplate(objEformsignTemplate.TemplateId__c );
        EformsignTemplateCtrl.getTemplatesBySObject('Account');
        test.stopTest();
    }




}