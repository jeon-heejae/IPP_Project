public with sharing class ChangeProjectMemberController {
    
    @AuraEnabled
    public static Boolean isProjectActive(Id projectId) {
        Project__c project = [
            SELECT Status__c 
            FROM Project__c 
            WHERE Id = :projectId];
        return project.Status__c != '종료';
    }

    @AuraEnabled
    public static List<ProjectMember__c> GetProjectMembers(Id projectId){ 
        List<ProjectMember__c> listProjectMember = new List<ProjectMember__c>();
        listProjectMember = [
                SELECT Id, Employee__r.EmployeeName__c,Position__c
                FROM ProjectMember__c
                WHERE Project__r.Id = :projectId
        ];
        System.debug(listProjectMember);
        return listProjectMember;
    }

    @AuraEnabled
    public static String GetMemberPosition(Id MemberId) { 
        ProjectMember__c member = [
        SELECT Position__c 
        FROM ProjectMember__c 
        WHERE Id = :MemberId];
        return member.Position__c;
    }

    @AuraEnabled
    public static List<Employee__c> GetAvailableEmployees() {
        
        Set<Id> setEmployeeId = new Set<Id>();
        List<ProjectMember__c> listCurrentP_m=new List<ProjectMember__c>(); 
        listCurrentP_m=[
            SELECT Employee__r.Id
            FROM ProjectMember__c 
            WHERE Project__r.EndDate__c > :Date.today()
        ];

        for (ProjectMember__c pm : listCurrentP_m) {
            setEmployeeId.add(pm.Employee__r.Id);
        }

        
        List<Employee__c> listAvailableEmployees=new List<Employee__c>();
        listAvailableEmployees=[
            SELECT Id, EmployeeName__c 
            FROM Employee__c 
            WHERE Id NOT IN :setEmployeeId];

        return listAvailableEmployees;
    }

    @AuraEnabled
    public static void ReplaceProjectMember(Id projectMemberId, Id newEmployeeId) {
       
        ProjectMember__c projectMember = new ProjectMember__c();
        projectMember.Id=projectMemberId;
        projectMember.Employee__c = newEmployeeId;
        
        update projectMember;
        
    }
}