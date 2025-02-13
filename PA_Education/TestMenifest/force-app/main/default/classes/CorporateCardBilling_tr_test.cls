/************************************************************************************
* File Name   	    : CorporateCardBilling_tr testClass
* Author	  		: Yeonlim
* Date				: 2024-01-16
* Modification Log
* ===================================================================================
* Ver      Date            Author          Modification
* ===================================================================================
* 1.0      2024-01-16      Yeonlim           Create
************************************************************************************/
@IsTest
public with sharing class CorporateCardBilling_tr_test {
    @IsTest
    static void doTest() {
        CorporateCard__c objCC = new CorporateCard__c(
                CardNumber__c = '0000000000000006',
                CardCompany__c = '03'
        );
        insert objCC;

        CorporateCardBilling__c objCCB = new CorporateCardBilling__c(
                CardNumber__c = '0000000000000006'
        );
        insert objCCB;
    }
}