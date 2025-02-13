/************************************************************************************
 * File Name   : ViewHRController_test.cls
 * Author      : Soyoung.Jung 
 * Date        : 2019.01.24
 * Target      : ViewHRController.cls
 * Description : 
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2019.01.24      Soyoung.Jung    Create                                       
*************************************************************************************/

@isTest
private class ViewHRController_test {

	@isTest
	static void itShould() {
		System.debug(ViewHRController.getInitData());
		System.debug(ViewHRController.queryHRView('2019-01-01', '2019-12-31', 'MONTHLY', true, 0, 5));
		System.debug(ViewHRController.queryHRView('2019-01-01', '2019-06-30', 'WEEKLY', true, 0, 5));
		System.debug(ViewHRController.queryHRView('2019-01-01', '2019-01-31', 'DAILY', true, 0, 5));
	}

	@testSetup 
	static void setData() {
		// 평일만 계산하기 때문에 데이트 필드들 값 고정
		PerformProject__c objPerformProject = TestObjectCreator.objPerformProject;
		objPerformProject.InputDate__c = Date.valueOf('2019-01-01');
		objPerformProject.WithdrawDate__c = Date.valueOf('2019-12-31');

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