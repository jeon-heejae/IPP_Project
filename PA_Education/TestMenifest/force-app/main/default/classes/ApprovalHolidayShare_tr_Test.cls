@isTest
private class ApprovalHolidayShare_tr_Test {
	
	@isTest static void testMe() {
		Test.startTest();
		Profile profile = TestDataFactory.getProfile('System Administrator');

		ApprovalHolidayShare_tr approvalHolidayShare = new ApprovalHolidayShare_tr();
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

		Holiday__c holiday = new Holiday__c();
		holiday.Holiday_User__c = user.Id;
		insert holiday;

		HolidayAction__c holidayAction = new HolidayAction__c();
		holidayAction.HolidayAction_Date1__c = system.today();
		holidayAction.HolidayAction_Type__c = 'Annual Holiday';
		holidayAction.OwnerId = user.Id;
		holidayAction.FirstHolidayRequest__c = user1.Id;
		holidayAction.SecondApproverSelection__c = false;
		holidayAction.HolidayAction_Parent__c = holiday.Id;
		insert holidayAction;

		holidayAction.FirstHolidayRequest__c = user3.Id;
		holidayAction.SecondApproverSelection__c = true;
		holidayAction.SecondApproverRequest__c = user1.Id;
		update holidayAction;

		Test.stopTest();
	}
	
}