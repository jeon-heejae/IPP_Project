/**
 * Created by attar on 2020-11-23.
 */

@IsTest
private class EmployeeDetailController_test {
    @IsTest
    static void test(){
        Test.startTest();

        Employee__c objEmployee = new Employee__c();
        objEmployee.Name = '대유인';
        objEmployee.Birthday__c = Date.valueOf('2013-04-01');
        objEmployee.CurrentAddress__c = '서울 성동구 성수일로99';
        objEmployee.MobilePhone__c = '010-0000-0000';
        objEmployee.Department__c = 'Platform DIV.';
        objEmployee.ExitDate__c = Date.valueOf('2020-12-31');
        //objEmployee.Reason__c = '사유';
        //objEmployee.MilitaryType__c = '육군';
        objEmployee.MilitaryServiceDiv__c = '필';
        //objEmployee.Clear__c = '금품청산';
        objEmployee.JoinDate__c = Date.valueOf('2020-07-01');
        objEmployee.Emergency_Contact__c = '010-0000-0000';
        objEmployee.UpdateDate__c = Date.valueOf('2020-12-09');

        insert objEmployee;

        Qualification__c objQualification = new Qualification__c();
        objQualification.Name = '자격증';
        objQualification.Employee_Name__c = objEmployee.Id;
        objQualification.ExpirationDate__c = Date.newInstance(2099, 12, 31);
        insert objQualification;

        EducationalHistory__c objEh = new EducationalHistory__c();
        objEh.Name = '동덕여대';
        objEh.GraduatedDate__c = Date.valueOf('2021-02-18');
        objEh.Employee_Name__c = objEmployee.Id;

        insert objEh;

        Career__c objCareer = new Career__c();
        objCareer.Name = '대유넥스티어';
        objCareer.CareerExitDate__c = Date.valueOf('2020-12-31');
        objCareer.CareerJoinDate__c = Date.valueOf('2020-07-01');
        objCareer.Employee_Name__c = objEmployee.Id;

        insert objCareer;

        String recordId = objEmployee.Id;

        EmployeeDetailController.doSaveData('사유', '금품청산', objEmployee.Id);
        ApexPages.currentPage().getParameters().put('recordId', objEmployee.Id);
        ApexPages.StandardController controller =  new ApexPages.StandardController(objEmployee);
        EmployeeDetailController ed = new EmployeeDetailController(controller);
        EmployeeDetailController.doGetData(recordId);

        Test.stopTest();
    }
}