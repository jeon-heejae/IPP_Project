/************************************************************************************
 * Description :
 *
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2022-09-06     yr.lee          Create
*************************************************************************************/

public with sharing class PrintExpenseController {
    public List<List<Expense__c>> listExpenseItem { get; set; }
   
    
    public PrintExpenseController() {
        //url속 "recordId" 라는 파라미터를 가져오는 코드
        Id recordId = ApexPages.currentPage().GetParameters().get('recordId');
        
        listExpenseItem=new List<List<Expense__c>>();
        //해당 Expense의 정보들을 가져오는 쿼리
        List<Expense__c> listExpense=
        [
            select Name, Description__c, Spending__c
            from Expense__c
            where Project__r.Id = :recordId
        ];

        List<Expense__c> currentPage=new List<Expense__c>();

        for (Integer i = 0; i < listExpense.size(); i++) {
            currentPage.add(listExpense[i]);
            if (Math.mod(i + 1, 20) == 0 || i == listExpense.size() - 1) {
                listExpenseItem.add(currentPage);
                currentPage = new List<Expense__c>();
            }
        }
        
    }

    @AuraEnabled
    public static String doSavePdf(String strRecordId) {
        String result = '';
        String vfPageUrl = '';
        
        try{
            vfPageUrl = '/apex/PrintExpense?recordId=' + strRecordId;
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


