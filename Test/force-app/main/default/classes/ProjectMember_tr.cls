public with sharing class ProjectMember_tr extends TriggerHandler {
   
    private List<ProjectMember__c> listProjectMemNew{get;set;}
    


    public ProjectMember_tr(){
       
        listProjectMemNew=(List<ProjectMember__c>) Trigger.new;
    }
    public override void beforeInsert(){
        beforeNameInsert();
        
    }

    public override void afterInsert(){
        
    }

    public override void beforeUpdate(){
        beforeNameInsert();
    }

    public override void afterUpdate(){
    }

    public override void beforeDelete(){
       
    }

    

    public void beforeNameInsert(){
        Set<Id> setProjectId = new Set<Id>();
        Set<Id> setEmployeeId = new Set<Id>();
    
        for(ProjectMember__c pm : listProjectMemNew) {
             setProjectId.add(pm.Project__c);
             setEmployeeId.add(pm.Employee__c);
        }
        
        Map<Id, Project__c> mapProject = new Map<Id, Project__c>([
            SELECT Name
            FROM Project__c
            WHERE Id IN :setProjectId
        ]);
        
        Map<Id, Employee__c> mapEmployee = new Map<Id, Employee__c>([
            SELECT EmployeeName__c
            FROM Employee__c
            WHERE Id IN :setEmployeeId
        ]);
        
        for(ProjectMember__c pm : listProjectMemNew) {
            String projectName = mapProject.get(pm.Project__c).Name;
            String employeeName = mapEmployee.get(pm.Employee__c).EmployeeName__c;
            String position = pm.Position__c ;
            
            pm.Name = projectName + '_' + position + '_' + employeeName;
        }

    }



}