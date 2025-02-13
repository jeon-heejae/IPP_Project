/**
 * Created by yj.kim on 2023-07-12.
 */
@IsTest
public with sharing class Project_tr_Test {
    @IsTest
    static void testUpdate(){

        User userObj = TestObjectCreator.objUser;
        insert userObj;

        User userObj2 = new User();
        userObj2.Email               = 'test2@test.com';
        userObj2.LastName            = 'testUser2';
        userObj2.FirstName           = 'testUser2';
        userObj2.ProfileId           = UserInfo.getProfileId();
        userObj2.Emailencodingkey    = 'ks_c_5601-1987';
        userObj2.Languagelocalekey   = 'en_US';
        userObj2.IsActive            = true;
        userObj2.Username            = 'testUser2@daeunextier.com';
        userObj2.Alias               = 'user2';
        userObj2.CommunityNickname   = 'user2';
        userObj2.TimeZoneSidKey      = 'Asia/Seoul';
        userObj2.LocaleSidKey        = 'ko_KR';
        insert userObj2;

        Project__c projectObj = new Project__c();
        projectObj.Name = 'testProject';
        projectObj.PMEmail__c = 'test@daeunextier.com';
        projectObj.Salesforce_Product__c = 'Sales Cloud';
        projectObj.Salesforce_Industry__c = '자동차';
        projectObj.OpeningDate__c = Date.today().addDays(60);
        projectObj.StartDate__c = Date.today();
        projectObj.EndDate__c = Date.today().addDays(60);
        projectObj.PM__c = userObj.Id;
        projectObj.Completed__c = false;
        insert projectObj;

        Test.startTest();

        Project__c obj = new Project__c();
        obj.Id = projectObj.Id;
        obj.PM__c = userObj2.Id;
        obj.Completed__c = true;
        update obj;

        Test.stopTest();
    }

}