/************************************************************************************
 * File Name   : QuoteCreation.cls
 * Author      : Jk.lee 
 * Date        : 2019.03.14
 * Target      : ExpenseCreationController_test.cls
 * Description : 경비 신청, 경비신청 상세를 입력하는 클래스 Test
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2019.03.19      JK.LEE        Create
*************************************************************************************/

@isTest
public class ExpenseCreationController_test {
    
    @isTest
	static void doTest() {
		Test.startTest();

		Account acc = new Account(Name = 'Test 계정',
								  ShortName__c = 'test');
		List<Account> acclist = new List<Account>();
		acclist.add(acc);
		insert acclist;

        Opportunity__c oppty = new Opportunity__c(Name = 'test 영업기회', AccountId__c = acc.Id);
		List<Opportunity__c> opptyList = new List<Opportunity__c>();
		opptyList.add(oppty);
		insert opptyList;

		Project__c project = new Project__c(Name = '본사공통');
		List<Project__c> projectList = new List<Project__c>();
		projectList.add(project);
		insert projectList;

		Project__c project1 = new Project__c(Name = '마케팅');
		List<Project__c> projectList1 = new List<Project__c>();
		projectList1.add(project1);
		insert projectList1;

        Profile p = new Profile();
        p = TestDataFactory.getProfile('System Admin');

        User user = new User(Alias = 'test1'
                            , Email='SysAdminTestuser@earth.org'
                            , EmailEncodingKey='UTF-8'
                            , LastName='test'
                            , FirstName='Testing'
                            , LanguageLocaleKey='en_US'
                            , LocaleSidKey='en_US'
                            , EmployeeNumber='AC100000'
                            , ProfileId = p.Id
                            , TimeZoneSidKey='Asia/Seoul'
                            , UserName='systemTestUser@earth.org'
							, Position__c = '9');

        insert user;

		String strYear = String.valueOf(System.today().year());
		String strMonth = String.valueOf(System.today().month());
		List<Expense__c> expenseList = new List<Expense__c>();
		Expense__c expense = new Expense__c(FirstExpenseRequest__c = user.Id,
											UseYear__c = strYear,
											UseMonth__c = strMonth,
											BudgetType__c = '본사행정',
											PaymentMethod__c = '법인카드');
		expenseList.add(expense);
		insert expenseList;


		List<Expense__c> expenseList2 = new List<Expense__c>();
		Expense__c expense2 = new Expense__c(UseYear__c = strYear,
											UseMonth__c = strMonth,
											BudgetType__c = '본사행정',
											PaymentMethod__c = '법인카드');

		expenseList.add(expense2);
		insert expenseList2;




		List<ExpenseDetail__c> expDetailList = new List<ExpenseDetail__c>();
		ExpenseDetail__c expDetail = new ExpenseDetail__c(
											Expense__c = expense.Id,
											Category1__c = '본사행정',
											Category2__c = '식비',
											Description__c ='배가고파서 회사카드로 참치를 먹었습니다 죄송합니다.',
											Amount__c = 1000,
											Date__c = system.today());
		expDetailList.add(expDetail);
		insert expDetailList;

		List<ExpenseDetail__c> expDetailList2 = new List<ExpenseDetail__c>();
		ExpenseDetail__c expDetail2 = new ExpenseDetail__c(
											Expense__c = expense.Id,
											Category1__c = '프로젝트',
											Category2__c = '식비',
											Description__c ='Salse',
											Project_Name__c =project.Id,
											Amount__c = 1000,
											Opportunity_Name__c = oppty.Id,
											Payment_Type__c= '개인카드',
											Date__c = system.today());
		expDetailList2.add(expDetail2);

		insert expDetailList2;

		List<ExpenseDetail__c> expDetailList3 = new List<ExpenseDetail__c>();
		ExpenseDetail__c expDetail3 = new ExpenseDetail__c(
											Expense__c = expense.Id,
											Category1__c = '영업',
											Category2__c = '식비',
											Description__c ='Salse',
											Project_Name__c =project.Id,
											Amount__c = 1000,
											Opportunity_Name__c = oppty.Id,
											Payment_Type__c= '개인카드',
											Date__c = system.today());
		expDetailList3.add(expDetail3);

		insert expDetailList3;



		ExpenseCreationController expenseController = new ExpenseCreationController();
        List<ExpenseDetail__c> listExpDetailTemp = new List<ExpenseDetail__c>();
		Map<String ,Object> mapExpDetail;
		List<Object> listObject = expDetailList;
		List<Object> listObject2 = new List<Object>();
		listObject2 = expDetailList2;



		List<Id> idtemp = new List<Id>();
		idtemp.add(expDetail.Id);

		Map<String, Object> mapReturnValue = ExpenseCreationController.getInitData(expense.Id);
		Map<String, Object> mapReturnValue2 = ExpenseCreationController.getInitData(expense2.Id);

		system.debug(ExpenseCreationController.getPicklistValue('Expense__c', 'UseYear__c'));
		system.debug(ExpenseCreationController.getObjectFieldLabel('Expense__c'));
		system.debug(ExpenseCreationController.doSave(expense, listObject, idtemp));
		ExpenseCreationController.doSave(expense, expDetailList2, idtemp);
		ExpenseCreationController.doSave(expense, expDetailList3, idtemp);


        Test.stopTest();
    }

}