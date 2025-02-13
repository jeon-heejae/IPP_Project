@isTest
public  class DN_LookupController_test {
    
    // static {
	// }

	// @TestSetup
	// static void setup() {
        
	// }

	@isTest  
    static void unitTest() {
		insert TestObjectCreator.objAccount;

        String queryString = 'SELECT Id, Name FROM Account WHERE ParentId = null';
        DN_LookupController.querySalesforceRecord(queryString);
        DN_LookupController.getLookupDatas(queryString, 'Account', new List<String>{'Name'});
	} 
		
}