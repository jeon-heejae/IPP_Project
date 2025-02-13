@isTest
public class HolidayManageContoller_Test {
    @testSetup
    static void setup() {
        Profile pf = [SELECT Id FROM Profile WHERE Name= 'System Administrator'];
        List<User> usrLst = new List<User>();
        for(Integer i = 0 ; i < 10 ; i++){
            User usr = new User(Alias = 'testUser'
                    , Email='SysAdminTestuser@earth.org' + String.valueOf(i)
                    , EmailEncodingKey='UTF-8'
                    , LastName='Testing'
                    , LanguageLocaleKey='en_US'
                    , LocaleSidKey='en_US'
                    , EmployeeNumber='AC100000' + String.valueOf(i)
                    , ProfileId = pf.Id
                    , TimeZoneSidKey='Asia/Seoul'
                    , UserName='SysAdminTestuser@earth.org' + String.valueOf(i)
//                    , IsActive= Math.mod(i,2)==0?true:false
                    , IsActive= true
            );
            usrLst.add(usr);
        }
//        Database.insert(usrLst, false);
        insert usrLst;
//
        List<Employee__c> listEmployee = new List<Employee__c>();
        for(User objUser : usrLst) {
            Employee__c objEmployee = new Employee__c();
            objEmployee.User__c = objUser.Id;
            objEmployee.Name = objUser.UserName;
            objEmployee.JoinDate__c = date.today();
            listEmployee.add(objEmployee);
        }
        insert listEmployee;
    }
    @isTest
    static void testHolidayManageController() {
        Test.startTest();
        HolidayManageController.doCreate();
        List<HolidayManageController.HolidayEmployeeWrapper> hldLst = HolidayManageController.getData(true);
        hldLst = HolidayManageController.getData(false);

        Set<Id> setHldId = new Set<Id>();
        for(HolidayManageController.HolidayEmployeeWrapper obj : hldLst) {
            setHldId.add(obj.Id);
        }

        List<Holiday__c> listHolidays = [
                SELECT Id, Name, Holiday_Additionaldays__c, Holiday_Calculated__c, Holiday_GivenHolidays__c, Holiday_IsActive__c, Holiday_IsAnnualleave__c, Holiday_JoinDate__c,
                        Holiday_LastActivity__c, Holiday_NoticeLevel__c, Holiday_PeriodEnd__c, Holiday_Remain__c, Holiday_StartDate__c, Holiday_Uncountable__c, Holiday_Unpaid__c, Holiday_UseDays__c,
                        Holiday_User__c, Holiday_User__r.Name, Holiday_User__r.UserRole.Name, Holiday_User__r.Title, Holiday_WorkingYears__c, Holiday_Monthly_Calculated__c,
                        Holiday_Annual_Calculated__c, Holiday_Monthly_Period__c, HolidayRemainOfLastYear__c, RemainOfLastYear__c, Holiday_Total_Remain__c,
                        Holiday_WomenHoliday_Count__c, Holiday_SickLeave_Count__c, Holiday_FamilyEvent_Count__c, Holiday_PublicWorks_Count__c, MonthlyOfLastYear__c
                FROM Holiday__c
                WHERE Id IN :setHldId
                ORDER BY Holiday_JoinDate__c
        ];

        for(Integer i = 0;i < hldLst.size();i++) {
            Holiday__c hld = listHolidays[i];
            hld.Holiday_JoinDate__c = Date.today().addYears(-i);
        }

        List<Map<String,Object>> objList = new List<Map<String,Object>>();
        Map<String,Object> objMap = new Map<String,Object>();

        for(Holiday__c obj : listHolidays){
            objMap.put('Id', obj.Id);
            objMap.put('GivenHolidays', '3');
            objList.add(objMap);
        }


        HolidayManageController.doSave(listHolidays);
        HolidayManageController.doModify(objList,3,'test');
//        HolidayManageController.doModify(objList,3,'');
//        HolidayManageController.doModify(objList,4,'');
        HolidayManageController.doUpdate();
        HolidayManageController.doSend(listHolidays);
        HolidayManageController.doReset(listHolidays,'unpaid');
        HolidayManageController.doReset(listHolidays,'uncountable');
        HolidayManageController.doCreate();
        Test.stopTest();
    }
}