public with sharing class MaintenanceRequestHelper extends TriggerHandler {
    private Map<Id,Case> mapCaseOld {get;set;}
    private Map<Id,Case> mapCaseNew {get;set;}
    private List<Case> listCaseNew {get;set;}
    
    public MaintenanceRequestHelper(){
        mapCaseOld = (Map<Id,Case>) Trigger.oldMap;
        mapCaseNew = (Map<Id,Case>) Trigger.newMap;
        listCaseNew = (List<Case>) Trigger.new;
    }
    
    public void updateWorkOrders() {
        List<Case> listNewCase = new List<Case>();
        Set<Id> closedCaseIds = new Set<Id>();
        
        for(Case objCase : listCaseNew){
            if(objCase.Status == 'Closed' && (objCase.Type == 'Repair' || objCase.Type == 'Routine Maintenance')){
                closedCaseIds.add(objCase.Id);
            }
        }
        
        if(closedCaseIds.isEmpty()) {
            return; // 처리할 케이스가 없으면 여기서 종료
        }
        
        // 관련 Equipment 정보를 한 번에 조회
        Map<Id, List<Equipment_Maintenance_Item__c>> caseToEquipmentMap = new Map<Id, List<Equipment_Maintenance_Item__c>>();
        for(Equipment_Maintenance_Item__c emi : [SELECT Maintenance_Request__c, Equipment__c, Equipment__r.Maintenance_Cycle__c 
                                                 FROM Equipment_Maintenance_Item__c 
                                                 WHERE Maintenance_Request__c IN :closedCaseIds]) {
            if(!caseToEquipmentMap.containsKey(emi.Maintenance_Request__c)) {
                caseToEquipmentMap.put(emi.Maintenance_Request__c, new List<Equipment_Maintenance_Item__c>());
            }
            caseToEquipmentMap.get(emi.Maintenance_Request__c).add(emi);
        }
        
        for(Case objCase : listCaseNew){
            if(closedCaseIds.contains(objCase.Id)){
                Case objCaseNew = new Case();
                objCaseNew.Vehicle__c = objCase.Vehicle__c;
                objCaseNew.Type = 'Routine Maintenance';
                objCaseNew.Subject = 'Routine Maintenance Follow-up';
                objCaseNew.Date_Reported__c = System.today();
                objCaseNew.Status = 'New';
                
                Decimal minCycle = null;
                if(caseToEquipmentMap.containsKey(objCase.Id)) {
                    for(Equipment_Maintenance_Item__c emi : caseToEquipmentMap.get(objCase.Id)) {
                        if(minCycle == null || (emi.Equipment__r.Maintenance_Cycle__c != null && emi.Equipment__r.Maintenance_Cycle__c < minCycle)) {
                            minCycle = emi.Equipment__r.Maintenance_Cycle__c;
                        }
                    }
                }
                
                if(minCycle != null) {
                    objCaseNew.Date_Due__c = System.today().addDays(minCycle.intValue());
                }
                
                listNewCase.add(objCaseNew);
            }
        }
        
        if(!listNewCase.isEmpty()) {
            insert listNewCase;
            
            // 새로운 Case와 Equipment를 연결
            List<Equipment_Maintenance_Item__c> newEMIs = new List<Equipment_Maintenance_Item__c>();
            for(Integer i = 0; i < listNewCase.size(); i++) {
                Case newCase = listNewCase[i];
                Id oldCaseId = (new List<Id>(closedCaseIds))[i];
                if(caseToEquipmentMap.containsKey(oldCaseId)) {
                    for(Equipment_Maintenance_Item__c oldEMI : caseToEquipmentMap.get(oldCaseId)) {
                        Equipment_Maintenance_Item__c newEMI = new Equipment_Maintenance_Item__c(
                            Maintenance_Request__c = newCase.Id,
                            Equipment__c = oldEMI.Equipment__c
                        );
                        newEMIs.add(newEMI);
                    }
                }
            }
            if(!newEMIs.isEmpty()) {
                insert newEMIs;
            }
        }
    }
    
    public override void afterUpdate(){
        updateWorkOrders();
    }
}