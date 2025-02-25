public with sharing class getInterviewListController {
    public List<Map<String, Object>> listMapInterviews { get; set; }

    public getInterviewListController() {
        String recordIds = ApexPages.currentPage().GetParameters().get('recordId');

        List<String> listRecordsId = recordIds.split(',');
        //System.debug('recordIds: ' + recordIds);

        List<Interview__c> listInterviews = [
            SELECT Id, Intv_Name__c, Intv_Training__c, Intv_Work__c, Intv_Others__c, Intv_Mentor__r.SignaturePhotoId__c,
                   Intv_Mentor__r.Name, Intv_Mentee__r.Name, Intv_Date__c
            FROM Interview__c
            WHERE Id IN :listRecordsId
            ORDER BY Intv_Mentee__r.Name,Intv_Date__c  
        ];

        listMapInterviews = new List<Map<String, Object>>();

        for (Interview__c objInterview : listInterviews) {
            Map<String, Object> mapInterviews = new Map<String, Object>();
            mapInterviews.put('Id', objInterview.Id);
            mapInterviews.put('Name', objInterview.Intv_Name__c);
            mapInterviews.put('Intv_Training', objInterview.Intv_Training__c!=null? objInterview.Intv_Training__c:'내용 없음');
            mapInterviews.put('Intv_Work', objInterview.Intv_Work__c!=null ?objInterview.Intv_Work__c: '내용 없음');
            mapInterviews.put('Intv_Others', objInterview.Intv_Others__c!=null ?objInterview.Intv_Others__c: '내용 없음');
            mapInterviews.put('Intv_Mentor_Name', objInterview.Intv_Mentor__r.Name);
            mapInterviews.put('Intv_Mentee_Name', objInterview.Intv_Mentee__r.Name);
            mapInterviews.put('Intv_Mentor_SignaturePhotoId', objInterview.Intv_Mentor__r.SignaturePhotoId__c!=null ? objInterview.Intv_Mentor__r.SignaturePhotoId__c: '');

            

            // 날짜 변환
            if (objInterview.Intv_Date__c != null) {
                DateTime localDateTime = objInterview.Intv_Date__c.addHours(9); // 시간대 변환 (한국 표준시)
                String formattedDate = localDateTime.format('yyyy. MM. d a hh:mm', 'ko');
                mapInterviews.put('Intv_Date', formattedDate);
            } else {
                mapInterviews.put('Intv_Date', '날짜 없음');
            }

            listMapInterviews.add(mapInterviews);
        }

        //System.debug('listMapInterviews: ' + listMapInterviews);
    }

    @AuraEnabled
    public static String generatePDF(String vfPageUrl) {
        try {
            //테스트 class를 위함 (Test.isRunningTest() 활용)
            if (Test.isRunningTest()) {
                return EncodingUtil.base64Encode(Blob.valueOf('Mock PDF Content'));
            }

            PageReference pdfPage = new PageReference(vfPageUrl);
            Blob pdfBlob = pdfPage.getContentAsPDF();
            

            // Base64로 변환하여 반환
            return EncodingUtil.base64Encode(pdfBlob);

        } catch (Exception e) {
            throw new AuraHandledException('PDF 생성 실패: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean checkRecordType(String listSelectId){
        System.debug('listSeectId: '+listSelectId);

            List<String> listRecordsId=new List<String>();
            listRecordsId=listSelectId.split(',');
            System.debug('listRecordsId: '+listRecordsId);
            
            List<Interview__c> listInterviews=new List<Interview__c>();
            listInterviews=[
                SELECT RecordType.Name
                FROM Interview__c
                WHERE Id IN :listRecordsId
            ];

            for(Interview__c objInterview:listInterviews){
                if(objInterview.RecordType.Name!='IPP'){
                    return false;
                }
            }
            return true;
    }

    @AuraEnabled
    public static Boolean checkMonth(String listSelectId){
        List<String> listRecordsId=new List<String>();
            listRecordsId=listSelectId.split(',');

            // listRecordsId.add('a3lF7000000WEuIIAW');
            // listRecordsId.add('a3lF7000000WEuwIAG');
            // listRecordsId.add('a3lF7000000WEsqIAG');
            List<Interview__c> listInterviews=new List<Interview__c>();
            listInterviews=[
                SELECT Intv_Date__c 
                FROM Interview__c 
                WHERE Id IN :listRecordsId
            ];

            Integer month=listInterviews[0].Intv_Date__c.Month();
            for(Interview__c objInterview:listInterviews){
                if(month!=objInterview.Intv_Date__c.Month()){
                    // System.debug('month: '+month);
                    // System.debug('objMonth: '+objInterview.Intv_Date__c.Month());
                    return false;
                }
            }

            return true;
    }

}