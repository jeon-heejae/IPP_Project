/**
 * Created by Kwanwoo.Jeon on 2024-01-16.
 */

@IsTest
private class ExpenseCreationCorporateCardCtrl_test {
    @TestSetup
    static void setUp(){
        List<Budget__c> listBudget = new List<Budget__c>();

        listBudget.add(new Budget__c(
                Name = 'test',
                Year__c = string.valueOf(Date.today().year() -1),
                BudgetAmount__c = 10000000,
                BudgetType__c = '본사행정'
        ));
        listBudget.add(new Budget__c(
                Name = 'test2',
                Year__c = string.valueOf(Date.today().year()),
                BudgetAmount__c = 10000000,
                BudgetType__c = '본사행정'
        ));
        listBudget.add(new Budget__c(
                Name = 'test',
                Year__c = string.valueOf(Date.today().year() -1),
                BudgetAmount__c = 10000000,
                BudgetType__c = '영업'
        ));
        listBudget.add(new Budget__c(
                Name = 'test',
                Year__c = string.valueOf(Date.today().year() -1),
                BudgetAmount__c = 10000000,
                BudgetType__c = '임원 및 감사님'
        ));
        insert listBudget;
    }

    @IsTest
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

        String strYear = String.valueOf(System.today().year() -1);
        String strMonth = String.valueOf(System.today().month());

        Expense__c expense = new Expense__c(FirstExpenseRequest__c = user.Id,
                UseYear__c = strYear,
                UseMonth__c = strMonth,
                BudgetType__c = '본사행정',
                PaymentMethod__c = '법인카드');
        insert expense;

        Expense__c expense2 = new Expense__c(UseYear__c = strYear,
                UseMonth__c = strMonth,
                BudgetType__c = '영업',
                PaymentMethod__c = '법인카드');
        insert expense2;

        ExpenseDetail__c objED = new ExpenseDetail__c(
                Expense__c = expense.Id,
                Category1__c = '본사행정',
                Category2__c = '식비',
                Description__c = '배가고파서 회사카드로 참치를 먹었습니다 죄송합니다.',
                Amount__c = 1000,
                Date__c = system.today()
        );
        insert objED;

        ExpenseDetail__c objE2 = new ExpenseDetail__c(
                Expense__c = expense.Id,
                Category1__c = '본사행정',
                Category2__c = '식비',
                Description__c = '배가고파서 회사카드로 참치를 먹었습니다 죄송합니다.',
                Amount__c = 1000,
                Date__c = system.today()
        );
        insert objE2;

        List<Map<String, Object>> expDetailList = new List<Map<String, Object>>();
        expDetailList.add(new Map<String, Object>{
                'Expense'           => expense.Id,
                'Category1'         => '본사행정',
                'Category2'         => '식비',
                'Description'       => '배가고파서 회사카드로 참치를 먹었습니다 죄송합니다.',
                'Amount'            => 1000,
                'Dt'                => '2024-03-29 19:00:00'
            }
        );


        List<Map<String, Object>> expDetailList3 = new List<Map<String, Object>>();
        expDetailList3.add(new Map<String, Object>{
                'Expense'           => expense2.Id,
                'Category1'         => '영업',
                'Category2'         => '식비',
                'Description'       => 'Sales',
                'ProjectNameId'     => project.Id,
                'Amount'            => 1000,
                'OpportunityNameId' => oppty.Id,
                'PaymentType'       => '개인카드',
                'Dt'                => '2024-03-29 19:00:00'
            }
        );
        expDetailList3.add(new Map<String,Object>{
                'Expense'               => expense2.Id,
                'Category1'             => '영업',
                'Category2'             => '식비',
                'Description'           => 'Sales',
                'ProjectNameId'         => project.Id,
                'Amount'                => 1000,
                'OpportunityNameId'     => oppty.Id,
                'PaymentType'           => '개인카드',
                'Dt'                    => '2024-03-29 19:00:00'
            }
        );

        List<Id> idtemp = new List<Id>();
        idtemp.add(objED.Id);

        ExpenseCreationCorporateCardController.getInitData(expense.Id);
        ExpenseCreationCorporateCardController.getInitData(expense2.Id);

        system.debug(ExpenseCreationCorporateCardController.getPicklistValue('Expense__c', 'UseYear__c'));
        system.debug(ExpenseCreationCorporateCardController.getObjectFieldLabel('Expense__c'));
        system.debug(ExpenseCreationCorporateCardController.doSave(expense, expDetailList, idtemp));
        ExpenseCreationCorporateCardController.doSave(expense, expDetailList3, idtemp);


        Test.stopTest();

    }
}