/**
 * Created by JWJANG on 2023-01-18.
 */

@isTest
public with sharing class NewHolidayLightningExtension_Test {
    @isTest
    static void NewHolidayLightningExtension_Test() {
        test.startTest();

        HolidayAction__c objHA = TestObjectCreator.objHolidayAction;
        HolidayAction__c objHA2 = objHa.clone();
        objHA2.HolidayAction_Type__c = 'Half-day Leave';
        HolidayAction__c objHA3 = objHa.clone();
        objHA3.HolidayAction_Type__c = 'Women Holiday';
        HolidayAction__c objHA3_1 = objHa3.clone();
        HolidayAction__c objHA4 = objHa.clone();
        objHA4.HolidayAction_Type__c = 'Reward Holiday';

        NewHolidayLightningExtension.doHolidayAction(new HolidayAction__c());
        Map<String, String> mapResult = NewHolidayLightningExtension.doHolidayAction(objHA);
        mapResult = NewHolidayLightningExtension.doHolidayAction(objHA2);
        mapResult = NewHolidayLightningExtension.doHolidayAction(objHA3);
        mapResult = NewHolidayLightningExtension.doHolidayAction(objHA3_1);
        mapResult = NewHolidayLightningExtension.doHolidayAction(objHA4);
        System.debug('testClass :: ' + mapResult);

        NewHolidayLightningExtension.getSelectFieldName();
        NewHolidayLightningExtension.selfApproverCheck();
        List<User> listUsers = [SELECT Id, ApprovalLine1__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        User objUser = TestObjectCreator.objUser;
        update objUser;
        if (!listUsers.isEmpty()) {
            listUsers[0].ApprovalLine1__c = objUser.Id;
        }
        update listUsers;


        NewHolidayLightningExtension.getApproverId();
        NewHolidayLightningExtension.employeeStatus();
        Project__c objPrj = TestObjectCreator.objProject;
        insert objPrj;
        NewHolidayLightningExtension.getProjectPmId(objPrj.Id);
        NewHolidayLightningExtension.getHolidayRemain();

        test.stopTest();

    }
}