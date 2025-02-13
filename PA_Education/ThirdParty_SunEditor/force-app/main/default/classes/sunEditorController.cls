public with sharing class sunEditorController {
    public static string gDomainHomeHost {get; set;}
    public static String gStrField {get; set;}


    @AuraEnabled
    public static string getDomainHost(){
        String strVfDomainHost=DomainCreator.getVisualforceHostname('c');
        System.debug('vfDomain: '+strVfDomainHost);
        return strVfDomainHost;
    }

    public sunEditorController(){
        gDomainHomeHost=DomainCreator.getLightningHostname();
        System.debug('gDomainHomeHost: '+gDomainHomeHost);
        Id recordID = Apexpages.currentPage().getParameters().get('recordId');
        List<Account> listAcc = [
            SELECT Id, SunEditor__c
            FROM Account
            WHERE Id =: recordID
        ];
        gStrField = listAcc[0].SunEditor__c;
    }

    @AuraEnabled
    public static String getSunEditor(Id fRecordId){
        
        List<Account> listAccounts=new List<Account>();
        listAccounts=[
            SELECT SunEditor__c
            FROM Account
            WHERE Id=:fRecordId
        ];

        if(!listAccounts.isEmpty()){
            return listAccounts[0].SunEditor__c;
        }
        return null;
    }

    @AuraEnabled
    public static Boolean doSaveRichText(Id fRecordId,String fStrRichText){
        Boolean flag=false;
        List<Account> listAccounts=new List<Account>();
        listAccounts=[
            SELECT SunEditor__c
            FROM Account
            WHERE Id=:fRecordId
        ];

        if(!listAccounts.isEmpty()){
            listAccounts[0].SunEditor__c=fStrRichText;

            Database.UpsertResult[] listUr=Database.upsert(listAccounts,false);

            for(Database.UpsertResult objUr: listUr){
                if(objUr.isSuccess()){
                    flag=true;
                }
                else{
                    flag= false;
                }
            }
        }
        return flag;
    }
    
}