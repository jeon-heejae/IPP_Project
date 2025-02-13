/************************************************************************************
 * File Name   : RenewalHPDaeuTrekRecord_Test.cls
 * Author      : SungJu.Kang
 * Date        : 2022. 01. 03
 * Target      : RenewalHPDaeuTrekRecord.cls
 * Description : RenewalHPDaeuTrekRecord.cls Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2022. 01. 03   SungJu.Kang            Create
*************************************************************************************/

@IsTest
private class RenewalHPDaeuTrekRecord_Test {
    @IsTest
    static void itShould() {
        Test.startTest();
        TrekRecord__c objTrekRecord = new TrekRecord__c();
        objTrekRecord.ProjectName__c = 'TESTProjectName';
        objTrekRecord.OrderNum__c = 1;
        objTrekRecord.HPCheckBox__c =true;
        insert objTrekRecord;

        RenewalHPDaeuTrekRecord.doSearchTrekRecords(true);
        RenewalHPDaeuTrekRecord.doSearchTrekRecords(false);
        RenewalHPDaeuTrekRecord.loadMoreTrekRecords(true);
        RenewalHPDaeuTrekRecord.loadMoreTrekRecords(false);
        RenewalHPDaeuTrekRecord.getRecordById(objTrekRecord.Id, true);
        RenewalHPDaeuTrekRecord.getRecordById(objTrekRecord.Id, false);
        Test.stopTest();
    }
}