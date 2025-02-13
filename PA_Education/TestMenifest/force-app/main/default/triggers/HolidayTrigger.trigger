/**
 * @description       : 휴가관리 레코드가 변경될 경우, 변경된 필드 트레킹
 * @author            : jinwoo.jang@daeunextier.com
 * @group             : DaeuNextier
 *
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2023-02-15   jinwoo.jang@daeunextier.com   Init
**/
trigger HolidayTrigger on Holiday__c (after update) {
    if(Trigger.isAfter && Trigger.isUpdate) {
        HolidayHistoryInsert.doHolidayHistoryInsert(Trigger.new, Trigger.oldMap);
    }
}