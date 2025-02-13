/************************************************************************************
* File Name   	    : 
* Author	  		: Yeonlim
* Date				: 2023-12-15
* Tester	  		:
* Target	  		:
* Description 	    : 
* Modification Log
* ===================================================================================
* Ver      Date            Author          Modification
* ===================================================================================
* 1.0      2023-12-15         Yeonlim           Create
************************************************************************************/
trigger OpportunityTrigger on Opportunity__c (before insert, before update, before delete, after insert, after update, after delete) {
    new Opportunity_tr().run();
}