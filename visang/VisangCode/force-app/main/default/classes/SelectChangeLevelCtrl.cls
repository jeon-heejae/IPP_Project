public with sharing class SelectChangeLevelCtrl {
    public ApexPages.StandardSetController standardSetController;
    public List<Contact> listCon {get;set;}
    public String strSelectedConId {get; set;}
    public SelectChangeLevelCtrl(ApexPages.StandardSetController standardSetController) {
        this.standardSetController = standardSetController;
        Id[] selectedId = new Id[0];
        for(Contact objCon : (List<Contact>)standardSetController.getSelected()){
            selectedId.add(objCon.Id);
        }
        strSelectedConId = JSON.serialize(selectedId);
    }
}