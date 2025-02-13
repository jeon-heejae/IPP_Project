/**
 * @description       : HolidayUtil Class에 대한 Test Class
 * @author            : cj.sohn@daeunextier.com
 * @group             : DaeuNextier
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-01-20   cj.sohn@daeunextier.com   Initial Version
**/
@IsTest
public with sharing class HolidayUtil_Test {
    @IsTest
    static void createEventTest(){
        HolidayAction__c holidayAction = TestObjectCreator.objHolidayAction;
        holidayAction.HolidayAction_Days__c = 5;
        holidayAction.HolidayAction_Date2__c = holidayAction.HolidayAction_Date1__c.addDays(1);
        holidayAction.HolidayAction_Date3__c = holidayAction.HolidayAction_Date2__c.addDays(1);
        holidayAction.HolidayAction_Date4__c = holidayAction.HolidayAction_Date3__c.addDays(1);
        holidayAction.HolidayAction_Date5__c = holidayAction.HolidayAction_Date4__c.addDays(1);
        holidayAction.OwnerId = UserInfo.getUserId();
        insert holidayAction;

        Test.startTest();
        HolidayUtil.createEvent(holidayAction);
        Test.stopTest();
    }

    @IsTest
    static void setEventTest(){
        HolidayAction__c holidayAction = TestObjectCreator.objHolidayAction;
        holidayAction.HolidayAction_Type__c = 'Half-day Leave';
        holidayAction.HolidayAction_HalfdayTime__c = 'PM';
        holidayAction.OwnerId = UserInfo.getUserId();
        insert holidayAction;

        Test.startTest();
        HolidayUtil.setEvent(holidayAction, Date.today());
        Test.stopTest();
    }

    @IsTest
    static void sendEmailTest(){
        User user = TestObjectCreator.objUser;
        Holiday__c holiday = TestObjectCreator.objHoliday;
        holiday.Holiday_JoinDate__c = Date.today().addYears(-1);
        holiday.Holiday_GivenHolidays__c = 0;
        insert holiday;
        Holiday__c searchedHoliday = [SELECT Id, Holiday_IsAnnualleave__c, Holiday_User__c, Holiday_UseDays__c, Holiday_JoinDate__c, Holiday_PeriodEnd__c, Holiday_GivenHolidays__c, Holiday_Calculated__c, Holiday_Remain__c FROM Holiday__c WHERE Id =: holiday.Id LIMIT 1];
        System.debug(searchedHoliday);

        Test.startTest();
        HolidayUtil.sendEmail('Info', user, searchedHoliday);
        HolidayUtil.sendEmail('1st', user, searchedHoliday);
        HolidayUtil.sendEmail('2nd', user, searchedHoliday);
        Test.stopTest();
    }

    @IsTest
    static void sendEmailForConfirmedHoliday(){
        List<User> listUser = new List<User>();
        for(Integer i = 0; i < 5; i++){
            User user = TestObjectCreator.objUser;
            user = TestObjectCreator.objUser.clone();
            user.Id = null;
            user.Username = user.UserName + '.' + String.valueOf(i);
            user.LastName = user.LastName + String.valueOf(i);
            user.FirstName = user.FirstName + String.valueOf(i);
            user.Alias = user.Alias + String.valueOf(i);
            user.CommunityNickname = user.CommunityNickname + String.valueOf(i);
            listUser.add(user);
            System.debug(user);
        }
        insert listUser;

        List<Employee__c> listEmployee = new List<Employee__c>();
        for(Integer i = 0; i < 5; i++){
            Employee__c employee = TestObjectCreator.objEmployee;
            if(i != 0){
                employee = TestObjectCreator.objEmployee.clone();
                employee.Id = null;
            }
            employee.User__c = listUser.get(i).Id;
            switch on i {
                when 0{
                    employee.Department__c = 'LG Service';
                }
                when 1{
                    employee.Department__c = 'MGMT';
                }
                when 2{
                    employee.Department__c = 'LG Service';
                    employee.DeptPosition__c = 'Department Head';
                }
                when 3{
                    employee.Department__c = 'MGMT';
                    employee.DeptPosition__c = '부사장';
                }
                when 4{
                    employee.Department__c = 'MGMT';
                    employee.DeptPosition__c = 'General Manager';
                }
            }
            listEmployee.add(employee);
        }
        insert listEmployee;

        Project__c project = TestObjectCreator.objProject;
        project.Business__c = 'LG Service';
        insert project;

//        PerformProject__c performProject = TestObjectCreator.objPerformProject;
//        insert performProject;

        Holiday__c holiday = TestObjectCreator.objHoliday;
        insert holiday;

        HolidayAction__c holidayAction = TestObjectCreator.objHolidayAction;
        holidayAction.HolidayAction_Days__c = 1;
        holidayAction.Position__c = '프로젝트 팀원';
        holidayAction.Department__c = 'LG Service';
        holidayAction.HolidayAction_IsConfirm__c = false;
        holidayAction.Project__c = project.Id;
        insert holidayAction;

        List<Employee__c> emailRecipients = new List<Employee__c>();
        emailRecipients.add(listEmployee.get(1));
        emailRecipients.add(listEmployee.get(2));

        Test.startTest();
        HolidayUtil.sendEmailForConfirmedHoliday(emailRecipients, project, holidayAction, listEmployee.get(0));
        Test.stopTest();
    }

    @IsTest
    static void shareFinance(){
        HolidayAction__c holidayAction = TestObjectCreator.objHolidayAction;
        holidayAction.HolidayAction_Days__c = 1;
        holidayAction.OwnerId = UserInfo.getUserId();
        insert holidayAction;

        Test.startTest();
        HolidayUtil.shareFinance(holidayAction);
        Test.stopTest();
    }
}