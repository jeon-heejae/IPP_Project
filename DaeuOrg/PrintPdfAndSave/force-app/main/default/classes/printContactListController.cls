public with sharing class printContactListController {
    public ApexPages.StandardSetController stdController;
    // public String setSelectedId  { get; set; }
    public Set<Id> setId {get; set;}
    //public List<Parents__c> listPar {get; set;}
    // public List<Map<String,Object>> params { get; set; }

    public printContactListController(ApexPages.StandardSetController stdController) {
        this.stdController = stdController;
        setId = new Set<Id>();

        System.debug('selected:'+stdController.getSelected());
       
        // 선택된 레코드 ID들을 setId에 저장
        for (SObject obj : stdController.getSelected()) {
            setId.add(obj.Id);
        }
        System.debug('setId ::'+ setId);

        // listPar=[
        //     SELECT id, Name
        //     FROM Parents__c
        //     WHERE id =:setId
        // ];

        // System.debug('listPar ::'+ listPar);

    //    List<Contact> objContact=new List<Contact>();
    //    objContact = [
    //        SELECT Id, Name,Title
    //        FROM Contact
    //        WHERE Id IN :setId
    //    ];

    //    params=new List<Map<String,Object>>();
    //    for(Contact con : objContact) {
    //        params.add(new Map<String, Object>{
    //            'Name' => con.Name,
    //            'Title' => con.Title,
    //            'Id' => con.Id
    //        });
    //    }
       

    //    System.debug('selectedInterviews ::'+ params);
   }

   

   

    @AuraEnabled
    public static String doSavePdf(String strRecordId) {
        String result = '';
        String vfPageUrl = '';
        
        try{
            vfPageUrl = '/apex/printContact?recordId=' + strRecordId;
            PageReference templatePageReference = new PageReference(vfPageUrl);
        
        
            Blob templateBLOB;
            if (System.test.isRunningTest()){
                templateBLOB = Blob.valueOf('Unit test');
            } else {
                templateBLOB = templatePageReference.getContentAsPDF();
            }
            
            List<AggregateResult> cntDocument = new List<AggregateResult>();
            cntDocument = [
                    SELECT id
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :strRecordId
                    GROUP BY Id
            ];
        
            ContentVersion objContentVersion = new ContentVersion();
            objContentVersion.Title                     = 'SAMPLE';
            objContentVersion.VersionData               = templateBLOB;
            objContentVersion.PathOnClient              = 'SAMPLE.pdf';
            objContentVersion.FirstPublishLocationId    = strRecordId;
        
            insert objContentVersion;
        
            objContentVersion = [
                    SELECT Id, ContentDocumentId 
                    FROM ContentVersion 
                    WHERE Id =:objContentVersion.Id
            ];
        
            List<ContentDocumentLink> listCdl = new List<ContentDocumentLink>([
                    SELECT Id, ShareType, Visibility
                    from ContentDocumentLink
                    where LinkedEntityId = :strRecordId
                    and ContentDocumentId = :objContentVersion.ContentDocumentId
            ]);
        
            result = 'success';
        
        } catch(Exception e){
            System.debug('Error line : ' + e.getLineNumber());
            System.debug('Error message : ' + e.getMessage());
            System.debug('Error  cause : ' + e.getCause());
            result = 'error';
        }
        
        return result;
    }
}