/*
	* ExpenseDetail_tr 테스트 클래스
	* 경비신청 ExpenseDetail
	* 2019년 03월 20일
	* 작성자: 이종경
*/

@IsTest(SeeAllData=true)
private class ExpenseDetail_tr_test {

	static testMethod void ExpenseDetail_tr_test() {
		Test.startTest();

		Profile p = new Profile();
		p = TestDataFactory.getProfile('System Admin');

		User user = new User(Alias = 'test1'
				, Email = 'SysAdminTestuser@earth.org'
				, EmailEncodingKey = 'UTF-8'
				, LastName = 'test'
				, FirstName = 'Testing'
				, LanguageLocaleKey = 'en_US'
				, LocaleSidKey = 'en_US'
				, EmployeeNumber = 'AC100000'
				, ProfileId = p.Id
				, TimeZoneSidKey = 'Asia/Seoul'
				, UserName = 'systemTestUser@earth.org'
				, Position__c = '9'
				);

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

		PriorExpenseApplication__c objPEA = new PriorExpenseApplication__c(
				Name = '테스트',
				UseDate__c = Date.today(),
				Place__c = '장소',
				AttendeeNumber__c = 1,
				Description__c = 'test',
				ApprovalStatus__c = '승인완료'
		);
		insert objPEA;

		CorporateCard__c objCC = new CorporateCard__c(
				Name = 'test',
				CardCompany__c = '06',
				CardNumber__c = '123456******7890',
				CardNickname__c = 'test card',
				EffectiveMonth__c = '2999.09',
				RealUser__c = UserInfo.getUserId()
				);
		insert objCC;

		CorporateCardBilling__c objCCB = new CorporateCardBilling__c(
				CorporateCard__c = objCC.Id,
				BillingDate__c = Date.today(),
				BillingAmount__c = 1000000
		);
		insert objCCB;


		List<ExpenseDetail__c> expDetailList = new List<ExpenseDetail__c>();
		List<ExpenseDetail__c> expDetailList1 = new List<ExpenseDetail__c>();
		List<ExpenseDetail__c> expDetailList2 = new List<ExpenseDetail__c>();
		List<ExpenseDetail__c> expDetailList3 = new List<ExpenseDetail__c>();
		List<ExpenseDetail__c> expDetailList4 = new List<ExpenseDetail__c>();
		List<ExpenseDetail__c> expDetailList5 = new List<ExpenseDetail__c>();
		List<ExpenseDetail__c> expDetailList6 = new List<ExpenseDetail__c>();

		ExpenseDetail__c expDetail = new ExpenseDetail__c(
				Expense__c = expense.Id,
				CorporateCardBilling__c = objCCB.Id,
				Category1__c = '본사행정',
				Category2__c = '고객접대',
				Description__c = '배가고파서 회사카드로 참치를 먹었습니다 죄송합니다.',
				Amount__c = 1000,
				Date__c = system.today());

		ExpenseDetail__c expDetail1 = new ExpenseDetail__c(
				Expense__c = expense.Id,
				Category1__c = '본사행정',
				Category2__c = '교육/훈련',
				Description__c = '배가고파서 회사카드로 참치를 먹었습니다 죄송합니다.',
				Amount__c = 1000,
				Date__c = system.today());

		ExpenseDetail__c expDetail2 = new ExpenseDetail__c(
				Expense__c = expense.Id,
				Category1__c = '본사행정',
				Category2__c = '도서인쇄비',
				Description__c = '배가고파서 회사카드로 참치를 먹었습니다 죄송합니다.',
				Amount__c = 1000,
				Date__c = system.today());

		ExpenseDetail__c expDetail3 = new ExpenseDetail__c(
				Expense__c = expense.Id,
				Category1__c = '본사행정',
				Category2__c = '소모품비',
				Description__c = '배가고파서 회사카드로 참치를 먹었습니다 죄송합니다.',
				Amount__c = 1000,
				Date__c = system.today());

		ExpenseDetail__c expDetail4 = new ExpenseDetail__c(
				Expense__c = expense.Id,
				Category1__c = '본사행정',
				Category2__c = '회의',
				Description__c = '배가고파서 회사카드로 참치를 먹었습니다 죄송합니다.',
				PriorExpenseApplication__c = objPEA.Id,
				Amount__c = 1000,
				Date__c = system.today());

		ExpenseDetail__c expDetail5 = new ExpenseDetail__c(
				Expense__c = expense.Id,
				Category1__c = '본사행정',
				Category2__c = '교통비',
				Description__c = '배가고파서 회사카드로 참치를 먹었습니다 죄송합니다.',
				Amount__c = 1000,
				Date__c = system.today());

		ExpenseDetail__c expDetail6 = new ExpenseDetail__c(
				Expense__c = expense.Id,
				Category1__c = '본사행정',
				Category2__c = '기타',
				Description__c = '배가고파서 회사카드로 참치를 먹었습니다 죄송합니다.',
				Amount__c = 1000,
				Date__c = system.today());

		expDetailList.add(expDetail);
		insert expDetailList;

		expDetailList.add(expDetail1);
		Upsert expDetailList;

		expDetailList.add(expDetail1);
		insert expDetailList1;

		expDetailList1.add(expDetail2);
		upsert expDetailList1;

		expDetailList3.add(expDetail3);
		insert expDetailList3;

		expDetailList3.add(expDetail4);
		upsert expDetailList3;

		expDetailList.add(expDetail5);
		insert expDetailList5;

		expDetailList.add(expDetail6);
		insert expDetailList6;

		Test.stopTest();

	}
}