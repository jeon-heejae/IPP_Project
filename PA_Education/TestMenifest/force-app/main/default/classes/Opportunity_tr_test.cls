/************************************************************************************
* File Name   	    : Opportunity_tr TestClass
* Author	  		: Yeonlim
* Date				: 2023-12-18
* Modification Log
* ===================================================================================
* Ver      Date            Author          Modification
* ===================================================================================
* 1.0      2023-12-18      Yeonlim           Create
************************************************************************************/
@IsTest
public with sharing class Opportunity_tr_test {
    @IsTest
    public static void Opportunity_tr_test() {
        Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Daeu Nextier Employee' LIMIT 1];

        User objUser = TestObjectCreator.objUser;
        objUser.ProfileId = objProfile.Id;
        objUser.Position__c = '9';
        insert objUser;

        Account objAcc = new Account(
                Name = 'TEST1',
                ShortName__c = 'TEST1'
        );

        insert objAcc;

        Opportunity__c objOppty = new Opportunity__c(
                Name = 'TEST',
                AccountId__c = objAcc.Id
        );

        insert objOppty;

        objOppty.ProposalPM__c = objUser.Id;
        update objOppty;
    }
}