/************************************************************************************
 * File Name   : ResourceProfileController_test.cls
 * Author      : Soyoung.Jung 
 * Date        : 2019.01.14
 * Target      : ResourceProfileController.cls
 * Description : ResourceProfileController.cls Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2019.01.14      Soyoung.Jung        Create
*************************************************************************************/

@isTest
private class ResourceProfileController_test {

	@isTest
	static void itShould() {
		Test.startTest();

		Employee__c objEmployee = TestObjectCreator.objEmployee;
		insert objEmployee;

		PageReference pageRef = Page.ResourceProfile_doc;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('ids', JSON.serialize(new List<String>{objEmployee.Id}));
        ApexPages.currentPage().getParameters().put('child', JSON.serialize(new List<String>{'Re_Education__r', 'Re_License__r', 'EmployeePerformPjt__r'}));

        ApexPages.StandardController stdController = new ApexPages.StandardController(objEmployee);
        ResourceProfileController controller = new ResourceProfileController(stdController);
        //controller.WrapperEmployee wrap = new controller.WrapperEmployee();
        //ResourceProfileController.WrapperEmployee wrap = new ResourceProfileController.WrapperEmployee();


        System.debug(controller.listWrapperEmployee);
        System.debug(controller.mapSummary);
        System.debug(controller.baseURL);
        System.debug(controller.sFileName);
        System.debug(controller.mapImage);
        System.debug(controller.listEmployee);
        System.debug(controller.mapChildLabel);

		Test.stopTest();
	}

}