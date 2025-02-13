public with sharing class ExpenseBudgetGridCmpController {

    @AuraEnabled
    public static Map<String, Object> getInit(Id recordId) {
        Expense__c objExpense = [
                SELECT Id, BudgetType__c
                FROM Expense__c
                WHERE Id =: recordId
        ];

        List<ExpenseDetail__c> listExpenseDetail = [
            SELECT Id, Name, FORMAT(Date__c) Date__c, Category2__c, Amount__c, Description__c, Project_Name__c,
                        Project_Name__r.Name, Opportunity_Name__c, Opportunity_Name__r.Name, Expense__c,
                        CardCompany__c, StoreName__c, BusinessType__c, StoreAddress__c,
                        fm_ProjectOppty__c, BillingAmount__c, PriorExpenseApplication__r.Name,
                        SalesType__c, Lead__c, Lead__r.Name, fm_Expense__c
            FROM ExpenseDetail__c
            WHERE Expense__c =: recordId
            ORDER BY Date__c, Category2__c
        ];

        return new Map<String, Object> {
            'objExpense'        => objExpense,
            'listExpenseDetail' => listExpenseDetail
        };
    }

    //Field Label 갖고오는 Map Container
    @AuraEnabled
    public static Map<String, String> getObjectFieldLabel(String sObjectName){
        Schema.SObjectType schemaObject = Schema.getGlobalDescribe().get(sObjectName);
        Schema.DescribeSObjectResult schemaObjectResult = schemaObject.getDescribe();
        Map<String, Schema.SObjectField> mapSchemaObjectResult = schemaObjectResult.fields.getMap();

        Map<String, String> mapFieldLabel = new Map<String, String>();
        for(Schema.SObjectField obj : mapSchemaObjectResult.values()){
            Schema.DescribeFieldResult f = mapSchemaObjectResult.get(obj.getDescribe().getName()).getDescribe();
            mapFieldLabel.put(f.getName(), f.getLabel());
        }
        return mapFieldLabel;
    }
}