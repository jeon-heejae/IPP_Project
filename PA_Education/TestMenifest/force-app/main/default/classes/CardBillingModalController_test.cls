/**
 * Created by Kwanwoo.Jeon on 2024-01-16.
 */
@IsTest
public with sharing class CardBillingModalController_test {
    @TestSetup
    static void SetUp(){
        User objUser = TestObjectCreator.objUser;
        insert objUser;

        CorporateCard__c objCC = new CorporateCard__c(
                CardNumber__c   = '0000000000000001',
                CardCompany__c  = '03',
                OwnerId = UserInfo.getUserId(),
                RealUser__c = UserInfo.getUserId()
        );
        insert objCC;

        CorporateCard__c objCC2 = new CorporateCard__c(
                CardNumber__c   = '0000000000000002',
                CardCompany__c  = '03',
                OwnerId = objUser.Id,
                RealUser__c = objUser.Id
        );
        insert objCC2;

        CorporateCardOwner__c objCCO = new CorporateCardOwner__c(
                User__c = UserInfo.getUserId(),
                StartDate__c = Date.today(),
                EndDate__c = Date.today(),
                CorporateCard__c = objCC2.Id
        );
        insert objCCO;


        CorporateCardBilling__c objCCB = new CorporateCardBilling__c(
                CorporateCard__c = objCC2.Id,
                BillingDate__c = Date.today()
        );
        insert objCCB;
        CorporateCardBilling__c objCCB2 = new CorporateCardBilling__c(
                CorporateCard__c = objCC2.Id,
                BillingDate__c = Date.today() -1
        );
        insert objCCB2;

        CorporateCardBilling__c objCCB3 = new CorporateCardBilling__c(
                CorporateCard__c = objCC.Id,
                BillingDate__c = Date.today()
        );
        insert objCCB3;
    }

    @IsTest
    static void doTest(){
        Test.startTest();
//        CardBillingModalController.getData(date.today().year(), Date.today().month(), '임원 및 감사님', new list<Id>{});
        CardBillingModalController.getData(date.today().year(), Date.today().month()-1, '임원 및 감사님', new list<Id>{});
        CardBillingModalController.getData(date.today().year(), Date.today().month()-1, '자격증', new list<Id>{});
        CardBillingModalController.getData(date.today().year(), Date.today().month()-1, '프로젝트', new list<Id>{});
        Test.stopTest();
    }
}