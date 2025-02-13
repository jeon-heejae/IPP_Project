/**
 * @description       : 1) 사용일자 리셋
 *                      2) 1차 촉진 메일 대상자에 대한 NoticeLevel Update
 *                      3) 2차 촉진 메일 대상자에 대한 NoticeLevel Update
 *                      4) 추가 부여 일수 리셋
 *                      5) 신규 입사자 대상 Holiday__c 레코드 생성
 *                      6) 전년도 연차일수 및 전년도 연차 사용일수 초기화
 * @author            : 알 수 없음
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 2.0   2021.01.12   CJ.Sohn                   Modified(추가 부여 일수 초기화)
**/
global class HolidayUpdateStatusBatch implements Database.Batchable<sObject> {

    global String query;

    global database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        /*
        1. 사용일자 리셋
        2. 1차 촉진 메일
        3. 2차 만료 메일
        
        date today = system.today();
        date firstDate = system.today().addMonth(6).addDay(10);
        date secondDate = system.today().addMonth(2);
        string todayStr = string.valueOf(today.year()) + '-' + string.valueOf(today.month()) + '-' + string.valueOf(today.day());
        string firstDateStr = string.valueOf(firstDate.year()) + '-' + firstDate.valueOf(today.month()) + '-' + string.valueOf(firstDate.day());
        string secondDateStr = string.valueOf(secondDate.year()) + '-' + string.valueOf(secondDate.month()) + '-' + string.valueOf(secondDate.day());
        string query  = ' SELECT Holiday_User__c,Holiday_JoinDate__c, Holiday_IsAnnualleave__c,Holiday_PeriodEnd__c,Holiday_Calculated__c,Holiday_GivenHolidays__c,Holiday_UseDays__c,Holiday_Remain__c ';
        query += ' FROM Holiday__c ';
        query += ' where Holiday_PeriodEnd__c in( ' + todayStr + ' ,  ' + firstDateStr  + ' , ' + secondDateStr   + ' )';
        */
        list<Holiday__c> hldLst = (list<Holiday__c>)scope;
        list<Holiday__c> updateLst = new list<Holiday__c>();
        date today = system.today();
        date firstDate = today.addMonths(6).addDays(10);
        date secondDate = today.addMonths(2);
        HolidaySetting__c hs = HolidaySetting__c.getOrgDefaults();
        for(Holiday__c h : hldLst){
            //  만료일자가 오늘이고 (입사일기준이거나) 또는(입사일 기준이면서 올림이거나) 또는 (입사일 기준 내림이면서 근속 1년이상) 인경우만
            if(h.Holiday_PeriodEnd__c == today && (hs.JoinDateRule__c || (!hs.JoinDateRule__c && hs.IsCeil__c) || (!hs.JoinDateRule__c && !hs.IsCeil__c && h.Holiday_WorkingYears__c > 0))){
                decimal useDay = 0;
                //  string actStr = 'Reset use days.';
                /**
                 * @author            : cj.sohn@daeunextier.com
                 * @description       : 추가 부여 일수 초기화
                 * @last modified on  : 2021-01-12
                **/
                Decimal givenHolidays = 0;
                String actStr = 'Reset use days and given holidays.';
                h.Holiday_GivenHolidays__c = givenHolidays;
                /** ===============================END=============================== **/
                /**
                 * @author            : cj.sohn@daeunextier.com
                 * @description       : 전년도 연차일수 및 전년도 연차 사용일수 초기화
                 * @last modified on  : 2021-12-28
                */
                if(h.Holiday_PeriodEnd__c == today){
                    h.CarriedOverOfLastYear__c = 0;
                    h.UseDaysOfLastYear__c = 0;
                    if(h.Holiday_Remain__c > 0) {
                        h.CarriedOverOfLastYear__c = h.Holiday_Remain__c;
                    }
                }
                /** ===============================END=============================== **/
                if(h.Holiday_Remain__c < 0){
                    useDay = h.Holiday_Remain__c * -1;
                    actStr = string.valueOf(useDay) + 'Day(s) move to this year.';
                }
                h.Holiday_UseDays__c = useDay ;
                h.Holiday_LastActivity__c = actStr ;
                h.Holiday_NoticeLevel__c = 'Not Need';

                updateLst.add(h);
            }
            else if(h.Holiday_PeriodEnd__c == firstDate){
                //User usr = [SELECT Email,Name FROM User WHERE Id = :h.Holiday_User__c];
                //HolidayUtil.sendEmail('1st', usr, h);
                h.Holiday_NoticeLevel__c = '1st Notice';
                updateLst.add(h);
            }
            else if(h.Holiday_PeriodEnd__c == secondDate){
                //User usr = [SELECT Email,Name FROM User WHERE Id = :h.Holiday_User__c];
                //HolidayUtil.sendEmail('2nd', usr, h);
                h.Holiday_NoticeLevel__c = '2nd Notice';
                updateLst.add(h);
            }
        }
        update updateLst;
    }

    global void finish(Database.BatchableContext BC){
        /**
             * @author            : cj.sohn@daeunextier.com
             * @description       : 신규 입사자에 대한 Holiday__c Record 부여
             * @last modified on  : 2021-01-12
            **/
        HolidayManageController.doCreate();
        /** ===============================END=============================== **/
    }
}