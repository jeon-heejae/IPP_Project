@isTest
public class SignaturePictureController_test {
    public static User loginUser;

    @testSetup
    static void setupTestData() {

        User userThis=[
            SELECT Id, Name, Profile.Name, UserRole.Name
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];


        System.runAs(userThis) { 
            // Create a test user
            Profile p = [SELECT Id FROM Profile WHERE Name='Daeu Nextier Employee' LIMIT 1];
            UserRole r = [SELECT Id FROM UserRole WHERE Name='Platform Member'];

             loginUser=new User(
                alias = 'loginUs', email='testEmail_121624@test.com', 
                emailencodingkey='UTF-8', lastname='testMentor_121124', 
                languagelocalekey='en_US', 
                localesidkey='en_US', profileid = p.Id, userroleid = r.Id,
                timezonesidkey='America/Los_Angeles', 
                username='loginUser_121624@daeunextier.com',
                Position__c='9');
                
            insert loginUser;

            Employee__c employee = new Employee__c(
                User__c = loginUser.Id,
                Gender__c = '남성',
                CurrentAddress__c = '상원12길34',
                Birthday__c = Date.newInstance(1990, 1, 1),
                EnglishName__c = 'Daeu',
                IdNumber__c = '123456-1234567',
                AddressNumber__c = '01010',
                WeddingAnniversary__c = Date.newInstance(2015, 5, 10),
                JoinArmyDate__c = Date.newInstance(2010, 6, 1),
                DischargeDate__c = Date.newInstance(2012, 6, 1),
                MilitaryServiceDiv__c = '미필',
                MilitaryType__c = '공군',
                Class__c = '상병',
                MilitaryTypeDescription__c = '가나다라마',
                Dependents__c = '4',
                UpdateDate__c = Date.newInstance(2018, 11, 01),
                DismissalDate__c = Date.newInstance(2025, 11, 01),
                Reason__c = '건강 악화',
                Clear__c = '청산 완료',
                Position__c = '13',  // 직급을 채워줘야 함
                OwnerId = loginUser.Id
            );

            insert employee;

            // PermissionSetAssignment 추가
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ViewPersonalInfoPermission' LIMIT 1];
            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = loginUser.Id,
                PermissionSetId = ps.Id
            );
            insert psa;

            // Employee 레코드 생성
            Employee__c objEmployee = new Employee__c(Name = 'Test Employee');
            insert objEmployee;

            // contentVersion 생성 
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = 'Sig_TestSignature';
            contentVersion.PathOnClient = 'TestSignature.png';
            contentVersion.VersionData = Blob.valueOf('Test data');
            insert contentVersion;

            List<ContentVersion> listCv = [
                SELECT Id, Title, ContentDocumentId 
                FROM ContentVersion 
                WHERE Id = :contentVersion.Id
            ];

            // Employee와 ContentVersion 연결
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = listCv[0].contentDocumentId;
            link.ShareType = 'V'; // Viewer
            link.LinkedEntityId = objEmployee.Id;
            insert link;
        }
    }

    @isTest
    public static void testGetSignaturePicture(){
        
        Employee__c objEmployee = [SELECT Id FROM Employee__c LIMIT 1];

        Test.startTest();
        ContentVersion signature = SignaturePictureController.getSignaturePicture(objEmployee.Id);
        Test.stopTest();
    }

    @isTest
    public static void testSaveSignaturePicture(){
        
        Employee__c employee = [SELECT Id FROM Employee__c LIMIT 1];

        
        String fileName = 'NewSignature.png';
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('New Signature Data'));

        
        Test.startTest();
        String contentDocumentId = SignaturePictureController.saveSignaturePicture(employee.Id, fileName, base64Data);
        Test.stopTest();
    }

    @isTest
    public static void testCheckId(){
        User currentUser = [SELECT Id FROM User WHERE alias = 'loginUs' LIMIT 1];
        Employee__c employee = [SELECT Id FROM Employee__c WHERE User__c = :currentUser.Id LIMIT 1];
          

        System.runAs(currentUser) {
            Test.startTest();
            Boolean result = SignaturePictureController.checkId(employee.Id);
            Test.stopTest();
        }
    }
    
}