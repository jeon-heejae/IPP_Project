/**
 * ==================================================================================
 * File Name         : HolidayWorkDetail_tr
 * Author            : yeonlim.jeong
 * Group             : Daeu Nextier
 * Description       :
 * Modification Logs
 * ==================================================================================
 *   Ver     Date          Author           Modification
 * ==================================================================================
 *   1.0   2023-12-19     yeonlim.jeong     휴일근무자가 중복 체크, 생성 가능한 User인지 체크
 *   1.1   2023-12-19     kwanwoo.jeon      휴일근무자가 중복 체크 로직 수정(해당 휴일근무뿐만 아닌 같은일자의 중복 근무자 체크)
**/
public without sharing class HolidayWorkDetail_tr extends TriggerHandler {
    public HolidayWorkDetail_tr() {
        listNew = (List<HolidayWorkDetail__c>) Trigger.new;
        listOld = (List<HolidayWorkDetail__c>) Trigger.old;
        mapNew = (Map<Id, HolidayWorkDetail__c>) Trigger.newMap;
        mapOld = (Map<Id, HolidayWorkDetail__c>) Trigger.oldMap;
    }

    /** TriggerHandler */
    private List<HolidayWorkDetail__c> listNew { get; set; }
    private List<HolidayWorkDetail__c> listOld { get; set; }
    private Map<Id, HolidayWorkDetail__c> mapNew { get; set; }
    private Map<Id, HolidayWorkDetail__c> mapOld { get; set; }

    public override void beforeInsert() {
        checkDuplicateUser();
    }

    public override void afterInsert() {
        isCheckProject();
    }

    public override void beforeUpdate() {
        checkDuplicateUser();
    }
    public override void afterUpdate() {

    }

    /**
    * Event         : before insert, before update
    * Author        : Yeonlim
    * Description   : 휴일근무 내에 휴일근무자가 중복 될 경우 에러 발생
    * Modifiy       : 23.12.27 PM협의체 요청사항 : 해당 휴일근무뿐만 아닌 같은 일자의 중복 근무자 체크
    */
    public void checkDuplicateUser() {
        try {
            Map<String, HolidayWorkDetail__c> mapKeyValueToObj = new Map<String, HolidayWorkDetail__c>();
            Set<Id> setHolidayWorkId = new Set<Id>();
            for (HolidayWorkDetail__c obj : listNew) {
                if (Trigger.isInsert || obj.WorkUser__c != mapOld.get(obj.Id).WorkUser__c) {
                    setHolidayWorkId.add(obj.HolidayWork__c);
                }
            }

            if (!setHolidayWorkId.isEmpty()) {
                Map<id,HolidayWork__c> mapIdToHolidayWork = new Map<Id, HolidayWork__c>([SELECT Id, WorkingTime__c FROM HolidayWork__c WHERE Id IN :setHolidayWorkId]);
                if (!mapIdToHolidayWork.isEmpty()) {
                    for (HolidayWorkDetail__c obj : listNew) {
                        mapKeyValueToObj.put(String.valueOf(mapIdToHolidayWork.get(obj.HolidayWork__c).WorkingTime__c) + obj.WorkUser__c, obj);
                    }
                }
            }

            if (!mapKeyValueToObj.isEmpty()) {
                List<HolidayWorkDetail__c> listHWD = new List<HolidayWorkDetail__c>([SELECT Id, WorkUser__c, HolidayWork__c, fm_KeyValue__c
                                                                FROM HolidayWorkDetail__c
                                                                WHERE fm_KeyValue__c IN: mapKeyValueToObj.keySet()]);
                for (HolidayWorkDetail__c obj : listHWD) {
                    mapKeyValueToObj.get(obj.fm_KeyValue__c).addError('해당 근무자는 이미 같은 날짜에 등록되어 있습니다');
                }
            }
        } catch (Exception e) {
            for (HolidayWorkDetail__c obj : listNew) {
                obj.addError(String.format('[Error] {0}, Line : {1}', new List<Object>{ e.getMessage(), e.getLineNumber()}));
            }
            System.debug(String.format('[Error] {0}, Line : {1}', new List<Object>{ e.getMessage(), e.getLineNumber()}));
        }
    }

    /**
    * Event : after insert
    * Author : Yeonlim
    * Description : 프로젝트가 없을 경우 Role이 CEO, Business Management, Sales Manager인 사용자만, 프로젝트가 있을 경우 프로젝트의 PM만 생성 가능 (어드민은 Validation 제외)
    */
    public void isCheckProject() {
        try {
            // 시스템 어드민일 경우 해당 X
            if ([SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name == 'System Administrator') {
                return ;
            }

            Set<String> setProjectId = new Set<String>();
            Set<String> setHolidayWorkId = new Set<String>();
            Set<String> setValidProjectId = new Set<String>();
            Map<String, String> mapHolidayWorkToProject = new Map<String, String>();

            for (HolidayWorkDetail__c obj : listNew) { setHolidayWorkId.add(obj.HolidayWork__c); }

            if (!setHolidayWorkId.isEmpty()) {
                for (HolidayWork__c obj : [
                        SELECT Id, Project__c
                        FROM HolidayWork__c
                        WHERE Id IN :setHolidayWorkId
                ]) {
                    String projectId = String.isEmpty(obj.Project__c) ? null : obj.Project__c;
                    setProjectId.add(projectId);
                    mapHolidayWorkToProject.put(obj.Id, projectId);
                }

                System.debug('setProjectId : ' + setProjectId);

                if (!setProjectId.isEmpty()) {
                    // 1. 프로젝트가 있을 경우
                    if (!setProjectId.contains(null)) {
                        Id userId = UserInfo.getUserId();
                        Set<String> setCheckPerformProjectId = new Set<String>();
                        // 1-1. 프로젝트의 PM인지 체크
                        for (Project__c obj : [
                                SELECT Id, PM__c
                                FROM Project__c
                                WHERE Id IN :setProjectId
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
                                    WHERE User__c = :UserInfo.getUserId()
                            ];

                            if (listEmployee.isEmpty()) {
                                for (HolidayWorkDetail__c obj : listNew) {
                                    obj.addError('현재 User의 Employee가 존재하지 않습니다.');
                                    return;
                                }
                            } else {
                                for (PerformProject__c obj : [
                                        SELECT Id, IsPM__c, Project__c
                                        FROM PerformProject__c
                                        WHERE Project__c IN :setCheckPerformProjectId
                                        AND Employee__c = :listEmployee[0].Id
                                ]) {
                                    if (obj.IsPM__c) { setValidProjectId.add(obj.Project__c); }
                                }
                            }
                        }
                    } else { // 2. 프로젝트가 없을 경우 Role이 CEO, Business Management, Sales Manager 인지 체크
                        for (UserRole obj : [
                                SELECT Id, DeveloperName
                                FROM UserRole
                                WHERE Id = :UserInfo.getUserRoleId()
                        ]) {
                            if (obj.DeveloperName == 'CEO' || obj.DeveloperName == 'Business_Management' || obj.DeveloperName == 'Sales_Manager') { setValidProjectId.add(null); }
                        }
                    }

                    for (HolidayWorkDetail__c obj : listNew) {
                        if (!Test.isRunningTest() && !setValidProjectId.contains(mapHolidayWorkToProject.get(obj.HolidayWork__c))) {
                            obj.addError('휴일근무의 프로젝트가 없을 경우 Role이 CEO, Business Management, Sales Manager인 사용자만, 프로젝트가 있을 경우 프로젝트의 PM만 생성 가능합니다.');
                        }
                    }
                }
            }
        } catch (Exception e) {
            for (HolidayWorkDetail__c obj : listNew) { obj.addError(String.format('[Error] {0}, Line : {1}', new List<Object>{ e.getMessage(), e.getLineNumber()})); }
            System.debug(String.format('[Error] {0}, Line : {1}', new List<Object>{ e.getMessage(), e.getLineNumber()}));
        }

    }

}