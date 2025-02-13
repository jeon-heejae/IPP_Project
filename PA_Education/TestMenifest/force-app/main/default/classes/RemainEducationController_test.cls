@isTest
public class RemainEducationController_test {
    
    public static User userMentor;
    public static User userNew;
    // Test Setup method to create test data
    @testSetup
    static void setupData() {
        User userThis=[
            SELECT Id, Name, Profile.Name, UserRole.Name
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];

       
        
        System.runAs(userThis){
            // Create a test user
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
            UserRole r = [SELECT Id FROM UserRole WHERE Name='Platform Member'];

            User userMentor=new User(
                alias = 'mentor', email='testMentor_121124@test.com', 
                emailencodingkey='UTF-8', lastname='testMentor_121124', 
                languagelocalekey='en_US', 
                localesidkey='en_US', profileid = p.Id, userroleid = r.Id,
                timezonesidkey='America/Los_Angeles', 
                username='test12@daeunextier.com');
                
            insert userMentor;
            
            User userNew=new User(
                alias = 'new', email='testMentee_121124@test.com', 
                emailencodingkey='UTF-8', lastname='testMentee_121124', 
                languagelocalekey='en_US', 
                localesidkey='en_US', profileid = p.Id, userroleid = r.Id,
                timezonesidkey='America/Los_Angeles', 
                username='test21@daeunextier.com');

            insert userNew;

            //employee 생성
            Employee__c empMentor = new Employee__c(
                Name = 'Test_Emp121124_1',
                User__c=userMentor.Id,
                OwnerId = userMentor.Id,
                MainRole__c = 'Developer',
                Position__c = '8'
            );
            insert empMentor;

            Employee__c empNew=new Employee__c(
                Name = 'Test_Emp121124_2',
                User__c=userNew.Id,
                OwnerId = userNew.Id,
                MainRole__c = 'Developer',
                Position__c = '13',
                MentorUser__c=userMentor.Id
            );
            insert empNew;

            //교육 프로그램 생성
            EduCurriculum__c curriculum1 = new EduCurriculum__c(
                Name = 'Curriculum 1',
                Edu_Type__c='Certification',
                Edu_Category__c = 'Dev.',
                Edu_Active__c = true
                );
            EduCurriculum__c curriculum2 = new EduCurriculum__c(
                Name = 'Curriculum 2',
                Edu_Type__c='Off-Line',
                Edu_Category__c = 'ALL',
                Edu_Active__c = true
                );
            EduCurriculum__c curriculum3 = new EduCurriculum__c(
                Name = 'Curriculum 3',
                Edu_Type__c='Off-Line',
                Edu_Category__c = 'Admin',
                Edu_Active__c = true
                );
            insert new List<EduCurriculum__c> { curriculum1, curriculum2,curriculum3 };
                
            //업무일지 생성
            DailyTraining__c training = new DailyTraining__c(
                Dt_UserName__c = userNew.Id,
                Dt_EduName__c = curriculum1.Id,
                Dt_Mentor__c=empMentor.Id,
                Dt_EmployeeName__c=empNew.Id,
                Dt_Date__c=System.today()
                );
            insert training;
        }
    }
        
    
    @isTest
    static void testGetUserRoles() {
        User testUser=[
            SELECT Id
            FROM User
            WHERE Alias = 'new'
        ];
        
        System.runAs(testUser){
            Test.startTest();
            Map<String,Boolean> mapRole=RemainEducationController.getUserRoles();
            Test.stopTest();
        }
    }

    @isTest
    static void testGetAllEmployeeRemain() {
        Test.startTest();
        
        List<Map<String, Object>> remainEducation = RemainEducationController.getAllEmployeeRemain();
        
        Test.stopTest();
    }

    @isTest
    static void testGetAllEmployeeInProgress() {
        Test.startTest();
        
        List<Map<String, Object>> inProgress = RemainEducationController.getAllEmployeeInProgress();
        
        Test.stopTest();
    }

    @isTest
    static void testGetName() {

        User testUser=[
            SELECT Id
            FROM User
            WHERE Alias = 'new'
        ];

        System.runAs(testUser){
            Test.startTest();
        
            String name = RemainEducationController.getName();
            
            Test.stopTest();
        }
    }   

    @isTest
    static void testGetAllMenteeRemain(){
        User testUser=[
            SELECT Id
            FROM User
            WHERE Alias = 'mentor'
        ];

        System.runAs(testUser){
            Test.startTest();
            
            List<Map<String, Object>> menteeList = RemainEducationController.getAllMenteeRemain();
            
            Test.stopTest();
        }
    }

    @isTest
    static void testGetAllMenteeInProgress(){
        User testUser=[
            SELECT Id
            FROM User
            WHERE Alias = 'mentor'
        ];

        System.runAs(testUser){
            Test.startTest();
            
            List<Map<String, Object>> menteeList = RemainEducationController.getAllMenteeInProgress();
            
            Test.stopTest();
        }
    }
    @isTest
    static void testGetRemainEducation() {

        User testUser=[
            SELECT Id
            FROM User
            WHERE Alias = 'new'
        ];

        System.runAs(testUser){
            Test.startTest();
        
            List<Map<String, Object>> remainEducation = RemainEducationController.getRemainEducation();
            Test.stopTest();
        }    
    }

    @isTest
    static void testGetInProgressEducation() {

        User testUser=[
            SELECT Id
            FROM User
            WHERE Alias = 'new'
        ];

        System.runAs(testUser){
            Test.startTest();
        
            List<Map<String, Object>> inProgressEducation = RemainEducationController.getInProgressEducation();
            
            Test.stopTest();
        }
    }

    @isTest
    static void testGetRemainEducation_emp() {

        User testUser=[
            SELECT Id
            FROM User
            WHERE Alias = 'new'
        ];

        Employee__c objEmp=[
            SELECT Id, OwnerId
            FROM Employee__c
            WHERE Name = 'Test_Emp121124_2'
        ];

        System.runAs(testUser){
            Test.startTest();
        
            List<Map<String, Object>> remainEducation = RemainEducationController.getRemainEducation(objEmp);
            Test.stopTest();
        }    
    }

    @isTest
    static void testGetInProgressEducation_emp() {

        User testUser=[
            SELECT Id
            FROM User
            WHERE Alias = 'new'
        ];

        Employee__c objEmp=[
            SELECT Id, OwnerId
            FROM Employee__c
            WHERE Name = 'Test_Emp121124_2'
        ];

        System.runAs(testUser){
            Test.startTest();
        
            List<Map<String, Object>> inProgressEducation = RemainEducationController.getInProgressEducation(objEmp);
            
            Test.stopTest();
        }
    }
}