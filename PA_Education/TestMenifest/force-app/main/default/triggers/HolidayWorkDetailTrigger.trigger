/**
 * Created by JWJANG on 2023-02-02.
 */
trigger HolidayWorkDetailTrigger on HolidayWorkDetail__c (before insert, before update, after insert, after update, after delete, after undelete) {
    new HolidayWorkDetail_tr().run();
}