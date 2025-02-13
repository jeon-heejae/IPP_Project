/**
 * Created by Kwanwoo.Jeon on 2023-12-14.
 */

trigger RewardHolidayTrigger on RewardHoliday__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new RewardHoliday_tr().run();
}