@isTest
private class Opportunity_Remark_Update_tr_test{
	@isTest 
	static void itShould(){
		Test.startTest();
		
		Set<Id> opportunityId = new Set<Id>();

		string strSplit = '';
		string strSplitAll ='';
		List<String> splitList = new List<String>();
		Task testTask = new Task();
		Date a = Date.newInstance(2017, 01, 1); 
		testTask.ActivityDate = Date.newInstance(2017, 01, 1);
		testTask.Subject ='d♬';
		testTask.Description ='d♬';		

		splitList.add('--------------일자 : '+a+'--------------♬');
		splitList.add('제목 : ' + testTask.Subject + '♬');
		splitList.add('내용 : ' + testTask.Description + '♬♬');

		opportunityId.add(testTask.WhatId);
		insert testTask;

		List<Opportunity_Tracking__c> opptylist = new List<Opportunity_Tracking__c>();
		
		List<Task> listTask = new List<Task>();

		strSplitAll += strSplit;

    	listTask.add(testTask);

		Opportunity_Remark_Update_tr.testMe(testTask);

		Test.stopTest();
	}
}