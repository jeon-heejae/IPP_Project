public with sharing class testController {
    public ApexPages.StandardSetController stdSetController;
    public List<Id> listId;
    public String setSelectedId {get;set;}

    public testController(ApexPages.StandardSetController standardSetController) {
        this.stdSetController = standardSetController;
        listId=new List<Id>();
        //Id[] selectedId = new Id[0];
        for(IF_Contact__c obj : (List<IF_Contact__c>)stdSetController.getSelected()){
            listId.add(obj.Id);
        }
        setSelectedId= JSON.serialize(listId);
        System.debug('setContactId >>' + setSelectedId);
        
    }
    
}