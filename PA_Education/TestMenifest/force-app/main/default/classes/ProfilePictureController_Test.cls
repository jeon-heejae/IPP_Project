@isTest
Private class ProfilePictureController_Test{

    @IsTest static void ProfilePictureController_Test(){

        Test.startTest();

        /*00e90000001qLEaAAM*/
        Profile p = [select id from Profile where Name='System Administrator'];
        //p = TestDataFactory.getProfile('System Administrator');   

        /*실제신청자*/
        User user = new User(Alias = 'testUser'
                            , Email='SysAdminTestuser@earth.org'
                            , EmailEncodingKey='UTF-8'
                            , LastName='Testing'
                            , LanguageLocaleKey='en_US'
                            , LocaleSidKey='en_US'
                            , EmployeeNumber='AC100000'
                            , ProfileId = p.Id
                            , TimeZoneSidKey='Asia/Seoul'
                            , UserName='SysAdminTestuser@earth.org');
                                
        insert user;
        Employee__c emp = new Employee__c();
        emp.Emergency_Contact__c = '123';
        insert emp;
        
        string before = 'Testing base 64 encode';
        Blob beforeblob = Blob.valueOf(before);
        string paramvalue = EncodingUtil.base64Encode(beforeblob);

        ProfilePictureController.saveAttachment(emp.Id, 'test file name', paramvalue , 'image/png');
        ProfilePictureController.getProfilePicture(emp.Id);
        
        Test.stopTest();   
    }
}