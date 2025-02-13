/**
 * Created by Kwanwoo.Jeon on 2023-12-21.
 */

@IsTest
private class RewardHoliday_tr_Test {
    @TestSetup
    static void setup(){
        User objUser = TestObjectCreator.objUser;
        insert objUser;
        
        Holiday__c objHoliday = TestObjectCreator.objHoliday;
        objHoliday.Holiday_User__c = objUser.Id;
        insert objHoliday;

        RewardHoliday__c objRewardHoliday = new RewardHoliday__c();
        objRewardHoliday.WorkUser__c = objUser.Id;
        objRewardHoliday.WorkingDate__c = Date.today();
        objRewardHoliday.WorkingTime__c = '0.5일 (4시간)';
        insert objRewardHoliday;
    }

    @IsTest
    static void testBehavior() {
        RewardHoliday__c objRewardHoliday = [SELECT id, BenefitPaymentYn__c FROM RewardHoliday__c WHERE BenefitPaymentYn__c = FALSE LIMIT 1];
        objRewardHoliday.BenefitPaymentYn__c = true;
        update objRewardHoliday;
    }
}