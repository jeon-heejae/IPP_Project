public with sharing class ChangeLevelCtrl {
    @AuraEnabled
    public static ListView returnListView(){
        ListView objListView = [
            SELECT Id, Name
            FROM ListView
            WHERE sObjectType = 'Contact' AND Name = '학생목록'
            LIMIT 1
        ];
        return objListView;
    }
    @AuraEnabled
    public static List<Contact> getRowData(String strConId){
        List<Object> listObj = (List<Object>)JSON.deserializeUntyped(strConId);
        System.debug('listObj >>' + listObj);
        List<String> listConId = new List<String>();
        for(Object obj : listObj){
            listConId.add((String)obj);
        }
        List<Contact> listCon = [
            SELECT Id, LastName, MathLevel__c, EnglishLevel__c, Description
            FROM Contact
            WHERE Id IN:listConId
        ];
        return listCon;
    }
    @AuraEnabled
    public static void updateWithInsert(List<Object> listObj){
        if(!listObj.isEmpty()){
            Set<Id> setConId = new Set<Id>();
            //Original Value를 위한 Contact Query
            for(Object obj : listObj){
                Map<Object, Object> mapObj = (Map<Object, Object>)obj;
                setConId.add((String)mapObj.get('Id'));
            }
            Map<Id, Contact> mapIdCon = new Map<Id, Contact>();
            mapIdCon.putAll([
                SELECT  Id, MathLevel__C, EnglishLevel__C
                FROM    Contact
                WHERE   Id IN: setConId
            ]);
            List<ContactLevelChange__c> listConLevUp = new List<ContactLevelChange__c>();
            List<Contact> listCon = new List<Contact>();
            for(Object obj : listObj){
                Map<Object, Object> mapObj = (Map<Object, Object>)obj;

                Contact objCon = mapIdCon.get((String)mapObj.get('Id'));
                if(mapObj.get('colMathLevel') != null && mapObj.get('colMathDescription') != null){
                    ContactLevelChange__c objLevelChange = new ContactLevelChange__c();
                    objLevelChange.ChangeTarget__c      = (String)mapObj.get('Id');
                    objLevelChange.OriginalLevel__c     = mapIdCon.get((String)mapObj.get('Id')).MathLevel__c;
                    objLevelChange.NewLevel__c          = (String)mapObj.get('colMathLevel');
                    objLevelChange.Description__c       = (String)mapObj.get('colMathDescription');
                    objLevelChange.Subject__c           = '수학';
                    System.debug('objLevelChange >>' + objLevelChange);
                    listConLevUp.add(objLevelChange);
                    
                    objCon.MathLevel__c = objLevelChange.NewLevel__c;
                }if(mapObj.get('colEnglishLevel') != null && mapObj.get('colEnglishDescription') != null){
                    ContactLevelChange__c objLevelChange = new ContactLevelChange__c();
                    objLevelChange.ChangeTarget__c      = (String)mapObj.get('Id');
                    objLevelChange.OriginalLevel__c     = mapIdCon.get((String)mapObj.get('Id')).EnglishLevel__c;
                    objLevelChange.NewLevel__c          = (String)mapObj.get('colEnglishLevel');
                    objLevelChange.Description__c       = (String)mapObj.get('colEnglishDescription');
                    objLevelChange.Subject__c           = '영어';
                    System.debug('objLevelChange >>' + objLevelChange);
                    listConLevUp.add(objLevelChange);
                    objCon.EnglishLevel__c = objLevelChange.NewLevel__c;
                }
                listCon.add(objCon);
            }
            if(!listConLevUp.isEmpty()){
                insert listConLevUp;
                update listCon;
            } 
        }
        
    }
}