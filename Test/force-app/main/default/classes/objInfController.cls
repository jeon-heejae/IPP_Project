public with sharing class objInfController {
    public List<IF_Contact__c> listContact {get; set;}

    public objInfController() {
        String recordIds=ApexPages.currentPage().GetParameters().get('recordId');

        if (String.isEmpty(recordIds)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'recordId is missing.'));
            return;
        }
       

        //String recordIds='a06dM000003YG8fQAG,a06dM000003YD2kQAG';
        List<String> listRecordsId=new List<String>();
        listRecordsId=recordIds.split(',');
        
        System.debug('recordIds: '+ recordIds);
        System.debug('listRecordIds: '+ listRecordsId[0]);

        listContact = new List<IF_Contact__c>();
        listContact = [
            SELECT Id, Name
            FROM IF_Contact__c
            WHERE Id In :listRecordsId
        ];

        System.debug('listContact: '+ listContact);


    }

    @AuraEnabled
    public static String generatePDF(String vfPageUrl) {
        try {
            PageReference pdfPage = new PageReference(vfPageUrl);
            Blob pdfBlob = pdfPage.getContentAsPDF();

            // Base64로 변환하여 반환
            return EncodingUtil.base64Encode(pdfBlob);

        } catch (Exception e) {
            throw new AuraHandledException('PDF 생성 실패: ' + e.getMessage());
        }
    }

}