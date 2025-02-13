/************************************************************************************
* File Name   	    : PerformProject_tr
* Author	  		: Yeonlim
* Date				: 2024-01-02
* Modification Log
* ===================================================================================
* Ver      Date            Author          Modification
* ===================================================================================
* 1.0      2024-01-02      Yeonlim          Create (기존 Trigger Handler 이식 + Approval Line 업데이트)
************************************************************************************/
public without sharing class PerformProject_tr extends TriggerHandler {
    public PerformProject_tr() {
        listNew = (List<PerformProject__c>) Trigger.new;
        listOld = (List<PerformProject__c>) Trigger.old;
        mapNew = (Map<Id, PerformProject__c>) Trigger.newMap;
        mapOld = (Map<Id, PerformProject__c>) Trigger.oldMap;
    }

    /** TriggerHandler */
    private List<PerformProject__c> listNew { get; set; }
    private List<PerformProject__c> listOld { get; set; }
    private Map<Id, PerformProject__c> mapNew { get; set; }
    private Map<Id, PerformProject__c> mapOld { get; set; }

    public override void afterInsert() {
        updateApprovalLine();
    }
    public override void beforeUpdate() {
        sendPMEmail();
    }
    public override void afterUpdate() {
        updateApprovalLine();
    }

    /**
    * Event : after insert, after update
    * Author : Yeonlim
    * Description : 프로젝트 수행팀 변경 시 Approval Line1에 휴가신청라인 업데이트
    */
    private void updateApprovalLine() {
        Map<Id, Id> mapEmployeeToProject = new Map<Id, Id>();
        for(PerformProject__c obj : listNew){
            if (obj.Project__c != null && obj.Employee__c != null) {
                if (Trigger.isInsert || mapOld.get(obj.Id).Employee__c != obj.Employee__c) {
                    mapEmployeeToProject.put(obj.Employee__c, obj.Project__c);
                }
            }
        }

        if (!mapEmployeeToProject.isEmpty()) {
            Map<Id, Id> mapProjectToPM = new Map<Id, Id>();
            for(Project__c obj : [
                    SELECT Id, PM__c
                    FROM Project__c
                    WHERE Id IN: mapEmployeeToProject.values()
            ]) {
                mapProjectToPM.put(obj.Id, obj.PM__c);
            }

            Map<Id, Id> mapUserToEmployee = new Map<Id, Id>();
            for (Employee__c obj : [
                    SELECT Id, User__c
                    FROM Employee__c
                    WHERE Id IN: mapEmployeeToProject.keySet()
            ]) {
                mapUserToEmployee.put(obj.User__c, obj.Id);
            }

            List<User> listUser = new List<User>();
            for (User obj : [
                    SELECT Id, ApprovalLine1__c
                    FROM User
                    WHERE Id IN: mapUserToEmployee.keySet()
            ]) {
                User objUser = new User(
                        Id = obj.Id,
                        ApprovalLine1__c = '휴가신청라인/ApprovalLine1/' + mapProjectToPM.get(mapEmployeeToProject.get(mapUserToEmployee.get(obj.Id)))
                );
                listUser.add(objUser);
            }

            if (!listUser.isEmpty()) {
                update listUser;
            }
        }
    }

    /**
    * Event : before update
    * Author : Yeojin
    * Description : [2023-07-10 추가] 1차평가 필요여부 = true 일때, 투입인력 평가 이메일 전송
    */
    private void sendPMEmail() {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        List<String> setEmail = new List<String>();
        List<String> setProjectId = new List<String>();
        String projectName = '';

        for (PerformProject__c obj : listNew) {
            if(mapOld.get(obj.Id).Fm_First_Evaluation_Check__c == false && obj.Fm_First_Evaluation_Check__c == true){
                setProjectId.add(obj.Project__c);
            }
        }

        if(!setProjectId.isEmpty()){
            List<Project__c> projectList = [
                    SELECT PMEmail__c, Name
                    FROM Project__c
                    WHERE Id =: setProjectId
                    LIMIT 1
            ];

            if(!projectList.isEmpty()){
                setEmail.add(projectList[0].PMEmail__c);
                projectName = projectList[0].Name;
            }

            if(!setEmail.isEmpty()){
                email.setToAddresses(setEmail);
                email.setSubject('[' + projectList[0].Name + '] 프로젝트 외주인력평가 안내');
                String body = '안녕하세요, <br/>';
                body += '[' + projectList[0].Name + '] 프로젝트 투입 1개월차 외주인력 평가를 진행해 주시기 바랍니다. <br/><br/>';
                body += '아래 링크를 누르시면 해당 프로젝트 레코드로 이동합니다. <br/>';
                body += '화면에서 [투입인력평가서] 버튼을 누르신 후 평가를 진행해주시기 바랍니다.';
                body += 'https://daeunextier.lightning.force.com/lightning/r/Project__c/' + listNew[0].Id + '/view <br/><br/>';
                body += '감사합니다.';
                email.setHtmlBody(body);

                OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'admin@daeunextier.com'];
                System.debug('owea : ' + owea);
                if ( owea.size() > 0 ) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }

                try{
                    if(!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                    System.debug('success');
                }catch(Exception e){
                    System.debug('error');
                }
            }
        }
    }
}