/**
 * @description       : 휴가 사용일수 카운팅 및 최종 승인 시, 사용자의 부서 및 포지션에 따른 이메일 발송
 * @author            : cj.sohn@daeunextier.com
 * @group             : DaeuNextier
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 2.0   2021-01-18   cj.sohn@daeunextier.com   사용자의 부서 및 포지션에 따른 이메일 발송
 * 3.0   2022-12-30   yuna.choi@daeunextier.com holiday action type에 따라 카운팅 되는 사용일수, 사용내역 한글로 수정
 * 4.0   2023-12-14   kwanwoo.jeon              User_tr.cls로 이식
**/
trigger HolidayActionUpdate on HolidayAction__c (before insert, before update, after insert, after update) {
    new HolidayAction_tr().run();

//    if (Trigger.isBefore) {
//
//        // [2023-08-09] 휴가 신청 시, Employee Id 값 설정 (Employee 화면에서 휴가 신청내역 확인을 위함)
//        if(Trigger.isInsert) {
//            Set<Id> setHoliday = new Set<Id>();
//            for (HolidayAction__c objHolidayAction : Trigger.new) {
//                if(objHolidayAction.HolidayAction_Parent__c != null) {
//                    setHoliday.add(objHolidayAction.HolidayAction_Parent__c);
//                }
//            }
//
//            if(!setHoliday.isEmpty()) {
//                Map<Id, Holiday__c> mapHoliday = new Map<Id, Holiday__c>([
//                        SELECT Id, Employee__c
//                        FROM Holiday__c
//                        WHERE Id IN :setHoliday
//                ]);
//                for (HolidayAction__c objHolidayAction : Trigger.new) {
//                    objHolidayAction.Employee__c = mapHoliday.get(objHolidayAction.HolidayAction_Parent__c) == null ?
//                            null : mapHoliday.get(objHolidayAction.HolidayAction_Parent__c).Employee__c;
//                }
//            }
//        }
//
//        if (Trigger.isUpdate) {
//            Map<Id, Holiday__c> hMap = new Map<Id, Holiday__c>();
//            List<HolidayAction__c> haLst = new List<HolidayAction__c>();
//
//            for (HolidayAction__c ha : Trigger.new) {
//                Boolean oldStatus = Trigger.oldMap.get(ha.Id).HolidayAction_IsConfirm__c;
//                Boolean newStatus = ha.HolidayAction_IsConfirm__c;
//                if (!oldStatus && newStatus) {
//                    Holiday__c h;
//                    if (hMap.containsKey(ha.HolidayAction_Parent__c)) {
//                        h = hMap.get(ha.HolidayAction_Parent__c);
//                    } else {
//                        h = [SELECT Id, Holiday_Total_Remain__c, Holiday_Uncountable__c, Holiday_Unpaid__c, Holiday_UseDays__c, CarriedOverOfLastYear__c, UseDaysOfLastYear__c, HolidayRemainOfLastYear__c, Holiday_FamilyEvent_Count__c,Holiday_SickLeave_Count__c, Holiday_WomenHoliday_Count__c, Holiday_PublicWorks_Count__c, Holiday_rewardRemainDays__c, Holiday_rewardDays__c FROM Holiday__c WHERE Id = :ha.HolidayAction_Parent__c];
//                    }
//
//                    // 필드를 새로 추가했기 때문에 기존 레코드에서는 null값이여서 null check
//                    h.Holiday_FamilyEvent_Count__c  = (h.Holiday_FamilyEvent_Count__c == null)  ? 0 : h.Holiday_FamilyEvent_Count__c;
//                    h.Holiday_SickLeave_Count__c    = (h.Holiday_SickLeave_Count__c == null)    ? 0 : h.Holiday_SickLeave_Count__c;
//                    h.Holiday_WomenHoliday_Count__c = (h.Holiday_WomenHoliday_Count__c == null) ? 0 : h.Holiday_WomenHoliday_Count__c;
//                    h.Holiday_PublicWorks_Count__c  = (h.Holiday_PublicWorks_Count__c == null)  ? 0 : h.Holiday_PublicWorks_Count__c;
//                    h.Holiday_rewardRemainDays__c   = (h.Holiday_rewardRemainDays__c == null)   ? 0 : h.Holiday_rewardRemainDays__c;
//                    h.Holiday_rewardDays__c         = (h.Holiday_rewardDays__c == null)         ? 0 : h.Holiday_rewardDays__c;
//
//                    // 사용내역 한글로 번역
//                    List<Schema.PicklistEntry> values = HolidayAction__c.HolidayAction_Type__c.getDescribe().getPicklistValues();
//                    Map<String,String> statusApiToLabelMap = new Map<String,String>();
//                    for(Schema.PicklistEntry sp : values) {
//                        // Map to hold Picklist API as Key and Picklist Label as Value
//                        statusApiToLabelMap.put(sp.getValue(), sp.getLabel());
//                    }
//                    System.debug('Label value of picklist >> ' + statusApiToLabelMap.get(ha.HolidayAction_Type__c));
//
//                    String lstActStr = statusApiToLabelMap.get(ha.HolidayAction_Type__c) + ' ' + String.valueOf(ha.HolidayAction_Days__c) + '일 사용';
//
//                    /**
//                     * @author            : hyunsoo.song@daeunextier.com
//                     * @description       : 연차 혹은 반차인 경우, 연차 사용일자로 카운팅 (전년도 연차 우선 사용 Control은 formula 필드단에서 함.)
//                     * @last modified on  : 2023-01-16
//                    */
//                    if (ha.HolidayAction_Type__c == 'Monthly Holiday' || ha.HolidayAction_Type__c == 'Annual Holiday') { // 연월차
//                        if(ha.HolidayAction_Days__c > h.Holiday_Total_Remain__c) ha.addError(Label.Cannot_Apply_Holiday);
//                        h.Holiday_UseDays__c += ha.HolidayAction_Days__c;
//                    } else if (ha.HolidayAction_Type__c == 'Half-day Leave') { // 반차
//                        if(ha.HolidayAction_Days__c > h.Holiday_Total_Remain__c) ha.addError(Label.Cannot_Apply_Holiday);
//                        h.Holiday_UseDays__c += 0.5;
//                    } else if (ha.HolidayAction_Type__c == 'Reward Holiday') { // 대체휴가
//                        if(ha.HolidayAction_Days__c > h.Holiday_rewardRemainDays__c) ha.addError(Label.Cannot_Apply_Reward_Holiday);
//                        h.Holiday_rewardDays__c += ha.HolidayAction_Days__c;
//                        h.Holiday_rewardRemainDays__c -= ha.HolidayAction_Days__c;
//                    } else if (ha.HolidayAction_Type__c == 'Reward Half-Holiday') { // 대체휴가(반차)
//                        if(ha.HolidayAction_Days__c > h.Holiday_rewardRemainDays__c) ha.addError(Label.Cannot_Apply_Reward_Holiday);
//                        h.Holiday_rewardDays__c += 0.5;
//                        h.Holiday_rewardRemainDays__c -= 0.5;
//                    } else if (ha.HolidayAction_Type__c == 'Women Holiday') { // 생리휴가
//                        h.Holiday_Unpaid__c += ha.HolidayAction_Days__c;
//                        h.Holiday_WomenHoliday_Count__c += ha.HolidayAction_Days__c;
//                    } else if (ha.HolidayAction_Type__c == 'Public Works') { // 공가
//                        h.Holiday_Uncountable__c += ha.HolidayAction_Days__c;
//                        h.Holiday_PublicWorks_Count__c += ha.HolidayAction_Days__c;
//                    } else if (ha.HolidayAction_Type__c == 'Family Leave') { // 경조휴가
//                        h.Holiday_Uncountable__c += ha.HolidayAction_Days__c;
//                        h.Holiday_FamilyEvent_Count__c += ha.HolidayAction_Days__c;
//                    } else if (ha.HolidayAction_Type__c == 'Sick Leave') { // 병가
//                        h.Holiday_Unpaid__c += ha.HolidayAction_Days__c;
//                        h.Holiday_SickLeave_Count__c += ha.HolidayAction_Days__c;
//                    } else {
//                        lstActStr = 'Add Alternative Holiday register.';
//                    }
//
//                    h.Holiday_LastActivity__c = lstActStr;
//                    hMap.put(h.Id, h);
//                }
//
//                // 취소 승인 되면 사용처리된 연차를 복구 함
//                Boolean oldIsCancled = Trigger.oldMap.get(ha.Id).Is_Cancled__c;
//                Boolean newIsCancled = ha.Is_Cancled__c;
//
//                if (!oldIsCancled && newIsCancled) { // 취소가 승인 false -> true로 바뀜
//                    Holiday__c h;
//                    if (hMap.containsKey(ha.HolidayAction_Parent__c)) {
//                        h = hMap.get(ha.HolidayAction_Parent__c);
//                    } else {
//                        h = [SELECT Id, Holiday_Uncountable__c, Holiday_Unpaid__c, Holiday_UseDays__c, CarriedOverOfLastYear__c, UseDaysOfLastYear__c, HolidayRemainOfLastYear__c, Holiday_FamilyEvent_Count__c,Holiday_SickLeave_Count__c, Holiday_WomenHoliday_Count__c, Holiday_PublicWorks_Count__c, Holiday_rewardRemainDays__c, Holiday_rewardDays__c FROM Holiday__c WHERE Id = :ha.HolidayAction_Parent__c];
//                    }
//
//                    // 필드를 새로 추가했기 때문에 기존 레코드에서는 null값이여서 null check
//                    h.Holiday_FamilyEvent_Count__c  = (h.Holiday_FamilyEvent_Count__c == null)  ? 0 : h.Holiday_FamilyEvent_Count__c;
//                    h.Holiday_SickLeave_Count__c    = (h.Holiday_SickLeave_Count__c == null)    ? 0 : h.Holiday_SickLeave_Count__c;
//                    h.Holiday_WomenHoliday_Count__c = (h.Holiday_WomenHoliday_Count__c == null) ? 0 : h.Holiday_WomenHoliday_Count__c;
//                    h.Holiday_PublicWorks_Count__c  = (h.Holiday_PublicWorks_Count__c == null)  ? 0 : h.Holiday_PublicWorks_Count__c;
//                    h.Holiday_rewardRemainDays__c   = (h.Holiday_rewardRemainDays__c == null)   ? 0 : h.Holiday_rewardRemainDays__c;
//                    h.Holiday_rewardDays__c         = (h.Holiday_rewardDays__c == null)         ? 0 : h.Holiday_rewardDays__c;
//
//                    List<Schema.PicklistEntry> values = HolidayAction__c.HolidayAction_Type__c.getDescribe().getPicklistValues();
//                    Map<String,String> statusApiToLabelMap = new Map<String,String>();
//                    for(Schema.PicklistEntry sp : values) {
//                        // Map to hold Picklist API as Key and Picklist Label as Value
//                        statusApiToLabelMap.put(sp.getValue(), sp.getLabel());
//                    }
//                    System.debug('Label value of picklist>>'+ statusApiToLabelMap.get(ha.HolidayAction_Type__c));
//
//                    String lstActStr = statusApiToLabelMap.get(ha.HolidayAction_Type__c) + ' ' + String.valueOf(ha.HolidayAction_Days__c) + '일 승인 취소';
//
//                    /**
//                     * @author            : hyunsoo.song@daeunextier.com
//                     * @description       : 연차 혹은 반차인 경우, 연차 사용일자로 카운팅 (전년도 연차 우선 사용 Control은 formula 필드단에서 함.)
//                     * @last modified on  : 2023-01-16
//                    */
//                    if (ha.HolidayAction_Type__c == 'Monthly Holiday' || ha.HolidayAction_Type__c == 'Annual Holiday') { // 연월차
//                        h.Holiday_UseDays__c -= ha.HolidayAction_Days__c;
//                    } else if (ha.HolidayAction_Type__c == 'Half-day Leave') { // 반차
//                        h.Holiday_UseDays__c -= 0.5;
//                    } else if (ha.HolidayAction_Type__c == 'Reward Holiday') { // 대체휴가
//                        h.Holiday_rewardDays__c -= ha.HolidayAction_Days__c;
//                        h.Holiday_rewardRemainDays__c += ha.HolidayAction_Days__c;
//                    } else if (ha.HolidayAction_Type__c == 'Reward Half-Holiday') { // 대체휴가(반차)
//                        h.Holiday_rewardDays__c -= 0.5;
//                        h.Holiday_rewardRemainDays__c += 0.5;
//                    } else if (ha.HolidayAction_Type__c == 'Women Holiday') { // 생리휴가
//                        h.Holiday_Unpaid__c -= ha.HolidayAction_Days__c;
//                        h.Holiday_WomenHoliday_Count__c -= ha.HolidayAction_Days__c;
//                    } else if (ha.HolidayAction_Type__c == 'Public Works') { // 공가
//                        h.Holiday_Uncountable__c -= ha.HolidayAction_Days__c;
//                        h.Holiday_PublicWorks_Count__c -= ha.HolidayAction_Days__c;
//                    } else if (ha.HolidayAction_Type__c == 'Family Leave') { // 경조휴가
//                        h.Holiday_Uncountable__c -= ha.HolidayAction_Days__c;
//                        h.Holiday_FamilyEvent_Count__c -= ha.HolidayAction_Days__c;
//                    } else if (ha.HolidayAction_Type__c == 'Sick Leave') { // 병가
//                        h.Holiday_Unpaid__c -= ha.HolidayAction_Days__c;
//                        h.Holiday_SickLeave_Count__c -= ha.HolidayAction_Days__c;
//                    } else {
//                        lstActStr = 'Add Alternative Holiday register.';
//                    }
//
//                    h.Holiday_LastActivity__c = lstActStr;
//                    hMap.put(h.Id, h);
//                }
//            }
//            update haLst;
//            update hMap.values();
//        }
//    }

//    else if (Trigger.isAfter) {
//        if (Trigger.isInsert) {
//            // 최초 경비 제출을 위한 Method
//            ApprovalHolidayShare_tr.doApprovalShareInsert(Trigger.new, Trigger.oldMap);
//        }
//        else if (Trigger.isUpdate) {
//            ApprovalHolidayShare_tr.doApprovalShareUpdate(Trigger.new, Trigger.oldMap);
//
//            /**
//             * @description       : 휴가 사용일수 카운팅 및 최종 승인 시, 사용자의 부서 및 포지션에 따른 이메일 발송
//             *                      1) 프로젝트 투입 직원(수신자: 부대표님, 전무님, 해당 사업부장, 관리직원)
//             *                      2) 임원 및 PM(수신자: 대표님, 부대표님, 전무님, 전사업부장, 관리직원)
//             *                      3) 영업팀 및 본사근무직원(수신자: 대표님, 부대표님, 전무님, 전사업부장, 관리직원)
//             * @author            : cj.sohn@daeunextier.com
//             * @group             : DaeuNextier
//             **/
//            // 전체 사업부장 및 관리직원 리스트
//            List<Employee__c> emailRecipients = [
//                    SELECT Id, Department__c, Name, Email__c, fm_Position__c
//                    FROM Employee__c
//                    WHERE (DeptPosition__c = 'CEO'                                              //  대표님
//                          OR DeptPosition__c = '부사장'                                          //  부대표님
//                          OR DeptPosition__c = 'General Manager'                                //  전무, 상무님
//                          OR DeptPosition__c = 'Department Head'                                //  사업부장
//                          OR (Department__c = 'MGMT' AND DeptPosition__c = 'Mgmt Support'))     //  관리부
//                          AND Status__c = TRUE
//            ];
//
//            // 휴가 신청자가 프로젝트에 참여중인 경우, 프로젝트별 데이터 정리
//            Set<Id> projectIds = new Set<Id>();
//            Map<Id, Id> projectIdByHolidayAction = new Map<Id, Id>();
//            for (HolidayAction__c hla : Trigger.new) {
//                if (hla.Project__c != null) {
//                    projectIds.add(hla.Project__c);
//                    projectIdByHolidayAction.put(hla.Id, hla.Project__c);
//                }
//            }
//
//            Map<Id, Project__c> projects;
//            if (projectIds.size() > 0) {
//                projects = new Map<Id, Project__c>([SELECT Id, Name, Business__c FROM Project__c WHERE Id IN:projectIds ORDER BY LastModifiedDate LIMIT 1]);
//            }
//
//            List<HolidayAction__c> holidayActions = [
//                    SELECT Id, Position__c, HolidayAction_UserName__c, HolidayAction_Days__c, Holiday_Date_Detail__c,
//                            Name, HolidayAction_Description__c, FirstHolidayRequest__r.Name, Project__c, HolidayAction_Parent__r.Holiday_User__c
//                    FROM HolidayAction__c
//                    WHERE Id IN:Trigger.newMap.keySet()
//            ];
//
//            // 휴가 신청하는 사원정보 정리
//            Set<Id> setUserIds = new Set<Id>();
//            for (HolidayAction__c hla : holidayActions) {
//                setUserIds.add(hla.HolidayAction_Parent__r.Holiday_User__c);
//            }
//
//            Map<Id, Employee__c> mapEmployeeByUserId = new Map<Id, Employee__c>();
//            List<Employee__c> listApplicants = [SELECT Id, User__c, fm_Position__c FROM Employee__c WHERE User__c IN:setUserIds];
//            for (Employee__c employee : listApplicants) {
//                mapEmployeeByUserId.put(employee.User__c, employee);
//            }
//
//            // 휴가 승인 시, 내부 관리자에게 이메일 발송
//            for (HolidayAction__c hla : holidayActions) {
//                if (Trigger.oldMap.get(hla.Id).HolidayAction_IsConfirm__c != Trigger.newMap.get(hla.Id).HolidayAction_IsConfirm__c && Trigger.newMap.get(hla.Id).HolidayAction_IsConfirm__c == true) {
//                    if (hla.Project__c != null) {
//                        HolidayUtil.sendEmailForConfirmedHoliday(emailRecipients, projects.get(projectIdByHolidayAction.get(hla.Id)), hla, mapEmployeeByUserId.get(hla.HolidayAction_Parent__r.Holiday_User__c));
//                    } else {
//                        HolidayUtil.sendEmailForConfirmedHoliday(emailRecipients, null, hla, mapEmployeeByUserId.get(hla.HolidayAction_Parent__r.Holiday_User__c));
//                    }
//                }
//            }
//        }
//    }


}