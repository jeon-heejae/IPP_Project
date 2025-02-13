/**
 * @description       : 
 *                      
 * @author            : hyunsoo.song@daeunextier.com
 * @group             :
 * @last modified on  : 2023-01-02
 * @last modified by  : hyunsoo.song@daeunextier.com
 * Modifications Log
 * Ver     Date             Author               Modification
 * 1.0   2023-01-02   hyunsoo.song@daeunextier.com   Initial Version
 */

@IsTest
private class HolidayLastYearUpdate_test {
    @TestSetup
    static void testSetup() {

        if([SELECT id FROM Employee__c WHERE User__c = :UserInfo.getUserId()].isEmpty()){
            Employee__c employee = TestObjectCreator.objEmployee;
            insert employee;
        }



        Holiday__c objHoliday = new Holiday__c();
        objHoliday.Holiday_User__c = UserInfo.getUserId();
        objHoliday.Employee__c = [SELECT id, Status__c FROM Employee__c WHERE User__c = :UserInfo.getUserId() LIMIT 1].Id;
        objHoliday.Holiday_UseDays__c = 2;
        objHoliday.HolidayRemainOfLastYear__c = 1;
        objHoliday.CarriedOverOfLastYear__c = 10;
        objHoliday.UseDaysOfLastYear__c = 9;
        insert objHoliday;

        System.debug('tt :: ' + [SELECT id, Holiday_Annual_Calculated__c, Holiday_IsActive__c  FROM Holiday__c WHERE Id = :objHoliday.Id]);
        System.debug('tt2 :: ' + [SELECT id, Status__c FROM Employee__c WHERE User__c = :UserInfo.getUserId()]);

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

            }
            employee.Id = null;
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
            }
            listEmployee.add(employee);
        }
        insert listEmployee;

//        Holiday__c holiday = TestObjectCreator.objHoliday;
//        insert holiday;

//        HolidayAction__c holidayAction = TestObjectCreator.objHolidayAction;
        HolidayAction__c holidayAction = new HolidayAction__c();
        holidayAction.HolidayAction_Parent__c = objHoliday.Id;
        holidayAction.HolidayAction_Date1__c = Date.newInstance(date.today().year()+1 , 1,10);
        holidayAction.HolidayAction_Type__c = 'Annual Holiday';
        holidayAction.FirstHolidayRequest__c = listUser[0].Id;

        holidayAction.HolidayAction_Days__c = 1;
        holidayAction.Position__c = '프로젝트 팀원';
        holidayAction.Department__c = 'LG Service';
        holidayAction.HolidayAction_IsConfirm__c = false;

        insert holidayAction;
//
//        Project__c project = TestObjectCreator.objProject;
//        project.Business__c = 'LG Service';
//        insert project;
//
//        PerformProject__c performProject = TestObjectCreator.objPerformProject;
//        insert performProject;

    }

    @IsTest
    static void doTest() {
        Test.startTest();

        ProcessInstanceWorkitem wi = [SELECT Id FROM ProcessInstanceWorkitem order BY CreatedDate DESC LIMIT 1];
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req2.setWorkitemId(wi.Id);
        Approval.ProcessResult result2 =  Approval.process(req2);

        String CRON_EXP = '0 0 0 ? * *';
        System.schedule('testBatch', CRON_EXP, new HolidayLastYearUpdate_sc());
        Test.stopTest();
    }
}