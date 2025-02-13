/**
 * Created by JWJANG on 2023-02-14.
 */

@IsTest
public with sharing class ProjectTrigger_Test {

    @IsTest
    static void ProjectTrigger_Test() {
        Test.startTest();

        User objUser = TestObjectCreator.objUser;
        insert objUser;

        Project__c objProject = TestObjectCreator.objProject;
        objProject.PM__c = objUser.Id;
        insert objProject;

        Test.stopTest();
    }
}