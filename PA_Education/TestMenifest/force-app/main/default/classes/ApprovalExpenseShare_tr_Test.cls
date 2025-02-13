@isTest
private class ApprovalExpenseShare_tr_Test {
    
    @isTest static void testMe() {
        Test.startTest();
        Profile profile = TestDataFactory.getProfile('System Administrator');

        ApprovalExpenseShare_tr approvalExpenseShare = new ApprovalExpenseShare_tr();
        /*경비 제출자*/
        User user = new User(Alias = 'User'
                            , Email='SysAdminTestuser@earth.org'
                            , EmailEncodingKey='UTF-8'
                            , LastName='Testing'
                            , LanguageLocaleKey='en_US'
                            , LocaleSidKey='en_US'
                            , EmployeeNumber='AC100000'
                            , TimeZoneSidKey='Asia/Seoul'
                            , ProfileId = profile.Id
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
                            , ProfileId = profile.Id
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
                            , ProfileId = profile.Id
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
                            , ProfileId = profile.Id
                            , UserName='SysAdminTestuser3@earth.org');                                                                                
        insert user3;

        Expense__c expense = new Expense__c();
        expense.ApprovalStatus__c = '작성';
        //expense.Type__c = '개인경비';
        expense.UseMonth__c = '6';
        expense.UseYear__c = '2018';
        expense.OwnerId = user.Id;
        expense.FirstExpenseRequest__c = user1.Id;
        expense.SecondApproverSelection__c = false;
        insert expense;

        expense.FirstExpenseRequest__c = user3.Id;
        expense.SecondApproverSelection__c = true;
        update expense;

        Test.stopTest();
    }
    
}