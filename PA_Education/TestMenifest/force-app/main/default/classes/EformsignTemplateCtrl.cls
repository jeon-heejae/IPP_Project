/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-05-28     hs.jung          Create
*************************************************************************************/
public with sharing class EformsignTemplateCtrl {
    @AuraEnabled
    public static void deleteTemplate(String templateId) {
        EformsignTokenizedApiWorkflow mng = new EformsignTemplateManager.Deletion(templateId);
        mng.execute();
    }

    public static List<EformsignTemplate__c> getTemplatesBySObject(String objectApiName){
        return [
                SELECT Id, name, TemplateId__c
                FROM EformsignTemplate__c
                WHERE ObjectApiName__c = :objectApiName
                AND IsDeployedF__c = TRUE
                AND IsDeletedInEformsign__c = FALSE
                ORDER BY CreatedDate DESC
        ];
    }
}