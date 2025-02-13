/**
 * @description       : HolidayManage.cmp(휴일 관리(관리자용))에서 호출하는 Apex Class
 * @author            : 알 수 없음
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 2.0   2021.01.12   cj.sohn@daeunextier.com       Modified
 * 2.1   2022.06.14   yc.park@daeunextier.com       Modified
 * 2.2   2022.12.27   hyunsoo.song@daeunextier.com  Modified
**/
public class HolidayManageController {
    private static Map<String, String> pickListValuesList;
    private static Boolean isFirst = true;

    /**
     * @param pIsChecked
     * 휴가관리 탭화면 Init 함수
     * @return List<HolidayEmployeeWrapper>
     */
    @AuraEnabled
    public static List<HolidayEmployeeWrapper> getData(Boolean pIsChecked) {
        pIsChecked = !pIsChecked;
        List<Holiday__c> hldLst = [
                SELECT Id, Name, Holiday_Additionaldays__c, Holiday_Calculated__c, Holiday_GivenHolidays__c, Holiday_IsActive__c, Holiday_IsAnnualleave__c, Holiday_JoinDate__c,
                        Holiday_LastActivity__c, Holiday_NoticeLevel__c, Holiday_PeriodEnd__c, Holiday_Remain__c, Holiday_StartDate__c, Holiday_Uncountable__c, Holiday_Unpaid__c, Holiday_UseDays__c,
                        Holiday_User__c, Holiday_User__r.Name, Holiday_User__r.UserRole.Name, Holiday_User__r.Title, Holiday_WorkingYears__c, Holiday_Monthly_Calculated__c,
                        Holiday_Annual_Calculated__c, Holiday_Monthly_Period__c, HolidayRemainOfLastYear__c, RemainOfLastYear__c, Holiday_Total_Remain__c, Holiday_rewardDays__c,
                        Holiday_WomenHoliday_Count__c, Holiday_SickLeave_Count__c, Holiday_FamilyEvent_Count__c, Holiday_PublicWorks_Count__c, MonthlyOfLastYear__c, Holiday_Total_Count__c,
                        fm_Holiday_rewardRemainDays__c, Holiday_reward_Total_Count__c, Holiday_BenefitPaymentDays__c
                FROM Holiday__c
                WHERE Holiday_IsActive__c = :pIsChecked
                ORDER BY Employee__r.EmployeeNo__c
        ];
        System.debug('hldLst : ' + hldLst);

        Map<Id, Employee__c> mapEmployee = new Map<Id, Employee__c>();
        for (Employee__c objEmp : [SELECT Department__c, Position__c, User__c, EmployeeNo__c FROM Employee__c WHERE Status__c = :pIsChecked]) {
            mapEmployee.put(objEmp.User__c, objEmp);
        }
        System.debug('mapEmployee : ' + mapEmployee);

        List<HolidayEmployeeWrapper> listWrapper = new List<HolidayEmployeeWrapper>();
        for (Holiday__c objHoliday : hldLst) {

            HolidayEmployeeWrapper objHEW = new HolidayEmployeeWrapper(objHoliday, mapEmployee.get(objHoliday.Holiday_User__c));
            System.debug('HolidayEmployeeWrapper : ' + objHEW);
            listWrapper.add(objHEW);
        }
        System.debug(String.format('List<HolidayEmployeeWrapper> (size : {0}) : {1}', new List<Object>{ listWrapper.size(), listWrapper }));

        return listWrapper;
    }

    @AuraEnabled
    public static String doSave(List<Holiday__c> hldLst) {
        System.debug(String.format('List<Holiday__c> (size : {0}) : {1}', new List<Object>{ hldLst.size(), hldLst }));
        for (Holiday__c obj : hldLst) {
            System.debug('Holiday__c : ' + obj);
        }

        try {
            update hldLst;
            return '저장되었습니다.';
        } catch (DmlException dmlExcept) {
            System.debug(String.format('[Error] {0}, Line : {1}', new List<Object>{ dmlExcept.getMessage(), dmlExcept.getLineNumber() }));
            return '에러가 발생했습니다. / ' + dmlExcept.getMessage();
        }
    }

