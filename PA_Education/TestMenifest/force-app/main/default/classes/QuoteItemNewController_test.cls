/************************************************************************************
 * File Name   : QuoteItemNewController_test.cls
 * Author      : Soyoung.Jung 
 * Date        : 2019.01.16
 * Target      : QuoteItemNewController.cls
 * Description : QuoteItemNewController.cls Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2019.01.16      Soyoung.Jung        Create
*************************************************************************************/

@isTest
private class QuoteItemNewController_test {

	@isTest
	static void itShould() {
		Test.startTest();
		
		Employee__c objEmployee = TestObjectCreator.objEmployee;
		objEmployee.DeptPosition__c = 'Platform Architecture';
		objEmployee.Position__c = '8';
		objEmployee.MainRole__c = 'Developer';
		insert objEmployee;

		QuoteItemNewController.getInitData();
		QuoteItemNewController.getDefaultValue(objEmployee.Id);

		Test.stopTest();
	}

	@testSetup 
	static void setData() {
		QuoteItemManage__c objQuoteItemManage = TestObjectCreator.objQuoteItemManage;
		insert objQuoteItemManage;
    }

}