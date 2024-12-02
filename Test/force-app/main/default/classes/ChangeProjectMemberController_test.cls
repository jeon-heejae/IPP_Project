@IsTest
public with sharing class ChangeProjectMemberController_test {

    @TestSetup
    static void makeData(){
        Project__c testProject1=new Project__c();
        testProject1.Name='Test IsProjectActive';
        testProject1.EndDate__c=Date.today().addDays(-1);
        testProject1.Status__c='종료';

        Project__c testProject2=new Project__c();
        testProject2.Name='Test In progressing';
        testProject2.EndDate__c=Date.today().addDays(1);
        testProject2.Status__c='진행중';

        insert testProject1;
        insert testProject2;

        Employee__c testEmployee1=new Employee__c();
        testEmployee1.EmployeeName__c='Test1';

        Employee__c testEmployee2=new Employee__c();
        testEmployee2.EmployeeName__c='Test2';

        insert testEmployee1;
        insert testEmployee2;

        ProjectMember__c testProjectMember=new ProjectMember__c();
        testProjectMember.Employee__c=testEmployee1.Id;
        testProjectMember.Project__c=testProject1.Id;
        testProjectMember.Position__c='PL';


        ProjectMember__c testProjectMember2=new ProjectMember__c();
        testProjectMember2.Employee__c=testEmployee2.Id;
        testProjectMember2.Project__c=testProject2.Id;
        testProjectMember2.Position__c='PM';

        insert testProjectMember;
        insert testProjectMember2;
    }
   @IsTest
    public static void testIsProjectActive() {
        Project__c testProjectActive=[
            SELECT Project__c.id, Project__c.Status__c
            FROM Project__c
            WHERE Project__c.Name='Test IsProjectActive'];

        System.Test.startTest();
        boolean result=ChangeProjectMemberController.isProjectActive(testProjectActive.id);
        System.Test.stopTest();
        System.assertEquals(false, result);
    }

    @IsTest
    public static void testGetProjectMembers(){
        Project__c testProject=[
            SELECT Id
            FROM Project__c
            WHERE Project__c.Name='Test IsProjectActive'
        ];
        
        System.Test.startTest();
        List<ProjectMember__c> testProjectMember=new List<ProjectMember__c>();
        testProjectMember=ChangeProjectMemberController.GetProjectMembers(testProject.Id);
        System.Test.stopTest();
        System.assertEquals(1, testProjectMember.size());
    }

    @IsTest
    public static void testGetMemberPosition(){
        ProjectMember__c testProjectMember=[
            SELECT Id
            FROM ProjectMember__c
            WHERE Project__r.Name='Test IsProjectActive'
        ];

        System.Test.startTest();
        String result=ChangeProjectMemberController.GetMemberPosition(testProjectMember.Id);
        System.Test.stopTest();
        System.assertEquals('PL', result);
    }
    
    @IsTest
    public static void testGetAvailableEmployees(){
        System.Test.startTest();
        List<Employee__c> testAvailableEmployees=new List<Employee__c>();
        testAvailableEmployees=ChangeProjectMemberController.GetAvailableEmployees();
        System.Test.stopTest();
        System.assertEquals(1, testAvailableEmployees.size());
    }

    @IsTest
public static void testReplaceProjectMember(){
    ProjectMember__c testProjectMember = [
        SELECT Id
        FROM ProjectMember__c
        WHERE Project__r.Name='Test In progressing'
    ];
    
    

    Employee__c testEmployee= [
        SELECT Id
        FROM Employee__c
        WHERE EmployeeName__c='Test1'
    ];

    System.Test.startTest();
    ChangeProjectMemberController.ReplaceProjectMember(testProjectMember.Id, testEmployee.Id);
    System.Test.stopTest();

    ProjectMember__c resultProjectMember = [
        SELECT Employee__r.EmployeeName__c
        FROM ProjectMember__c
        WHERE Id = :testProjectMember.Id
    ];

    System.assertEquals('Test1', resultProjectMember.Employee__r.EmployeeName__c);
}
}