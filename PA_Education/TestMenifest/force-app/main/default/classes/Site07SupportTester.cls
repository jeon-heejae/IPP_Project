@isTest
private class Site07SupportTester {
    static testMethod void myUnitTest() {
		test.startTest();
		
		Site07Support con = new Site07Support();
		
		con.registerLead();
		
		con.username = 'name';
		con.email = 'aaa@aaa.com';
		con.registerLead();
		
		
		test.stopTest();
    }
}