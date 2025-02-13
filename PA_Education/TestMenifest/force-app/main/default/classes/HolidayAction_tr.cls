/**
 * @description       : 휴가신청 트리거
 * @author            : Kwanwoo.Jeon
 * @group             : DaeuNextier
 * @Test Class        : HolidayActionUpdate_Test.apex
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   2023-12-14   Kwanwoo.Jeon              기존 트리거 코드 이식 -> 수정 필요 (반복문 내 SOQL 조회문)
 * 1.1   2023-12-14   Kwanwoo.Jeon              대체휴가 신청 시 해당 유저의 일수 대체휴가 사용 필드에 체크
**/

public without sharing class HolidayAction_tr extends TriggerHandler{
    private static List<HolidayAction__c> listNew {get; set;}
    private static List<HolidayAction__c> listOld {get; set;}
    private static Map<Id, HolidayAction__c> mapNew {get; set;}
    private static Map<Id, HolidayAction__c> mapOld {get; set;}

    public HolidayAction_tr() {
        listNew = (List<HolidayAction__c>) Trigger.new;
        listOld = (List<HolidayAction__c>) Trigger.old;
        mapNew  = (Map<Id, HolidayAction__c>) Trigger.newMap;
        mapOld  = (Map<Id, HolidayAction__c>) Trigger.oldMap;
    }

    public override void beforeInsert() {
        methodBeforeInsert();
    }
    public override void beforeUpdate() {
        methodBeforeUpdate();
    }
    public override void afterInsert() {
        methodAfterInsert();
    }
    public override void afterUpdate() {
        doApprovalShareUpdate();
        methodAfterUpdate();
        UsingRewardHoliday();
    }

    // [2023-08-09] 휴가 신청 시, Employee Id 값 설정 (Employee 화면에서 휴가 신청내역 확인을 위함)
    public void methodBeforeInsert() {
        Set<Id> setHoliday = new Set<Id>();
        for (HolidayAction__c objHolidayAction : listNew) {
            if(objHolidayAction.HolidayAction_Parent__c != null) {
                setHoliday.add(objHolidayAction.HolidayAction_Parent__c);
            }
        }

        if(!setHoliday.isEmpty()) {
            Map<Id, Holiday__c> mapHoliday = new Map<Id, Holiday__c>([
                    SELECT Id, Employee__c
                    FROM Holiday__c
                    WHERE Id IN :setHoliday
            ]);
            for (HolidayAction__c objHolidayAction : listNew) {
                objHolidayAction.Employee__c = mapHoliday.get(objHolidayAction.HolidayAction_Parent__c) == null ?
                        null : mapHoliday.get(objHolidayAction.HolidayAction_Parent__c).Employee__c;
            }
        }
    }
    public void methodBeforeUpdate(){
        Map<Id, Holiday__c> hMap = new Map<Id, Holiday__c>();
//        List<HolidayAction__c> haLst = new List<HolidayAction__c>();

        for (HolidayAction__c ha : listNew) {
            Boolean oldStatus = mapOld.get(ha.Id).HolidayAction_IsConfirm__c;
            Boolean newStatus = ha.HolidayAction_IsConfirm__c;
            if (!oldStatus && newStatus) {
                Holiday__c h;
                if (hMap.containsKey(ha.HolidayAction_Parent__c)) {
                    h = hMap.get(ha.HolidayAction_Parent__c);
                } else {
                    h = [SELECT Id, Holiday_Total_Remain__c, Holiday_Uncountable__c, Holiday_Unpaid__c, Holiday_UseDays__c, CarriedOverOfLastYear__c, UseDaysOfLastYear__c, HolidayRemainOfLastYear__c, Holiday_FamilyEvent_Count__c,Holiday_SickLeave_Count__c, Holiday_WomenHoliday_Count__c, Holiday_PublicWorks_Count__c, Holiday_rewardDays__c, fm_Holiday_rewardRemainDays__c FROM Holiday__c WHERE Id = :ha.HolidayAction_Parent__c];
                }

                // 필드를 새로 추가했기 때문에 기존 레코드에서는 null값이여서 null check
                h.Holiday_FamilyEvent_Count__c  = (h.Holiday_FamilyEvent_Count__c == null)  ? 0 : h.Holiday_FamilyEvent_Count__c;
                h.Holiday_SickLeave_Count__c    = (h.Holiday_SickLeave_Count__c == null)    ? 0 : h.Holiday_SickLeave_Count__c;
                h.Holiday_WomenHoliday_Count__c = (h.Holiday_WomenHoliday_Count__c == null) ? 0 : h.Holiday_WomenHoliday_Count__c;
                h.Holiday_PublicWorks_Count__c  = (h.Holiday_PublicWorks_Count__c == null)  ? 0 : h.Holiday_PublicWorks_Count__c;
//                h.Holiday_rewardRemainDays__c   = (h.Holiday_rewardRemainDays__c == null)   ? 0 : h.Holiday_rewardRemainDays__c;
                h.Holiday_rewardDays__c         = (h.Holiday_rewardDays__c == null)         ? 0 : h.Holiday_rewardDays__c;

                // 사용내역 한글로 번역
                List<Schema.PicklistEntry> values = HolidayAction__c.HolidayAction_Type__c.getDescribe().getPicklistValues();
                Map<String,String> statusApiToLabelMap = new Map<String,String>();
                for(Schema.PicklistEntry sp : values) {
                    // Map to hold Picklist API as Key and Picklist Label as Value
                    statusApiToLabelMap.put(sp.getValue(), sp.getLabel());
                }
                System.debug('Label value of picklist >> ' + statusApiToLabelMap.get(ha.HolidayAction_Type__c));

                String lstActStr = statusApiToLabelMap.get(ha.HolidayAction_Type__c) + ' ' + String.valueOf(ha.HolidayAction_Days__c) + '일 사용';

                /**
                 * @author            : hyunsoo.song@daeunextier.com
                 * @description       : 연차 혹은 반차인 경우, 연차 사용일자로 카운팅 (전년도 연차 우선 사용 Control은 formula 필드단에서 함.)
                 * @last modified on  : 2023-01-16
                */
                if (ha.HolidayAction_Type__c == 'Monthly Holiday' || ha.HolidayAction_Type__c == 'Annual Holiday') { // 연월차
                    if(ha.HolidayAction_Days__c > h.Holiday_Total_Remain__c) ha.addError(Label.Cannot_Apply_Holiday);
                    h.Holiday_UseDays__c += ha.HolidayAction_Days__c;
                } else if (ha.HolidayAction_Type__c == 'Half-day Leave') { // 반차
                    if(ha.HolidayAction_Days__c > h.Holiday_Total_Remain__c) ha.addError(Label.Cannot_Apply_Holiday);
                    h.Holiday_UseDays__c += 0.5;
                } else if (ha.HolidayAction_Type__c == 'Reward Holiday') { // 대체휴가
                    if(ha.HolidayAction_Days__c > h.fm_Holiday_rewardRemainDays__c) ha.addError(Label.Cannot_Apply_Reward_Holiday);
                    h.Holiday_rewardDays__c += ha.HolidayAction_Days__c;
//                    h.Holiday_rewardRemainDays__c -= ha.HolidayAction_Days__c;
                } else if (ha.HolidayAction_Type__c == 'Reward Half-Holiday') { // 대체휴가(반차)
                    if(ha.HolidayAction_Days__c > h.fm_Holiday_rewardRemainDays__c) ha.addError(Label.Cannot_Apply_Reward_Holiday);
                    h.Holiday_rewardDays__c += 0.5;
//                    h.Holiday_rewardRemainDays__c -= 0.5;
                } else if (ha.HolidayAction_Type__c == 'Women Holiday') { // 생리휴가
                    h.Holiday_Unpaid__c += ha.HolidayAction_Days__c;
                    h.Holiday_WomenHoliday_Count__c += ha.HolidayAction_Days__c;
                } else if (ha.HolidayAction_Type__c == 'Public Works') { // 공가
                    h.Holiday_Uncountable__c += ha.HolidayAction_Days__c;
                    h.Holiday_PublicWorks_Count__c += ha.HolidayAction_Days__c;
                } else if (ha.HolidayAction_Type__c == 'Family Leave') { // 경조휴가
                    h.Holiday_Uncountable__c += ha.HolidayAction_Days__c;
                    h.Holiday_FamilyEvent_Count__c += ha.HolidayAction_Days__c;
                } else if (ha.HolidayAction_Type__c == 'Sick Leave') { // 병가
                    h.Holiday_Unpaid__c += ha.HolidayAction_Days__c;
                    h.Holiday_SickLeave_Count__c += ha.HolidayAction_Days__c;
                } else {
                    lstActStr = 'Add Alternative Holiday register.';
                }

                h.Holiday_LastActivity__c = lstActStr;
                hMap.put(h.Id, h);
            }

            // 취소 승인 되면 사용처리된 연차를 복구 함
            Boolean oldIsCancled = mapOld.get(ha.Id).Is_Cancled__c;
            Boolean newIsCancled = ha.Is_Cancled__c;

            if (!oldIsCancled && newIsCancled) { // 취소가 승인 false -> true로 바뀜
                Holiday__c h;
                if (hMap.containsKey(ha.HolidayAction_Parent__c)) {
                    h = hMap.get(ha.HolidayAction_Parent__c);
                } else {
                    h = [SELECT Id, Holiday_Uncountable__c, Holiday_Unpaid__c, Holiday_UseDays__c, CarriedOverOfLastYear__c, UseDaysOfLastYear__c, HolidayRemainOfLastYear__c, Holiday_FamilyEvent_Count__c,Holiday_SickLeave_Count__c, Holiday_WomenHoliday_Count__c, Holiday_PublicWorks_Count__c, Holiday_rewardDays__c, fm_Holiday_rewardRemainDays__c FROM Holiday__c WHERE Id = :ha.HolidayAction_Parent__c];
                }

                // 필드를 새로 추가했기 때문에 기존 레코드에서는 null값이여서 null check
                h.Holiday_FamilyEvent_Count__c  = (h.Holiday_FamilyEvent_Count__c == null)  ? 0 : h.Holiday_FamilyEvent_Count__c;
                h.Holiday_SickLeave_Count__c    = (h.Holiday_SickLeave_Count__c == null)    ? 0 : h.Holiday_SickLeave_Count__c;
                h.Holiday_WomenHoliday_Count__c = (h.Holiday_WomenHoliday_Count__c == null) ? 0 : h.Holiday_WomenHoliday_Count__c;
                h.Holiday_PublicWorks_Count__c  = (h.Holiday_PublicWorks_Count__c == null)  ? 0 : h.Holiday_PublicWorks_Count__c;
//                h.Holiday_rewardRemainDays__c   = (h.Holiday_rewardRemainDays__c == null)   ? 0 : h.Holiday_rewardRemainDays__c;
                h.Holiday_rewardDays__c         = (h.Holiday_rewardDays__c == null)         ? 0 : h.Holiday_rewardDays__c;

                List<Schema.PicklistEntry> values = HolidayAction__c.HolidayAction_Type__c.getDescribe().getPicklistValues();
                Map<String,String> statusApiToLabelMap = new Map<String,String>();
                for(Schema.PicklistEntry sp : values) {
                    // Map to hold Picklist API as Key and Picklist Label as Value
                    statusApiToLabelMap.put(sp.getValue(), sp.getLabel());
                }
                System.debug('Label value of picklist>>'+ statusApiToLabelMap.get(ha.HolidayAction_Type__c));

                String lstActStr = statusApiToLabelMap.get(ha.HolidayAction_Type__c) + ' ' + String.valueOf(ha.HolidayAction_Days__c) + '일 승인 취소';

                /**
                 * @author            : hyunsoo.song@daeunextier.com
                 * @description       : 연차 혹은 반차인 경우, 연차 사용일자로 카운팅 (전년도 연차 우선 사용 Control은 formula 필드단에서 함.)
                 * @last modified on  : 2023-01-16
                */
                if (ha.HolidayAction_Type__c == 'Monthly Holiday' || ha.HolidayAction_Type__c == 'Annual Holiday') { // 연월차
                    h.Holiday_UseDays__c -= ha.HolidayAction_Days__c;
                } else if (ha.HolidayAction_Type__c == 'Half-day Leave') { // 반차
                    h.Holiday_UseDays__c -= 0.5;
                } else if (ha.HolidayAction_Type__c == 'Reward Holiday') { // 대체휴가
                    h.Holiday_rewardDays__c -= ha.HolidayAction_Days__c;
//                    h.Holiday_rewardRemainDays__c += ha.HolidayAction_Days__c;
                } else if (ha.HolidayAction_Type__c == 'Reward Half-Holiday') { // 대체휴가(반차)
                    h.Holiday_rewardDays__c -= 0.5;
//                    h.Holiday_rewardRemainDays__c += 0.5;
                } else if (ha.HolidayAction_Type__c == 'Women Holiday') { // 생리휴가
                    h.Holiday_Unpaid__c -= ha.HolidayAction_Days__c;
                    h.Holiday_WomenHoliday_Count__c -= ha.HolidayAction_Days__c;
                } else if (ha.HolidayAction_Type__c == 'Public Works') { // 공가
                    h.Holiday_Uncountable__c -= ha.HolidayAction_Days__c;
                    h.Holiday_PublicWorks_Count__c -= ha.HolidayAction_Days__c;
                } else if (ha.HolidayAction_Type__c == 'Family Leave') { // 경조휴가
                    h.Holiday_Uncountable__c -= ha.HolidayAction_Days__c;
                    h.Holiday_FamilyEvent_Count__c -= ha.HolidayAction_Days__c;
                } else if (ha.HolidayAction_Type__c == 'Sick Leave') { // 병가
                    h.Holiday_Unpaid__c -= ha.HolidayAction_Days__c;
                    h.Holiday_SickLeave_Count__c -= ha.HolidayAction_Days__c;
                } else {
                    lstActStr = 'Add Alternative Holiday register.';
                }

                h.Holiday_LastActivity__c = lstActStr;
                hMap.put(h.Id, h);
            }
        }
//        update haLst;
        update hMap.values();

    }
    public void methodAfterInsert() {
        // 최초 경비 제출을 위한 Method
        ApprovalHolidayShare_tr.doApprovalShareInsert(listNew, mapOld);
    }
    public void doApprovalShareUpdate() {
        ApprovalHolidayShare_tr.doApprovalShareUpdate(listNew, mapOld);
    }

    public void methodAfterUpdate() {
        
        /**
         * @description       : 휴가 사용일수 카운팅 및 최종 승인 시, 사용자의 부서 및 포지션에 따른 이메일 발송
         *                      1) 프로젝트 투입 직원(수신자: 부대표님, 전무님, 해당 사업부장, 관리직원)
         *                      2) 임원 및 PM(수신자: 대표님, 부대표님, 전무님, 전사업부장, 관리직원)
         *                      3) 영업팀 및 본사근무직원(수신자: 대표님, 부대표님, 전무님, 전사업부장, 관리직원)
         * @author            : cj.sohn@daeunextier.com
         * @group             : DaeuNextier
         **/
        // 전체 사업부장 및 관리직원 리스트
        List<Employee__c> emailRecipients = [
                SELECT Id, Department__c, Name, Email__c, toLabel(Position__c)
                FROM Employee__c
                WHERE (DeptPosition__c = 'CEO'                                              //  대표님
                OR DeptPosition__c = '부사장'                                          //  부대표님
                OR DeptPosition__c = 'General Manager'                                //  전무, 상무님
                OR DeptPosition__c = 'Department Head'                                //  사업부장
                OR (Department__c = 'MGMT' AND DeptPosition__c = 'Mgmt Support'))     //  관리부
                AND Status__c = TRUE
        ];

        // 휴가 신청자가 프로젝트에 참여중인 경우, 프로젝트별 데이터 정리
        Set<Id> projectIds = new Set<Id>();
        Map<Id, Id> projectIdByHolidayAction = new Map<Id, Id>();
        for (HolidayAction__c hla : listNew) {
            if (hla.Project__c != null) {
                projectIds.add(hla.Project__c);
                projectIdByHolidayAction.put(hla.Id, hla.Project__c);
            }
        }

        Map<Id, Project__c> projects;
        if (projectIds.size() > 0) {
            projects = new Map<Id, Project__c>([SELECT Id, Name, Business__c FROM Project__c WHERE Id IN:projectIds ORDER BY LastModifiedDate LIMIT 1]);
        }

        List<HolidayAction__c> holidayActions = [
                SELECT Id, Position__c, HolidayAction_UserName__c, HolidayAction_Days__c, Holiday_Date_Detail__c, isSystemJob__c,
                        Name, HolidayAction_Description__c, FirstHolidayRequest__r.Name, Project__c, HolidayAction_Parent__r.Holiday_User__c
                FROM HolidayAction__c
                WHERE Id IN:Trigger.newMap.keySet()
        ];

        // 휴가 신청하는 사원정보 정리
        Set<Id> setUserIds = new Set<Id>();
        for (HolidayAction__c hla : holidayActions) {
            setUserIds.add(hla.HolidayAction_Parent__r.Holiday_User__c);
        }

        Map<Id, Employee__c> mapEmployeeByUserId = new Map<Id, Employee__c>();
        List<Employee__c> listApplicants = [SELECT Id, User__c, toLabel(Position__c) FROM Employee__c WHERE User__c IN:setUserIds];
        for (Employee__c employee : listApplicants) {
            mapEmployeeByUserId.put(employee.User__c, employee);
        }

        // 휴가 승인 시, 내부 관리자에게 이메일 발송
        for (HolidayAction__c hla : holidayActions) {
            if ( hla.isSystemJob__c == true ) continue;
            if (mapOld.get(hla.Id).HolidayAction_IsConfirm__c != mapNew.get(hla.Id).HolidayAction_IsConfirm__c && mapNew.get(hla.Id).HolidayAction_IsConfirm__c == true) {
                if (hla.Project__c != null) {
                    HolidayUtil.sendEmailForConfirmedHoliday(emailRecipients, projects.get(projectIdByHolidayAction.get(hla.Id)), hla, mapEmployeeByUserId.get(hla.HolidayAction_Parent__r.Holiday_User__c));
                } else {
                    HolidayUtil.sendEmailForConfirmedHoliday(emailRecipients, null, hla, mapEmployeeByUserId.get(hla.HolidayAction_Parent__r.Holiday_User__c));
                }
            }
        }
    }


    //대체휴가 시 승인 됐을경우 먼저들어온 대체휴가 부터 차감 로직 구현(대체휴가 사용으로 변경)
    //취소 승인 시 사용 휴가가 0보다 큰 대체휴가들 중 나중에 들어온 것 순으로 사용일자 차감(미사용으로 변경)
    public void UsingRewardHoliday(){
        Map<id, Decimal> mapHolidayToUsedRewardHolidaySum = new Map<id, Decimal>();
        Map<id, Decimal> mapHolidayToUsedRewardHolidayCancledSum = new Map<id, Decimal>();
        for(HolidayAction__c obj: listNew){
            //todo 취소 승인 시 로직  추가 필요
            if((obj.HolidayAction_Type__c == 'Reward Holiday' || obj.HolidayAction_Type__c == 'Reward Half-Holiday')){
                //휴가 승인
                if (obj.HolidayAction_IsConfirm__c && !mapOld.get(obj.Id).HolidayAction_IsConfirm__c) {
                    mapHolidayToUsedRewardHolidaySum.put(obj.HolidayAction_Parent__c, mapHolidayToUsedRewardHolidaySum.get(obj.HolidayAction_Parent__c) == null ? obj.HolidayAction_Days__c : mapHolidayToUsedRewardHolidaySum.get(obj.HolidayAction_Parent__c) + obj.HolidayAction_Days__c);
                //취소 승인
                }else if(obj.Is_Cancled__c && !mapOld.get(obj.Id).Is_Cancled__c){
                    mapHolidayToUsedRewardHolidayCancledSum.put(obj.HolidayAction_Parent__c, mapHolidayToUsedRewardHolidayCancledSum.get(obj.HolidayAction_Parent__c) == null ? obj.HolidayAction_Days__c : mapHolidayToUsedRewardHolidayCancledSum.get(obj.HolidayAction_Parent__c) + obj.HolidayAction_Days__c);
                }
            }
        }
        if (!mapHolidayToUsedRewardHolidaySum.isEmpty() || !mapHolidayToUsedRewardHolidayCancledSum.isEmpty()) {
            Map<String, String> mapUserToHoliday = new Map<String, String>();
            Map<String, String> mapUserToCancledHoliday = new Map<String, String>();
            list<Holiday__c> listHoliday = new List<Holiday__c>([
                                        SELECT Id, Holiday_rewardDays__c, Holiday_User__c
                                        FROM Holiday__c
                                        WHERE Id IN : mapHolidayToUsedRewardHolidaySum.keySet() OR Id IN : mapHolidayToUsedRewardHolidayCancledSum.keySet()]);

            for (Holiday__c objHoliday: listHoliday){
                if (mapHolidayToUsedRewardHolidaySum.keySet().contains(objHoliday.Id)) {
//                    objHoliday.Holiday_rewardDays__c += mapHolidayToUsedRewardHolidaySum.get(objHoliday.Id);
                    mapUserToHoliday.put(objHoliday.Holiday_User__c, objHoliday.Id);
                }

                if (mapHolidayToUsedRewardHolidayCancledSum.keySet().contains(objHoliday.Id)) {
//                    objHoliday.Holiday_rewardDays__c -= mapHolidayToUsedRewardHolidaySum.get(objHoliday.Id);
                    mapUserToCancledHoliday.put(objHoliday.Holiday_User__c, objHoliday.Id);
                }
            }
            System.debug('mapUserToHoliday :: ' + mapUserToHoliday);
            System.debug('mapUserToCancledHoliday :: ' + mapUserToCancledHoliday);
            System.debug('mapHolidayToUsedRewardHolidaySum :: ' + mapHolidayToUsedRewardHolidaySum);


            Map<Id, RewardHoliday__c> mapUpdateReward = new Map<Id, RewardHoliday__c>();

            if (!mapUserToCancledHoliday.isEmpty()) {
                //근무일자가 늦은 대체 휴가부터 복구
                list<RewardHoliday__c> listReward = new List<RewardHoliday__c>([
                        SELECT id, Use_Holiday__c, WorkUser__c
                        FROM RewardHoliday__c
                        WHERE WorkUser__c IN : mapUserToCancledHoliday.keySet()
                        AND Use_Holiday__c > 0
                        ORDER BY WorkingDate__c desc]);
                System.debug('listReward :: ' + listReward);
                if (!listReward.isEmpty()) {
                    for (RewardHoliday__c objReward: listReward){
                        System.debug(' 123 ' + mapHolidayToUsedRewardHolidayCancledSum.get(mapUserToCancledHoliday.get(objReward.WorkUser__c)));
                        if (mapHolidayToUsedRewardHolidayCancledSum.get(mapUserToCancledHoliday.get(objReward.WorkUser__c)) >= 0) {
                            if (objReward.Use_Holiday__c < mapHolidayToUsedRewardHolidayCancledSum.get(mapUserToCancledHoliday.get(objReward.WorkUser__c))) {
                                mapHolidayToUsedRewardHolidayCancledSum.put(mapUserToCancledHoliday.get(objReward.WorkUser__c), mapHolidayToUsedRewardHolidayCancledSum.get(mapUserToCancledHoliday.get(objReward.WorkUser__c)) - objReward.Use_Holiday__c);
                                objReward.Use_Holiday__c = 0;
                            }else{
                                Decimal temp = mapHolidayToUsedRewardHolidayCancledSum.get(mapUserToCancledHoliday.get(objReward.WorkUser__c));
                                mapHolidayToUsedRewardHolidayCancledSum.put(mapUserToCancledHoliday.get(objReward.WorkUser__c), 0);
                                objReward.Use_Holiday__c -= temp;
                            }
                            mapUpdateReward.put(objReward.Id, objReward);
                        }
                    }
                }
            }


            if (!mapUserToHoliday.isEmpty()) {
                //근무일자가 빠른 대체 휴가부터 소진
                list<RewardHoliday__c> listReward = new List<RewardHoliday__c>([
                                        SELECT id, Use_Holiday__c, WorkUser__c, Remain_Holiday__c, OccurHoliday__c
                                        FROM RewardHoliday__c
                                        WHERE WorkUser__c IN : mapUserToHoliday.keySet()
                                        AND (Remain_Holiday__c > 0
                                        OR Id IN :mapUpdateReward.keySet())
                                        ORDER BY WorkingDate__c
                                        ]);


                if (!listReward.isEmpty()) {
                    for (RewardHoliday__c objReward: listReward){
                        if (mapHolidayToUsedRewardHolidaySum.get(mapUserToHoliday.get(objReward.WorkUser__c)) >= 0) {
                            System.debug('mapHolidayToUsedRewardHolidaySum.get(mapUserToHoliday.get(objReward.WorkUser__c)) :: ' + mapHolidayToUsedRewardHolidaySum.get(mapUserToHoliday.get(objReward.WorkUser__c)));

                            if (objReward.Remain_Holiday__c <= mapHolidayToUsedRewardHolidaySum.get(mapUserToHoliday.get(objReward.WorkUser__c))) {
                                mapHolidayToUsedRewardHolidaySum.put(mapUserToHoliday.get(objReward.WorkUser__c), mapHolidayToUsedRewardHolidaySum.get(mapUserToHoliday.get(objReward.WorkUser__c)) - objReward.Remain_Holiday__c);
                                objReward.Use_Holiday__c = objReward.OccurHoliday__c;
                            }else{
                                Decimal temp = mapHolidayToUsedRewardHolidaySum.get(mapUserToHoliday.get(objReward.WorkUser__c));
                                objReward.Use_Holiday__c += temp;
                                mapHolidayToUsedRewardHolidaySum.put(mapUserToHoliday.get(objReward.WorkUser__c), 0);
                            }
                            System.debug('objReward :: ' + objReward);
                            mapUpdateReward.put(objReward.Id, objReward);
                        }
                    }
                }
            }

            System.debug('mapUpdateReward :: ' + mapUpdateReward);
            if (!mapUpdateReward.isEmpty()) {
                update mapUpdateReward.values();
            }
        }
    }


}