public with sharing class RefreshBudgetListController {
    public ApexPages.StandardSetController stdSetController;
    public List<Id> listId;
    public String setSelectedId {get;set;}

    public RefreshBudgetListController(ApexPages.StandardSetController standardSetController) {
        this.stdSetController = standardSetController;
        listId=new List<Id>();
    
        for(Project__c obj : (List<Project__c>)stdSetController.getSelected()){
            listId.add(obj.Id);
        }
        setSelectedId= JSON.serialize(listId);
        System.debug('setContactId >>' + setSelectedId);
        
    }
    
}


