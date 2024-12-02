public with sharing class AddressSearchMainController {
    @AuraEnabled
    public static Map<String, String> getAddressData(String recordId) {
        Contact contact = [
            SELECT Id, PostalCode__c, RoadAddress__c, DetailAddress__c 
            FROM Contact 
            WHERE Id = :recordId];
        
        Map<String, String> addressData = new Map<String, String>();
        addressData.put('PostalCode__c', contact.PostalCode__c);
        addressData.put('RoadAddress__c', contact.RoadAddress__c);
        addressData.put('DetailAddress__c', contact.DetailAddress__c);
        
        return addressData;
    }
    
    @AuraEnabled
    public static void saveAddressData(String recordId, Map<String, String> addressData) {
        Contact contact = new Contact(
            Id = recordId,
            PostalCode__c = addressData.get('PostalCode__c'),
            RoadAddress__c = addressData.get('RoadAddress__c'),
            DetailAddress__c = addressData.get('DetailAddress__c')
        );
        
        update contact;
    }
    
    
}