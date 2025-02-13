/**
 * ==================================================================================
 * File Name         : RenewalHPContactFormContrller
 * Author            : Changjoo.Sohn
 * Group             : Daeu Nextier
 * Description       : Any questions of Renewal Homepage Page
 * Modification Logs
 * ==================================================================================
 *   Ver     Date          Author          Modification
 * ==================================================================================
 *   1.0   2022-01-27     Changjoo.Sohn   Initial Version
**/
public without sharing class RenewalHPContactFormController {
    @AuraEnabled
    public static List<Map<String, String>> getPickListValues(String objectType, String selectedField) {
        List<Map<String, String>> pickListValuesList = new List<Map<String, String>>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple) {
            if(pickListVal.getValue() =='None') continue;

            pickListValuesList.add(new Map<String, String>{
                    'label' => pickListVal.getLabel(),
                    'value' => pickListVal.getValue()
            });
        }
        return pickListValuesList;
    }

    @AuraEnabled
    public static String doSave(Map<String, Object> paramMap){
        System.debug('paramMap: ' + paramMap);
        String strName = String.valueOf(paramMap.get('Name'));
        String strCompany = String.valueOf(paramMap.get('Company'));
        String strMobile = String.valueOf(paramMap.get('Mobile'));
        String strEmail = String.valueOf(paramMap.get('Email'));
        String strType = String.valueOf(paramMap.get('LeadType'));
        String strSubject = String.valueOf(paramMap.get('Subject'));
        String strDescription = String.valueOf(paramMap.get('Description'));

        Lead__c objLead = new Lead__c();
        objLead.Name = strName;
        objLead.Company__c = strCompany;
        objLead.Phone__c = strMobile;
        objLead.Email__c = strEmail;
        objLead.LeadSource__c = '웹';
        objLead.Type__c = strType;
        objLead.WebSubject__c = strSubject;
        objLead.WebMessage__c = strDescription;
        objLead.PersonalInformationUseAgreement__c = true;
        objLead.PersonalInformationUseAgreementDate__c = Date.today();
        insert objLead;

        return '0';
    }
}