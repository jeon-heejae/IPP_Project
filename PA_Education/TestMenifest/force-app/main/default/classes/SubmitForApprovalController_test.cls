@IsTest
public with sharing class SubmitForApprovalController_test {
    @TestSetup
    static void testSetup() {
        Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Daeu Nextier Employee' LIMIT 1];
        User objUser = TestObjectCreator.objUser;
        objUser.ProfileId = objProfile.Id;
        objUser.Username = 'test@demo.co.kr';
        objUser.Position__c = '9';
        insert objUser;
    }

    @IsTest
    static void doTest(){
        test.startTest();
        User objUser = [SELECT Id FROM User ORDER BY CreatedDate DESC LIMIT 1];
        HolidayWork__c objHW = new HolidayWork__c();
        objHW.Status__c = '계획승인';
        objHW.Month__c = '2월';
        objHW.Year__c = '2023년';
        objHW.WorkOrderUser__c = objUser.Id;
        insert objHW;

        HolidayWorkDetail__c objHWD = new HolidayWorkDetail__c();
        objHWD.HolidayWork__c   = objHW.Id;
        objHWD.WorkUser__c      = objUser.Id;
        objHWD.Stage__c         = 'Design & Build';
        objHWD.WorkingDate__c   = Date.newInstance(2023, 2, 22);
        objHWD.WorkingTime__c   = '4';
        objHWD.WorkDetail__c    = '작업 내용';
        insert objHWD;

        objHWD.WorkUser__c = objUser.Id;

        SubmitForApprovalController.doApproval(objHW.Id, '');

        update objHWD;
        test.stopTest();
    }
}