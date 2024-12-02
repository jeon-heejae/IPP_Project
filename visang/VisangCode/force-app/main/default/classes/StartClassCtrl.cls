public with sharing class StartClassCtrl {
    @AuraEnabled
    public static void updates(String recordId){
        
        Contact objCon = [
            SELECT Id, Parent__c, startClassDate__c, EndClassDate__c, LastName
            FROM Contact
            WHERE Id =:recordId
        ];
        objCon.StartClassDate__c = System.today();
        objCon.EndClassDate__c = System.today().addYears(1);
        update objCon;
    
    ContractWay__c objContract = new ContractWay__c();
        objContract.Name = '{' + objCon.LastName + '} 학생 계약';
        objContract.StartDate__c = System.today();
        objContract.EndDate__c = System.today().addYears(1);
        objContract.Contact__c = objCon.Id;
        objContract.Parents__c = objCon.Parent__c;
        insert objContract;
    }
}