    /**
     * @description       : 휴가 추가 일수 타입 변경 (Integer->Decimal)
     * @author            : yc.park@daeunextier.com
     * @group             : DaeuNextier
     * @return            : String
    **/
    @AuraEnabled
    public static String doModify(List<Map<String, Object>> hldLst, Decimal addDays, String addDesc) {

        Decimal day = 0;
        String msg = UserInfo.getLastName();
        try {
            day = addDays;
        } catch (Exception e) {
            System.debug(String.format('[Error] {0}, Line : {1}', new List<Object>{ e.getMessage(), e.getLineNumber() }));
        }

        msg += ' had adding ' + String.valueOf(day) + ' day(s). Reason : ';
        msg += String.format(' had adding {0} day(s). Reason : {1}', new List<Object>{ String.valueOf(day), (addDesc == null || addDesc == '') ? 'Additional Holidays.' : addDesc});

        //2023.06.13 yj.kim 수정 - 에러발생
        System.debug('hldLst : ' + hldLst);
        System.debug('day : ' + day);
        Map<String, Object> mapTarget = new Map<String, Object>();
        List<Holiday__c> updateList = new List<Holiday__c>();
        for (Object hld : hldLst) {
            mapTarget = (Map<String, Object>) hld;

            System.debug('Holiday_GivenHolidays__c : ' + mapTarget.get('GivenHolidays'));
            Holiday__c obj = new Holiday__c();

            obj.Id = String.valueOf(mapTarget.get('Id'));
            if(mapTarget.get('GivenHolidays') != null){
                System.debug('1');
                obj.Holiday_GivenHolidays__c = Double.valueOf(mapTarget.get('GivenHolidays')) + day ;
            }else{
                System.debug('2');
                obj.Holiday_GivenHolidays__c = Double.valueOf(mapTarget.get('GivenHolidays'));
            }
            obj.Holiday_LastActivity__c = msg ;

            updateList.add(obj);
        }

        try {
            update updateList;
            return '저장되었습니다.';
        } catch (Exception e) {
            System.debug(String.format('[Error] {0}, Line : {1}', new List<Object>{ e.getMessage(), e.getLineNumber() }));
            return '에러가 발생했습니다. / ' + e.getMessage();
        }
    }

    @AuraEnabled
    public static String doSend(List<Holiday__c> hldLst) {
        try {
            List<User> usrLst = new List<User>();
            Set<Id> usrIdSet = new Set<Id>();
            for (Holiday__c hld : hldLst) {
                usrIdSet.add(hld.Holiday_User__c);
            }
            usrLst = [SELECT Email, Name FROM User WHERE Id = :usrIdSet];
            Map<Id, User> usrMap = new Map<Id, User>();
            for (User usr : usrLst) {
                usrMap.put(usr.Id, usr);
            }
            Integer sendCnt = 0;
            Integer errCnt = 0;
            for (Holiday__c hld : hldLst) {
                Boolean finish = HolidayUtil.sendEmail('Info', usrMap.get(hld.Holiday_User__c), hld);
                if (finish) {
                    sendCnt++;
                } else {
                    errCnt++;
                }
            }
            return '발송이 완료되었습니다. 성공 : ' + String.valueOf(sendCnt) + '건, 실패 : ' + String.valueOf(errCnt) + '건.';
        } catch (Exception dmlExcept) {
            System.debug(String.format('[Error] {0}, Line : {1}', new List<Object>{ dmlExcept.getMessage(), dmlExcept.getLineNumber() }));
            return '에러가 발생했습니다. / ' + dmlExcept.getMessage();
        }
    }
    
    @AuraEnabled
    public static String doReset(List<Holiday__c> hldLst, String type) {
        String msg = UserInfo.getLastName() + ' had reset ' + type + ' holidays.';
        for (Holiday__c hld : hldLst) {
            if (type == 'unpaid') {
                hld.Holiday_Unpaid__c = 0;
            } else if (type == 'uncountable') {
                hld.Holiday_Uncountable__c = 0;
            }

            hld.Holiday_LastActivity__c = msg ;
        }
        try {
            update hldLst;
            return '저장되었습니다.';
        } catch (DmlException dmlExcept) {
            System.debug(String.format('[Error] {0}, Line : {1}', new List<Object>{ dmlExcept.getMessage(), dmlExcept.getLineNumber() }));
            return '에러가 발생했습니다. / ' + dmlExcept.getMessage();
        }
    }

