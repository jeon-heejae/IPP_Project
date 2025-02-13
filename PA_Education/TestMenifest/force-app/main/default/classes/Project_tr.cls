/** ==================================================================================
*   File Name   Project_tr
*   Author      : yj.kim
*   Date        : 2023.07.07
*   Description : 프로젝트 PM Email Update, 완료여부 = true 시 해당 PM에게 Email 전송
* ==================================================================================
*   Ver     Date            Author          Modification
* ==================================================================================
*   1.0     2023.07.04      yj.kim    Create
* ==================================================================================
**/

public with sharing class Project_tr extends TriggerHandler{

    private List<Project__c> listNew { get; set; }
    private List<Project__c> listOld { get; set; }
    private Map<Id, Project__c> mapNew { get; set; }
    private Map<Id, Project__c> mapOld { get; set; }

    public Project_tr() {
        listNew = (List<Project__c>) Trigger.new;
        listOld = (List<Project__c>) Trigger.old;
        mapNew = (Map<Id, Project__c>) Trigger.newMap;
        mapOld = (Map<Id, Project__c>) Trigger.oldMap;
    }

    public override void beforeInsert() {
        updatePMEmail();
    }

    public override void afterInsert() {
        createBudget();
    }

    public override void beforeUpdate() {
        updatePMEmail();
        sendEmail();
    }

    public override void afterUpdate() { }

    public override void beforeDelete() { }

    public override void afterDelete() { }

    public void updatePMEmail(){
        Set<Id> setPmUserId = new Set<Id>();
        for (Project__c objProject : listNew) {
            setPmUserId.add(objProject.PM__c);
        }

        Map<Id, User> mapPmUser = new Map<Id, User>([SELECT Id, email FROM User WHERE Id IN :setPmUserId]);
        for (Project__c objProject : listNew) {
            String email = objProject.PM__c == null || mapPmUser.get(objProject.PM__c) == null ? null : mapPmUser.get(objProject.PM__c).Email;
            objProject.PMEmail__c = email;
        }
    }

    public void sendEmail(){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        List<String> setEmail = new List<String>();
        String projectId = '';

        for (Project__c objProject : listNew) {
            if(objProject.Completed__c == true && mapOld.get(objProject.Id).Completed__c == false){
                setEmail.add(objProject.PMEmail__c);
                projectId = objProject.Id;
            }
        }

        System.debug('setEmail : ' + setEmail);
        if(!setEmail.isEmpty()){
            email.setToAddresses(setEmail);
            email.setSubject('[' + listNew[0].Name + '] 프로젝트 인력평가 안내');
            String body = '안녕하세요, <br/>';
            body += '[' + listNew[0].Name + '] 프로젝트 투입 전체 투입인원평가를 진행해 주시기 바랍니다. <br/><br/>';
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

    public void createBudget(){
        list<Budget__c> listBudget = new List<Budget__c>();
        for (Project__c obj : listNew) {
            System.debug(obj);
            listBudget.add(new Budget__c(
                    Project__c = obj.Id,
                    BudgetType__c = '프로젝트',
                    Name = 'triggerName'
            ));
        }
        if (!listBudget.isEmpty()) {
            insert listBudget;
        }
    }

}