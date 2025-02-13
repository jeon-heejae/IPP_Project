/**
 * Created by yj.kim on 2023-07-12.
 */
@IsTest
public with sharing class EmployeeEvaluationBtnController_Test {
    @IsTest
    static void testEvaluation(){
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

        User userObj3 = new User();
        userObj3.Email               = 'testUser3@test.com';
        userObj3.LastName            = 'testUser3';
        userObj3.FirstName           = 'testUser3';
        userObj3.ProfileId           = UserInfo.getProfileId();
        userObj3.Emailencodingkey    = 'ks_c_5601-1987';
        userObj3.Languagelocalekey   = 'en_US';
        userObj3.IsActive            = true;
        userObj3.Username            = 'testUser3@daeunextier.com';
        userObj3.Alias               = 'User3';
        userObj3.CommunityNickname   = 'User3';
        userObj3.TimeZoneSidKey      = 'Asia/Seoul';
        userObj3.LocaleSidKey        = 'ko_KR';
        insert userObj3;

        Employee__c em1 = TestObjectCreator.objEmployee;
        em1.Type__c = '내부직원';
        insert em1;

        Employee__c em2 = new Employee__c();
        em2.Name = 'Test Employee2';
        em2.Emergency_Contact__c = '01000000000';
        em2.User__c = userObj2.Id;
        em2.Type__c = '내부직원';
        insert em2;

        Employee__c em3 = new Employee__c();
        em3.Name = 'Test Employee3';
        em3.Emergency_Contact__c = '010000000100';
        em3.User__c = userObj3.Id;
        em3.Type__c = '외부직원';
        insert em3;

        Project__c projectObj = new Project__c();
        projectObj.Name = 'testProject';
        projectObj.PMEmail__c = 'test@daeunextier.com';
        projectObj.Salesforce_Product__c = 'Sales Cloud';
        projectObj.Salesforce_Industry__c = '자동차';
        projectObj.OpeningDate__c = Date.today().addDays(60);
        projectObj.StartDate__c = Date.today();
        projectObj.EndDate__c = Date.today().addDays(60);
        projectObj.PM__c = userObj2.Id;
        projectObj.Completed__c = true;
        insert projectObj;

        PerformProject__c performObj = new PerformProject__c();
        performObj.Project__c = projectObj.Id;
        performObj.Employee__c = em1.Id;
        performObj.InputDate__c = Date.today().addDays(-30);
        performObj.IsPM__c = true;
        insert performObj;

        PerformProject__c performObj2 = new PerformProject__c();
        performObj2.Project__c = projectObj.Id;
        performObj2.Employee__c = em2.Id;
        performObj2.InputDate__c = Date.today().addDays(-30);
        insert performObj2;

        PerformProject__c performObj3 = new PerformProject__c();
        performObj3.Project__c = projectObj.Id;
        performObj3.Employee__c = em3.Id;
        performObj3.InputDate__c = Date.today().addDays(-30);
        insert performObj3;

        PerformProject__c updateObj = new PerformProject__c();
        updateObj.Id = performObj.Id;
        updateObj.InputDate__c = Date.today().addDays(-60);
        update updateObj;

        List<Map<String, Object>> inList = new List<Map<String, Object>>();
        Map<String, Object> inMap = new Map<String, Object>();
        List<Map<String, Object>> exList = new List<Map<String, Object>>();
        Map<String, Object> exMap = new Map<String, Object>();

        inMap.put('performProjectId', performObj2.Id);
        inMap.put('project', projectObj.Id);
        inMap.put('employeeId', em2.Id);
        inMap.put('fromDate', Date.today());
        inMap.put('toDate', Date.today());
        inMap.put('competency', 'S');
        inMap.put('communication', 'S');
        inMap.put('cooperation', 'S');
        inMap.put('passion', 'S');
        inMap.put('attitude', 'S');
        inMap.put('addWork', '');
        inMap.put('addComment', '');
        inList.add(inMap);

        exMap.put('performProjectId', performObj2.Id);
        exMap.put('project', projectObj.Id);
        exMap.put('employeeId', em3.Id);
        exMap.put('fromDate', Date.today());
        exMap.put('toDate', Date.today());
        exMap.put('competency', 'S');
        exMap.put('communication', 'S');
        exMap.put('cooperation', 'S');
        exMap.put('passion', 'S');
        exMap.put('attitude', 'S');
        exMap.put('addWork', '');
        exMap.put('addComment', '');
        exList.add(inMap);

        Test.startTest();
        EmployeeEvaluationBtnController.doInit(projectObj.Id);
        EmployeeEvaluationBtnController.doSave(inList, exList, false);
        Test.stopTest();



    }
}