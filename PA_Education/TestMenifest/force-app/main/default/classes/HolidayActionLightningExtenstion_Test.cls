/*
* Component Name                : HolidayActionLightning.cmp
* Component Controller          : HolidayActionLightningController.js
* Component Helper              : HolidayActionLightningHelper.js
* Component Contorlller Class   : HolidayActionLightningExtension.cls
* Test Class                    : HolidayActionLightningExtension_Test.cls
* Description                   : 휴일관리 라이트닝 신청 폼 TEST
* Modification Log 
* =============================================================== 
* Ver     Date          Author           Modification
* ===============================================================
  1.0   2018.08.27      JK.lee              Create
  1.0   2018.12.28      JK.lee              Modified

  ----- ORG가 변경될 때  System Profile 이름을 확인해 getProfile 선언-> ERROR 발생
*/  


@isTest
private class HolidayActionLightningExtenstion_Test{

    @IsTest static void HolidayActionLightningExtenstion_Test(){

        Test.startTest();

        /*00e90000001qLEaAAM*/
        //Profile p = [select id from Profile where Name='System Administrator'];
        Profile p = new Profile();
        p = TestDataFactory.getProfile('System Admin');   

        /*실제신청자*/
        User user = new User(Alias = 'testUser'
                            , Email='SysAdminTestuser@earth.org'
                            , EmailEncodingKey='UTF-8'
                            , LastName='Testing'
                            , LanguageLocaleKey='en_US'
                            , LocaleSidKey='en_US'
                            , EmployeeNumber='AC100000'
                            , ProfileId = p.Id
                            , TimeZoneSidKey='Asia/Seoul'
                            , UserName='SysAdminTestuser@earth.org'
                            , Position__c = '9');
                                
        insert user;

        /*1차승인자*/
        User user1 = new User(Alias = 'UserTest'
                            , Email='SysAdminTestuser@earth.org'
                            , EmailEncodingKey='UTF-8'
                            , LastName='Testing1'
                            , LanguageLocaleKey='en_US'
                            , LocaleSidKey='en_US'
                            , EmployeeNumber='AC100001'
                            , ProfileId = p.Id
                            , TimeZoneSidKey='Asia/Seoul'
                            , UserName='SysAdminUserTest@earth.org'
                            , Position__c = '9');
                                
        insert user1;

      Holiday__c spq = new Holiday__c();
        spq.Holiday_UseDays__c = 1;
        spq.Holiday_User__c = user.Id;

        insert spq;
        
        System.debug(HolidayActionLightningExtension.getSelectFieldName());

        HolidayAction__c listSave = new HolidayAction__c();    
        listSave.FirstHolidayRequest__c = user1.Id;
        listSave.SecondApproverSelection__c = false;
        listSave.HolidayAction_Parent__c = spq.Id;
        listSave.Name = '휴가신청합니다.';
        listSave.HolidayAction_Date1__c = Date.newInstance(2018, 7,30);
        listSave.HolidayAction_Date2__c = Date.newInstance(2018, 7,31);
        listSave.HolidayAction_Date3__c = Date.newInstance(2018, 8,1);
        listSave.HolidayAction_Date4__c = Date.newInstance(2018, 8,2);
        listSave.HolidayAction_Date5__c = Date.newInstance(2018, 8,3);
        listSave.HolidayAction_Days__c = 1;
        listSave.HolidayAction_HalfdayTime__c='AM';
        listSave.HolidayAction_IsEmergency__c=false;
        listSave.HolidayAction_Type__c='Women Holiday';
        spq.Holiday_JoinDate__c = system.today().addYears(-2).addDays(1);
        spq.Holiday_LastActivity__c = '1';
          

        HolidayActionLightningExtension.doHolidayAction(listSave, user.Id);
        System.debug(HolidayActionLightningExtension.selfApproverCheck());

        User user2 = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        user2.ApprovalLine1__c = 'ApprovalLine1/ApprovalLine1/0059000000UJxUFAA1/';
        update user2;
        System.debug(HolidayActionLightningExtension.getApproverId());

        Employee__c employee = TestObjectCreator.objEmployee;
        employee.Name = UserInfo.getUserName();
        employee.Department__c = 'LG Service';
        employee.Position__c = '8';

        PerformProject__c performProject = TestObjectCreator.objPerformProject;
        insert performProject;
        System.debug(HolidayActionLightningExtension.employeeStatus());

        Test.stopTest();
    }
}





/**
 * An apex page controller that exposes the change password functionality
 */
//@IsTest public with sharing class ChangePasswordControllerTest {
//    @IsTest(SeeAllData=true) public static void testChangePasswordController() {
//        // Instantiate a new controller with all parameters in the page
//        ChangePasswordController controller = new ChangePasswordController();
//        controller.oldPassword = '123456';
//        controller.newPassword = 'qwerty1'; 
//        controller.verifyNewPassword = 'qwerty1';                
        
//        System.assertEquals(controller.changePassword(),null);                           
//    }    
//}