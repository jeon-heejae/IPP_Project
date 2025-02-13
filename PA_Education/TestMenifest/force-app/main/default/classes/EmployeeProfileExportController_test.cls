/************************************************************************************
 * File Name   : EmployeeProfileExportController_test.cls
 * Author      : Soyoung.Jung 
 * Date        : 2019.01.14
 * Target      : EmployeeProfileExportController.cls
 * Description : EmployeeProfileExportController.cls Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2019.01.14      Soyoung.Jung        Create
*************************************************************************************/

@isTest
private class EmployeeProfileExportController_test {

	@isTest
	static void itShould() {
		Test.startTest();

		Employee__c objEmployee = TestObjectCreator.objEmployee;
		insert objEmployee;

		System.debug(EmployeeProfileExportController.getInitData());
		System.debug(EmployeeProfileExportController.getListEmployee(50, 0));

		Test.stopTest();
	}

}