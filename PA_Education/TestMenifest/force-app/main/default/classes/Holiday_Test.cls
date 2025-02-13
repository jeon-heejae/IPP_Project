@isTest
public class Holiday_Test{
    static User testUser;
    static TestMethod void HolidayEditListController_Test(){
        Profile p = TestDataFactory.getProfile('System Admin');
        
        testUser = TestDataFactory.createUser(p);   
        
        Test.startTest();
        
        HolidayEditListController hel = new HolidayEditListController();
        hel.doCreate();
        //hel.search();
        hel.hldChkLst[0].hld.Holiday_JoinDate__c = system.today().addYears(-1).addDays(-1);
        hel.hldChkLst[0].hld.Holiday_Unpaid__c = 1;
        hel.hldChkLst[0].hld.Holiday_Uncountable__c = 1;
        //hel.hldChkLst[0].hld.id = testUser.id;
        hel.doSave();
        hel.checkChange();
        hel.doSend();
        hel.checkChange();
        hel.doResetUnpaid();
        hel.checkChange();
        hel.doResetUncountable();
        hel.checkChange();
        hel.addDays = '2';
        hel.addDesc = null;
        hel.doAdd();
        hel.checkChange();
        hel.addDays = '3';
        hel.addDesc = 'test';
        hel.doAdd();
        hel.checkChange();
        hel.addDays = 'a';
        hel.addDesc = 'test';
        hel.doAdd();
        hel.checkChange();
        hel.checkChange();
        hel.doCancel();
        Test.stopTest();
    }
    static TestMethod void HolidayActionExtension_Test(){

        //Profile p = TestDataFactory.getProfile('System Admin');
        //testUser = TestDataFactory.createUser(p);   

        

        /*00e90000001qLEaAAM*/
        //Profile p = [select id from Profile where Name='System Administrator'];

      Test.startTest();

        Profile p = new Profile();
        p = TestDataFactory.getProfile('System Admin');   
        testUser = TestDataFactory.createUser(p);   
        //user1 = TestDataFactory.createUser(p);   

        //HolidayEditListController hel = new HolidayEditListController();
        //hel.doCreate();
        //string id = hel.hldChkLst[0].hld.Id;


        /*실제신청자*/
        User user = new User(Alias = 'test1'
                            , Email='SysAdminTestuser@earth.org'
                            , EmailEncodingKey='UTF-8'
                            , LastName='Testing'
                            , FirstName='Tester'
                            , LanguageLocaleKey='en_US'
                            , LocaleSidKey='en_US'
                            , EmployeeNumber='AC100000'
                            , ProfileId = p.Id
                            , TimeZoneSidKey='Asia/Seoul'
                            , UserName='systemTestUser@earth.org');
                                
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
                            , UserName='SysAdminUserTest@earth.org');
                                
        insert user1;

        string id = user.id;
        HolidayAction__c ha = new HolidayAction__c();
        ha.HolidayAction_Parent__c = id;
        ApexPages.StandardController ctrl = new ApexPages.StandardController(ha);  

        //Holiday__c hae = new Holiday__c();
        //hae.Holiday_UseDays__c = 1;
        //hae.Holiday_User__c = user.Id;

        //insert hae;

        HolidayActionExtension hae = new HolidayActionExtension(ctrl);
        hae.hldyActn.Name = 'test';
        hae.hldyActn.FirstHolidayRequest__c = user1.Id;
        hae.hldyActn.HolidayAction_Description__c = 'test';
        hae.hldyActn.HolidayAction_Parent__c = id;
        hae.hldyActn.HolidayAction_IsConfirm__c = false;
        hae.hldyActn.HolidayAction_IsEmergency__c = false;
        hae.hldyActn.HolidayAction_Type__c = 'Alternative Holiday Register';
        hae.typeCheck();
        hae.hldyActn.HolidayAction_Type__c = 'Monthly Holiday';
        hae.typeCheck();
        hae.hldyActn.HolidayAction_Days__c = 6;
        hae.changeDay();
        hae.hldyActn.HolidayAction_Days__c = 5;
        hae.doSave();
        hae.doCancel();
        
