/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-05-22     hs.jung          Create
*************************************************************************************/
global with sharing class EformsignDocumentCtrl {

    @AuraEnabled
    public static List<EformsignTemplate__c> getRelatedTemplatesBySObject(String objectApiName){
        return EformsignTemplateCtrl.getTemplatesBySObject(objectApiName);
    }

    @AuraEnabled
    public static EformsignDocument__c getDocument(Id recordId){
        return EformsignDocumentManager.getDocument(recordId);
    }

    @AuraEnabled(cacheable=true)
    public static List<EformsignDocument__c> getRelatedDocs(Id recordId) {
        List<EformsignDocument__c> efsDocList = [
                SELECT Id
                        , Name, toLabel(DocumentCurrentStatus__c)
                FROM EformsignDocument__c
                WHERE TargetObjectRecordId__c =: recordId
                ORDER BY CreatedDate DESC
        ];

        return efsDocList;
    }

    @AuraEnabled
    public static Object downloadDocument(Id recordId, Boolean hasAudit) {
        EformsignTokenizedApiWorkflow mng = new EformsignDocumentManager.Download(recordId, hasAudit);
        Object result = mng.execute();

        return result;
    }

    @AuraEnabled
    public static Object syncDocumentInfo(Id recordId) {
        EformsignTokenizedApiWorkflow mng = new EformsignDocumentManager.StatusSyncer(recordId);
        Object result = mng.execute();

        return result;
    }

    @AuraEnabled
    public static Object cancelDocument(Id recordId, String comment) {
        EformsignTokenizedApiWorkflow mng = new EformsignDocumentManager.Cancelation(recordId, comment);
        Object result = mng.execute();

        return result;
    }

    @AuraEnabled
    public static Object deleteDocument(Id recordId) {
        EformsignTokenizedApiWorkflow mng = new EformsignDocumentManager.Deletion(recordId);
        Object result = mng.execute();

        return result;
    }

    // ToDo: 사용 확인 후, 불필요 코드라면 삭제
    global class EformsignDocument{
        String id;
        String name;
        String documentCurrentStatus;
        public EformsignDocument(String id, String name, String documentCurrentStatus){
            this.id = id;
            this.name = name;
            this.documentCurrentStatus = documentCurrentStatus;
        }
    }

    /**
     * Created by MZC01-BEN on 2023-10-31.
     * 회사 멤버 정보가 포함된 Access Token으로 작성 가능한 템플릿 목록을 조회하는 API
     * 세일즈포스 개체와 결합하여 개체 상세페이지에 부착
     * Gim Check: 아직 사용하지 않는 것으로 파악
     */
    // @InvocableMethod(callout=true label='Get Available Template List')
    // public static List<String> getTemplateList(){
    //     EformsignEnvironment__c defaultConfig = EformsignApiEnvironmentManager.getInfo();
    //     HttpRequest req = new HttpRequest();
    //     req.setEndpoint(defaultConfig.ApiBaseUrl__c + '/v2.0/api/forms');
    //     req.setMethod('GET');
    //     req.setHeader('Content-Type', 'application/json');
    //     req.setHeader('Authorization', 'Bearer ' + EformsignTokenManager.getAccessToken());
    //     try {
    //         Http http = new Http();
    //         HttpResponse result = http.send(req);
    //         String responseBody = result.getBody();
    //         Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
    //         String code = (String) responseMap.get('code');
    //         EformsignWrapperTemplateForms forms = new EformsignWrapperTemplateForms(JSON.createParser(responseBody));

    //         System.debug('body: ' + responseBody);
    //         System.debug('Tot Row: ' + forms.total_rows);

    //         //이용가능한 템플릿이 없을 경우
    //         if(forms.total_rows == 0) return null;

    //         List<EformsignWrapperTemplateForms.Templates> templates = forms.templates;
    //         for(EformsignWrapperTemplateForms.Templates template : templates){
    //             System.debug('template Id: ' + template.form_id);
    //             System.debug('template name: ' + template.name +'\n');
    //         }


    //         if (String.isNotEmpty(code) && code == '4010002') {
    //             //result = requestNewToken();
    //         }
    //     } catch (Exception e) {
    //         System.debug('Error: ' + e.getMessage());
    //     }
    //     return null;
    // }
}