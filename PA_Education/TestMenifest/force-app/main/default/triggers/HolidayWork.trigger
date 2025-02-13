/**
 * Created by yj.kim on 2023-06-07.
 * 휴일근무 승인완료일때, 대체휴가에 대한 이력 관리
 */

trigger HolidayWork on HolidayWork__c (before insert, before update, before delete, after insert, after update, after delete) {
    new HolidayWork_tr().run();
}