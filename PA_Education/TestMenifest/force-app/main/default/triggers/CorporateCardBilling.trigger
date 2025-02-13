/**
 * Created by yeonlim on 2024-01-12.
 */
trigger CorporateCardBilling on CorporateCardBilling__c (before insert, before update, before delete, after insert, after update, after delete) {
    new CorporateCardBilling_tr().run();
}