/**
 * Object		: ImportInspectionTester.cls
 * Function		: 
 * Author		: Yohan.Kang.
 * Date			: 2015.2.28
 * Description	: 
 			ImportInspection.Cls
 */
@isTest
private class ImportInspectionTester {
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Account AC = ObjectCreateTester.AC;
        insert AC;
        
        Item__c IT = ObjectCreateTester.IT;
        IT.Type__c = '부품';
        insert IT;
        
        ImportInspection con = new ImportInspection();
        
        con.MyTest(AC, IT);
    }
}