    @AuraEnabled
    public static String doCreate() {
        try {
            List<User> usrLst = [SELECT Id, CreatedDate FROM User WHERE Id NOT IN (SELECT Holiday_User__c FROM Holiday__c) AND IsActive = TRUE AND UserType = 'Standard'];
            if (usrLst.isEmpty()) {
                return 'There is no new employee.';
            }

            /**
             * @author            : cj.sohn@daeunextier.com
             * @description       : 사용자에 해당하는 사원 정보를 조회하여 사용자별 입사일을 맵핑하도록 수정.
             * @last modified on  : 2021-01-12
            **/
            Set<Id> setUserIds = new Set<Id>();
            for (User usr : usrLst) {
                setUserIds.add(usr.Id);
            }
            List<Employee__c> listEmployees = [SELECT Id, User__c, JoinDate__c FROM Employee__c WHERE User__c IN :setUserIds];
            Map<Id, Employee__c> mapJoinDateByUserId = new Map<Id, Employee__c>();
            if (listEmployees.size() > 0) {
                for (Employee__c employee : listEmployees) {
                    mapJoinDateByUserId.put(employee.User__c, employee);
                }
            }

            List<Holiday__c> hLst = new List<Holiday__c>();
            for (User usr : usrLst) {
                Date joinDate = mapJoinDateByUserId.get(usr.Id) == null || mapJoinDateByUserId.get(usr.Id).JoinDate__c == null ? Date.valueOf(usr.CreatedDate) : mapJoinDateByUserId.get(usr.Id).JoinDate__c;
                Id employeeId = mapJoinDateByUserId.get(usr.Id) == null ? null : mapJoinDateByUserId.get(usr.Id).Id;
                Holiday__c h = new Holiday__c(Holiday_JoinDate__c = joinDate, Employee__c = employeeId, Holiday_LastActivity__c = 'Created.', Holiday_NoticeLevel__c = 'Not Need', Holiday_User__c = usr.Id);
                hLst.add(h);
            }
            insert hLst;
            /** ===============================END=============================== **/

            List<Holiday__Share> hsLst = new List<Holiday__Share>();
            for (Holiday__c h : hLst) {
                Holiday__Share hldShr = new Holiday__Share();
                hldShr.ParentId = h.Id;
                hldShr.RowCause = Schema.Holiday__Share.RowCause.Holiday_Owner__c;
                hldShr.UserOrGroupId = h.Holiday_User__c ;
                hldShr.AccessLevel = 'Read';
                hsLst.add(hldShr);
            }
            insert hsLst;
            return String.valueOf(hsLst.size()) + '명의 휴일정보가 생성되었습니다.';

        } catch (DmlException dmlExcept) {
            System.debug(String.format('[Error] {0}, Line : {1}', new List<Object>{ dmlExcept.getMessage(), dmlExcept.getLineNumber() }));
            return '에러가 발생했습니다. / ' + dmlExcept.getMessage();
        }
    }

    /**
     * @description       : 임직원 정보를 Employee__c에서 수정 시 업데이트 버튼을 통해 Holiday__c에 존재하는 직원 정보 업데이트
     * @author            : hyunsoo.song@daeunextier.com
     * @group             : DaeuNextier
     * @return            : String
    **/
    @AuraEnabled
    public static String doUpdate() {
        try {
            // 등록된 직원 리스트
            List<Employee__c> listEmployees = [SELECT Id, User__c, Name, JoinDate__c, Status__c FROM Employee__c];
            if (listEmployees.size() > 0) {
                Map<Id, Employee__c> mapJoinDateByUserId = new Map<Id, Employee__c>();
                for (Employee__c employee : listEmployees) {
                    mapJoinDateByUserId.put(employee.User__c, employee);
                }

                Boolean changeFlag = false;
                Map<Id, Holiday__c> mapJoinDateHoliday = new Map<Id, Holiday__c>();
                for (Holiday__c holiday : [SELECT Id, Holiday_JoinDate__c, Holiday_User__c, Holiday_IsActive__c, Employee__c FROM Holiday__c WHERE Holiday_User__c != NULL]) {
                    changeFlag = false;

                    // 입사일자
                    if (mapJoinDateByUserId.get(holiday.Holiday_User__c) != null && (mapJoinDateByUserId.get(holiday.Holiday_User__c).JoinDate__c != holiday.Holiday_JoinDate__c)) {
                        holiday.Holiday_JoinDate__c = mapJoinDateByUserId.get(holiday.Holiday_User__c).JoinDate__c;
                        changeFlag = true;
                    }

                    // Employee
                    if (holiday.Employee__c == null && mapJoinDateByUserId.get(holiday.Holiday_User__c) != null) {
                        holiday.Employee__c = mapJoinDateByUserId.get(holiday.Holiday_User__c).Id;
                        changeFlag = true;
                    }

                    if(changeFlag) {
                        mapJoinDateHoliday.put(holiday.Id, holiday);
                    }
                }

                if (mapJoinDateHoliday.size() > 0) {
                    update mapJoinDateHoliday.values();
                    return String.valueOf(mapJoinDateHoliday.size()) + '명의 임직원 정보가 업데이트 되었습니다.';
                }
            }

            return '정보가 수정된 임직원이 존재하지 않습니다.';
        } catch (DmlException dmlExcept) {
            System.debug('dmlExcept.getMessage() : ' + dmlExcept.getMessage() + ' line : ' + dmlExcept.getLineNumber());
            return '에러가 발생했습니다. / ' + dmlExcept.getMessage();
        }
    }

