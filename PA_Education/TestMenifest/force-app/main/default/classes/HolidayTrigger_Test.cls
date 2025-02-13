/**
 * Created by attar on 2020-11-23.
 */

@IsTest
private class HolidayTrigger_Test {

    @TestSetup
    static void setData() {
        User objUser = TestObjectCreator.objUser;
        insert objUser;

        Employee__c objEmployee = TestObjectCreator.objEmployee;
        objEmployee.User__c = objUser.Id;
        insert objEmployee;

        Holiday__c objHoliday = TestObjectCreator.objHoliday;
        objHoliday.Holiday_User__c = objUser.Id;
        insert objHoliday;
    }
    @IsTest
    static void test() {
        Test.startTest();

        Holiday__c objHoliday = [SELECT Id FROM Holiday__c LIMIT 1];
        objHoliday.Holiday_GivenHolidays__c = 5;
        objHoliday.Holiday_NoticeLevel__c = '1st Notice';
        objHoliday.PeriodStartDate__c = Date.today();
        objHoliday.Holiday_LastActivity__c = 'test';
        update objHoliday;

        Test.stopTest();
    }
}