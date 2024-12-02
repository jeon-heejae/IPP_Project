public with sharing class SendEmailController {
    
    @AuraEnabled
    public static Map<String,List<Object>> getObject(Id OfflineClassId){
        
        try {
            //String OfflineClassId='a00NS00000FT7dOYAT';
            //화상강의 선생님
            OfflineClass__c objOfflineClass = [SELECT Teacher__c from OfflineClass__c where Id = :OfflineClassId];
            //선생님 수업듣는 학생이름, 부모님 이메일
            List<Contact> listContact = [SELECT LastName, Parent__r.Email__c FROM Contact where Teacher__c = :objOfflineClass.Teacher__c];
    
            
            Map<String,List<Object>> mapResult=new Map<String,List<Object>>();
            List<Contact> listStudentName=new List<Contact>();
            List<String> listEmail=new List<String>();
            for(Contact con : listContact){
                if(con.Parent__c != null && con.Parent__r.Email__c != null){
                    listEmail.add(con.Parent__r.Email__c);
                }
                listStudentName.add(con);
            }
            mapResult.put('Email',listEmail);
            mapResult.put('Name',listStudentName);
            //학생이름에 따른 레벨 변경
            List<ContactLevelChange__c> listLevel=[SELECT Description__c, NewLevel__c, OriginalLevel__c, Subject__c,ChangeTarget__c
            From ContactLevelChange__c
            WHERE ChangeTarget__c= :listStudentName];
            mapResult.put('Change',listLevel);
           
            System.debug('mapResult: ' + mapResult);
            
            return mapResult;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void sendEmailWithAttachment(Id recordId, List<String> toAddress, List<Contact> students, List<ContactLevelChange__c> levelChanges) {
        try {
            // 이번 달의 설문조사 링크 가져오기
            String surveyUrl = getSurveyUrl();
            System.debug('URL: '+ surveyUrl);
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            
            System.debug('Email: '+ toAddress.size()+ ' '+ toAddress);
            System.debug('students: '+ students.size()+ ' '+ students);
            System.debug('levelChanges: '+ levelChanges.size()+ ' '+ levelChanges);
            
            for (Integer i = 0; i < toAddress.size(); i++) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                
                System.debug('Email: '+toAddress[i]);
                // 수신자 설정
                email.setToAddresses(new List<String>{toAddress[i]});
            
                // 제목 설정
                String month=String.valueOf(System.today().month());
                System.debug(month);
                email.setSubject(month+ '월 화상강의 종료 안내문');
            
                
                // 개인화된 본문 생성
                String body = '안녕하세요, '+ students[i].LastName+ ' 부모님\n';
                body+='화상강의 종료 후 수업자료 전송해드립니다. \n\n';
                
                Boolean hasLevelChanges = false;
                String levelChangeContent = '';
                String previousSubject = '';
                Boolean isFirstSubject = true;

                for (ContactLevelChange__c change : levelChanges) {
                    System.debug('Student: ' + students[i]);
                    System.debug('change: ' + change);
                    if (change.ChangeTarget__c == students[i].Id) {
                        hasLevelChanges = true;
                        
                        // 과목이 변경되었을 때 구분선 추가
                        if (change.Subject__c != previousSubject) {
                            if (!isFirstSubject) {
                                levelChangeContent += '---------------------------------------------------------------------\n\n';
                            }
                            isFirstSubject = false;
                            previousSubject = change.Subject__c;
                        }

                        levelChangeContent += '과목: ' + change.Subject__c + '\n';
                        levelChangeContent += '기존 레벨: ' + change.OriginalLevel__c + '\n';
                        levelChangeContent += '새 레벨: ' + change.NewLevel__c + '\n';
                        levelChangeContent += '선생님의 한마디: ' + change.Description__c + '\n\n';
                    }
                }

                if (hasLevelChanges) {
                    body += students[i].LastName + ' 학생의 레벨 변경 사항을 알려드립니다.\n\n';
                    body += levelChangeContent;
                }
                
                body += '이번달 설문조사 링크입니다. 설문에 참여해 주시기 바랍니다!\n' + surveyUrl + '\n\n';
                body += '감사합니다.';
                
                email.setPlainTextBody(body);
                
                // 첨부 파일 추가
                List<Messaging.EmailFileAttachment> attachments = getAttachments(recordId);
                if (!attachments.isEmpty()) {
                    email.setFileAttachments(attachments);
                }
                
                emails.add(email);
            }
            
            if (!emails.isEmpty()) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
                System.debug('result: '+emails);
                for (Messaging.SendEmailResult result : results) {
                    if (!result.isSuccess()) {
                        Messaging.SendEmailError[] errors = result.getErrors();
                        String errorMessage = '';
                        for (Messaging.SendEmailError error : errors) {
                            errorMessage += error.getMessage() + '\n';
                        }
                        throw new AuraHandledException(errorMessage);
                    }
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('이메일 전송 중 오류가 발생했습니다: ' + e.getMessage());
        }
    }
    
    public static String getSurveyUrl() {
        Integer currentMonth = System.today().month();
        String queryCondition = '%' + currentMonth + '%';
        List<ArdiraSurvey__Survey__c> surveys = [SELECT ArdiraSurvey__Community_Response_URL__c
                                                 FROM ArdiraSurvey__Survey__c
                                                 WHERE Name LIKE :queryCondition
                                                 LIMIT 1];
        return !surveys.isEmpty() ? surveys[0].ArdiraSurvey__Community_Response_URL__c : '';
    }
    
    public static List<Messaging.EmailFileAttachment> getAttachments(Id recordId) {
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        
        List<ContentDocumentLink> links = [SELECT ContentDocumentId 
                                           FROM ContentDocumentLink 
                                           WHERE LinkedEntityId = :recordId];
        
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink link : links) {
            contentDocumentIds.add(link.ContentDocumentId);
        }
        
        List<ContentVersion> versions = [SELECT Title, FileExtension, VersionData, ContentSize
                                         FROM ContentVersion 
                                         WHERE ContentDocumentId IN :contentDocumentIds
                                         AND Title LIKE '%전송용%'];
        
        for (ContentVersion version : versions) {
            if (version.ContentSize <= 5000000) { // 5MB 이하
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName(version.Title + '.' + version.FileExtension);
                attachment.setBody(version.VersionData);
                attachments.add(attachment);
            }
        }
        
        return attachments;
    }

    @AuraEnabled
public static String doSavePdf(String strRecordId) {
    String result = '';
    String vfPageUrl = '';

    try {
        // 기존 PDF 파일 확인
        List<ContentDocumentLink> existingDocs = [
            SELECT ContentDocument.Title, ContentDocument.FileType
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :strRecordId
            AND ContentDocument.FileType = 'PDF'
            AND ContentDocument.Title = '(전송용)화상강의 안내문'
        ];

        if (!existingDocs.isEmpty()) {
            // 이미 PDF가 존재하는 경우
            result = 'already_exists';
        } else {
            // PDF가 없는 경우, 새로 생성
            vfPageUrl = '/apex/PdfTemplet?recordId=' + strRecordId;
            PageReference templatePageReference = new PageReference(vfPageUrl);

            Blob templateBLOB;
            if (Test.isRunningTest()) {
                templateBLOB = Blob.valueOf('Unit test');
            } else {
                templateBLOB = templatePageReference.getContentAsPDF();
            }

            ContentVersion objContentVersion = new ContentVersion();
            objContentVersion.Title = '(전송용)화상강의 안내문';
            objContentVersion.VersionData = templateBLOB;
            objContentVersion.PathOnClient = 'sample.pdf';
            objContentVersion.FirstPublishLocationId = strRecordId;

            insert objContentVersion;

            result = 'success';
        }
    } catch(Exception e) {
        System.debug('Error line : ' + e.getLineNumber());
        System.debug('Error message : ' + e.getMessage());
        System.debug('Error cause : ' + e.getCause());
        result = 'error: ' + e.getMessage();
    }

    System.debug('result: '+ result);
    return result;
}
}