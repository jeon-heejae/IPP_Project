/**
 * ==================================================================================
 * File Name         : Opportunity_tr
 * Author            : yeonlim.jeong
 * Group             : Daeu Nextier
 * Description       :
 * Modification Logs
 * ==================================================================================
 *   Ver     Date          Author           Modification
 * ==================================================================================
 *   1.0   2023-12-19     yeonlim.jeong     제안 PM 입력 시 해당 User에게 Manual Sharing 걸기
**/
public without sharing class Opportunity_tr  extends TriggerHandler {
    private static List<Opportunity__c> listNew {get; set;}
    private static List<Opportunity__c> listOld {get; set;}
    private static Map<Id, Opportunity__c> mapNew {get; set;}
    private static Map<Id, Opportunity__c> mapOld {get; set;}

    public Opportunity_tr() {
        listNew = (List<Opportunity__c>) Trigger.new;
        listOld = (List<Opportunity__c>) Trigger.old;
        mapNew  = (Map<Id, Opportunity__c>) Trigger.newMap;
        mapOld  = (Map<Id, Opportunity__c>) Trigger.oldMap;
    }

    public override void afterInsert() {
        createEmployeeNo();
    }

    public override void afterUpdate() {
        createEmployeeNo();
    }

    /**
    * Event : after insert, after update
    * Author : Yeonlim
    * Description : 제안 PM 입력 시 해당 User에게 Manual Sharing 걸기
    */
    public void createEmployeeNo() {
        Map<String, Opportunity__Share> mapUserIdToObjShare = new Map<String, Opportunity__Share>();
        Map<String, String> mapIdToOldUser = new Map<String, String>();
        Map<String, String> mapIdToNewUser = new Map<String, String>();

        for (Opportunity__c obj : listNew) {
            if ((Trigger.isUpdate && obj.ProposalPM__c != mapOld.get(obj.Id).ProposalPM__c) || Trigger.isInsert) {
                if (obj.ProposalPM__c != null) {
                    Opportunity__Share objOppty = new Opportunity__Share(
                            ParentId      = obj.Id,
                            UserOrGroupId = obj.ProposalPM__c,
                            AccessLevel   = 'Edit',
                            RowCause      = 'Manual'
                    );

                    mapUserIdToObjShare.put(obj.Id + '-' + obj.ProposalPM__c, objOppty);
                    mapIdToNewUser.put(obj.Id, obj.ProposalPM__c);
                }

                if (Trigger.isUpdate) {
                    mapIdToOldUser.put(obj.Id, mapOld.get(obj.Id).ProposalPM__c);
                } else {
                    mapIdToOldUser.put(obj.Id, obj.ProposalPM__c);
                }
            }
        }

        List<Opportunity__Share> listDeleteShare = new List<Opportunity__Share>();

        if (!mapIdToOldUser.isEmpty()) {
            for (Opportunity__Share obj : [
                    SELECT Id, ParentId, UserOrGroupId, RowCause
                    FROM Opportunity__Share
                    WHERE ParentId IN: mapIdToOldUser.keySet()
            ]) {
                if (Trigger.isUpdate && mapIdToOldUser.get(obj.ParentId) == obj.UserOrGroupId && obj.RowCause == 'Manual') {
                    listDeleteShare.add(obj);
                }
                if (mapIdToNewUser.get(obj.ParentId) == obj.UserOrGroupId && obj.RowCause == 'Owner') {
                    mapUserIdToObjShare.remove(obj.ParentId + '-' + obj.UserOrGroupId);
                }
            }

            System.debug('listDeleteShare : ' + listDeleteShare);

            if (!listDeleteShare.isEmpty()) {
                delete listDeleteShare;
            }

            System.debug('mapUserIdToObjShare : ' + mapUserIdToObjShare);

            if (!mapUserIdToObjShare.isEmpty()) {
                insert mapUserIdToObjShare.values();
            }
        }
    }

}