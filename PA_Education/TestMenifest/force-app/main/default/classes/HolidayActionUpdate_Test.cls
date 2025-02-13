/**
 * @description       : HolidayActionUpdate.trigger에 대한 Test Class
 * @author            : cj.sohn@daeunextier.com
 * @group             : DaeuNextier
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   2021-01-20   cj.sohn@daeunextier.com           Initial Version
 * @.0   2023-12-22   kwanwoo.jeon@daeunextier.com      HolidayActionUpdate.trigger에서 HolidayAction_tr.apex로 이관 후 대체휴가 관련 테스트 추가
**/

@IsTest
private class HolidayActionUpdate_Test {
    @TestSetup
    static void setup() {
        List<User> listUser = new List<User>();
        for(Integer i = 0; i < 3; i++){
            User user = TestObjectCreator.objUser;
            if(i != 0){
                user = TestObjectCreator.objUser.clone();
                user.Id = null;
                user.Username = user.UserName + '.' + String.valueOf(i);
                user.LastName = user.LastName + String.valueOf(i);
                user.FirstName = user.FirstName + String.valueOf(i);
                user.Alias = user.Alias + String.valueOf(i);
                user.CommunityNickname = user.CommunityNickname + String.valueOf(i);
            }
            listUser.add(user);
            System.debug(user);
        }
        insert listUser;

        List<Employee__c> listEmployee = new List<Employee__c>();
        for(Integer i = 0; i < 3; i++){
            Employee__c employee = TestObjectCreator.objEmployee;
            if(i != 0){
                employee = TestObjectCreator.objEmployee.clone();
                employee.Id = null;
            }
            employee.User__c = listUser.get(i).Id;
            switch on i {
                when 0{
                    employee.Department__c = '사업본부';
                }
                when 1{
                    employee.Department__c = '사업1부';
                }
                when 2{
                    employee.Department__c = '사업2부';
                    employee.DeptPosition__c = 'Department Head';
                }
            }
            listEmployee.add(employee);
        }
        insert listEmployee;

        Holiday__c holiday = TestObjectCreator.objHoliday;
        holiday.Holiday_reward_Total_Count__c = 10;

        insert holiday;

        HolidayAction__c holidayAction = TestObjectCreator.objHolidayAction;
        holidayAction.HolidayAction_Days__c = 1;
        holidayAction.Position__c = '프로젝트 팀원';
        holidayAction.Department__c = '사업1부';
        holidayAction.HolidayAction_IsConfirm__c = false;
        insert holidayAction;

        Project__c project = TestObjectCreator.objProject;
        project.Business__c = '사업2부';
        insert project;

//        PerformProject__c performProject = TestObjectCreator.objPerformProject;
//        insert performProject;
    }
    
    @IsTest
    static void testAnnualHoliday() {
        HolidayAction__c holidayAction = [SELECT Id FROM HolidayAction__c LIMIT 1];
        Project__c project = [SELECT Id FROM Project__c LIMIT 1];
        Test.startTest();
        holidayAction.HolidayAction_IsConfirm__c = true;
        holidayAction.Project__c = project.Id;
        update holidayAction;

        holidayAction.Is_Cancled__c = true;
        update holidayAction;
        Test.stopTest();
    }

    @IsTest
    static void testMonthlyHoliday() {
        HolidayAction__c holidayAction = [SELECT Id FROM HolidayAction__c LIMIT 1];
        Project__c project = [SELECT Id FROM Project__c LIMIT 1];
        Test.startTest();
        holidayAction.HolidayAction_Type__c = 'Monthly Holiday';
        holidayAction.HolidayAction_IsConfirm__c = true;
        holidayAction.Project__c = project.Id;
        update holidayAction;

        holidayAction.Is_Cancled__c = true;
        update holidayAction;
        Test.stopTest();
    }

    @IsTest
    static void testHalfdayLeave() {
        HolidayAction__c holidayAction = [SELECT Id FROM HolidayAction__c LIMIT 1];
        Project__c project = [SELECT Id FROM Project__c LIMIT 1];
        Test.startTest();
        holidayAction.HolidayAction_Type__c = 'Half-day Leave';
        holidayAction.HolidayAction_IsConfirm__c = true;
        holidayAction.Project__c = project.Id;
        update holidayAction;

        holidayAction.Is_Cancled__c = true;
        update holidayAction;
        Test.stopTest();
    }

    @IsTest
    static void testWomenHoliday() {
        HolidayAction__c holidayAction = [SELECT Id FROM HolidayAction__c LIMIT 1];
        Project__c project = [SELECT Id FROM Project__c LIMIT 1];
        Test.startTest();
        holidayAction.HolidayAction_Type__c = 'Women Holiday';
        holidayAction.HolidayAction_IsConfirm__c = true;
        holidayAction.Project__c = project.Id;
        update holidayAction;

        holidayAction.Is_Cancled__c = true;
        update holidayAction;
        Test.stopTest();
    }

    @IsTest
    static void testPublicWorks() {
        HolidayAction__c holidayAction = [SELECT Id FROM HolidayAction__c LIMIT 1];
        Project__c project = [SELECT Id FROM Project__c LIMIT 1];
        Test.startTest();
        holidayAction.HolidayAction_Type__c = 'Public Works';
        holidayAction.HolidayAction_IsConfirm__c = true;
        holidayAction.Project__c = project.Id;
        update holidayAction;

        holidayAction.Is_Cancled__c = true;
        update holidayAction;
        Test.stopTest();
    }

    @IsTest
    static void testSickLeave() {
        HolidayAction__c holidayAction = [SELECT Id FROM HolidayAction__c LIMIT 1];
        Project__c project = [SELECT Id FROM Project__c LIMIT 1];
        Test.startTest();
        holidayAction.HolidayAction_Type__c = 'Sick Leave';
        holidayAction.HolidayAction_IsConfirm__c = true;
        holidayAction.Project__c = project.Id;
        update holidayAction;

        holidayAction.Is_Cancled__c = true;
        update holidayAction;
        Test.stopTest();
    }

    @IsTest
    static void testRewardHoliday() {
        HolidayAction__c holidayAction = [SELECT Id FROM HolidayAction__c LIMIT 1];
        Project__c project = [SELECT Id FROM Project__c LIMIT 1];
        Test.startTest();
        holidayAction.HolidayAction_Type__c = 'Reward Holiday';
        holidayAction.HolidayAction_IsConfirm__c = true;
        holidayAction.Project__c = project.Id;
        update holidayAction;

        holidayAction.Is_Cancled__c = true;
        update holidayAction;
        Test.stopTest();
    }
}