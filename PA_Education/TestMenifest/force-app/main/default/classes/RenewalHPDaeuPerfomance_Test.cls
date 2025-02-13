/************************************************************************************
 * File Name   : RenewalHPDaeuPerfomance_Test.cls
 * Author      : SungJu.Kang
 * Date        : 2022. 01. 03
 * Target      : RenewalHPDaeuPerfomance.cls
 * Description : RenewalHPDaeuPerfomance.cls Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2022. 01. 03   SungJu.Kang            Create
*************************************************************************************/

@IsTest
private class RenewalHPDaeuPerfomance_Test {
    @IsTest
    static void itShould(){
        Test.startTest();

        Performance__c objPerformance = new Performance__c();
        objPerformance.Sales__c = 100000000;
        objPerformance.HeadCount__c = 40;
        objPerformance.Date__c = Date.today();
        insert objPerformance;

        RenewalHPDaeuPerfomance.getPerformances();


        Test.stopTest();
    }
}