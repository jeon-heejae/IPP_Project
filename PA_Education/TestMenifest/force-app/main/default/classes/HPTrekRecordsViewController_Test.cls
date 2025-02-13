/**
 * Created by sjhyk on 2022-01-20.
 */

@IsTest
private class HPTrekRecordsViewController_Test {
    @IsTest
    static  void itShould() {
        Test.startTest();

        TrekRecord__c objTrekRecord = new TrekRecord__c();
        objTrekRecord.ProjectName__c = 'TESTProjectName';
        objTrekRecord.StartYear__c = '2022';
        objTrekRecord.OrderNum__c = 1;
        insert objTrekRecord;

        HPTrekRecordsViewController.doSearchTrekRecords();
        HPTrekRecordsViewController.getRecordById(objTrekRecord.Id);


        Test.stopTest();
    }
}