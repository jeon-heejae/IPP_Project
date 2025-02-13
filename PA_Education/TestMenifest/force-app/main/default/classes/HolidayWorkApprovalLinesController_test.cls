/**
 * Created by Kwanwoo.Jeon on 2024-02-01.
 */

@IsTest
private class HolidayWorkApprovalLinesController_test {
    @IsTest
    static void testBehavior() {
        Test.startTest();

        User user1 = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        User user2 = TestObjectCreator.objUser;
        User user3 = user2.clone(false);
        User user4 = user2.clone(false);

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

        insert user2;
        insert user3;
        insert user4;

        // user1.ApprovalLine1__c = 'ApprovalLine1__c/ApprovalLine1__c/'+ user2.Id;
        user1.ApprovalLine2__c = 'ApprovalLine2__c/ApprovalLine2__c/'+ user2.Id;
        user1.ApprovalLine3__c = 'ApprovalLine3__c/ApprovalLine3__c/'+ user2.Id +'/'+ user3.Id;
        user1.ApprovalLine4__c = 'ApprovalLine4__c/ApprovalLine4__c/'+ user2.Id;
        update user1;

//        String insertValue = 'ApprovalLine1__c/ApprovalLine1__c/'+ user2.Id;
//        String fieldName   = 'ApprovalLine1';

        List<User> objListUser = new List<User>();
        objListUser.add(user1);
        objListUser.add(user2);
        objListUser.add(user3);
        objListUser.add(user4);

        HolidayWork__c objHW = new HolidayWork__c();
        objHW.WorkingTime__c = Date.today();
        insert objHW;


        HolidayWorkDetail__c objHWD = new HolidayWorkDetail__c();
        objHWD.HolidayWork__c = objHW.Id;
        objHWD.WorkUser__c = user1.Id;
        objHWD.Stage__c = 'Planning';
        objHWD.PlanningTime__c = '4';
        objHWD.WorkDetail__c = '4';
        insert objHWD;

        HolidayWorkApprovalLinesController.getApprovalLines();
        HolidayWorkApprovalLinesController.doSubmit('HolidayWork__c', '코멘트입니다.', objHW.Id, objListUser);
        HolidayWorkApprovalLinesController.doSubmit('HolidayWork__c', '코멘트입니다.', '213456435', objListUser);




        Test.stopTest();
    }
}