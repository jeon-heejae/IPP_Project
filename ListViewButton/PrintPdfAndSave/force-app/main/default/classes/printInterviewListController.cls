public with sharing class printInterviewListController {
    public ApexPages.StandardSetController stdSetController;
    public List<Id> listId;
    public String setSelectedId {get;set;}

    public printInterviewListController(ApexPages.StandardSetController standardSetController) {
        this.stdSetController = standardSetController;
        listId=new List<Id>();
    
        for(Interview__c obj : (List<Interview__c>)stdSetController.getSelected()){
            listId.add(obj.Id);
        }
        setSelectedId= JSON.serialize(listId);
        System.debug('setContactId >>' + setSelectedId);
        
    }
    
}


