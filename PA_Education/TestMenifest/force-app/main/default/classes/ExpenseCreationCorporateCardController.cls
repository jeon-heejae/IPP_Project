/**
 * Created by Kwanwoo.Jeon on 2024-01-04.
 */

public without sharing class ExpenseCreationCorporateCardController {
    public static List<Map<String, String>> getPicklistValue(String objectAPIName, String fieldName) {
        List<Map<String, String>> options = new List<Map<String, String>>();

        Schema.SObjectType sobject_type = Schema.getGlobalDescribe().get(objectAPIName);
        Schema.DescribeSObjectResult sobjectDescribe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();

        List<Schema.PicklistEntry> pickListValues = fieldMap.get(fieldName).getDescribe().getPicklistValues();

        for (Schema.PicklistEntry pickListEntry : pickListValues) {
            if (pickListEntry.isActive()) {
                options.add(new Map<String, String>{
                        'value'     => pickListEntry.getValue(),
                        'label' => pickListEntry.getLabel(),
                        'default' => String.valueOf(pickListEntry.isDefaultValue())
                });
            }
        }
        return options;
    }

    //Field Label 갖고오는 Map Container
    @AuraEnabled
    public static Map<String, String> getObjectFieldLabel(String sObjectName){
        Schema.SObjectType schemaObject = Schema.getGlobalDescribe().get(sObjectName);
        Schema.DescribeSObjectResult schemaObjectResult = schemaObject.getDescribe();
        Map<String, Schema.SObjectField> mapSchemaObjectResult = schemaObjectResult.fields.getMap();

        Map<String, String> mapFieldLabel = new Map<String, String>();
        for(Schema.SObjectField obj : mapSchemaObjectResult.values()){
            Schema.DescribeFieldResult f = mapSchemaObjectResult.get(obj.getDescribe().getName()).getDescribe();
            mapFieldLabel.put(f.getName(), f.getLabel());
        }
        return mapFieldLabel;
    }

    @AuraEnabled
    public static Map<String, Object> getInitData(Id expId){
        //경비신청 레코드 조회
        Expense__c objExpense = new Expense__c();
        if(expId != null){
            objExpense = [
                    SELECT Id, Name, Submit_Date__c, FirstExpenseRequest__c, FirstExpenseRequest__r.Name,
                           SecondApproverSelection__c, UseYear__c, UseMonth__c, Project__c, Project__r.Name,
                           BudgetType__c
                    FROM   Expense__c
                    WHERE  Id =: expId
            ];
        }

        List<Map<String, Object>> listExpDetail = new List<Map<String, Object>>();
        if(expId != null){
            // 경비신청 상세 조회
            for (ExpenseDetail__c obj : [
                    SELECT  Id, Name, Date__c, Category2__c, Amount__c, Description__c, Project_Name__c, Project_Name__r.Name,
                            Opportunity_Name__c, Opportunity_Name__r.Name, Expense__c, CardCompany__c, StoreName__c, BusinessType__c,
                            StoreAddress__c, BillingAmount__c, CorporateCardBilling__c, SalesType__c, Lead__c, Lead__r.Name,
                            PriorExpenseApplication__c, PriorExpenseApplication__r.Name, CorporateCardBilling__r.fm_CardNickname__c
                    FROM    ExpenseDetail__c
                    WHERE   Expense__c =: expId
                    ORDER BY Date__c, Category2__c
            ]) {
                Map<String, Object> mapObject = new Map<String, Object>();
                mapObject.put('Id',                                 obj.Id);
                mapObject.put('Name',                               obj.Name);
                mapObject.put('Dt',                                 String.valueOf(obj.Date__c));
                mapObject.put('Category2',                          obj.Category2__c);
                mapObject.put('Amount',                             obj.Amount__c);
                mapObject.put('Description',                        obj.Description__c);
                mapObject.put('ProjectNameId',                      obj.Project_Name__c);
                mapObject.put('ProjectName',                        obj.Project_Name__r.Name);
                mapObject.put('OpportunityNameId',                  obj.Opportunity_Name__c);
                mapObject.put('OpportunityName',                    obj.Opportunity_Name__r.Name);
                mapObject.put('Expense',                            obj.Expense__c);
                mapObject.put('CardCompany',                        obj.CardCompany__c);
                mapObject.put('StoreName',                          obj.StoreName__c);
                mapObject.put('BusinessType',                       obj.BusinessType__c);
                mapObject.put('StoreAddress',                       obj.StoreAddress__c);
                mapObject.put('BillingAmount',                      obj.BillingAmount__c);
                mapObject.put('CorporateCardBilling',               obj.CorporateCardBilling__c);
                mapObject.put('SalesType',                          obj.SalesType__c);
                mapObject.put('Lead',                               obj.Lead__c);
                mapObject.put('LeadName',                           obj.Lead__r.Name);
                mapObject.put('PriorExpenseApplication',            obj.PriorExpenseApplication__c);
                mapObject.put('PriorExpenseApplicationName',        obj.PriorExpenseApplication__r.Name);
                mapObject.put('CorporateCardNickName',              obj.CorporateCardBilling__r.fm_CardNickname__c);

                listExpDetail.add(mapObject);
            }
        }

        //24.11.01 kc - 경비신청 생성 - 사용목적 default 값 : 프로젝트 - 로 설정을 위한 조건
        //mapReturnValue 에 PerformProject 추가
        List<PerformProject__c> listPerformProject= new List<PerformProject__c>();
        if(expId == null){
            listPerformProject = [
                    SELECT Id, Name, Project__r.Id, Project__r.Name, InputDate__c, WithdrawDate__c
                    FROM   PerformProject__c
                    WHERE  Employee__r.User__r.Id = :UserInfo.getUserId()
                    AND    WithdrawDate__c >= : Date.today().toStartOfMonth().addMonths(-1)
                    AND    InputDate__c < : Date.today().toStartOfMonth()
                    ORDER BY InputDate__c
            ];
        }
        //

        List<Map<String, String>> picklistBudgetType = getPicklistValue('Expense__c', 'BudgetType__c');
        String userBudgetType = [SELECT BudgetType__c FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1].BudgetType__c;

        if (userBudgetType != null) {
            List<String> listUserBT = userBudgetType .split(';');
            for(Integer i = 0; i < picklistBudgetType.size(); i++){
                if (!listUserBT.contains(picklistBudgetType[i].get('value'))) {
                    picklistBudgetType.remove(i);
                    i--;
                }
            }
        }else{
            picklistBudgetType = new List<Map<String, String>>();
        }

        Map<String, Object> mapReturnValue = new Map<String, Object>{
                'Expense'            => objExpense,
                'ExpenseDetail'      => listExpDetail,
                'PerformProject'     => listPerformProject,
                'PicklistYear'       => getPicklistValue('Expense__c', 'UseYear__c'),
                'PicklistMonth'      => getPicklistValue('Expense__c', 'UseMonth__c'),
                'PicklistBudgetType' => picklistBudgetType,
                'PicklistSalesType'  => getPicklistValue('ExpenseDetail__c', 'SalesType__c'),
                'PicklistCategory1'  => getPicklistValue('ExpenseDetail__c', 'Category1__c'),
                'PicklistCategory2'  => getPicklistValue('ExpenseDetail__c', 'Category2__c'),
                'PicklistPayment'    => getPicklistValue('ExpenseDetail__c', 'Payment_Type__c')
        };

        System.debug('mapReturnValue : ' + mapReturnValue);
        return mapReturnValue;
    }

    @AuraEnabled
    public static String doSave(Expense__c objExp, List<Object> listExpDetail, List<Id> listDel) {
        List<ExpenseDetail__c> listExpDetailTemp = new List<ExpenseDetail__c>();

        //24.01.10 예산 오브젝트 연결로 인해 경비신청 오브젝트에 예산 오브젝트 연결
        List<Budget__c> listBudget =
                objExp.BudgetType__c == '프로젝트' ?
                        [
                                SELECT Id, fm_RemainingAmount__c, Project__r.Contract__c, Project__r.Contract__r.IsContract__c
                                FROM    Budget__c
                                WHERE   BudgetType__c = :objExp.BudgetType__c
                                AND     Project__c =: objExp.Project__c
                                AND     fm_ActiveStatus__c = TRUE
                                LIMIT   1
                        ] :
                        [
                                SELECT Id, fm_RemainingAmount__c
                                FROM    Budget__c
                                WHERE   BudgetType__c = :objExp.BudgetType__c
                                AND     fm_ActiveStatus__c = TRUE
                                LIMIT   1
                        ];

        if (!listBudget.isEmpty()) {
            if (listBudget.get(0).fm_RemainingAmount__c < objExp.TotalAmount__c ) {
                if (objExp.BudgetType__c == '프로젝트' && listBudget.get(0).Project__r.Contract__c != null && listBudget.get(0).Project__r.Contract__r.IsContract__c) {
                    throw new AuraHandledException('잔여 예산보다 경비신청금액이 많습니다.');
                }else if (objExp.BudgetType__c != '프로젝트') {
                    throw new AuraHandledException('잔여 예산보다 경비신청금액이 많습니다.');
                }
            }
            objExp.Budget__c = listBudget.get(0).Id;
            objExp.PaymentMethod__c = '법인카드';
        }else{
            throw new AuraHandledException('해당 사용목적의 활성화된 예산이 없습니다.');
        }

        //category1 의 본사행정 ,마케팅 선택시 자동으로 입력되는 Id 값
//        Project__c projectCommon = [select Id, Name from Project__c where Name = '본사공통' limit 1];
//        Project__c projectMarketing = [select Id, Name from Project__c where Name = '마케팅' limit 1];
        Savepoint preSave = Database.setSavepoint();

        //19.08.07 검색 값 중복issue 분기로직 추가 kmh
        try {
            if (objExp.BudgetType__c != '프로젝트') {
                objExp.Project__c = null;
            }
            upsert objExp;
        } catch(DmlException dmlExcep) {
            System.debug('dmlExcep.getMessage() : ' + dmlExcep.getMessage());
            Database.rollback(preSave);
            return 'ERROR/에러가 발생했습니다./'+dmlExcep.getMessage();
        }

        for(Object objExpDetail : listExpDetail){
            Map<String, Object> mapExpDetail = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(objExpDetail));

            ExpenseDetail__c objExpDetailTemp = new ExpenseDetail__c();
            if(objExpDetailTemp.Expense__c == null){
                objExpDetailTemp.Expense__c = objExp.Id;
            }

            objExpDetailTemp.Id                         = String.valueOf(mapExpDetail.get('Id'));
            objExpDetailTemp.Date__c                    = Datetime.valueOf(String.valueOf(mapExpDetail.get('Dt')));
            objExpDetailTemp.Amount__c                  = Decimal.valueOf(String.valueOf(mapExpDetail.get('Amount')));
            objExpDetailTemp.Description__c             = String.valueOf(mapExpDetail.get('Description'));
            objExpDetailTemp.Category2__c               = String.valueOf(mapExpDetail.get('Category2'));
            objExpDetailTemp.SalesType__c               = objExp.BudgetType__c == '영업'? String.valueOf(mapExpDetail.get('SalesType')) : null;
            objExpDetailTemp.Project_Name__c            = objExp.BudgetType__c == '영업' && objExpDetailTemp.SalesType__c == '프로젝트'? String.valueOf(mapExpDetail.get('ProjectNameId')) : null;
            objExpDetailTemp.Opportunity_Name__c        = objExp.BudgetType__c == '영업' && objExpDetailTemp.SalesType__c == '영업기회'? String.valueOf(mapExpDetail.get('OpportunityNameId')) : null;
            objExpDetailTemp.Lead__c                    = objExp.BudgetType__c == '영업' && objExpDetailTemp.SalesType__c == '잠재고객'? String.valueOf(mapExpDetail.get('Lead')) : null;
            objExpDetailTemp.CorporateCardBilling__c    = String.valueOf(mapExpDetail.get('CorporateCardBilling'));
            objExpDetailTemp.PriorExpenseApplication__c = String.valueOf(mapExpDetail.get('PriorExpenseApplication'));
            objExpDetailTemp.StoreName__c               = String.valueOf(mapExpDetail.get('StoreName'));
            objExpDetailTemp.StoreAddress__c            = String.valueOf(mapExpDetail.get('StoreAddress'));
            objExpDetailTemp.BillingAmount__c           = String.valueOf(mapExpDetail.get('BillingAmount'));
            objExpDetailTemp.CardCompany__c             = String.valueOf(mapExpDetail.get('CardCompany'));
            objExpDetailTemp.BusinessType__c            = String.valueOf(mapExpDetail.get('BusinessType'));

            //SalesType에 따른 Validation 설정
            if(objExp.BudgetType__c == '영업' && objExpDetailTemp.SalesType__c == '프로젝트' && objExpDetailTemp.Project_Name__c == null) {
                throw new AuraHandledException('프로젝트를 선택하세요.');
            }else if(objExp.BudgetType__c == '영업' && objExpDetailTemp.SalesType__c == '영업기회' && objExpDetailTemp.Opportunity_Name__c == null){
                throw new AuraHandledException('영업기회를 선택하세요.');
            }else if (objExp.BudgetType__c == '영업' && objExpDetailTemp.SalesType__c == '잠재고객' && objExpDetailTemp.Lead__c == null) {
                throw new AuraHandledException('잠재고객을 선택하세요.');
            }
            listExpDetailTemp.add(objExpDetailTemp);



//            if(objExpDetailTemp.Category1__c == '마케팅' && projectMarketing != null){
//                objExpDetailTemp.Project_Name__c  = projectMarketing.Id;
//            }else if(objExpDetailTemp.Category1__c == '본사행정' && projectCommon != null){
//                objExpDetailTemp.Project_Name__c  = projectCommon.Id;
//            }

//            objExpDetailTemp.Category1__c = String.valueOf(mapExpDetail.get('Category1__c'));
//            if(objExpDetailTemp.SalesType__c == '프로젝트') {
//                if(mapExpDetail.get('Project_Name__c') == null || String.valueOf(mapExpDetail.get('Project_Name__c')) == '') {
//                    throw new AuraHandledException('프로젝트를 선택하세요.');
//                }
//                objExpDetailTemp.Id = String.valueOf(mapExpDetail.get('Id'));
//                objExpDetailTemp.Amount__c = Decimal.valueOf(String.valueOf(mapExpDetail.get('Amount__c')));
//                objExpDetailTemp.Project_Name__c = String.valueOf(mapExpDetail.get('Project_Name__c'));
//                objExpDetailTemp.Description__c = String.valueOf(mapExpDetail.get('Description__c'));
//                objExpDetailTemp.Category2__c = String.valueOf(mapExpDetail.get('Category2__c'));
//                objExpDetailTemp.Date__c = Date.valueOf(String.valueOf(mapExpDetail.get('Date__c')));
//                objExpDetailTemp.Payment_Type__c = String.valueOf(mapExpDetail.get('Payment_Type__c'));
//                objExpDetailTemp.Opportunity_Name__c = null;
//
//                listExpDetailTemp.add(objExpDetailTemp);
//
//            }
//            else if(objExpDetailTemp.Category1__c == '영업') {
//                if(mapExpDetail.get('Opportunity_Name__c') == null || String.valueOf(mapExpDetail.get('Opportunity_Name__c')) == '') {
//                    throw new AuraHandledException('프로젝트를 선택하세요.');
//                }
//                objExpDetailTemp.Id = String.valueOf(mapExpDetail.get('Id'));
//                objExpDetailTemp.Amount__c = Decimal.valueOf(String.valueOf(mapExpDetail.get('Amount__c')));
//                objExpDetailTemp.Opportunity_Name__c = String.valueOf(mapExpDetail.get('Opportunity_Name__c'));
//                objExpDetailTemp.Description__c = String.valueOf(mapExpDetail.get('Description__c'));
//                objExpDetailTemp.Category2__c = String.valueOf(mapExpDetail.get('Category2__c'));
//                objExpDetailTemp.Date__c = Date.valueOf(String.valueOf(mapExpDetail.get('Date__c')));
//                objExpDetailTemp.Payment_Type__c = String.valueOf(mapExpDetail.get('Payment_Type__c'));
//                objExpDetailTemp.Project_Name__c = null;
//
//                listExpDetailTemp.add(objExpDetailTemp);
//            }
//            else {
//                objExpDetailTemp.Id = String.valueOf(mapExpDetail.get('Id'));
//                objExpDetailTemp.Amount__c = Decimal.valueOf(String.valueOf(mapExpDetail.get('Amount__c')));
//                objExpDetailTemp.Project_Name__c = String.valueOf(mapExpDetail.get('Project_Name__c'));
//                objExpDetailTemp.Opportunity_Name__c = String.valueOf(mapExpDetail.get('Opportunity_Name__c'));
//                objExpDetailTemp.Description__c = String.valueOf(mapExpDetail.get('Description__c'));
//                objExpDetailTemp.Category2__c = String.valueOf(mapExpDetail.get('Category2__c'));
//                objExpDetailTemp.Date__c = Date.valueOf(String.valueOf(mapExpDetail.get('Date__c')));
//                objExpDetailTemp.Payment_Type__c = String.valueOf(mapExpDetail.get('Payment_Type__c'));
//
//                listExpDetailTemp.add(objExpDetailTemp);
//            }
        }

        try {
            if(!listDel.isEmpty()){
                List<ExpenseDetail__c> listExpDetailDel = [SELECT Id FROM ExpenseDetail__c WHERE Id IN : listDel];
                if (!listExpDetailDel.isEmpty()) {
                    delete listExpDetailDel;
                }
            }

            if(!listExpDetailTemp.isEmpty()){
                upsert listExpDetailTemp;
            }

        } catch(DmlException dmlExcep) {
            System.debug('dmlExcep.getDmlMessage(0) : ' + dmlExcep.getDmlMessage(0));
            Database.rollback(preSave);
            return 'ERROR/에러가 발생했습니다. /'+dmlExcep.getDmlMessage(0);
        }

        return 'SUCCESS/성공적으로 저장되었습니다./'+ objExp.Id;
    }

    @AuraEnabled
    public static Map<String, Object> getTerm(String projectId){
        List<PerformProject__c> listPerformProject = [
                SELECT Id, Project__r.Id, Project__r.Name, InputDate__c, WithdrawDate__c
                FROM PerformProject__c
                WHERE Project__c =: projectId
                AND Employee__r.User__r.Id = :UserInfo.getUserId()
        ];

        Map<String, Object> mapReturnValue = new Map<String, Object>{
                'projectId'          => listPerformProject[0].Project__r.Id,
                'projectName'        => listPerformProject[0].Project__r.Name,
                'inputDate'          => listPerformProject[0].InputDate__c,
                'withdrawDate'       => listPerformProject[0].WithdrawDate__c
        };

        return mapReturnValue;
    }

}