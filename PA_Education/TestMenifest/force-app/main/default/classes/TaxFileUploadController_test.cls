/**
 * Created by user on 2024-08-14.
 */
@IsTest
public with sharing class TaxFileUploadController_test {

    @IsTest
    static void testGetBillingList() {
        User testUser = new User(
                Alias = 'tuser',
                Email = 'testuser@example.com',
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'testuser@example.comMMMMssdfs11',
                LastName = 'ttus'
        );
        insert testUser;
        User retrievedUser = [SELECT Id FROM User WHERE UserName = 'testuser@example.comMMMMssdfs11' LIMIT 1];
        User retrievedUser2 = [SELECT Id FROM User WHERE LastName = '전관우' LIMIT 1];


        CorporateCard__c testCard = new CorporateCard__c(
                Name = '하나 945081******8562',
                CardCompany__c = '03',
                CardNumber__c = '945081******8562',
                CardNickname__c = '별칭',
                EffectiveMonth__c =  '2028.02',
                RealUser__c = retrievedUser2.Id
        );
        insert testCard;

        CorporateCard__c retrievedCard = [SELECT Id FROM CorporateCard__c WHERE Name = '하나 945081******8562' LIMIT 1];

        Date testDate = Date.newInstance(2024, 1, 15);
        CorporateCardBilling__c testBilling = new CorporateCardBilling__c(
                CorporateCard__c = retrievedCard.Id,
                BillingDate__c = testDate,
                StoreBusinessNumber__c = '1234567890',
                BillingAmount__c = 30000
        );
        insert testBilling;

        Test.startTest();
        List<CorporateCardBilling__c> result = TaxFileUploadController.getBillingList(2024, 1);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'There should be one billing record.');
    }
    @IsTest
    static void testUpdateBillingList() {
        User testUser = new User(
                Alias = 'tuser',
                Email = 'testuser@example.com',
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'testuser@example.comMMMMssdfs11',
                LastName = 'ttus'
        );
        insert testUser;
        User retrievedUser = [SELECT Id FROM User WHERE UserName = 'testuser@example.comMMMMssdfs11' LIMIT 1];
        User retrievedUser2 = [SELECT Id FROM User LIMIT 1];


        CorporateCard__c testCard = new CorporateCard__c(
                Name = '하나 945081******8562',
                CardCompany__c = '03',
                CardNumber__c = '945081******8562',
                CardNickname__c = '별칭',
                EffectiveMonth__c =  '2028.02',
                RealUser__c = retrievedUser2.Id
        );
        insert testCard;

        CorporateCard__c retrievedCard = [SELECT Id,RealUser__c FROM CorporateCard__c WHERE Name = '하나 945081******8562' LIMIT 1];

        List<CorporateCardBilling__c> testBillingList = new List<CorporateCardBilling__c>();
        Date testDate = Date.newInstance(2024, 1, 15);
        CorporateCardBilling__c testBilling = new CorporateCardBilling__c(
                CorporateCard__c = retrievedCard.Id,
                BillingDate__c = testDate,
                StoreBusinessNumber__c = '1234567890',
                BillingAmount__c = 30000
        );
        testBillingList.add(testBilling);
        CorporateCardBilling__c testBilling2 = new CorporateCardBilling__c(
                CorporateCard__c = retrievedCard.Id,
                BillingDate__c = testDate,
                StoreBusinessNumber__c = '',
                BillingAmount__c = 30000
        );
        testBillingList.add(testBilling2);
        insert testBillingList;

        List<List<String>> data = new List<List<String>>();
        List<String> row = new List<String>();
        row.add('1234567890');    // Business number
        row.add('법인사업자');     // Store Type
        row.add('서비스');       // Business Type 1
        row.add('유료도로운영'); // Business Type 2
        row.add('공제');      // Deduction 1
        row.add('');        // Deduction 2
        data.add(row);
        row = new List<String>();
        row.add('');              // Business number
        row.add('법인사업자');     // Store Type
        row.add('서비스');       // Business Type 1
        row.add('유료도로운영'); // Business Type 2
        row.add('공제');      // Deduction 1
        row.add('');        // Deduction 2

        List<CorporateCardBilling__c> billingList = [SELECT Id, Name, StoreBusinessNumber__c FROM CorporateCardBilling__c];
        Test.startTest();
        Map<String, String> result = TaxFileUploadController.updateBillingList(billingList, data);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'There should be one result.');


        // Validate that the record was updated correctly
        CorporateCardBilling__c updatedBilling = [SELECT Tax_StoreType__c, Tax_BusinessType1__c, Tax_BusinessType2__c, Tax_deduction1__c, Tax_deduction2__c FROM CorporateCardBilling__c WHERE Id = :testBilling.Id];
        System.assertEquals('법인사업자', updatedBilling.Tax_StoreType__c, 'The Store Type should be updated.');
        System.assertEquals('서비스', updatedBilling.Tax_BusinessType1__c, 'The Business Type 1 should be updated.');
        System.assertEquals('유료도로운영', updatedBilling.Tax_BusinessType2__c, 'The Business Type 2 should be updated.');
        System.assertEquals('공제', updatedBilling.Tax_deduction1__c, 'The Deduction 1 should be updated.');

    }
}