    public class HolidayEmployeeWrapper {
        @AuraEnabled public String Id;                              // Holiday__c
        @AuraEnabled public String Name;                            // Holiday__c
        @AuraEnabled public String User;                            // Holiday__c
        @AuraEnabled public String UserName;                        // Holiday__c
        @AuraEnabled public Date JoinDate;                          // Holiday__c
        @AuraEnabled public String SumMonthly;                      // Holiday__c
        @AuraEnabled public String MonthlyPeriod;                   // Holiday__c
        @AuraEnabled public String RemainOfLastYear;                // Holiday__c
        @AuraEnabled public String AnnualCalculated;                // Holiday__c
        @AuraEnabled public String SumAnnualCalcRemainLastYear;     // Holiday__c
        @AuraEnabled public String PublicWorksCount;                // Holiday__c
        @AuraEnabled public String GivenHolidays;                   // Holiday__c
        @AuraEnabled public String UseDays;                         // Holiday__c
        @AuraEnabled public String TotalRemain;                     // Holiday__c
        @AuraEnabled public String FamilyEventCount;                // Holiday__c
        @AuraEnabled public String SickLeaveCount;                  // Holiday__c
        @AuraEnabled public String WomenHolidayCount;               // Holiday__c
        @AuraEnabled public String rewardDaysCount;                 // Holiday__c
        @AuraEnabled public String rewardRemainDays;                // Holiday__c
        @AuraEnabled public String totalrewardDays;                 // Holiday__c
        @AuraEnabled public String BenefitPaymentDays;              // Holiday__c

        @AuraEnabled public String Department;                      // Employee__c
        @AuraEnabled public String Position;                        // Employee__c
        @AuraEnabled public String EmployeeNo;                      // Employee__c

        public HolidayEmployeeWrapper(Holiday__c objHoliday, Employee__c objEmployee) {
            this.Id                             = objHoliday.Id;
            this.Name                           = objHoliday.Name;
            this.User                           = objHoliday.Holiday_User__c;
            this.UserName                       = objHoliday.Holiday_User__r.Name;
            this.JoinDate                       = objHoliday.Holiday_JoinDate__c;
            this.SumMonthly                     = objHoliday.MonthlyOfLastYear__c != null ? String.valueOf(objHoliday.Holiday_Monthly_Calculated__c + objHoliday.MonthlyOfLastYear__c) : String.valueOf(objHoliday.Holiday_Monthly_Calculated__c);
            this.MonthlyPeriod                  = String.valueOf(objHoliday.Holiday_Monthly_Period__c);
            this.RemainOfLastYear               = String.valueOf(objHoliday.HolidayRemainOfLastYear__c);
            this.AnnualCalculated               = String.valueOf(objHoliday.Holiday_Annual_Calculated__c);

            // 총 연월차 (전년도 연월차 잔여일수 + 올해 월차일수 + 올해 연차일수)
            this.SumAnnualCalcRemainLastYear    = String.valueOf(objHoliday.Holiday_Total_Count__c);
            this.PublicWorksCount               = String.valueOf(objHoliday.Holiday_PublicWorks_Count__c);
            this.GivenHolidays                  = String.valueOf(objHoliday.Holiday_GivenHolidays__c);
            this.UseDays                        = String.valueOf(objHoliday.Holiday_UseDays__c);
            this.TotalRemain                    = String.valueOf(objHoliday.Holiday_Total_Remain__c);
            this.FamilyEventCount               = String.valueOf(objHoliday.Holiday_FamilyEvent_Count__c);
            this.SickLeaveCount                 = String.valueOf(objHoliday.Holiday_SickLeave_Count__c);
            this.WomenHolidayCount              = String.valueOf(objHoliday.Holiday_WomenHoliday_Count__c);
            this.rewardDaysCount                = String.valueOf(objHoliday.Holiday_rewardDays__c);
            this.rewardRemainDays               = String.valueOf(objHoliday.fm_Holiday_rewardRemainDays__c);
            this.totalrewardDays                = String.valueOf(objHoliday.Holiday_reward_Total_Count__c);
            this.BenefitPaymentDays             = String.valueOf(objHoliday.Holiday_BenefitPaymentDays__c);

            if (objEmployee != null) {
                this.Department                 = objEmployee.Department__c;
                if (isFirst) pickListValuesList = getPositionLabel();
                this.Position                   = pickListValuesList.get(objEmployee.Position__c);
                this.EmployeeNo                 = objEmployee.EmployeeNo__c;
            }
        }

        public Map<String, String> getPositionLabel() {
            isFirst = false;
            pickListValuesList = new Map<String, String>();

            List<Schema.PicklistEntry> ple = Employee__c.Position__c.getDescribe().getPicklistValues();
            for (Schema.PicklistEntry pickListVal : ple) {
                pickListValuesList.put(pickListVal.getValue(), pickListVal.getLabel());
            }

            return pickListValuesList;
        }
    }
}