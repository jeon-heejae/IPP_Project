/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-05-22     hs.jung          Create
*************************************************************************************/
global with sharing class EformsignDocumentPageCtrl {
    public EformsignUserInfoProvider.IUserInfoProvider tokenUser {get; set;}
    public EformsignTokenManager tokenManager {get; set;}

    public String tokenUserEmail {
        get {
            return this.tokenUser.getUserEmail();
        }
    }

    public String accessTokenJson {get; set;}
    public String envInfoJson {get; set;}
    public String startFieldId {get; set;}
    public String serializedSObjList {get; set;}

    public Map<String, List<EformsignSObjectInfoService.ObjectInfo>> sObjectInfos {get; set;}
    private class FieldValMappingWrap{
        String id;
        Object value;
        Boolean enabled;
        Boolean required;
        private FieldValMappingWrap(String fieldId, Object value){
            this.id = fieldId;
            this.value = value;
            this.enabled = true;
            this.required = true;
        }
    }

    public EformsignDocumentPageCtrl() {
        this.tokenUser = new EformsignUserInfoProvider.CurrentUserProvider();
        this.tokenManager = new EformsignTokenManager(this.tokenUser);
    }

    public void init() {
        this.accessTokenJson = this.tokenManager.getAccessTokenForEmbeddeingJson();
        System.debug('accessTokenJson: ' + this.accessTokenJson);
        this.envInfoJson = EformsignApiEnvironmentManager.getEmbadingEnvInfoJson();
        this.startFieldId = EformsignSObjectInfoService.getStartFieldId();

        String documentId = ApexPages.currentPage().getParameters().get('documentId');
        String recId = ApexPages.currentPage().getParameters().get('recordId');
        String objectApiName = ApexPages.currentPage().getParameters().get('objectApiName');
        String templateRecordId = ApexPages.currentPage().getParameters().get('templateRecordId');
        System.debug('recId: ' + recId);
        System.debug('objectApiName: ' + objectApiName);
        System.debug('templateRecordId: ' + templateRecordId);
        System.debug('documentId: ' + documentId);

        // 매핑 필드 저장용 리스트
        List<FieldValMappingWrap> sObjList = new List<FieldValMappingWrap>();
        serializedSObjList = JSON.serialize(sObjList);

        // documentId 존재 시, 필드 매핑 없이 문서 미리보기로 진행
        if(String.isNotEmpty(documentId)) {
            return;
        }

        /* queryString - Template Mapping 필드를 통해 바인딩된 개체의 필드값 취득 로직 작성 필요.
        * 1. Template Field Mapping 테이블 구성
        * 2. 하기 Database.query용 필드 바인딩
        * ToDo. LookUp관계
        * */

        // 템플릿 작성용으로 저장된 필드API명 리스트 취득
        List<EformsignTemplateField__c> fieldMappingList = [
                SELECT Id
                        , TargetFieldApiName__c
                        , TargetFieldType__c
                FROM EformsignTemplateField__c
                WHERE EformsignTemplate__c =: templateRecordId
        ];
        System.debug( 'fieldMappingList>>> ' + fieldMappingList);
        // 필드 매핑에 필요한 필드명 추출
        List<String> fieldNameList = new List<String>();
        for(EformsignTemplateField__c fieldMapping : fieldMappingList){
            /* Utilities =>  DN_Util */
            if(DN_Util.isExistField(objectApiName, fieldMapping.TargetFieldApiName__c)) {
                fieldNameList.add(fieldMapping.TargetFieldApiName__c);
            }
        }

        // 매핑용 필드가 없으면, 종료
        if (fieldNameList.size() == 0) {
            return;
        }

        //실제 데이터 쿼리
        String tarObjQueryStr = 'SELECT ' + String.join(fieldNameList,', ') +
                                ' FROM ' + objectApiName +
                                ' WHERE Id =: recId';
        System.debug( 'tarObjQueryStr >>>> ' + tarObjQueryStr);
        SObject sobj = Database.query(tarObjQueryStr);

        //prefill 양식에 맞게 포맷팅
        for(String fieldApiName : fieldNameList){
            Object valDB = sobj.get(fieldApiName);
            Object val = sobj.get(fieldApiName);
            if (val == null) {
                continue;
            }

            String type = EformsignSObjectInfoService.getFieldType(objectApiName, fieldApiName);
            if (type == 'DateTime') {
                val = ((DateTime) val).format();
            } else if (type == 'Date') {
                val = ((Date) val).format();
            } else if (type == 'Time') {
                Datetime datetimeWithTime = Datetime.newInstance(Date.today(), (Time) val);
                // 사용자의 시간대 및 로케일에 맞게 시간만 포맷팅
                val = datetimeWithTime.format('HH:mm');
            } else if (
                    type == 'CURRENCY'
                    || type == 'Double'
                    || type == 'Integer'
                    || type == 'Long'
            ) {
                val = ((Decimal) val).format();
            } else if (type == 'Percent') {
                val = ((Decimal) val).format() + '%';
            } else {
                String valStr = (String) val;
                val = valStr.replace('\n', '\\n').replace('\r', '\\r');
            }

            sObjList.add(
                    new FieldValMappingWrap(this.startFieldId + fieldApiName, val)
            );
        }
        serializedSObjList = JSON.serialize(sObjList);
    }

    //문서 작성 후 SFDC 레코드 저장 메소드
    @RemoteAction
    global static String insertDocumentId(String response, STring templateRecordId, String recordId, String objectApiName) {
        // 로직 구현
        String result = 'success';
        try{
            System.debug('record: ' + response);
            Efs_DocResultWrapper docResult = Efs_DocResultWrapper.parse(response);
            System.debug('recordId: ' + recordId);
            System.debug('objectApiName: ' + objectApiName);
            System.debug('templateRecordId: ' + templateRecordId);
            EformsignDocument__c efsDoc = new EformsignDocument__c(Name = docResult.title + '[' + objectApiName + ']',
                    DocumentId__c =docResult.document_id,
                    TargetObjectRecordId__c = recordId,
                    EformsignTemplate__c = Id.valueOf(templateRecordId),
                   DocumentCurrentStatus__c = '001', // to-do : picklist 종류?
                    /* Utilities =>  DN_Util */
                    TargetRecordURL__c = DN_Util.getLightningURL()+'/lightning/r/'+recordId+'/view',
                    ObjectName__c = objectApiName);

            System.debug('저장된 문서 레코드: ' + efsDoc);
            Database.SaveResult saveResult = Database.insert(efsDoc);
            result = saveResult.isSuccess() ? result : 'error';
        }catch (Exception e){
            System.debug('Error: ' + e);
            System.debug('Line[' + e.getLineNumber() + ']: ' + e.getMessage());
            result = 'error';
        }
        return result;
    }
}