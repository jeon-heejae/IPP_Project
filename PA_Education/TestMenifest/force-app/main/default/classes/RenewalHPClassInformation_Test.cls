/************************************************************************************
 * File Name   : RenewalHPClassInformation_Test.cls
 * Author      : SungJu.Kang
 * Date        : 2022. 01. 03
 * Target      : RenewalHPClassInformation.cls
 * Description : RenewalHPClassInformation.cls Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2022. 01. 03   SungJu.Kang            Create
*************************************************************************************/

@IsTest
private class RenewalHPClassInformation_Test {
    @IsTest
    static void itShould() {
        Test.startTest();

        Class__c objClass = new Class__c();
        objClass.StartDate__c = Datetime.now();
        objClass.Subject__c = 'TestSubject';
        insert objClass;

        RenewalHPClassInformation.getClassInformation(true);
        RenewalHPClassInformation.getClassInformation(false);

        Map<String, Object> mapTarget = new Map<String, Object>();
        mapTarget.put('Mobile', 01024451509);
        mapTarget.put('Register','테스트');
        mapTarget.put('ClassId', objClass.Id);
        mapTarget.put('BirthDate' , Date.today());

        RenewalHPClassInformation.doSaveApplyTo(mapTarget,'testclass', 'testdate','jpg');
        



        Test.stopTest();
    }

}