        ha = new HolidayAction__c();
        ha.HolidayAction_Parent__c = id;
        ctrl = new ApexPages.StandardController(ha); 
        hae = new HolidayActionExtension(ctrl);
        hae.hldyActn.Name = 'test';
        hae.hldyActn.FirstHolidayRequest__c = user1.Id;
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
        hae.hldyActn.FirstHolidayRequest__c = user1.Id;
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
        hae.hldyActn.FirstHolidayRequest__c = user1.Id;
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
        hae.hldyActn.FirstHolidayRequest__c = user1.Id;
        hae.hldyActn.HolidayAction_Description__c = 'test';
        hae.hldyActn.HolidayAction_Parent__c = id;
        hae.hldyActn.HolidayAction_IsConfirm__c = false;
        hae.hldyActn.HolidayAction_IsEmergency__c = false;
        hae.hldyActn.HolidayAction_Type__c = 'Sick Leave';
        hae.typeCheck();
        hae.doSave();
        hae.doCancel();
        
        string refId = '';
        ha = new HolidayAction__c();
        ha.HolidayAction_Parent__c = id;
        ctrl = new ApexPages.StandardController(ha);  
        hae = new HolidayActionExtension(ctrl);
        hae.hldyActn.Name = 'test';
        hae.hldyActn.FirstHolidayRequest__c = user1.Id;
        hae.hldyActn.HolidayAction_Description__c = 'test';
        hae.hldyActn.HolidayAction_Parent__c = id;
        hae.hldyActn.HolidayAction_IsConfirm__c = false;
        hae.hldyActn.HolidayAction_IsEmergency__c = false;
        hae.hldyActn.HolidayAction_Type__c = 'Alternative Holiday Register';
        hae.typeCheck();
        hae.doSave();
        hae.doCancel();
        
        
        //refId = [SELECT Id FROM HolidayAction__c WHERE HolidayAction_Type__c = 'Alternative Holiday Register'].Id;
        //ha = new HolidayAction__c();
        //ha.HolidayAction_Parent__c = id;
        //ctrl = new ApexPages.StandardController(ha);   
        //hae = new HolidayActionExtension(ctrl);
        //hae.hldyActn.Name = 'test';
        //hae.hldyActn.FirstHolidayRequest__c = user1.Id;
        //hae.hldyActn.HolidayAction_Description__c = 'test';
        //hae.hldyActn.HolidayAction_Parent__c = id;
        //hae.hldyActn.HolidayAction_IsConfirm__c = false;
        //hae.hldyActn.HolidayAction_IsEmergency__c = true;
        //hae.hldyActn.HolidayAction_Type__c = 'Alternative Holiday';
        //hae.hldyActn.HolidayAction_AlternativeBase__c = refId;
        //hae.typeCheck();
        //hae.doSave();
        //hae.doCancel();

