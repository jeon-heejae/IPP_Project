/************************************************************************************
* File Name   	    : CorporateCard_tr testClass
* Author	  		: Yeonlim
* Date				: 2024-01-17
* Modification Log
* ===================================================================================
* Ver      Date            Author          Modification
* ===================================================================================
* 1.0      2024-01-17      Yeonlim           Create
************************************************************************************/
@IsTest
public with sharing class CorporateCard_tr_test {
    @IsTest
    static void doTest() {
        User objUser = TestObjectCreator.objUser;
        insert objUser;

        Employee__c objEmp = TestObjectCreator.objEmployee;
        objEmp.User__c = objUser.Id;
        insert objEmp;

        CorporateCard__c objCC = new CorporateCard__c(
                CardNumber__c   = '0000000000000006',
                CardCompany__c  = '03',
                EmployeeNo__c   = [SELECT EmployeeNo__c FROM Employee__c WHERE Id =: objEmp.Id].EmployeeNo__c
        );
        insert objCC;

        User objUser2 = objUser.clone();
        objUser2.CommunityNickname  = 'test';
        objUser2.Username           = 'test@daeu.com';
        insert objUser2;

        objCC.RealUser__c = objUser2.Id;
        update objCC;
    }

}