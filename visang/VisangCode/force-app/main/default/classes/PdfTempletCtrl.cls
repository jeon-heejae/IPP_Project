public with sharing class PdfTempletCtrl {
    public List<Contact> listCon {get;set;}
    public List<Parents__c> listPar {get;set;}
    public OfflineClass__c objOff {get;set;}

    public PdfTempletCtrl() {
        //url속 "recordId" 라는 파라미터를 가져오는 코드
        Id recordId = ApexPages.currentPage().GetParameters().get('recordId');
        objOff = [
            SELECT Id, Teacher__c, ClassDate__c, ClassContent__c, Comment__c, 
                    Teacher__r.Name, Teacher__r.Mobile__c, Teacher__r.TeacherUniversity__c
            FROM OfflineClass__c
            WHERE Id = :recordId
        ];
        
        String TeacherId = objOff.Teacher__c;

        listCon = [
            SELECT Id, Parent__c, Teacher__c, LastName
            FROM Contact
            WHERE Teacher__c =:TeacherId
        ];
        Set<Id> setParId = new Set<Id>();
        for(Contact objCon : listCon){
            setParId.add(objCon.Parent__c);
        }
        System.debug('listCon >>' + listCon);
        listPar = [
            SELECT Id, Email__c
            FROM Parents__c
            WHERE Id =: setParId
        ];
        System.debug('listPar >>' + listPar);
        
    }
}