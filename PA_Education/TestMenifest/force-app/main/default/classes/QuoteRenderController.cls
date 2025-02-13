public class QuoteRenderController{
    public List<QuoteItem__c> consultLst {get;set;}
    public List<QuoteItem__c> licenseLst {get;set;}
    public List<QuoteItem__c> trainingLst {get;set;}
    public Boolean hasCon {get;set;}
    public Boolean hasLis {get;set;}
    public Boolean hasTrn {get;set;}
    public String extUrl {get;set;}
    
    public QuoteRenderController(ApexPages.StandardController stdCtrl){
        String qId = stdCtrl.getId();
        extUrl = URL.getSalesforceBaseUrl().toExternalForm();
        consultLst = new List<QuoteItem__c>();
        licenseLst = new List<QuoteItem__c>();
        trainingLst = new List<QuoteItem__c>();
        hasCon = false;
        hasLis = false;
        hasTrn = false;
        List<QuoteItem__c> qiLst = [SELECT  Name,QuoteItem_ConsultAmount__c,QuoteItem_ConsultDiscountAmount__c,QuoteItem_ConsultDiscountedPrice__c,QuoteItem_ConsultLevel__c,
                                                 QuoteItem_ConsultListAmount__c,QuoteItem_ConsultListPrice__c,QuoteItem_ConsultManMonths__c,QuoteItem_ConsultName__c,QuoteItem_ConsultRemark__c,
                                                 QuoteItem_ConsultType__c,QuoteItem_LicenseAmount__c,QuoteItem_LicenseDiscountAmount__c,QuoteItem_LicenseDiscountedPriceYear__c,
                                                 QuoteItem_LicenseDiscountedPrice__c,QuoteItem_LicenseListAmount__c,QuoteItem_LicenseListPriceYear__c,QuoteItem_LicenseListPrice__c,
                                                 QuoteItem_LicenseNumberOfUser__c,QuoteItem_LicenseRemark__c,QuoteItem_LicenseType__c,QuoteItem_Quote__c,RecordType.Name,
                                                 QuoteItem_TrainingRemark__c, QuoteItem_TrainingDescription__c, QuoteItem_TrainingCount__c, QuoteItem_TrainingSalesAmount__c,
                                                 QuoteItem_TrainingSalesPrice__c, QuoteItem_TrainingStandardPrice__c
                                            FROM QuoteItem__c
                                           WHERE QuoteItem_Quote__c = :qId
                                        ORDER BY QuoteItem_SortOrder__c,Name ];
        for(QuoteItem__c qi : qiLst){
            system.debug(qi.RecordType.Name);
            if(qi.RecordType.Name == '컨설팅')
                consultLst.add(qi);      
            else if(qi.RecordType.Name == '라이센스')
                licenseLst.add(qi);         
            else if(qi.RecordType.Name == '교육')
                trainingLst.add(qi);         
        }
        if(consultLst.size()>0) hasCon = true;
        if(licenseLst.size()>0) hasLis = true;
        if(trainingLst.size()>0) hasTrn = true;
    }
}