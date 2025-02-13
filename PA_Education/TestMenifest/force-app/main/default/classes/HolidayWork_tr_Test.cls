/**
 * Created by yj.kim on 2023-06-09.
 */

@IsTest
public with sharing class HolidayWork_tr_Test {
    @TestSetup
    static void testSetup() {
        Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Daeu Nextier Employee' LIMIT 1];

        User objUser = TestObjectCreator.objUser;
        objUser.LastName = 'testest';
        objUser.ProfileId = objProfile.Id;
        objUser.Position__c = '9';
        insert objUser;

        User objUser2 = objUser.clone();
        objUser2.LastName = 'testest2';
        objUser2.Username = 'test13@demo.co';
        objUser2.CommunityNickname = 'tt';
        objUser2.Position__c = '9';
        insert objUser2;

        Project__c objProject = TestObjectCreator.objProject;
        objProject.PM__c = objUser.Id;
        insert objProject;

//        Employee__c objEmployee = TestObjectCreator.objEmployee;
//        objEmployee.User__c = objUser2.Id;
//        insert objEmployee;

        PerformProject__c objPP = TestObjectCreator.objPerformProject;
        objPP.Employee__c = [SELECT Id FROM Employee__c ORDER BY CreatedDate DESC LIMIT 1].Id;
        objPP.IsPM__c = true;
        insert objPP;
    }

    @IsTest
    static void testUpdateHoliday() {
        User objUser = [SELECT Id, UserRoleId, Position__c FROM User WHERE LastName = 'testest'ORDER BY CreatedDate DESC LIMIT 1];
        System.debug('123123123 ' + objUser.Position__c);
        PerformProject__c performProject = [SELECT Project__c, Id, Employee__c, Employee__r.User__c FROM PerformProject__c ORDER BY CreatedDate LIMIT 1];
        User objUser2 = [SELECT Id FROM User WHERE Id =: performProject.Employee__r.User__c LIMIT 1];

        Test.startTest();
        System.runAs(objUser2) {
            HolidayWork__c objHW3 = new HolidayWork__c();
            objHW3.Project__c       = performProject.Project__c;
            objHW3.Status__c        = '계획작성중';
            objHW3.Month__c         = '2월';
            objHW3.Year__c          = '2023년';
            objHW3.WorkOrderUser__c = objUser.Id;
            objHW3.WorkingTime__c   = Date.today();
            insert objHW3;
        }

        System.runAs(objUser) {
            Project__c project = [SELECT Id FROM Project__c ORDER BY CreatedDate DESC LIMIT 1];
            Employee__c objEmployee = TestObjectCreator.objEmployee;
            objEmployee.User__c = objUser.Id;
            insert objEmployee;

            HolidayWork__c objHW2 = new HolidayWork__c();
            objHW2.Project__c       = project.Id;
            objHW2.Status__c        = '계획작성중';
            objHW2.Month__c         = '2월';
            objHW2.Year__c          = '2023년';
            objHW2.WorkOrderUser__c = objUser.Id;
            objHW2.WorkingTime__c   = Date.today();
            insert objHW2;

            HolidayWorkDetail__c objHWD = new HolidayWorkDetail__c();
            objHWD.HolidayWork__c   = objHW2.Id;
            objHWD.WorkUser__c      = objUser.Id;
            objHWD.Stage__c         = 'Design & Build';
            objHWD.WorkDetail__c    = '작업 내용';
            objHWD.WorkingDate__c   = Date.today();
            insert objHWD;

            objHW2.Status__c = '근무승인요청';
            update objHW2;

            objHW2.Status__c = '계획승인';
            update objHW2;

            objHWD.WorkingTime__c = '4';
            update objHWD;

            objHW2.Is_Confirm__c = true;
            update objHW2;

            objHW2.Is_Confirm__c = false;
            update objHW2;
        }

        Test.stopTest();
    }
}