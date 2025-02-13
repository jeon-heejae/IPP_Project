/************************************************************************************
 * File Name   : RenewalHPNotice_Test.cls
 * Author      : SungJu.Kang
 * Date        : 2022. 01. 03
 * Target      : RenewalHPNotice.cls
 * Description : RenewalHPNotice.cls Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2022. 01. 13   SungJu.Kang            Create
*************************************************************************************/

@IsTest
private class RenewalHPNotice_Test {
    @IsTest
    static void itShould() {
        Test.startTest();
        UrgentNotice__c objUrgentNotice = new UrgentNotice__c();
        objUrgentNotice.Subject__c = 'Test Subject';
        objUrgentNotice.Description__c = 'Test Description';
        objUrgentNotice.StartDate__c = Date.today().addDays(-3);
        objUrgentNotice.EndDate__c = Date.today().addDays(3);
        insert objUrgentNotice;

        RenewalHPNotice.getUrgentNotice();

        Test.stopTest();
    }
}