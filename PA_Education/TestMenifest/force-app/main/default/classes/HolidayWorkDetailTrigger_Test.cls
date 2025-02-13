/**
 * @description       : HolidayWorkDetailTrigger.trigger에 대한 Test Class
 * @author            : jinwoo.jang@daeunextier.com
 * @group             : DaeuNextier
 * Modifications Log 
 * Ver   Date         Author                        Modification
 * 1.0   2023-02-08   jinwoo.jang@daeunextier.com   Initial Version
**/
@IsTest
private class HolidayWorkDetailTrigger_Test {
    @TestSetup
    static void testSetup() {
        Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Daeu Nextier Employee' LIMIT 1];
        User objUser = TestObjectCreator.objUser;
        objUser.Username = 'test@demo.co.kr';
        insert objUser;
    }

    @IsTest
    static void testInsertHolidayWork() {
        User objUser = [SELECT Id, UserRole.Name FROM User ORDER BY CreatedDate DESC LIMIT 1];

        Test.startTest();
        System.runAs(objUser) {
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
            update objHWD;
        }

        Test.stopTest();
    }

    @IsTest
    static void testInsertHolidayWork2() {
            User objUser = [SELECT Id, Username FROM User ORDER BY CreatedDate DESC LIMIT 1];

            Test.startTest();
            System.runAs(objUser) {
                Project__c project = TestObjectCreator.objProject;
                project.Business__c = 'LG Service';
                insert project;

                Employee__c objEmployee = TestObjectCreator.objEmployee;
                objEmployee.User__c = objUser.Id;
                insert objEmployee;

                PerformProject__c objPP = new PerformProject__c();
                objPP.Project__c  = project.Id;
                objPP.Employee__c = objEmployee.Id;
                objPP.IsPM__c = true;
                insert objPP;

                HolidayWork__c objHW2 = new HolidayWork__c();
                objHW2.Project__c       = project.Id;
                objHW2.Status__c        = '계획작성중';
                objHW2.Month__c         = '2월';
                objHW2.Year__c          = '2023년';
                objHW2.WorkOrderUser__c = objUser.Id;
                insert objHW2;

                HolidayWorkDetail__c objHWD = new HolidayWorkDetail__c();
                objHWD.HolidayWork__c   = objHW2.Id;
                objHWD.WorkUser__c      = objUser.Id;
                objHWD.Stage__c         = 'Design & Build';
                objHWD.WorkingDate__c   = Date.newInstance(2023, 2, 22);
                objHWD.WorkDetail__c    = '작업 내용';
                insert objHWD;

                HolidayWorkDetail__c objHWD2 = objHWD.clone();
                insert objHWD2;

                update objHWD;
            }

            Test.stopTest();
    }

    @IsTest
    static void testInsertHolidayWork3() {
        Test.startTest();
        Project__c project = TestObjectCreator.objProject;
        project.PM__c = UserInfo.getUserId();
        project.Business__c = 'LG Service';
        project.PM__c = UserInfo.getUserId();
        insert project;

        HolidayWork__c objHW2 = new HolidayWork__c();
        objHW2.Project__c = project.Id;
        objHW2.Status__c = '계획작성중';
        objHW2.Month__c = '2월';
        objHW2.Year__c = '2023년';
        objHW2.WorkOrderUser__c = UserInfo.getUserId();
        insert objHW2;

        HolidayWorkDetail__c objHWD = new HolidayWorkDetail__c();
        objHWD.HolidayWork__c   = objHW2.Id;
        objHWD.WorkUser__c      = UserInfo.getUserId();
        objHWD.Stage__c         = 'Design & Build';
        objHWD.WorkingDate__c   = Date.newInstance(2023, 2, 22);
        objHWD.WorkDetail__c    = '작업 내용';
        insert objHWD;

        Test.stopTest();
    }
}