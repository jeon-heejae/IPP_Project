/**
 * @description       : 매년 12월 31일 11:00:00 에 '올해 월차일수, 올해 연차일수, 연월차 사용일수, 연월차 잔여일수'를
 *                      '전년도 월차일수, 전년도 연차일수, 전년도 연월차 사용일수, 전년도 연월차 잔여일수' 각각에 값 update.
 *                      
 * @author            : hyunsoo.song@daeunextier.com
 * @group             :
 * @last modified on  : 2022-12-29
 * @last modified by  : hyunsoo.song@daeunextier.com
 * Modifications Log
 * Ver     Date             Author                  Modification
 * 1.0   2022-12-29   hyunsoo.song@daeunextier.com  Initial Version
 * 2.0   2023-12-20   kwanwoo.jeon@daeunextier.com  대체휴가 관련 로직 추가
 * 2.1   2023-12-27   kwanwoo.jeon@daeunextier.com  전년도 연월차 사용일수를 전년도에 사용한 전체 연월차 일수가 아닌, 전년도에 발생한 연월차 일수 중에 사용한 연월차 일수로 표시되게 변경
 * 2.2   2024-01-02   kwanwoo.jeon@daeunextier.com  전년도 연월차 사용일수에 추가부여일수 추가
 */
public with sharing class HolidayLastYearUpdate_ba implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery;
        strQuery = ' SELECT  Id, Name, Holiday_Total_Remain__c, Holiday_UseDays__c, Holiday_GivenHolidays__c, Holiday_Annual_Calculated__c, ' +
                    ' HolidayRemainOfLastYear__c, CarriedOverOfLastYear__c, UseDaysOfLastYear__c, Holiday_Monthly_Calculated__c, ' +
                    ' Holiday_reward_Total_Count__c, Holiday_rewardDays__c, Holiday_BenefitPaymentDays__c, fm_Holiday_rewardRemainDays__c, ' +
                    ' RewardHolidayRemainOfLastYear__c, RewardHolidayTotalOfLastYear__c, RewardHolidayUseDaysOfLastYear__c, RewardHolidayPaymentDaysOfLastYear__c ';
        strQuery += ' FROM   Holiday__c';
        strQuery += ' WHERE  (Holiday_Annual_Calculated__c != NULL OR Holiday_Annual_Calculated__c != 0)';
        strQuery += ' AND    Holiday_IsActive__c = TRUE';
        System.debug('[HolidayLastYearUpdate] Query : ' + strQuery);

        return Database.getQueryLocator(strQuery);
    }

    public void execute(Database.BatchableContext bc, List<Holiday__c> listHoliday) {
        System.debug('[HolidayLastYearUpdate] Execute Start !!');
        Map<Id, Holiday__c> mapTarget = new Map<Id, Holiday__c>();
        for(Holiday__c obj : listHoliday) {

            //2023.12.27 하형석 이사님 요청으로 전년도 연월차 사용일수를 전년도 잔여 보다 사용일수가 적을 경우 0, else 올해 사용한 연월차 사용일수로 설정
            //전년도 연월차 사용일수 = 0 || 연월차 사용일수 - 전년도 잔여일수
            obj.UseDaysOfLastYear__c = (obj.Holiday_UseDays__c - obj.Holiday_GivenHolidays__c) < obj.HolidayRemainOfLastYear__c? 0 : (obj.Holiday_UseDays__c- obj.Holiday_GivenHolidays__c) - obj.HolidayRemainOfLastYear__c;

            // 전년도 연차 잔여일수 (전년도 연월차 사용기한 때문에 분기처리)
            if(obj.Holiday_UseDays__c > obj.HolidayRemainOfLastYear__c || (obj.HolidayRemainOfLastYear__c == 0 || obj.HolidayRemainOfLastYear__c == null)) {
                // 전년도 연월차 잔여일수 = 연월차 잔여일수
                obj.HolidayRemainOfLastYear__c = obj.Holiday_Total_Remain__c;
            } else {
                // 전년도 연월차 잔여일수 = 올해 연차일수 + 올해 월차일수 + 추가 부여 일수
                obj.HolidayRemainOfLastYear__c = obj.Holiday_Annual_Calculated__c + obj.Holiday_Monthly_Calculated__c + obj.Holiday_GivenHolidays__c;
            }

            // 전년도 월차일수 = 올해 월차일수
            obj.MonthlyOfLastYear__c = obj.Holiday_Monthly_Calculated__c;
            //전년도 연차일수 = 올해 연차일수
            obj.CarriedOverOfLastYear__c = obj.Holiday_Annual_Calculated__c;

            // 전년도 연월차 데이터 계산 완료 이후, 연월차 사용일수 및 추가 부여일수 초기화
            obj.Holiday_UseDays__c = 0;
            obj.Holiday_GivenHolidays__c = 0;

            // 경조휴가, 병가, 생리휴가, 공가 초기화
            obj.Holiday_FamilyEvent_Count__c = 0;
            obj.Holiday_SickLeave_Count__c = 0;
            obj.Holiday_WomenHoliday_Count__c = 0;
            obj.Holiday_PublicWorks_Count__c = 0;

            //2023.12.20    kwanwoo.jeon    대체휴가 필드 설정
            //전년도 대체휴가일수 = 총 대체휴가일수 - 전년도 대체휴가일수(ex. 23년 대체휴가 발생 일수는 23년 총에서 22년 발생일수를 뺀 값)
            obj.RewardHolidayTotalOfLastYear__c = obj.Holiday_reward_Total_Count__c - obj.RewardHolidayTotalOfLastYear__c;
            //전년도 대체휴가 사용일수 = 올해 대체휴가 사용일수
            obj.RewardHolidayUseDaysOfLastYear__c = obj.Holiday_rewardDays__c;
            //전년도 잔여 대체휴가일수 = 올해 대체휴가 잔여 일수
            obj.RewardHolidayRemainOfLastYear__c = obj.fm_Holiday_rewardRemainDays__c;
            //전년도 대체휴가 수당 지급일수 = 올해 대체휴가 수당 지급일수
            obj.RewardHolidayPaymentDaysOfLastYear__c = obj.Holiday_BenefitPaymentDays__c;

            //올해 총 대체휴가일수 = 전년도 잔여 대체휴가 일수 (+ 올해 발생한 대체휴가 일수 이기 때문에 scheduler에서는 전년도 잔여 대체휴가로만 계산)
            obj.Holiday_reward_Total_Count__c = obj.RewardHolidayRemainOfLastYear__c;

            //대체휴가 초기화
            obj.Holiday_rewardDays__c = 0;
            obj.Holiday_BenefitPaymentDays__c = 0;

            mapTarget.put(obj.Id, obj);
        }

        System.debug('mapTarget.size()' + mapTarget);

        if(mapTarget.size() != 0) {
            try {
                list<HolidayAction__c> listHolidayAction = new List<HolidayAction__c>([
                                SELECT  Id, HolidayAction_Parent__c, HolidayAction_Type__c,
                                        HolidayAction_Date1__c, HolidayAction_Date2__c, HolidayAction_Date3__c, HolidayAction_Date4__c, HolidayAction_Date5__c,
                                        HolidayAction_Date6__c, HolidayAction_Date7__c, HolidayAction_Date8__c, HolidayAction_Date9__c, HolidayAction_Date10__c
                                FROM    HolidayAction__c
                                WHERE   HolidayAction_Parent__c in : mapTarget.keySet()
                                AND     CreatedDate = THIS_YEAR
                                AND     HolidayAction_IsConfirm__c = TRUE
                                AND    (HolidayAction_Date1__c    > THIS_YEAR
                                OR      HolidayAction_Date2__c    > THIS_YEAR
                                OR      HolidayAction_Date3__c    > THIS_YEAR
                                OR      HolidayAction_Date4__c    > THIS_YEAR
                                OR      HolidayAction_Date5__c    > THIS_YEAR
                                OR      HolidayAction_Date6__c    > THIS_YEAR
                                OR      HolidayAction_Date7__c    > THIS_YEAR
                                OR      HolidayAction_Date8__c    > THIS_YEAR
                                OR      HolidayAction_Date9__c    > THIS_YEAR
                                OR      HolidayAction_Date10__c   > THIS_YEAR)
                ]);

                System.debug('listHolidayAction.size()' + listHolidayAction.size());
                map<Id, Decimal> mapIdToDaysCount = new Map<Id, Decimal>();
                map<Id, Decimal> mapIdToRewardDaysCount = new Map<Id, Decimal>();
                if (!listHolidayAction.isEmpty()) {
                    Integer intThisYear = Date.today().year();
                    for (HolidayAction__c obj: listHolidayAction){
                        if (new List<String>{'Annual Holiday','Half-day Leave','Reward Holiday','Reward Half-Holiday'}.contains(obj.HolidayAction_Type__c)) {
                            Decimal cnt = 0;
                            cnt = obj.HolidayAction_Date1__c    != null && obj.HolidayAction_Date1__c.year()    > intThisYear     ? obj.HolidayAction_Type__c.contains('Half') ?  cnt + 0.5 : cnt + 1 : cnt;
                            cnt = obj.HolidayAction_Date2__c    != null && obj.HolidayAction_Date2__c.year()    > intThisYear     ? cnt + 1 : cnt;
                            cnt = obj.HolidayAction_Date3__c    != null && obj.HolidayAction_Date3__c.year()    > intThisYear     ? cnt + 1 : cnt;
                            cnt = obj.HolidayAction_Date4__c    != null && obj.HolidayAction_Date4__c.year()    > intThisYear     ? cnt + 1 : cnt;
                            cnt = obj.HolidayAction_Date5__c    != null && obj.HolidayAction_Date5__c.year()    > intThisYear     ? cnt + 1 : cnt;
                            cnt = obj.HolidayAction_Date6__c    != null && obj.HolidayAction_Date6__c.year()    > intThisYear     ? cnt + 1 : cnt;
                            cnt = obj.HolidayAction_Date7__c    != null && obj.HolidayAction_Date7__c.year()    > intThisYear     ? cnt + 1 : cnt;
                            cnt = obj.HolidayAction_Date8__c    != null && obj.HolidayAction_Date8__c.year()    > intThisYear     ? cnt + 1 : cnt;
                            cnt = obj.HolidayAction_Date9__c    != null && obj.HolidayAction_Date9__c.year()    > intThisYear     ? cnt + 1 : cnt;
                            cnt = obj.HolidayAction_Date10__c   != null && obj.HolidayAction_Date10__c.year()   > intThisYear     ? cnt + 1 : cnt;


                            if (cnt > 0) {
                                if (new List<String>{'Annual Holiday','Half-day Leave'}.contains(obj.HolidayAction_Type__c)) {
                                    mapIdToDaysCount.put(obj.HolidayAction_Parent__c, mapIdToDaysCount.get(obj.HolidayAction_Parent__c) != null ? mapIdToDaysCount.get(obj.HolidayAction_Parent__c) + cnt : cnt);
                                }else if(new List<String>{'Reward Holiday','Reward Half-Holiday'}.contains(obj.HolidayAction_Type__c)) {
                                    mapIdToRewardDaysCount.put(obj.HolidayAction_Parent__c, mapIdToRewardDaysCount.get(obj.HolidayAction_Parent__c) != null ? mapIdToRewardDaysCount.get(obj.HolidayAction_Parent__c) + cnt : cnt);
                                }
                            }
                        }
                    }
                    if (!mapIdToDaysCount.isEmpty()) {
                        for (Id holidayId : mapIdToDaysCount.keySet()){
                            //전년도 사용일수(-), 전년도 잔여일수(+), 올해 사용일수(+)
                            //cnt = 내년도에 사용한 연차일수 (ex. 23.12에 결제올린 24.1 연차)
                            //전년도 사용일수 < cnt가 많을 경우 전년도 잔여일수 += 전년도 사용일수/ 사용일수 = 0/ 올해 사용일수 + cnt
                            if (mapTarget.get(holidayId).UseDaysOfLastYear__c < mapIdToDaysCount.get(holidayId)) {
                                mapTarget.get(holidayId).HolidayRemainOfLastYear__c += mapTarget.get(holidayId).UseDaysOfLastYear__c; //전년도 잔여일수 += 전년도 사용일수
                                mapTarget.get(holidayId).UseDaysOfLastYear__c       = 0; //전년도 사용일수 = 0
                            }else{
                                mapTarget.get(holidayId).UseDaysOfLastYear__c       -= mapIdToDaysCount.get(holidayId); //전년도 사용일수(-)
                                mapTarget.get(holidayId).HolidayRemainOfLastYear__c += mapIdToDaysCount.get(holidayId); //전년도 잔여일수(+)
                            }
                            mapTarget.get(holidayId).Holiday_UseDays__c += mapIdToDaysCount.get(holidayId); //올해 사용일수(+)
                        }
                    }
                    if (!mapIdToRewardDaysCount.isEmpty()) {
                        for (Id holidayId : mapIdToRewardDaysCount.keySet()){
                            //전년도 대체휴가 사용일수(-), 전년도 대체휴가 잔여일수(+), 올해 총 대체휴가(+), 올해 대체휴가 사용일수(+)
                            mapTarget.get(holidayId).RewardHolidayUseDaysOfLastYear__c  -= mapIdToRewardDaysCount.get(holidayId);
                            mapTarget.get(holidayId).RewardHolidayRemainOfLastYear__c   += mapIdToRewardDaysCount.get(holidayId);
                            mapTarget.get(holidayId).Holiday_reward_Total_Count__c      += mapIdToRewardDaysCount.get(holidayId);
                            mapTarget.get(holidayId).Holiday_rewardDays__c              += mapIdToRewardDaysCount.get(holidayId);
                        }
                    }
                }
                update mapTarget.values();

            } catch (Exception e) {
                System.debug('error :: ' + e.getMessage() + ' // ' + e.getLineNumber());
            }
        }

        System.debug('[HolidayLastYearUpdate] Execute End !!');
    }

    public void finish(Database.BatchableContext bc) { }
}