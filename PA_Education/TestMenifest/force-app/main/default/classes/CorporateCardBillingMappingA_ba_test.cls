/************************************************************************************
 * Description :
 *
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-12-10        yr.lee         Create
*************************************************************************************/
@IsTest
public with sharing class CorporateCardBillingMappingA_ba_test {
    @IsTest
    static public void testBatch(){
        Date objToday = Date.today();
        CATS_TMP_ACQUIRE__c objCTA = new CATS_TMP_ACQUIRE__c();
        objCTA.Seq__c = 001;
        objCTA.CardNo__c = '0000000000000001';
        objCTA.ApprDate__c = String.valueOf(objToday.addMonths(-1));
        insert objCTA;
        CATS_TMP_ACQUIRE__c objCTA2 = new CATS_TMP_ACQUIRE__c();
        objCTA2.Seq__c = 001;
        objCTA2.CardNo__c = '0000000000000001';
        objCTA2.ApprDate__c = String.valueOf(objToday.addMonths(-1));
        insert objCTA2;
        CorporateCard__c objCC = new CorporateCard__c(
                CardNumber__c   = '0000000000000001',
                CardCompany__c  = '03',
                OwnerId = UserInfo.getUserId(),
                RealUser__c = UserInfo.getUserId()
        );
        insert objCC;
        CorporateCardBillingMappingA_ba cardBillingMappingABa = new CorporateCardBillingMappingA_ba();
        Database.executeBatch(cardBillingMappingABa, 100);
    }
}