        /* 현재 사용하지 않는 휴가 주석처리함
         * LJK 2019-01-10
        */
        
        
        list<HolidayAction__c> haLst = [SELECT Id FROM HolidayAction__c];
        for(HolidayAction__c has : haLst)
            has.HolidayAction_IsConfirm__c = true;
        update haLst;
        Test.stopTest();
    }
    static TestMethod void HolidayMyInfoController_Test(){
        //Profile p = TestDataFactory.getProfile('System Admin');        
        //testUser = TestDataFactory.createUser(p);  

        Profile p = new Profile();
        p = TestDataFactory.getProfile('System Admin');   

        HolidayEditListController hel = new HolidayEditListController();
        hel.doCreate(); 


        /*실제신청자*/
        User user = new User(Alias = 'test1'
                            , Email='SysAdminTestuser@earth.org'
                            , EmailEncodingKey='UTF-8'
                            , LastName='Testing'
                            , FirstName='Tester'
                            , LanguageLocaleKey='en_US'
                            , LocaleSidKey='en_US'
                            , EmployeeNumber='AC100000'
                            , ProfileId = p.Id
                            , TimeZoneSidKey='Asia/Seoul'
                            , UserName='myInfoTESTuser@earth.org');
                                
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
                            , UserName='myInfoApprover@earth.org');
                                
        insert user1;

        testUser = TestDataFactory.createUser(p);   

        Holiday__c spq = new Holiday__c();
        spq.Holiday_UseDays__c = 1;
        spq.Holiday_User__c = user.Id;

        insert spq;

        
        PageReference myVfPage = Page.MyHolidayInfo;
        Test.setCurrentPageReference(myVfPage);
       
        ApexPages.currentPage().getParameters().put('sfdc.userId',user.id);
        String id = ApexPages.currentPage().getParameters().get('sfdc.userId');

        //system.assertEquals(true,id!=null);
        Holiday__History hh = new Holiday__History(ParentId = spq.id, Field = 'Holiday_LastActivity__c');
        //Holiday__History hh2 = new Holiday__History(ParentId = spq.Holiday_User__c, Field = 'Holiday_LastActivity__c');
        //Holiday__History hh3 = new Holiday__History(ParentId = spq.Holiday_User__c, Field = 'Holiday_LastActivity__c');
        
        insert hh;
        //insert hh2;
        //hel.hldChkLst[0].hld.Holiday_LastActivity__c = 'test';
        //update hel.hldChkLst[0].hld;
        //insert hh3;


        Test.startTest();
        System.runAs(testUser){
            HolidayMyInfoController ac = new HolidayMyInfoController();
            spq.Holiday_LastActivity__c = 'test2';
            update spq;
            ac.Action();
            ac.RedirectToProfile();
            HolidayMyInfoController.HolidayHistoryClass hc = new HolidayMyInfoController.HolidayHistoryClass();
            hc.CreatedDate = spq.CreatedDate;
            hc.createdDateStr  = '' ;
            hc.user = '' ;
            hc.isNumeric = true ;
            hc.language = '' ;
            hc.actStrVerb1 = '' ;
            hc.actStrNoun = '' ;
            hc.actStrNounPosition = '' ;
            hc.actStrVerb2 = '' ;
            hc.actStrOldPosition = '' ;
            hc.actStrNewPosition = '' ;
            hc.actStrOldValue = '' ;
            hc.actStrNewValue = '' ;
            hc.actStrOldDecimal = null ;
            hc.actStrNewDecimal = null ;
            Holiday__History hstory = new Holiday__History();
            hc.history  = hstory;
            List<Holiday__History> hstoryList = new List<Holiday__History>();
            hstoryList.add(hstory);
            
        }
        Test.stopTest();
    }
    static testMethod void HolidaySchedulertTest() {
        HolidayEditListController hel = new HolidayEditListController();
        System.debug('hel.hldChkLst.size() : ' + hel.hldChkLst.size());
        hel.doCreate();
        // hel.search();
        System.debug('hel.hldChkLst.size() : ' + hel.hldChkLst.size());
        hel.hldChkLst[0].hld.Holiday_JoinDate__c = system.today().addYears(-2).addDays(1);
        hel.hldChkLst[0].hld.Holiday_LastActivity__c = '1';
        hel.hldChkLst[1].hld.Holiday_JoinDate__c = system.today().addYears(-1).addMonths(-6).addDays(-9);
        hel.hldChkLst[1].hld.Holiday_LastActivity__c = '2';
        hel.hldChkLst[2].hld.Holiday_JoinDate__c = system.today().addYears(-1).addMonths(-10).addDays(1);
        hel.hldChkLst[2].hld.Holiday_LastActivity__c = '3';
        hel.doSave();
        list<Holiday__c> hLst = [SELECT Holiday_LastActivity__c, Holiday_PeriodEnd__c FROM Holiday__c];
        insert new HolidaySetting__c(SetupOwnerId=UserInfo.getOrganizationId(), IsCeil__c= true, HoldayRuleDate__c = null, JoinDateRule__c = true);
        system.debug(hLst);
        // TO DO: implement unit test
        test.StartTest();
        //
       
        HolidayScheduler s = new HolidayScheduler() ;
        String sch = '0 1 0 * * ?';
        system.schedule('Test HolidayScheduler', sch, s);
 
        test.StopTest();
    }
}