@isTest
private class ViewHRInfoController_test {
    
    @isTest
    static void itShould() {
        System.debug(ViewHRInfoController.getInitData(TestObjectCreator.objPerformProject.Employee__c, '2019-01-06', '2019-12-31'));
    }
    
    @testSetup
    static void setData() {
        PerformProject__c objPerformProject = TestObjectCreator.objPerformProject;
        objPerformProject.InputDate__c 	 	= Date.valueOf('2019-01-01');
		objPerformProject.WithdrawDate__c 	= Date.valueOf('2019-12-31');        
        insert objPerformProject;
        
        
        HolidayAction__c objHolidayAction = TestObjectCreator.objHolidayAction;
		objHolidayAction.HolidayAction_Days__c  = 5;
		objHolidayAction.HolidayAction_Date1__c = Date.valueOf('2019-01-14');
		objHolidayAction.HolidayAction_Date2__c = Date.valueOf('2019-01-15');
		objHolidayAction.HolidayAction_Date3__c = Date.valueOf('2019-01-16');
		objHolidayAction.HolidayAction_Date4__c = Date.valueOf('2019-01-17');
		objHolidayAction.HolidayAction_Date5__c = Date.valueOf('2019-01-18');
        // objHolidayAction.HolidayAction_IsConfirm__c = true;

		insert objHolidayAction;
        
    }
}