public with sharing class SearchContactController {
    @AuraEnabled
    public static List<Contact> searchContacts(String searchLastName, String searchAccountName, 
    String searchEmail) {
        String searchQuery = 'SELECT Id, LastName, Account.Name, Email FROM Contact WHERE ';
        List<String> conditions = new List<String>();
        
        if (String.isNotBlank(searchLastName)) {
            conditions.add('LastName  like \'' + searchLastName + '%\'');
            
        }
        if (String.isNotBlank(searchAccountName)) {
            conditions.add('Account.Name  like \'' + searchAccountName + '%\'' );
            
        }
        if (String.isNotBlank(searchEmail)) {
            conditions.add('Email  like \'' + searchEmail + '%\'' );
            
        }
        searchQuery += String.join(conditions, ' AND ');     
    
        List<Contact> listSearchContacts = Database.query(searchQuery);

        return listSearchContacts;
     }
    }
