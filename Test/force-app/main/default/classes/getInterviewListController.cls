public with sharing class getInterviewListController {
    public List<Interview__c> Interviews {get; set;}

    public getInterviewListController() {
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

        Interviews=new List<Interview__c>();
        // 선택된 레코드들을 Interviews에 할당
        Interviews = [
            SELECT Id, Name, Intv_Training__c, Intv_Work__c, Intv_Others__c, Intv_Mentor__r.SignaturePhotoId__c,
            Intv_Mentor__r.Name,Intv_Mentee__r.Name, Intv_Date__c
            FROM Interview__c
            WHERE Id IN :listRecordsId
        ];
        System.debug('Interviews ::'+ Interviews);
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