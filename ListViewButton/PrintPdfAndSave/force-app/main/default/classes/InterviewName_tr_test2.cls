@isTest
public class InterviewName_tr_test2 {
    @TestSetup
    static void setupData(){
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
                alias = 'mentor', email='jsmith@acme.com', 
                emailencodingkey='UTF-8', lastname='test1', 
                languagelocalekey='en_US', 
                localesidkey='en_US', profileid = p.Id, userroleid = r.Id,
                timezonesidkey='America/Los_Angeles', 
                username='test12@test21.com');
                
                insert userMentor;

            User userNew=new User(
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

            Interview__c objInt=new Interview__c();
            objInt.Intv_Date__c=Date.today();
            objInt.Intv_Mentor__c = empMentor.Id;
            objInt.Intv_Mentee__c=empNew.Id;
            insert objInt;
        }
    }

    @isTest
    static void testbeforeInsert() {
        Employee__c empMentee = [SELECT Name FROM Employee__c WHERE Name = 'Test Employee2'];
        Employee__c empMentor = [SELECT Name FROM Employee__c WHERE Name = 'Test Employee1'];

        Test.startTest();
        Interview__c newInterview = new Interview__c();
        newInterview.Intv_Date__c = Date.today().addDays(-1);
        newInterview.Intv_Mentee__c = empMentee.Id;
        newInterview.Intv_Mentor__c = empMentor.Id;
        insert newInterview;
        Test.stopTest();
    }

    @isTest
    static void testafterInsert() {
        Employee__c empMentee = [SELECT Name FROM Employee__c WHERE Name = 'Test Employee2'];
        Employee__c empMentor = [SELECT Name FROM Employee__c WHERE Name = 'Test Employee1'];

        Test.startTest();
        Interview__c newInterview = new Interview__c();
        newInterview.Intv_Date__c = Date.today().addDays(-1);
        newInterview.Intv_Mentee__c = empMentee.Id;
        newInterview.Intv_Mentor__c = empMentor.Id;
        insert newInterview;
        Test.stopTest();
    }

    @isTest
    static void testafterUpdate() {
        Employee__c empMentee = [SELECT Name FROM Employee__c WHERE Name = 'Test Employee2'];
        Employee__c empMentor = [SELECT Name FROM Employee__c WHERE Name = 'Test Employee1'];
        Interview__c newInterview = new Interview__c();
        newInterview.Intv_Date__c = Date.today().addDays(-1);
        newInterview.Intv_Mentee__c = empMentee.Id;
        newInterview.Intv_Mentor__c = empMentor.Id;
        insert newInterview;

        Test.startTest();
        Interview__c updateInterview=[
            SELECT Intv_Name__c, Intv_Mentee__c,Intv_Date__c, Intv_Mentor__c
            FROM Interview__c 
            WHERE Id = :newInterview.Id];
            updateInterview.Intv_Date__c = Date.today().addDays(-2);
            update updateInterview;
        Test.stopTest();
    }

    @isTest
    static void testafterDelete() {
        Employee__c empMentee = [SELECT Name FROM Employee__c WHERE Name = 'Test Employee2'];
        Employee__c empMentor = [SELECT Name FROM Employee__c WHERE Name = 'Test Employee1'];
        Interview__c newInterview = new Interview__c();
        newInterview.Intv_Date__c = Date.today().addDays(-1);
        newInterview.Intv_Mentee__c = empMentee.Id;
        newInterview.Intv_Mentor__c = empMentor.Id;
        insert newInterview;

        Test.startTest();
        Interview__c deleteInterview=[
            SELECT Intv_Name__c, Intv_Mentee__c,Intv_Date__c, Intv_Mentor__c
            FROM Interview__c 
            WHERE Id = :newInterview.Id];
            delete deleteInterview;
        Test.stopTest();
    }
}