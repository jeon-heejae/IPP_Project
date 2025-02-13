@isTest
private class ApprovalLineCreateController_Test {

    @isTest
    static void doTest() {
        Test.startTest();
        
        User user1 = TestObjectCreator.objUser;
        User user2 = user1.clone(false);
        User user3 = user1.clone(false);
        User user4 = user1.clone(false);
        User user5 = user1.clone(false);
        User user6 = user1.clone(false);
        
        user2.Email               = 'atest@test.com';
        user2.Username            = 'atestclass@test.com';
        user2.Alias               = 'auser';
        user2.CommunityNickname   = 'auser';

        user3.Email               = 'aatest@test.com';
        user3.Username            = 'aatestclass@test.com';
        user3.CommunityNickname   = 'ausedr';

        user4.Email               = 'aatest@test.com';
        user4.Username            = 'aatesgtclass@test.com';
        user4.CommunityNickname   = 'ausera';

        user5.FirstName           = '';
        user5.LastName            = '경영지원부';
        user5.Username            = 'aatesgtclassss331@test.com';
        user5.CommunityNickname   = 'auserae';

//        user5.FirstName           = 'RpName';
//        user5.Username            = 'aatesgtclasrpss331@test.com';
//        user5.CommunityNickname   = 'auserrpaae';


        insert user1;
        insert user2;
        insert user3;
        insert user4;


        // user1.ApprovalLine1__c = 'ApprovalLine1__c/ApprovalLine1__c/'+ user2.Id;
        user1.ApprovalLine2__c = 'ApprovalLine2__c/ApprovalLine2__c/'+ user2.Id;
        user1.ApprovalLine3__c = 'ApprovalLine3__c/ApprovalLine3__c/'+ user2.Id +'/'+ user3.Id;
        user1.ApprovalLine4__c = 'ApprovalLine4__c/ApprovalLine4__c/'+ user2.Id;
        update user1;

        String insertValue = 'ApprovalLine1__c/ApprovalLine1__c/'+ user2.Id;
        String fieldName   = 'ApprovalLine1';

        List<User> objListUser = new List<User>();
        objListUser.add(user1);
        objListUser.add(user2);
        objListUser.add(user3);
        objListUser.add(user4);

        //Project__c
        Project__c project1     = TestObjectCreator.objProject;
        project1.Business__c    = '사업1부';
        project1.PM__c          = user4.Id;

        insert project1;

        //Expense__c
        Expense__c objExpense       = TestObjectCreator.objExpense;
        Expense__c objExpense2      = objExpense.clone(false);
        objExpense2.BudgetType__c   = '프로젝트';
        objExpense2.Project__c      = project1.Id;

        insert objExpense;
        insert objExpense2;

        ApprovalLineCreateController.doSave(insertValue, fieldName, user1);
        ApprovalLineCreateController.doSave('error', 'error', user1);
        ApprovalLineCreateController.doSubmit('Expense__c', '코멘트입니다.', objExpense.Id, objListUser);
        ApprovalLineCreateController.doSubmit('Expense__c', '코멘트입니다.', '213456435', objListUser);

        //PriorExpenseApplication__c
        PriorExpenseApplication__c objPriorExpense = TestObjectCreator.objPriorExpense;
        insert objPriorExpense;

        ApprovalLineCreateController.doSave(insertValue, fieldName, user1);
        ApprovalLineCreateController.doSave('error', 'error', user1);
        ApprovalLineCreateController.doSubmit('PriorExpenseApplication__c', '코멘트입니다.', objPriorExpense.Id, objListUser);
        ApprovalLineCreateController.doSubmit('PriorExpenseApplication__c', '코멘트입니다.', '213456435', objListUser);

        ApprovalLineCreateController.checkProject(objExpense.Id);
        ApprovalLineCreateController.checkProject(objExpense2.Id);
        insert user5;
        Employee__c emp = TestObjectCreator.objEmployee;
        emp.DeptPosition__c = 'Department Head';
        emp.Department__c   = '사업1부';
        emp.Position__c     = '1';
        insert emp;

        ApprovalLineCreateController.checkProject(objExpense2.Id);


        Test.stopTest();
    }
}