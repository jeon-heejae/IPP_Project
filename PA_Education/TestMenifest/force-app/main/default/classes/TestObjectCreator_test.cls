/************************************************************************************
 * File Name   : TestObjectCreator_test.cls
 * Author      : Soyoung.Jung 
 * Date        : 2019.01.14
 * Target      : TestObjectCreator.cls
 * Description : TestObjectCreator.cls Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2019.01.14      Soyoung.Jung        Create
*************************************************************************************/

@isTest
private class TestObjectCreator_test {

	@isTest
	static void itShould() {
		Test.startTest();
		//테스트 클래스에서 사용할 개체 테스트
		System.debug(TestObjectCreator.objQuoteItemManage);
		System.debug(TestObjectCreator.objHolidayAction);
		//	System.debug(TestObjectCreator.objHolidayWorks);
		System.debug(TestObjectCreator.objPerformProject);
		System.debug(TestObjectCreator.objQuote);
		System.debug(TestObjectCreator.objQuoteItemManage);
		System.debug(TestObjectCreator.objQuoteItem);
		//	System.debug(TestObjectCreator.objBilling);
		System.debug(TestObjectCreator.objPaymentSchedule);
		System.debug(TestObjectCreator.objSubContracting);
		System.debug(TestObjectCreator.objExpense);
		System.debug(TestObjectCreator.objExpenseDetail);

		Test.stopTest();
	}

}