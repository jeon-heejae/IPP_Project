/**
 * Object		: OutSoursingUtilTester.cls
 * Function		: 
 * Author		: Yohan.Kang.
 * Date			: 2015.5.31
 * Description	: 
 			OutSoursingUtil.Cls
 */
@isTest
private class OutSoursingUtilTester {
    static testMethod void myUnitTest() {
    	Inventory__c IV = OBjectCreateTester.IV;
    	insert IV;
    	
    	Outsoursing__c OS = new Outsoursing__c();
    	OS.Inventory__c = IV.Id;
    	insert OS;
    	
    	OutsoursingResult__c OSR = new OutsoursingResult__c();
    	OSR.Outsoursing__c = OS.Id;
    	insert OSR;
    	
		OutSoursingUtil con = new OutSoursingUtil();
        con.TestMe();
    }
}