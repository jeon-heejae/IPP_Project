public with sharing class EmployeeController {

    @AuraEnabled
    public static Boolean isCheck(Id recordId){
        String userId=UserInfo.getUserId();
        Boolean flag=false;

        List<Employee__c> listUserName=new List<Employee__c>();
        listUserName=[
            SELECT OwnerId
            FROM Employee__c
            WHERE Id=:recordId
        ];

        if(listUserName[0].OwnerId==userId){
            flag=true;
        }

        return flag;
    }

    @AuraEnabled
    public static Employee__c getEmployeeSecret(){
        Id recordId='a2O0k000004DqJ4EAK';
        List<Employee__c> listEmp=new List<Employee__c>();

        listEmp=[
            SELECT Id, Gender__c, CurrentAddress__c, Birthday__c, EnglishName__c, 
            IdNumber__c, AddressNumber__c, WeddingAnniversary__c,
            JoinArmyDate__c, DischargeDate__c, MilitaryServiceDiv__c, 
            MilitaryType__c, Class__c, MilitaryTypeDescription__c, 
            Dependents__c, UpdateDate__c, DismissalDate__c, Reason__c, 
            Clear__c, OwnerId, User__c
            FROM Employee__c
            where Id=:recordId
        ];

        System.debug(listEmp[0]);
        return listEmp[0];
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues(String objectName, String fieldName) {
        List<String> picklistValues = new List<String>();
            
        // Describe the object's field and get picklist values
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
            
        // Add each picklist value to the list
        for (Schema.PicklistEntry entry : picklistEntries) {
            if (entry.isActive()) {
                picklistValues.add(entry.getLabel()); // or use entry.getValue() if you need the API name
            }
        }
            
        return picklistValues;
    }

    @AuraEnabled
    public static Boolean updateEmpInfo(Employee__c employee){
        try {
            System.debug('emp: '+employee.Gender__c);
            update employee;
            return true;
        } catch (Exception e) {
            return false;
        }
    }
    
}