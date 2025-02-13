/**
 * Object       : Inventory_LineTester.cls
 * Function     : 
 * Author       : yohan.kang
 * Date         : 2015.06.07
 * Tester 		: 
 * page			: 
 * Description  : 
 *		Inventory_Line.Cls
 */
@isTest
private class Inventory_LineTester {
	@isTest static void test_method_one() {
		Warehouse__c WH = ObjectCreateTester.WH;
		WH.Type__c = '공정';
		insert WH;

		Inventory__c IV = ObjectCreateTester.IV;
		IV.CntImport__c = 1000;
		insert IV;

		system.debug('@@@@@ IV.CntInventory2__c' + IV.CntInventory2__c);

		Inventory_Line con = new Inventory_Line();
		con.TestMe();
	}
}