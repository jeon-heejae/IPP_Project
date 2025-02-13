/**
 * Created by choiyuna on 2022-11-14.
 */
@IsTest
public with sharing class FormRequestControllerTest {
    @IsTest(SeeAllData=true)
    public static void test() {
        Test.startTest();

        createPageRefByRecordId(createFormRequestRecord('대표이사').Id);
        System.assertEquals('CEO', getFormRequestController().title_Eng);

        createPageRefByRecordId(createFormRequestRecord('부사장').Id);
        System.assertEquals('Vice President', getFormRequestController().title_Eng);

        createPageRefByRecordId(createFormRequestRecord('전무').Id);
        System.assertEquals('Executive Vice President', getFormRequestController().title_Eng);

        createPageRefByRecordId(createFormRequestRecord('상무').Id);
        System.assertEquals('Managing Director', getFormRequestController().title_Eng);

        createPageRefByRecordId(createFormRequestRecord('이사').Id);
        System.assertEquals('Director', getFormRequestController().title_Eng);

        //todo test
        createPageRefByRecordId(createFormRequestRecord('부장').Id);
        System.assertEquals('General Manager', getFormRequestController().title_Eng);

        createPageRefByRecordId(createFormRequestRecord('차장').Id);
        System.assertEquals('Deputy General Manager', getFormRequestController().title_Eng);

        createPageRefByRecordId(createFormRequestRecord('과장').Id);
        System.assertEquals('Manager', getFormRequestController().title_Eng);

        createPageRefByRecordId(createFormRequestRecord('대리').Id);
        System.assertEquals('Assistant Manager', getFormRequestController().title_Eng);

        createPageRefByRecordId(createFormRequestRecord('사원').Id);
        System.assertEquals('Staff', getFormRequestController().title_Eng);

        createPageRefByRecordId(createFormRequestRecord('센터장').Id);
        System.assertEquals('Head of GDC center', getFormRequestController().title_Eng);

        createPageRefByRecordId(createFormRequestRecord('인턴').Id);
        System.assertEquals('Intern', getFormRequestController().title_Eng);

        Test.stopTest();
    }

    public static FormRequest__c createFormRequestRecord(String testTitle) {
        Employee__c testEmployee = new Employee__c();
        testEmployee.Name = '김김김';
        insert testEmployee;

        FormRequest__c testFormRequest = new FormRequest__c();
        testFormRequest.EngName__c = 'kimyee';
        testFormRequest.FormRequest_Type__c = '재직증명서';
        testFormRequest.FormRequest_Purpose__c = 'test';
        testFormRequest.FormRequest_ToSubmit__c = 'test';
        testFormRequest.Employee_Name__c = testEmployee.Id;
        testFormRequest.FormRequest_Title__c = testTitle;
        testFormRequest.LanguageType__c = '국문';
        insert testFormRequest;

        return testFormRequest;
    }

    public static void createPageRefByRecordId(Id recordId) {
        PageReference pageRef = Page.FormRequestRenderPageEng;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', recordId);
    }

    public static FormRequestController getFormRequestController() {
        FormRequest__c objFormRequest = new FormRequest__c();
        objFormRequest.LanguageType__c = '국문';

        return new FormRequestController(new ApexPages.StandardController(objFormRequest));
    }

}