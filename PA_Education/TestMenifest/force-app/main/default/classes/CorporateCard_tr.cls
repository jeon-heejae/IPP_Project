/************************************************************************************
* File Name   	    : CorporateCard_tr
* Author	  		: Yeonlim
* Date				: 2024-01-17
* Modification Log
* ===================================================================================
* Ver      Date            Author          Modification
* ===================================================================================
* 1.0      2024-01-17      Yeonlim           Create
************************************************************************************/
public with sharing class CorporateCard_tr extends TriggerHandler {
    private static List<CorporateCard__c> listNew { get; set; }
    private static List<CorporateCard__c> listOld { get; set; }
    private static Map<Id, CorporateCard__c> mapNew { get; set; }
    private static Map<Id, CorporateCard__c> mapOld { get; set; }

    public CorporateCard_tr() {
        listNew = (List<CorporateCard__c>) Trigger.new;
        listOld = (List<CorporateCard__c>) Trigger.old;
        mapNew = (Map<Id, CorporateCard__c>) Trigger.newMap;
        mapOld = (Map<Id, CorporateCard__c>) Trigger.oldMap;
    }

    public override void beforeInsert() {
        doSetRealUser();
    }

    public override void beforeUpdate() {
        updateEmployeeNo();
    }

    /**
    * Event : before insert
    * Author : Yeonlim
    * Description : 사번 필드에 해당하는 User를 실사용자, Owner 필드에 넣어줌
    *               [2024-02-07 추가] 사번필드에 값이 없을 경우 Owner, 실사용자에 시스템 어드민 User를 넣어줌
    */
    public void doSetRealUser() {
        Set<String> setEmployeeNo = new Set<String>();
        Id systemAdminId = [SELECT Id FROM User WHERE Username LIKE '%adm@daeunextier.com%'].Id;
        for (CorporateCard__c obj : listNew) {
            if (String.isBlank(obj.RealUser__c)) {
                if (String.isNotBlank(obj.EmployeeNo__c)) {
                    setEmployeeNo.add(obj.EmployeeNo__c);
                } else {
                    obj.OwnerId     = systemAdminId;
                    obj.RealUser__c = systemAdminId;
                }
            }
        }

        if (!setEmployeeNo.isEmpty()) {
            Map<String, String> mapEmployeeNoToUserId = new Map<String, String>();
            for (Employee__c obj : [
                    SELECT EmployeeNo__c, User__c
                    FROM Employee__c
                    WHERE EmployeeNo__c IN :setEmployeeNo
            ]) {
                mapEmployeeNoToUserId.put(obj.EmployeeNo__c, obj.User__c);
            }

            for (CorporateCard__c obj : listNew) {
                obj.OwnerId     = mapEmployeeNoToUserId.get(obj.EmployeeNo__c);
                obj.RealUser__c = mapEmployeeNoToUserId.get(obj.EmployeeNo__c);
            }
        }
    }

    /**
    * Event : before update
    * Author : Yeonlim
    * Description : 실사용자가 변경될 경우, 해당 User의 사번 필드를 찾아서 Update
    */
    public void updateEmployeeNo() {
        Set<String> setRealUserId = new Set<String>();
        for (CorporateCard__c obj : listNew) {
            if (obj.RealUser__c != mapOld.get(obj.Id).RealUser__c) {
                setRealUserId.add(obj.RealUser__c);
            }
        }

        if (!setRealUserId.isEmpty()) {
            Map<String, String> mapUserIdToEmployeeNo = new Map<String, String>();
            for (Employee__c obj : [
                    SELECT EmployeeNo__c, User__c
                    FROM Employee__c
                    WHERE User__c IN: setRealUserId
            ]) {
                mapUserIdToEmployeeNo.put(obj.User__c, obj.EmployeeNo__c);
            }

            for (CorporateCard__c obj : listNew) {
                obj.EmployeeNo__c = mapUserIdToEmployeeNo.get(obj.RealUser__c);
            }
        }
    }
}