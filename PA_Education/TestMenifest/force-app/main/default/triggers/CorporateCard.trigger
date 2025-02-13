/**
 * Created by yeonlim on 2024-01-17.
 */
trigger CorporateCard on CorporateCard__c (before insert, before update, before delete, after insert, after update, after delete) {
    new CorporateCard_tr().run();
}