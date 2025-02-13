/************************************************************************************
 * Description : 템플릿 편집하기!!!
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-07-03     hs.jung          Create
*************************************************************************************/

global with sharing class EformsignEditTemplatePageCtrl {
    public List<Id> listRecordIds { get; set; }
    public String efTemplatesJson { get; set; }
    public String errorMessage {get; set;}

    public EformsignUserInfoProvider.IUserInfoProvider tokenUser { get; set; }
    public EformsignTokenManager tokenManager { get; set; }

    public String tokenUserEmail {
        get {
            return this.tokenUser.getUserEmail();
        }
    }
    ApexPages.StandardSetController stdController;
    public EformsignEditTemplatePageCtrl(ApexPages.StandardSetController controller) {
        List<SObject> selectedRecords = controller.getSelected();

        if(selectedRecords.isEmpty()){
            errorMessage = '편집할 레코드를 선택해주세요.';
        } else if(selectedRecords.size() > 1){
            errorMessage = '하나만 선택해주세요.';
        }

        listRecordIds = new List<Id>();
        for (SObject record : selectedRecords) {
            listRecordIds.add(record.Id);
        }
        this.efTemplatesJson = JSON.serialize(getTemplate(listRecordIds));
        this.stdController = controller;
        this.tokenUser = new EformsignUserInfoProvider.RepresentativeAdminProvider();
        this.tokenManager = new EformsignTokenManager(this.tokenUser);
    }

    public String accessTokenJson { get; set; }
    public String envInfoJson { get; set; }
    public String startFieldId { get; set; }

    public void init() {
        this.accessTokenJson = this.tokenManager.getAccessTokenForEmbeddeingJson();
        this.envInfoJson = EformsignApiEnvironmentManager.getEmbadingEnvInfoJson();
        this.startFieldId = EformsignSObjectInfoService.getStartFieldId();
    }

    @RemoteAction
    public static Map<String, EformsignSObjectInfoService.ObjectInfo> getSObjectInfo(String selectedObject) {
        System.debug('selectedObject >>> ' + selectedObject);
        return EformsignSObjectInfoService.getSObjectInfo(selectedObject);
    }

    @RemoteAction
    global static EformsignTemplate__c upsertTemplate(Boolean isDeployed, Map<String, String> tamplateMap, List<Map<String, String>> fieldInofs) {
        String objectApiName = tamplateMap.get('objectApiName');
        String templateId = tamplateMap.get('templateId');
        Integer templateVersion = Integer.valueof(tamplateMap.get('templateVersion'));
        String templateName = tamplateMap.get('templateName');

        // 템플릿 생성 및 수정
        EformsignTemplate__c template = new EformsignTemplate__c();
        template.TemplateId__c = templateId;
        template.ObjectApiName__c = objectApiName;
        template.TemplateVersion__c = templateVersion;
        template.Name = templateName;

        List<EformsignTemplate__c> templates = [
                SELECT Id
                FROM EformsignTemplate__c
                WHERE
                        TemplateId__c = :templateId
                LIMIT 1
        ];
        System.debug('templates >> ' + templates);
        Boolean isEdit = !templates.isEmpty();

        // 템플릿 수정
        if (isEdit) {
            template.Id = templates[0].Id;
        }

        // 템플릿 디플로이 반영
        if (isDeployed) {
            template.DeployedTemplateVersion__c = templateVersion;
        }

        upsert template;
        System.debug('  template ::::: ' + template);
        System.debug('  isEdit ::::: ' + isEdit);

        if (isEdit && isDeployed) {
            // 수정하여 배포하였으므로 이전 필드 정보 삭제
            List<EformsignTemplateField__c> previousFields = [
                    SELECT Id
                    FROM EformsignTemplateField__c
                    WHERE EformsignTemplate__c = :template.Id
            ];

            if (!previousFields.isEmpty()) {
                delete previousFields;
            }
        }

        // 템플릿의 세일즈포스 필드 정보 저장
        List<EformsignTemplateField__c> fields = new List<EformsignTemplateField__c>();
        for (Map<String, String> field : fieldInofs) {
            fields.add(
                    new EformsignTemplateField__c(
                            EformsignTemplate__c = template.Id,
                            Name = templateName + '/' + field.get('id')
                            , TargetFieldApiName__c = field.get('id')
                            , TargetFieldType__c = field.get('type')
                    )
            );
        }

        if (!fields.isEmpty()) {
            insert fields;
        }

        return template;
    }

    @AuraEnabled
    public static Eformsigntemplate__c getTemplate(list<Id> recordId) {
        List<Eformsigntemplate__c> listTemplate = [
                SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate
                        , LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, TemplateId__c
                        , IsDeletedInEformsign__c, DeployedTemplateVersion__c, ObjectApiName__c
                        , IsDeployedF__c, TemplateVersion__c
                FROM Eformsigntemplate__c
                WHERE Id in :recordId
                ORDER BY LastModifiedDate DESC
        ];

        System.debug('listTemplate: ' + listTemplate);

        if (listTemplate.isEmpty()) {
            return null;
        }

        return listTemplate[0];
    }

}