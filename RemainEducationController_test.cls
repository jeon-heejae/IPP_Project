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

            userMentor=new User(
                alias = 'mentor', email='jsmith@acme.com', 
                emailencodingkey='UTF-8', lastname='test1', 
                languagelocalekey='en_US', 
                localesidkey='en_US', profileid = p.Id, userroleid = r.Id,
                timezonesidkey='America/Los_Angeles', 
                username='test12@test21.com');
                
                insert userMentor;
            
            userNew=new User(
                alias = 'new', email='jsmith@acme.com', 
                emailencodingkey='UTF-8', lastname='test2', 
                languagelocalekey='en_US', 
                localesidkey='en_US', profileid = p.Id, userroleid = r.Id,
                timezonesidkey='America/Los_Angeles', 
                username='test21@test12.com');

                insert userNew;

            //employee 생성
            Employee__c empMentor = new Employee__c(
                Name = 'Test Employee1',
                OwnerId = userMentor.Id,
                MainRole__c = 'Developer',
                Position__c = '12'
            );
            insert empMentor;

            Employee__c empNew=new Employee__c(
                Name = 'Test Employee2',
                OwnerId = userNew.Id,
                MainRole__c = 'Developer',
                Position__c = '9',
                MentorUser__c=empMentor.OwnerId
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
            insert new List<EduCurriculum__c> { curriculum1, curriculum2 };
                
            //업무일지 생성
            DailyTraining__c training = new DailyTraining__c(
                OwnerId = userNew.Id,
                Dt_EduName__c = curriculum1.Id
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

             // 예상되는 역할이 리스트에 포함되어 있는지 검증
             System.assertNotEquals(null, mapRole, 'Roles list should not be null');
             System.assert(!maprole.isEmpty(), 'Roles list should not be empty');
        }
    }

    @isTest
    static void testGetAllEmployeeRemain() {
        Test.startTest();
        
        List<Map<String, Object>> remainEducation = RemainEducationController.getAllEmployeeRemain();
        
        Test.stopTest();
        System.assertNotEquals(null, remainEducation);
        System.assertEquals(1, remainEducation.size()); 
    }

    @isTest
    static void testGetAllEmployeeInProgress() {
        Test.startTest();
        
        List<Map<String, Object>> inProgress = RemainEducationController.getAllEmployeeInProgress();
        
        Test.stopTest();

        System.assertNotEquals(null, inProgress);
        System.assertEquals(1, inProgress.size()); // Expecting 1 completed training
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

}
