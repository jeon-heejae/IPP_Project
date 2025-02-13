/**
 * ==================================================================================
 * File Name         : HolidayWork_tr
 * Author            : yj.kim
 * Group             : Daeu Nextier
 * Description       :
 * Modification Logs
 * ==================================================================================
 *   Ver     Date          Author           Modification
 * ==================================================================================
 *   1.0   2023-06-07     yj.kim            휴일근무 승인완료일때, 대체휴가에 대한 이력 관리 + Holiday__c Object 대체휴가 잔여일수 Update
 *   2.0   2023-12-12     kwanwoo.jeon      휴일근무 최종 근무 승인 반려 혹은 recall 시 HolidayWorkDetail의 근무시간 Null로 변경
 *   2.1   2023-12-19     yeonlim.jeong     프로젝트가 없을 경우 Role이 CEO, Business Management, Sales Manager인 사용자만, 프로젝트가 있을 경우 프로젝트의 PM만 생성 가능
 *   2.2   2023-01-02     yeonlim.jeong     프로젝트가 있을 경우 PM 여부, 프로젝트 관리자에게 Manual Sharing
**/
public without sharing class HolidayWork_tr extends TriggerHandler{
    public HolidayWork_tr() {
        listNew = (List<HolidayWork__c>) Trigger.new;
        listOld = (List<HolidayWork__c>) Trigger.old;
        mapNew = (Map<Id, HolidayWork__c>) Trigger.newMap;
        mapOld = (Map<Id, HolidayWork__c>) Trigger.oldMap;
    }

    /** TriggerHandler */
    private List<HolidayWork__c> listNew { get; set; }
    private List<HolidayWork__c> listOld { get; set; }
    private Map<Id, HolidayWork__c> mapNew { get; set; }
    private Map<Id, HolidayWork__c> mapOld { get; set; }

    public override void beforeInsert() {
        isCheckProject();
    }
    public override void afterInsert() {
        doSharePM();
    }
    public override void beforeUpdate() {
        doInsertRewardHoliday();
    }
    public override void afterUpdate() {
        resetWorkingTime();
    }

    public void doInsertRewardHoliday() {
        Set<String> setHolidayWorkId = new Set<String>();
//        Set<String> setCancelId = new Set<String>();
        Map<String, Decimal> workUserToHours = new Map<String, Decimal>();
//        Map<String, Decimal> deleteUserToHours = new Map<String, Decimal>();

        for(HolidayWork__c obj : listNew){
            if(obj.Is_Confirm__c == true && mapOld.get(obj.Id).Is_Confirm__c != true){
                setHolidayWorkId.add(obj.Id);
            }

//            if(obj.Is_Canceled__c == true && mapOld.get(obj.Id).Is_Canceled__c != true){
//                setCancelId.add(obj.Id);
//            }
        }
        System.debug('setHolidayWorkId : ' + setHolidayWorkId);

        List<RewardHoliday__c> updateRewardList = new List<RewardHoliday__c>();
        Map<Id, Holiday__c> hMap = new Map<Id, Holiday__c>();

        //승인완료인 휴일근무(HolidayWork__c)에 한해 HolidayWorkDetail__c 레코드들 가져와서 이력관리(RewardHoliday__c)에 Insert
        if(!setHolidayWorkId.isEmpty()){
            List<HolidayWorkDetail__c> workDeList = [
                    SELECT HolidayWork__c, HolidayWork__r.Project__c, WorkUser__c, WorkingDate__c, fm_Hours__c, fm_RewardDays__c, HolidayWork__r.WorkingTime__c
                    FROM HolidayWorkDetail__c
                    WHERE HolidayWork__c =: setHolidayWorkId
                    AND fm_Hours__c != 0

            ];

            if(!workDeList.isEmpty()){
                for(HolidayWorkDetail__c workDe : workDeList){
                    RewardHoliday__c obj = new RewardHoliday__c();
                    obj.Project__c = workDe.HolidayWork__r.Project__c;
                    obj.WorkUser__c = workDe.WorkUser__c;
                    obj.WorkingDate__c = workDe.HolidayWork__r.WorkingTime__c;
                    obj.HolidayWork__c = workDe.HolidayWork__c;
                    if(workDe.fm_Hours__c == 4){
                        obj.WorkingTime__c = '0.5일 (4시간)';
                    }else if(workDe.fm_Hours__c == 8){
                        obj.WorkingTime__c = '1일 (8시간)';
                    }

                    //근무자(WorkUser__c)의 총 휴일근무 시간 구하기
                    if (workUserToHours.containsKey(obj.WorkUser__c)) {
                        Decimal totalHours = workUserToHours.get(obj.WorkUser__c);
                        totalHours += workDe.fm_RewardDays__c;
                        workUserToHours.put(obj.WorkUser__c, totalHours);
                    } else {
                        workUserToHours.put(obj.WorkUser__c, workDe.fm_RewardDays__c);
                    }

                    updateRewardList.add(obj);
                }
            }
        }

        if(!updateRewardList.isEmpty()){
            //Holiday Object 근무자별 대체휴가 잔여일수 Update
            if(!workUserToHours.isEmpty()){
                List<Holiday__c> h = [
                        SELECT Id, Holiday_User__c, Holiday_reward_Total_Count__c
                        FROM Holiday__c
                        WHERE Holiday_User__c =: workUserToHours.keySet()
                ];
                System.debug('h : ' + h);

                for(Holiday__c holidayObj : h){
                    if(holidayObj.Holiday_reward_Total_Count__c != null) {
                        holidayObj.Holiday_reward_Total_Count__c += workUserToHours.get(holidayObj.Holiday_User__c);
                    }else{
                        holidayObj.Holiday_reward_Total_Count__c = workUserToHours.get(holidayObj.Holiday_User__c);
                    }
                    hMap.put(holidayObj.Id, holidayObj);
                }
                System.debug('hMap : ' + hMap);
                insert updateRewardList;
                update hMap.values();
            }
        }

        // 취소 승인 되면 관련 이력관리(RewardHoliday__c) 레코드 delete, Holiday Object 근무자별 대체휴가 잔여일수 Update
        //2023.12.12 취소승인이 근무계획에 대한 취소승인으로 변경됨에 따라 해당 로직 제거
//        Map<Id, Holiday__c> h2Map = new Map<Id, Holiday__c>();
//        if(!setCancelId.isEmpty()){
//            List<RewardHoliday__c> rewardList = [
//                    SELECT Id, WorkUser__c, OccurHoliday__c
//                    FROM RewardHoliday__c
//                    WHERE HolidayWork__c =: setCancelId
//            ];
//
//            if(!rewardList.isEmpty()){
//                for(RewardHoliday__c rh : rewardList){
//                    if (deleteUserToHours.containsKey(rh.WorkUser__c)) {
//                        Decimal totalHours = deleteUserToHours.get(rh.WorkUser__c);
//                        totalHours += rh.OccurHoliday__c;
//                        deleteUserToHours.put(rh.WorkUser__c, totalHours);
//                    } else {
//                        deleteUserToHours.put(rh.WorkUser__c, rh.OccurHoliday__c);
//                    }
//                }
//                delete rewardList;
//            }
//
//            if(!deleteUserToHours.isEmpty()){
//                List<Holiday__c> h = [
//                        SELECT Id, Holiday_User__c, Holiday_rewardRemainDays__c
//                        FROM Holiday__c
//                        WHERE Holiday_User__c =: deleteUserToHours.keySet()
//                ];
//                System.debug('h : ' + h);
//
//                for(Holiday__c holidayObj : h){
//                    if(holidayObj.Holiday_rewardRemainDays__c != null) {
//                        holidayObj.Holiday_rewardRemainDays__c -= deleteUserToHours.get(holidayObj.Holiday_User__c);
//                    }else{
//                        holidayObj.Holiday_rewardRemainDays__c = deleteUserToHours.get(holidayObj.Holiday_User__c);
//                    }
//                    h2Map.put(holidayObj.Id, holidayObj);
//                }
//                update h2Map.values();
//            }
//        }
    }

    /**
    * Event : after Update
    * Author : kwanwoo.jeon
    * Description : 2023.12.12 최종 근무 승인 반려 혹은 recall 시 HolidayWorkDetail의 근무시간 Null로 변경
    */
    public void resetWorkingTime(){
        list<Id> listTargetId = new List<Id>();
        for (HolidayWork__c obj: listNew){
            if (obj.Status__c == '계획승인' && mapOld.get(obj.Id).Status__c == '근무승인요청') {
                listTargetId.add(obj.Id);
            }
        }

        if (!listTargetId.isEmpty()) {
            list<HolidayWorkDetail__c> listHWDetail = new List<HolidayWorkDetail__c>([SELECT id, WorkingTime__c from HolidayWorkDetail__c where HolidayWork__c in: listTargetId]);
            if (!listHWDetail.isEmpty()) {
                for (HolidayWorkDetail__c obj: listHWDetail){
                    obj.WorkingTime__c = null;
                }
                update listHWDetail;
            }
        }

    }

    /**
    * Event : before insert
    * Author : Yeonlim
    * Description : 프로젝트가 없을 경우 Role이 CEO, Business Management, Sales Manager인 사용자만, 프로젝트가 있을 경우 프로젝트의 PM만 생성 가능 (어드민은 Validation 제외)
    */
    public void isCheckProject() {
        // 시스템 어드민일 경우 해당 X
        if ([SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name == 'System Administrator') {
            return ;
        }

        Set<String> setProjectId = new Set<String>();
        Set<String> setValidProjectId = new Set<String>();
        for (HolidayWork__c obj : listNew) {
            setProjectId.add(obj.Project__c);
        }

        // 1. 프로젝트가 있을 경우
        if (!setProjectId.contains(null)) {
            Id userId = UserInfo.getUserId();
            Set<String> setCheckPerformProjectId = new Set<String>();
            // 1-1. 프로젝트의 PM인지 체크
            for(Project__c obj : [
                    SELECT Id, PM__c
                    FROM Project__c
                    WHERE Id IN: setProjectId
            ]) {
                if (obj.PM__c != userId) {
                    setCheckPerformProjectId.add(obj.Id);
                } else {
                    setValidProjectId.add(obj.Id);
                }
            }

            // 1-2. 프로젝트 수행팀의 PM인지 체크
            if (!setCheckPerformProjectId.isEmpty()) {
                List<Employee__c> listEmployee = [
                        SELECT Id
                        FROM Employee__c
                        WHERE User__c =: UserInfo.getUserId()
                ];

                if (listEmployee.isEmpty()) {
                    for (HolidayWork__c obj : listNew) {
                        obj.addError('현재 User의 Employee가 존재하지 않습니다.');
                        return ;
                    }
                } else {
                    for (PerformProject__c obj : [
                            SELECT Id, IsPM__c, Project__c
                            FROM PerformProject__c
                            WHERE Project__c IN: setCheckPerformProjectId
                            AND Employee__c =: listEmployee[0].Id
                    ]) {
                        if (obj.IsPM__c) {
                            setValidProjectId.add(obj.Project__c);
                        }
                    }
                }
            }
        } else { // 2. 프로젝트가 없을 경우 Role이 CEO, Business Management, Sales Manager 인지 체크
            for (UserRole obj : [
                    SELECT Id, DeveloperName
                    FROM UserRole
                    WHERE Id =: UserInfo.getUserRoleId()
            ]) {
                if (obj.DeveloperName == 'CEO' || obj.DeveloperName == 'Business_Management' || obj.DeveloperName == 'Sales_Manager') {
                    setValidProjectId.add(null);
                }
            }
        }

        for (HolidayWork__c obj : listNew) {
            if (!setValidProjectId.contains(obj.Project__c)) {
                obj.addError('휴일근무의 프로젝트가 없을 경우 Role이 CEO, Business Management, Sales Manager인 사용자만, 프로젝트가 있을 경우 프로젝트의 PM만 생성 가능합니다.');
            }
        }

    }

    /**
    * Event : after insert
    * Author : Yeonlim
    * Description : 프로젝트가 있을 경우 PM 여부, 프로젝트 관리자에게 Manual Sharing
    */
    public void doSharePM() {
        Set<Id> setProjectId = new Set<Id>();
        for (HolidayWork__c obj : listNew) {
            if (obj.Project__c != null) {
                setProjectId.add(obj.Project__c);
            }
        }

        if (!setProjectId.isEmpty()) {
            Id userId = UserInfo.getUserId();

            Map<String, List<String>> mapProjectIdToListPM = new Map<String, List<String>>();
            // 1. 프로젝트 - 프로젝트 관리자
            for (Project__c obj : [
                    SELECT Id, PM__c
                    FROM Project__c
                    WHERE Id IN: setProjectId
                    AND PM__c != :userId
            ]) {
                List<String> listPM = mapProjectIdToListPM.get(obj.Id);

                if (listPM == null) {
                    listPM = new List<String>();
                    mapProjectIdToListPM.put(obj.Id, listPM);
                }

                listPM.add(obj.PM__c);
            }

            // 2. 프로젝트 수행팀 - PM 여부 체크된 사용자
            for (PerformProject__c obj : [
                    SELECT Id, Project__c, Employee__r.User__c
                    FROM PerformProject__c
                    WHERE Project__c IN: setProjectId
                    AND IsPM__c = TRUE
                    AND Employee__r.User__c != :userId
            ]) {
                List<String> listPM = mapProjectIdToListPM.get(obj.Project__c);

                if (listPM == null) {
                    listPM = new List<String>();
                    mapProjectIdToListPM.put(obj.Project__c, listPM);
                }

                listPM.add(obj.Employee__r.User__c);
            }

            if (!mapProjectIdToListPM.isEmpty()) {
                List<HolidayWork__Share> listHWShare = new List<HolidayWork__Share>();

                for (HolidayWork__c obj : listNew) {
                    for (String pmId : mapProjectIdToListPM.get(obj.Project__c)) {
                        if(pmId != null){
                            HolidayWork__Share objHWShare = new HolidayWork__Share(
                                    ParentId      = obj.Id,
                                    UserOrGroupId = pmId,
                                    AccessLevel   = 'Read',
                                    RowCause      = 'Manual'
                            );
                            listHWShare.add(objHWShare);
                        }
                    }
                }

                System.debug('listHWShare : ' + listHWShare);
                if (!listHWShare.isEmpty()) {
                    insert listHWShare;
                }
            }

        }
    }

}