public with sharing class SendEmailController {
    
    @AuraEnabled
    public static List<String> getParentEmail(Id OfflineClassId){
        try {
            OfflineClass__c objOfflineClass = [SELECT Teacher__c from OfflineClass__c where Id = :OfflineClassId];
            
            List<Contact> listContact = [SELECT Parent__r.Email__c FROM Contact where Teacher__c = :objOfflineClass.Teacher__c];
    
            List<String> listParentEmail = new List<String>();
            for(Contact con : listContact){
                if(con.Parent__c != null && con.Parent__r.Email__c != null){
                    listParentEmail.add(con.Parent__r.Email__c);
                }
            }
    
            System.debug('listParentEmail: ' + listParentEmail);
            
            return listParentEmail;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void sendEmailWithAttachment(Id recordId, List<String> toAddress, String subject, String body){

            // Id recordId='a00NS00000FPDuIYAX';
            // List<String> toAddress=new List<String>();
            // toAddress.add('heejae.jeon@daeunextier.com');
            // toAddress.add('kebkbssmart@naver.com');
            // String subject='통신문';
            // String body='감사합니다';

            //이번달의 설문조사 링크 가져오기
            Integer Month=System.today().month();
            String queryCondition='%'+Integer.valueOf(Month)+'%';
            List<ArdiraSurvey__Survey__c> listUrl=[SELECT ArdiraSurvey__Community_Response_URL__c
            from ArdiraSurvey__Survey__c
            where Name like :queryCondition];
            //System.debug('listUrl: '+listUrl);

            String surveyUrl='';
            if(!listUrl.isEmpty()){
                surveyUrl=listUrl[0].ArdiraSurvey__Community_Response_URL__c;
            }
            System.debug('url: '+surveyUrl);

            body+='\n\n'+'이번달 설문조사링크입니다.설문부탁드려요!\n'+surveyUrl;


            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            // 수신자 이메일 주소 설정
            mail.setToAddresses(toAddress);
            //
            // List<String> listMock = new List<String>();
            // listMock.add('test@test.com');
            // mail.setCcAddresses(listMock);
            // mail.setBccAddresses(listMock);
            
            // 이메일 제목 설정
            mail.setSubject(subject);
            
            // 이메일 본문 설정
            mail.setPlainTextBody(body);

            //첨부파일 id검색
            List<String> contentVersionIds = new List<String>();
            for (ContentDocumentLink cdl : [
                SELECT ContentDocumentId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :recordId
            ]) {
                contentVersionIds.add(cdl.ContentDocumentId);
            }
            System.debug('listId: '+ contentVersionIds);

            List<Messaging.EmailFileAttachment> attachList = new List<Messaging.EmailFileAttachment>();

            //첨부파일 검색
            for (ContentVersion cv : [
                SELECT Title, FileExtension, VersionData, ContentSize
                FROM ContentVersion WHERE ContentDocumentId IN :contentVersionIds
                AND Title like '%전송용%'
            ]) {
                if (cv.ContentSize <= 5000000 ) { // 5MB 이하
                    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                    attach.setFilename(cv.Title + '.' + cv.FileExtension);
                    attach.setBody(cv.VersionData);
                    attachList.add(attach);
                    System.debug('cv:' +cv);
                }
                System.debug('Else(cv):' +cv);
            }
    
            System.debug('attachList: '+attachList);


            //PDF 파일 첨부
            mail.setFileAttachments(attachList);

            // System.debug('Remaining email invocations: ' + Limits.getEmailInvocations());
            // System.debug('Email invocations limit: ' + Limits.getLimitEmailInvocations());
            
            
            // 이메일 전송
            Messaging.SendEmailResult[] result = 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

            
            if (!result[0].isSuccess()) {
                Messaging.SendEmailError[] errors = result[0].getErrors();
                String message = '';

                for (Messaging.SendEmailError err : errors) {
                    message += err.getMessage() + '\n';
                }

                throw new AuraHandledException(message);
            }
    }

    @AuraEnabled
    public static String doSavePdf(String strRecordId) {
    String result = '';
    String vfPageUrl = '';
   
    try{
        vfPageUrl = '/apex/PdfTemplet?recordId=' + strRecordId;
        PageReference templatePageReference = new PageReference(vfPageUrl);
   
        Blob templateBLOB;
        if (Test.isRunningTest()){
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
        
        objContentVersion.Title                     = '(전송용)화상강의 안내문';
        objContentVersion.VersionData               = templateBLOB;
        objContentVersion.PathOnClient              = 'sample.pdf';
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