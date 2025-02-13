/************************************************************************************
* File Name   	    : Employee_tr TestClass
* Author	  		: Yeonlim
* Date				: 2023-12-18
* Modification Log
* ===================================================================================
* Ver      Date            Author          Modification
* ===================================================================================
* 1.0      2023-12-18      Yeonlim           Create
************************************************************************************/
@IsTest
public with sharing class Employee_tr_test {
    @TestSetup
    public static void testSetUp(){
        Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Daeu Nextier Employee' LIMIT 1];
        User objUser = TestObjectCreator.objUser;
        objUser.LastName = 'testest';
        objUser.ProfileId = objProfile.Id;
        objUser.Position__c = '9';
        insert objUser;
    }

    @IsTest
    public static void Employee_tr_test() {
        User objUser = [SELECT id,name, LastName from User WHERE LastName = 'testest' LIMIT 1];

        Employee__c objEmployee = new Employee__c(
                Name  = 'TEST2',
                Type__c = '내부직원',
                User__c = objUser.Id,
                JoinDate__c = Date.today()
        );

        insert objEmployee;

        objEmployee.Position__c = '8';
        update objEmployee;

    }

    @IsTest
    public static void Employee_tr_test2() {

        User objUser = [
                SELECT Id, Name, LastName
                FROM User
                WHERE LastName = 'testest'
                LIMIT 1
        ];

        Employee__c objEmployee = new Employee__c(
                Name  = 'TEST2',
                Type__c = '내부직원',
                User__c = objUser.Id,
                JoinDate__c = Date.today()
        );
        insert objEmployee;

        User resultUser = [
                SELECT Id, LastName, EmployeeNumber
                FROM User
                WHERE LastName = 'testest'
                LIMIT 1
        ];
        Employee__c resultEmployee = [
                SELECT Id, EmployeeNo__c
                FROM Employee__c
                WHERE User__c = :objUser.Id
                LIMIT 1
        ];
        System.assertEquals(resultUser.EmployeeNumber, resultEmployee.EmployeeNo__c);
    }
}