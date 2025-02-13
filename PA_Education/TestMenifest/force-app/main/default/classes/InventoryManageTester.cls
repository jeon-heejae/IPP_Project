/**
 * Object		: InventoryManageTester.cls
 * Function		: 
 * Author		: Yohan.Kang.
 * Date			: 2015.2.28
 * Description	: 
 			InventoryManage.Cls
 */
@isTest
private class InventoryManageTester {
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        Account AC = ObjectCreateTester.AC;
        insert AC;
        
        Warehouse__c WH = ObjectCreateTester.WH;
        WH.Type__c = '창고';
        insert WH;
        
        Item__c IT = ObjectCreateTester.IT;
        insert IT;
        
        Item__c subIT = ObjectCreateTester.subIT;
        insert subIT;
        
        ProcessInfo__c PI = ObjectCreateTester.PI;
        insert PI;
        
        ProcessInfoDetail__c PID = ObjectCreateTester.PID;
        insert PID;
        
        Inventory__c IV = ObjectCreateTester.IV;
        insert IV;
        
        Inventory__c subIV = new Inventory__c();
        subIV.Account__c = AC.Id;
        subIV.Warehouse__c = WH.Id;
        subIV.Item__c = subIT.Id;
        subIV.CntImport__c = 100;
        insert subIV;
        
        InventoryManage con = new InventoryManage();
        
        con.MyTest(IT);
    }
}