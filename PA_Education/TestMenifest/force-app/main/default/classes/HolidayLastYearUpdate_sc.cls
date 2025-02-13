/**
 * @description       : 올해 관련 연차일수를 전년도 연차일수로 Update
 *                      
 * @author            : hyunsoo.song@daeunextier.com
 * @group             :
 * @last modified on  : 2022-12-29
 * @last modified by  : hyunsoo.song@daeunextier.com
 * Modifications Log
 * Ver     Date             Author               Modification
 * 1.0   2022-12-29   hyunsoo.song@daeunextier.com   Initial Version
 */
/*
    매년 12월 31일 23:00:00 Setting
    String CRON_EXP = '0 0 23 31 12 ? *';  // 초 분 시 일 월 요일 년
    System.schedule('HolidayLastYearUpdate 매년 12월 31일 업데이트', CRON_EXP, new HolidayLastYearUpdate_sc());
 */
global class HolidayLastYearUpdate_sc implements Schedulable {

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new HolidayLastYearUpdate_ba(),100);
    }
}