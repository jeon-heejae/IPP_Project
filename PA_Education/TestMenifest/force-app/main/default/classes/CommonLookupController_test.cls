@isTest
private class CommonLookupController_test {
	
     @isTest static void doTest() {
        Test.startTest();

        Employee__c objEmployee = TestObjectCreator.objEmployee;
        insert objEmployee;

        CommonLookupController.doGetItemList('Employee__c', 'test');

        Test.stopTest();
    }

}