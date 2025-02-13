/************************************************************************************
 * File Name   : RenewalHPDaeuProfile_Test.cls
 * Author      : SungJu.Kang
 * Date        : 2022. 01. 03
 * Target      : RenewalHPDaeuProfile.cls
 * Description : RenewalHPDaeuProfile.cls Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2022. 01. 03   SungJu.Kang            Create
*************************************************************************************/


@IsTest
private class RenewalHPDaeuProfile_Test {

    @IsTest
    static void itShould() {
        Test.startTest();

        CompanyHistory__c objCompanyHistory = new CompanyHistory__c();
        objCompanyHistory.OrderNum__c = 2;
        insert objCompanyHistory;

        RenewalHPDaeuProfile.doSearchCompanyHistory(true);
        RenewalHPDaeuProfile.doSearchCompanyHistory(false);

        Test.stopTest();


    }

}