/**
 * Created by Kwanwoo.Jeon on 2023-12-21.
 */

@IsTest
private class HolidayWorkApprovalController_Test {
    @TestSetup
    static void testSetup(){
        User objUser = TestObjectCreator.objUser;
        insert objUser;

        HolidayWork__c objHW = new HolidayWork__c();
        objHW.WorkingTime__c = Date.today();
        insert objHW;


        HolidayWorkDetail__c objHWD = new HolidayWorkDetail__c();
        objHWD.HolidayWork__c = objHW.Id;
        objHWD.WorkUser__c = objUser.Id;
        objHWD.Stage__c = 'Planning';
        objHWD.PlanningTime__c = '4';
        objHWD.WorkDetail__c = '4';
        insert objHWD;

    }
    @IsTest
    static void testBehavior() {
        HolidayWork__c objHW  = [SELECT id FROM HolidayWork__c limit 1];
        HolidayWorkDetail__c objHWD  = [SELECT id FROM HolidayWorkDetail__c limit 1];
        HolidayWorkApprovalController.doInit(objHW.Id);

        HolidayWorkApprovalController.doSave(
                new List<Map<String, String>>{new map<String, String>{'Id'=>objHWD.Id, 'WorkingTime' => '4'}},
                'test',
                objHW.Id);
    }
}