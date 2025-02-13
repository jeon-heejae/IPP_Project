/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-05-28     hs.jung          Create
*************************************************************************************/
public with sharing class EformsignDocumentManager {

    public static EformsignDocument__c getDocument(Id recordId) {
        List<EformsignDocument__c> documents = [
                SELECT Id
                        , Name
                        , DocumentId__c
                        , EformsignTemplate__r.TemplateId__c
                        , DocumentCurrentStatus__c
                FROM EformsignDocument__c
                WHERE Id = :recordId
        ];

        System.debug('documents: ' + documents);

        if (documents.isEmpty()) {
            return null;
        }

        return documents[0];
    }

    public abstract class DocumentWork extends EformsignTokenizedApiWorkflow {
        protected override EformsignUserInfoProvider.IUserInfoProvider createUserInfo() {
            return new EformsignUserInfoProvider.CurrentUserProvider();
        }
    }

    public abstract class DocumentAdminWork extends EformsignTokenizedApiWorkflow {
        protected override EformsignUserInfoProvider.IUserInfoProvider createUserInfo() {
            return new EformsignUserInfoProvider.RepresentativeAdminProvider();
        }
    }

    public static Map<String, String> getPicklistValues(String objectName, String fieldName) {
        Map<String, String> picklistMap = new Map<String, String>();
        try {
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            if (objectType == null) return picklistMap;

            Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
            Schema.sObjectField picklistField = fieldMap.get(fieldName);
            if (picklistField == null) return picklistMap;

            Schema.DescribeFieldResult fieldDescribe = picklistField.getDescribe();

            for (Schema.PicklistEntry p : fieldDescribe.getPicklistValues()) {
                picklistMap.put(p.getValue(), p.getLabel());
            }
        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
        }

        return picklistMap;
    }


    public class Download extends DocumentWork {
        EformsignDocument__c efsDocument;
        private final String fileName;
        private final Boolean hasAuthFile;

        public Download(Id recordId, Boolean hasAuthFile) {
            this.efsDocument = getDocument(recordId);

            Map<String, String> picklistMap = new Map<String, String>();
            /* Utilities =>  DN_Util */
            picklistMap = getPicklistValues('EformsignDocument__c', 'DocumentCurrentStatus__c');
            this.fileName = efsDocument.Name + '[' + picklistMap.get(efsDocument.DocumentCurrentStatus__c) + ']';

            this.hasAuthFile = hasAuthFile;
        }

        @TestVisible
        protected override HttpResponse sendRequest() {
            Http http = new Http();
            HttpRequest req = this.requestBuilder.getDocumentDownloadRequest(this.efsDocument.DocumentId__c, this.fileName, this.hasAuthFile);
            HttpResponse result = http.send(req);

            return result;
        }

        protected override Boolean shouldExecuteDatabaseLogic() {
            if (this.response.getStatusCode() != 200) {
                //Exception Handling - Response from target server.
                return false;
            }

            return true;
        }

        protected override void databaseLogic() {
            Blob responseBody = this.response.getBodyAsBlob();
            String extension = '.' + this.response.getHeader('Content-Type').split(';')[0].split('/')[1];
            System.debug(this.response.getHeader('Content-Type').split(';')[0].split('/'));
//            System.debug(this.response.getHeader('Content-Disposition').split('filename=')[1].replaceAll('"', '').replace(';', ''));

            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S';
            conVer.PathOnClient = this.fileName + extension;
            conVer.Title = this.fileName;
            conVer.VersionData = responseBody;
            insert conVer;
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :conVer.Id].ContentDocumentId;
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = this.efsDocument.Id;
            conDocLink.ContentDocumentId = conDoc;
            conDocLink.shareType = 'V';
            insert conDocLink;

            this.result = this.result.success(conDoc);
        }
    }

    public class StatusSyncer extends DocumentWork {
        EformsignDocument__c efsDocument;

        public StatusSyncer(Id recordId) {
            this.efsDocument = getDocument(recordId);
        }


        protected override HttpResponse sendRequest() {
            Http http = new Http();
            HttpRequest req = this.requestBuilder.getDocumentInfoRequest(this.efsDocument.DocumentId__c);
            HttpResponse result = http.send(req);

            return result;
        }

        protected override Boolean shouldExecuteDatabaseLogic() {
            if (this.response.getStatusCode() != 200) {
                //Exception Handling - Response from target server.
                return false;
            }

            return true;
        }
        @TestVisible
        protected override void databaseLogic() {
            EformsignWrapperDocumentInfo wrapper = new EformsignWrapperDocumentInfo(JSON.createParser(this.response.getBody()));

            //문서 현재상태 - 필드매핑부
            System.debug('efsDocuInfo: ' + wrapper);
            this.efsDocument.DocumentCurrentStatus__c = wrapper.current_status.status_type;

            update this.efsDocument;

            //히스토리 레코드 생성부
            // if(wrapper.histories.size() > 0){
            List<Event> histories = new List<Event>();
//            Id recordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('EformsignDocumentHistory').getRecordTypeId();
            Id recordId = this.efsDocument.Id;
            for (EformsignWrapperDocumentInfo.Histories history : wrapper.histories) {
                System.debug('===  history: ' + history);
                Event efsDocHistory = new Event();
                DateTime executedDate = DateTime.newInstance(history.executed_date);

                //Required Fields
                efsDocHistory.Subject = wrapper.document_name + '_' + String.valueOf(executedDate);
                efsDocHistory.eformsign_DocHistory_ExternalKey__c = wrapper.id + history.executed_date;
                efsDocHistory.StartDateTime = executedDate;
                efsDocHistory.EndDateTime = executedDate;
                /* 필드매핑 임시 주석 hs.jung */
//                efsDocHistory.RecordTypeId = recordTypeId;
                efsDocHistory.WhatId = String.valueOf( recordId);
                efsDocHistory.Recipient__c = history.executor.name;
                efsDocHistory.RecipientId__c = history.executor.id;
                efsDocHistory.DocumentCurrentStatus__c = history.action_type;
                efsDocHistory.Description = history.comment;
                //이외 필드 매핑
                //executor
                //recipient
                //id or name

                histories.add(efsDocHistory);
            }

            if (histories.size() > 0) {
                System.debug( ' upsert? ');
                upsert histories eformsign_DocHistory_ExternalKey__c;
            }
            // }

            this.result = this.result.success(this.efsDocument);
        }
    }

    public class Cancelation extends DocumentAdminWork {
        EformsignDocument__c efsDocument;
        List<String> recordIds;
        String comment;
        List<Object> successResult;
        List<Object> failResult;

        public Cancelation(Id recordId, String comment) {
            this.efsDocument = getDocument(recordId);
            this.recordIds = new List<String>{
                    this.efsDocument.DocumentId__c
            };

            if (String.isBlank(comment)) {
                this.comment = '';
            } else {
                this.comment = comment;
            }
        }

        protected override HttpResponse sendRequest() {
            Map<String, Object> input = new Map<String, Object>{
                    'document_ids' => this.recordIds
                    , 'comment' => this.comment
            };

            Map<String, Object> wrapper = new Map<String, Object>{
                    'input' => input
            };

            HttpRequest req = this.requestBuilder.getDocumentCancelRequest();
            req.setBody(JSON.serialize(wrapper));

            Http http = new Http();
            HttpResponse result = http.send(req);
            System.debug('result.getBody() >>> ' + result.getBody());
            // JSON 문자열을 Map으로 파싱
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(result.getBody());
            System.debug('parsed: ' + parsed);

            // 'result' 객체 추출 후, 'success_result' 및 'fail_result' 추출
            Map<String, Object> parsedResult = (Map<String, Object>) parsed.get('result');
            System.debug('parsedResult: ' + parsedResult);

            // 성공: eformsign 문서Id 반환
            this.successResult = (List<Object>) parsedResult.get('success_result');
            System.debug('Success Result: ' + successResult);

            // 실패: eformsign 문서Id, code, message 반환
            this.failResult = (List<Object>) parsedResult.get('fail_result');
            System.debug('Fail Result: ' + failResult);

            return result;
        }

        protected override Boolean shouldExecuteDatabaseLogic() {
            System.debug('this.response.getStatusCode(): ' + this.response.getStatusCode());

            // 문서 취소가 실패해도 getStatusCode()가 200인 경우도 있음. 예) "code": "4000166"
            if (this.response.getStatusCode() != 200) {
                this.result = this.result.failure('networkErorr');
                return false;
            } else if (!this.failResult.isEmpty()) {
                return false;
            }

            // 이미 취소된 문서는 문서 동기화 안내 후 진행
            // Map<String, Object> failResultMap = (Map<String, Object>) this.failResult[0];
            // if ((String) failResultMap.get('code') != '4000166') {
            //     return false;
            // }

            return true;
        }

        @TestVisible
        protected override void databaseLogic() {
            final String canceledStatus = '042';  // 문서 취소
            this.efsDocument.DocumentCurrentStatus__c = canceledStatus;
            System.debug('this.efsDocument.DocumentCurrentStatus__c: ' + this.efsDocument.DocumentCurrentStatus__c);

            update this.efsDocument;
        }
    }

    public class Deletion extends DocumentAdminWork {
        EformsignDocument__c efsDocument;

        public Deletion(Id recordId) {
            this.efsDocument = getDocument(recordId);
        }

        protected override HttpResponse sendRequest() {
            HttpRequest req = this.requestBuilder.getDocumentDeleteRequest();
            List<String> input = new List<String>{
                    this.efsDocument.DocumentId__c
            };
            Map<String, Object> wrapper = new Map<String, Object>{
                    'document_ids' => input
            };

            req.setBody(JSON.serialize(wrapper));

            Http http = new Http();
            HttpResponse result = http.send(req);

            return result;
        }

        protected override Boolean shouldExecuteDatabaseLogic() {
            // JSON 문자열을 Map으로 파싱
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(this.response.getBody());
            System.debug('parsed: ' + parsed);

            String code = (String) parsed.get('code');
            String errorMessage = (String) parsed.get('ErrorMessage');

            // "code": "4000004",
            // "ErrorMessage": "No document selected."
            if (this.response.getStatusCode() != 200) {
                this.result = this.result.failure(errorMessage);
                return false;
            }

            // ToDo: 없는 문서는 안내 후, 문서 동기화 진행?
            // if (code == '4000004') {
            //     ;
            // }

            return true;
        }

        protected override void databaseLogic() {
            final String newStatus = '049';// 문서 삭제
            this.efsDocument.DocumentCurrentStatus__c = newStatus;
            this.efsDocument.IsDeletedInEformsign__c = true;

            update this.efsDocument;
        }
    }
}