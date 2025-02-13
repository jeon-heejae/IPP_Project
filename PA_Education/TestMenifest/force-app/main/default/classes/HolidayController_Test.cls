/*
* Component Name                : MyHolidayInfoLightning.cmp
* Component Controller          : MyHolidayInfoLightningController.js
* Component Helper              : MyHolidayInfoLightningHelper.js
* Component Contorlller Class   : HolidayController.cls
* Test Class                    : HolidayController_Test.cls
* Description                   : 휴가정보 Detail Test
* Modification Log 
* =============================================================== 
* Ver     Date          Author           Modification
* ===============================================================
  1.0   2018.08.27      JK.Lee             Create
  1.0   2018.11.20                         Modified
*/

@isTest
public class HolidayController_Test {
    static User testUser;

    @isTest
    static void HolidayController_Test() {

        Test.startTest();

        Profile p = TestDataFactory.getProfile('System Admin');
        Profile p2 = TestDataFactory.getProfile('System Admin');

        testUser = TestDataFactory.createUser(p);
        HolidayEditListController hel = new HolidayEditListController();
        hel.doCreate();
        string id = testUser.id;

        HolidayAction__c ha = new HolidayAction__c();
        ha.HolidayAction_Parent__c = id;
        ApexPages.StandardController ctrl = new ApexPages.StandardController(ha);

        HolidayActionExtension hae = new HolidayActionExtension(ctrl);
        //hae.hldyActn.Name = 'test';
        //hae.hldyActn.FirstHolidayRequest__c = testUser.Id;
        //hae.hldyActn.HolidayAction_Description__c = 'test';
        //hae.hldyActn.HolidayAction_Parent__c = id;
        //hae.hldyActn.HolidayAction_IsConfirm__c = false;
        //hae.hldyActn.HolidayAction_IsEmergency__c = false;
        //hae.hldyActn.HolidayAction_Type__c = 'Alternative Holiday Register';
        //hae.typeCheck();
        //hae.hldyActn.HolidayAction_Type__c = 'Monthly Holiday';
        //hae.typeCheck();
        //hae.hldyActn.HolidayAction_Days__c = 6;
        //hae.changeDay();
        //hae.hldyActn.HolidayAction_Days__c = 5;
        //hae.doSave();
        //hae.doCancel();

        ha = new HolidayAction__c();
        ha.HolidayAction_Parent__c = id;
        ctrl = new ApexPages.StandardController(ha);
        hae = new HolidayActionExtension(ctrl);
        hae.hldyActn.Name = 'test';
        hae.hldyActn.FirstHolidayRequest__c = testUser.Id;
        hae.hldyActn.HolidayAction_Description__c = 'test';
        hae.hldyActn.HolidayAction_Parent__c = id;
        hae.hldyActn.HolidayAction_IsConfirm__c = false;
        hae.hldyActn.HolidayAction_IsEmergency__c = false;
        hae.hldyActn.HolidayAction_Type__c = 'Women Holiday';
        hae.typeCheck();
        hae.doSave();
        hae.doCancel();

        ha = new HolidayAction__c();
        ha.HolidayAction_Parent__c = id;
        ctrl = new ApexPages.StandardController(ha);
        hae = new HolidayActionExtension(ctrl);
        hae.hldyActn.Name = 'test';
        hae.hldyActn.FirstHolidayRequest__c = testUser.Id;
        hae.hldyActn.HolidayAction_Description__c = 'test';
        hae.hldyActn.HolidayAction_Parent__c = id;
        hae.hldyActn.HolidayAction_IsConfirm__c = false;
        hae.hldyActn.HolidayAction_IsEmergency__c = false;
        hae.hldyActn.HolidayAction_Type__c = 'Annual Holiday';
        hae.typeCheck();
        hae.doSave();
        hae.doCancel();

        ha = new HolidayAction__c();
        ha.HolidayAction_Parent__c = id;
        ctrl = new ApexPages.StandardController(ha);
        hae = new HolidayActionExtension(ctrl);
        hae.hldyActn.Name = 'test';
        hae.hldyActn.FirstHolidayRequest__c = testUser.Id;
        hae.hldyActn.HolidayAction_Description__c = 'test';
        hae.hldyActn.HolidayAction_Parent__c = id;
        hae.hldyActn.HolidayAction_IsConfirm__c = false;
        hae.hldyActn.HolidayAction_IsEmergency__c = false;
        hae.hldyActn.HolidayAction_Type__c = 'Public Works';
        hae.typeCheck();
        hae.doSave();
        hae.doCancel();

        ha = new HolidayAction__c();
        ha.HolidayAction_Parent__c = id;
        ctrl = new ApexPages.StandardController(ha);
        hae = new HolidayActionExtension(ctrl);
        hae.hldyActn.Name = 'test';
        hae.hldyActn.FirstHolidayRequest__c = testUser.Id;
        hae.hldyActn.HolidayAction_Description__c = 'test';
        hae.hldyActn.HolidayAction_Parent__c = id;
        hae.hldyActn.HolidayAction_IsConfirm__c = false;
        hae.hldyActn.HolidayAction_IsEmergency__c = false;
        hae.hldyActn.HolidayAction_Type__c = 'Sick Leave';
        hae.typeCheck();
        hae.doSave();
        hae.doCancel();

        //string refId = '';
        //ha = new HolidayAction__c();
        //ha.HolidayAction_Parent__c = id;
        //ctrl = new ApexPages.StandardController(ha);  
        //hae = new HolidayActionExtension(ctrl);
        //hae.hldyActn.Name = 'test';
        //hae.hldyActn.FirstHolidayRequest__c = testUser.Id;
        //hae.hldyActn.HolidayAction_Description__c = 'test';
        //hae.hldyActn.HolidayAction_Parent__c = id;
        //hae.hldyActn.HolidayAction_IsConfirm__c = false;
        //hae.hldyActn.HolidayAction_IsEmergency__c = false;
        //hae.hldyActn.HolidayAction_Type__c = 'Alternative Holiday Register';
        //hae.typeCheck();
        //hae.doSave();
        //hae.doCancel();


        //refId = [SELECT Id FROM HolidayAction__c WHERE HolidayAction_Type__c = 'Alternative Holiday Register'].Id;
        //ha = new HolidayAction__c();
        //ha.HolidayAction_Parent__c = id;
        //ctrl = new ApexPages.StandardController(ha);   
        //hae = new HolidayActionExtension(ctrl);
        //hae.hldyActn.Name = 'test';
        //hae.hldyActn.FirstHolidayRequest__c = testUser.Id;
        //hae.hldyActn.HolidayAction_Description__c = 'test';
        //hae.hldyActn.HolidayAction_Parent__c = id;
        //hae.hldyActn.HolidayAction_IsConfirm__c = false;
        //hae.hldyActn.HolidayAction_IsEmergency__c = true;
        //hae.hldyActn.HolidayAction_Type__c = 'Alternative Holiday';
        //hae.hldyActn.HolidayAction_AlternativeBase__c = refId;
        //hae.typeCheck();
        //hae.doSave();
        //hae.doCancel();

        list<HolidayAction__c> haLst = [SELECT Id FROM HolidayAction__c];
        for (HolidayAction__c has : haLst) {
            has.HolidayAction_IsConfirm__c = true;
        }
        update haLst;

//        HolidayEditListController hels = new HolidayEditListController();
//        hels.doCreate();
//        System.debug('hels.hldChkLst.size() : ' + hels.hldChkLst.size());
//        ApexPages.currentPage().getParameters().put('sfdc.userId', hels.hldChkLst[0].hld.Holiday_User__c);
//        String ids = ApexPages.currentPage().getParameters().get('sfdc.userId');
//        system.assertEquals(true, ids != null);
//        Holiday__History hh = new Holiday__History(ParentId = hels.hldChkLst[0].hld.Id, Field = 'Holiday_LastActivity__c');
//        Holiday__History hh2 = new Holiday__History(ParentId = hels.hldChkLst[0].hld.Id, Field = 'Holiday_LastActivity__c');
//        Holiday__History hh3 = new Holiday__History(ParentId = hels.hldChkLst[0].hld.Id, Field = 'Holiday_LastActivity__c');

//        insert hh;
//        insert hh2;
//        hels.hldChkLst[0].hld.Holiday_LastActivity__c = 'test';
//        update hels.hldChkLst[0].hld;
//        insert hh3;


        HolidayEditListController heledit = new HolidayEditListController();
        heledit.doCreate();
        heledit.search();
        //heledit.hldChkLst[0].hld.Holiday_JoinDate__c = system.today().addYears(-2).addDays(1);
        //heledit.hldChkLst[0].hld.Holiday_LastActivity__c = '1';
        //heledit.hldChkLst[1].hld.Holiday_JoinDate__c = system.today().addYears(-1).addMonths(-6).addDays(1);
        //heledit.hldChkLst[1].hld.Holiday_LastActivity__c = '2';
        //heledit.hldChkLst[2].hld.Holiday_JoinDate__c = system.today().addYears(-1).addMonths(-10).addDays(1);
        //heledit.hldChkLst[2].hld.Holiday_LastActivity__c = '3';
        heledit.doSave();
        list<Holiday__c> hLst = [SELECT Holiday_LastActivity__c, Holiday_PeriodEnd__c FROM Holiday__c];
        system.debug(hLst);
        // TO DO: implement unit test


        //String recId = String.valueOf(heledit.hldChkLst[0].hld.id);

        HolidayController.getPermissionCheck(Id);
        HolidayController.getHoliday(Id);
        HolidayController.getHolidayHistory(Id);
        HolidayController.getHolidayAction(Id, true);
        HolidayController.getHolidayAction(Id, false);
        HolidayController.getObjectFieldLabel('Holiday__c');
        Test.stopTest();
    }
}