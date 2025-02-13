/**
 * Object       : ProcessProductTester.cls
 * Function     : 
 * Author       : yohan.kang
 * Date         : 2015.05.11
 * Tester 		: ProcessProduct.trigger
 					ProcessProductUtil.cls
 * page			: 
 * Description  : 
 */
@isTest
private class ProcessProductTester {
    static testMethod void myUnitTest() {
    	ProcessProduct__c PP = ObjectCreateTester.PP;
    	insert PP;
    	
    	ProcessProductUtil.TestMe(PP);
    }
}