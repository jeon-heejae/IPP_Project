/************************************************************************************
* File Name   	    : PerformProject_tr testclass
* Author	  		: Yeonlim
* Date				: 2024-01-02
* Modification Log
* ===================================================================================
* Ver      Date            Author          Modification
* ===================================================================================
* 1.0      2024-01-02      Yeonlim           Create
************************************************************************************/
@IsTest
public with sharing class PerformProject_tr_test {
    @IsTest
    static void doTest() {
        Employee__c objEmployee = TestObjectCreator.objEmployee;
        objEmployee.Type__c = '외부직원';
        insert objEmployee;

        PerformProject__c objPerformProject = TestObjectCreator.objPerformProject;
        objPerformProject.InputDate__c = Date.today();
        insert objPerformProject;

        objPerformProject.InputDate__c = Date.today().addMonths(-3);
        update objPerformProject;
    }
}