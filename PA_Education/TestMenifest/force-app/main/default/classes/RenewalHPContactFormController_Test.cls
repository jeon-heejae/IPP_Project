/**
 * @description       : Test Class for RenewalHPContactFormController.cls
 * @author            : CJSohn
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   2022-01-30   CJSohn        Initial Version
**/
@IsTest
private class RenewalHPContactFormController_Test {
    @IsTest
    static void itShould() {
        Test.startTest();

        Class__c objClass = new Class__c();
        objClass.StartDate__c = Datetime.now();
        objClass.Subject__c = 'TestSubject';
        insert objClass;

        RenewalHPContactFormController.getPickListValues('Lead__c','Type__c');

        Map<String, Object> mapTarget = new Map<String, Object>();
        mapTarget.put('Name', 'CJ Sohn');
        mapTarget.put('Company', 'Daeu Nextier');
        mapTarget.put('Mobile', '010-4231-3017');
        mapTarget.put('Email', 'cj.sohn@daeunextier.com');
        mapTarget.put('LeadType', '');
        mapTarget.put('Subject', 'Subject');
        mapTarget.put('Description', 'Description');

        RenewalHPContactFormController.doSave(mapTarget);

        Test.stopTest();
    }
}