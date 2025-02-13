@isTest
public  class ApprovalRelatedListController_Test {
    @isTest 
    static void test1() {

        /*ProcessInstanceStep*/
        /*processInstanceWorkItemList*/
        
         // Setup test data
        // This code runs as the system user
        
		/*1 .user Id*/
		
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       	User user = new User(Alias = 'User'
                            , Email='SysAdminTestuser@earth.org'
                            , EmailEncodingKey='UTF-8'
                            , LastName='Testing'
                            , LanguageLocaleKey='en_US'
                            , LocaleSidKey='en_US'
                            , EmployeeNumber='AC100000'
                            , TimeZoneSidKey='Asia/Seoul'
                            , ProfileId = p.Id
                            , UserName='SysAdminTestuser@earth.org');
        insert user;

        /*Manager 및 2차승인자*/
        User user1 = new User(Alias = 'User1'
                            , Email='SysAdminTestuser1@earth.org'
                            , EmailEncodingKey='UTF-8'
                            , LastName='Testing1'
                            , LanguageLocaleKey='en_US'
                            , LocaleSidKey='en_US'
                            , EmployeeNumber='AC100001'
                            , TimeZoneSidKey='Asia/Seoul'
                            , ProfileId = p.Id
                            , UserName='SysAdminTestuser1@earth.org');
        insert user1;
        user.ManagerId = user1.Id;
        update user;

        /*1차승인자*/
        User user2 = new User(Alias = 'User2'
                            , Email='SysAdminTestuser1@earth.org'
                            , EmailEncodingKey='UTF-8'
                            , LastName='Testing2'
                            , LanguageLocaleKey='en_US'
                            , LocaleSidKey='en_US'
                            , EmployeeNumber='AC100002'
                            , TimeZoneSidKey='Asia/Seoul'
                            , ProfileId = p.Id
                            , UserName='SysAdminTestuser2@earth.org');
        insert user2;

        /*변경할 1차승인자*/
        User user3 = new User(Alias = 'User3'
                            , Email='SysAdminTestuser3@earth.org'
                            , EmailEncodingKey='UTF-8'
                            , LastName='Testing2'
                            , LanguageLocaleKey='en_US'
                            , LocaleSidKey='en_US'
                            , EmployeeNumber='AC100003'
                            , TimeZoneSidKey='Asia/Seoul'
                            , ProfileId = p.Id
                            , UserName='SysAdminTestuser3@earth.org');
        insert user3;

        String strYear = String.valueOf(System.today().year());
        String strMonth = String.valueOf(System.today().month());
		Expense__c expense2 = new Expense__c(FirstExpenseRequest__c = user.Id,
											UseYear__c = strYear,
											UseMonth__c = strMonth);
		insert expense2;

		ExpenseDetail__c expDetail = new ExpenseDetail__c(
											Expense__c = expense2.Id,
											Category1__c = '본사행정',
											Category2__c = '식비',
											Description__c ='경비신청.',
											Amount__c = 1000,
											Date__c = system.today()
        									);
		insert expDetail;


        Expense__c expense = new Expense__c();
        expense.ApprovalStatus__c = '작성';
        //expense.Type__c = '개인경비';
        expense.UseMonth__c = strMonth;
        expense.UseYear__c = strYear;
        expense.OwnerId = user.Id;
        expense.FirstExpenseRequest__c = user1.Id;
        expense.SecondApproverSelection__c = false;
        //expense.Approver1__c = user2.Id;
        insert expense;

        expense.FirstExpenseRequest__c = user3.Id;
        expense.SecondApproverSelection__c = true;
        update expense;
        Id id = user.Id;
        String userId = String.valueOf(id);

		project__c projectObj = new project__c();
        insert projectObj;

        ProjectBudget__c projectBudject = new ProjectBudget__c();
        projectBudject.Name = '[ABC상사]20181126-0000018 예산 신청';
        projectBudject.project__c = projectObj.Id;

        insert projectBudject;

        ProjectBudgetDetail__c bugetDetail = new ProjectBudgetDetail__c();
        bugetDetail.ProjectBudget__c = projectBudject.Id;
        insert bugetDetail;

        // Create an approval request for the expense

    	Account a = new Account(Name='Example');
        a.shortName__c = 'mh';
        insert a;

        ApprovalRelateList__c approvalRelated = new ApprovalRelateList__c();
        approvalRelated.ObjectType__c='Expense__c';
        approvalRelated.RelatedObject__c='ExpenseDetail__c:Expense__c';
        approvalRelated.RelateObjectIcon__c='ExpenseIcon__c:Expense__c';
        approvalRelated.Name= 'ApprovalRelateList';
        insert approvalRelated;

       	// ProcessInstanceId 가져오기
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(expense.Id);
        req1.setSubmitterId(user3.Id);
        req1.setProcessDefinitionNameOrId('New_Expenses_Approval2');
        req1.setSkipEntryCriteria(true);

        Approval.ProcessResult result = Approval.process(req1);

        system.debug('result.status:::'+result.getInstanceStatus());

        List<ProcessInstanceStep> instanceStepList = [SELECT Id, ProcessInstanceId FROM ProcessInstanceStep WHERE ProcessInstanceId =: result.getInstanceId()];

        List<ApprovalRelatedListController.wrapTargetObj> resultList1 = new List<ApprovalRelatedListController.wrapTargetObj>();
        //List<ApprovalRelatedListController.wrapTargetObj> resultList2 = new List<ApprovalRelatedListController.wrapTargetObj>();

		Test.startTest();

        ApprovalRelatedListController.doInit(instanceStepList[0].Id);

        expense.Approver1__c = user2.Id;
        update expense;

        Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
        req2.setComments('Submitting request for approval.');
        req2.setObjectId(expense.Id);
        req2.setSubmitterId(user3.Id);
        req2.setProcessDefinitionNameOrId('New_Expenses_Approval2');
        req2.setSkipEntryCriteria(true);

        Approval.ProcessResult result2 = Approval.process(req2);

        system.debug('result.status2:::'+result2.getInstanceStatus());

        List<ProcessInstanceWorkitem> processInstanceWorkItemList = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId =: result2.getInstanceId()];

		ApprovalRelatedListController.doInit(processInstanceWorkItemList[0].Id);

        Test.stopTest();

		    	 
   }
}