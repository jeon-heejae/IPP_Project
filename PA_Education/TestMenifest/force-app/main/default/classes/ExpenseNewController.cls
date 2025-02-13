public class ExpenseNewController {

    public static List<Map<String, String>> getPicklistValue(String objectAPIName, String fieldName) {
        List<Map<String, String>> options = new List<Map<String, String>>();
        
        Schema.SObjectType sobject_type = Schema.getGlobalDescribe().get(objectAPIName);
        Schema.DescribeSObjectResult sobjectDescribe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();
        
        List<Schema.PicklistEntry> pickListValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry pickListEntry : pickListValues) {
            if (pickListEntry.isActive()) options.add(new Map<String, String>{'value' => pickListEntry.getValue()
                                                                                , 'label' => pickListEntry.getLabel()
                                                                                , 'default' => String.valueOf(pickListEntry.isDefaultValue())
                                                                                });
        }
        return options;
    }
	//Field Label 갖고오는 Map Container
	@AuraEnabled
    public static Map<String, String> getObjectFieldLabel(String sObjectName){
		Schema.SObjectType schemaObject = Schema.getGlobalDescribe().get(sObjectName); 
		Schema.DescribeSobjectResult schemaObjectResult = schemaObject.getDescribe();
		Map<String, Schema.SObjectField> mapSchemaObjectResult = schemaObjectResult.fields.getMap();        

		Map<String, String> mapFieldLabel = new Map<String, String>();
		for(Schema.SObjectField obj : mapSchemaObjectResult.values()){                            
			Schema.DescribeFieldResult f = mapSchemaObjectResult.get(obj.getDescribe().getName()).getDescribe();
			//system.debug('mapFieldLabel: : : : '+mapFieldLabel);
			mapFieldLabel.put(f.getName(), f.getLabel());
		}

		return mapFieldLabel;
	}

	@AuraEnabled
    public static Map<String, Object> getInitData(Id expId){
        System.debug('getInitData For Parameter index throw=========Start');

    	//경비신청 레코드 조회
        Expense__c objExpense = new Expense__c();
        if(expId != null){
    	   objExpense = [SELECT ID,
    							 Name,
    							 Submit_Date__c,
    							 FirstExpenseRequest__c,
    							 FirstExpenseRequest__r.Name,
    							 SecondApproverSelection__c,
                                 UseYear__c,
                                 UseMonth__c
								 FROM Expense__c
								 WHERE Id =: expId
    							 ]; 

        }
        List<ExpenseDetail__c> listExpDetail = new List<ExpenseDetail__c>();
        if(expId != null){
    	//경비신청 상세 조회
    	   listExpDetail = [SELECT Id,
    								Name,
    								Date__c,
    								Category1__c,
    								Category2__c,
    								Payment_Type__c,
    								Amount__c,
                                    Description__c,
    								Project_Name__c,
    								Project_Name__r.Name,
    								Opportunity_Name__c,
    								Opportunity_Name__r.Name,
                                    Expense__c
    								FROM ExpenseDetail__c
    								WHERE Expense__c =: expId ORDER BY Date__c DESC, Category1__c
    								];
        }
        else{
        //초기 Init Row 생성
            listExpDetail = new List<ExpenseDetail__c>();
			ExpenseDetail__c objExpenseDetail= new ExpenseDetail__c(
                                                    Id = null,
                                                    Date__c = system.today(),
                                                    Category1__c = '본사행정',
                                                    Category2__c = '식비',
                                                    Payment_Type__c = '개인카드',
                                                    Amount__c = 0,
                                                    Description__c = '',
                                                    Project_Name__c = null,
                                                    Opportunity_Name__c = null,
                                                    Expense__c = expId
                                                    );
            listExpDetail.add(objExpenseDetail);
        }
			Map<String, Object> mapReturnValue = new Map<String, Object>{
				'Expense' => objExpense,
				'ExpenseDetail' => listExpDetail,
                'PicklistYear' => getPicklistValue('Expense__c', 'UseYear__c'),
                'PicklistMonth' => getPicklistValue('Expense__c', 'UseMonth__c'),
				'PicklistCategory1' => getPicklistValue('ExpenseDetail__c', 'Category1__c'),
				'PicklistCategory2' => getPicklistValue('ExpenseDetail__c', 'Category2__c'),
				'PicklistPayment' => getPicklistValue('ExpenseDetail__c', 'Payment_Type__c')
            };
        System.debug('mapReturnValue::_ ' + mapReturnValue);
        System.debug('getInitData For Parameter index throw=========End');

        return mapReturnValue;  
    } 


    

    @AuraEnabled
    public static String doSave(Expense__c objExp, List<Object> listExpDetail, List<Id> listDel) {
        List<ExpenseDetail__c> listExpDetailTemp = new List<ExpenseDetail__c>();
        ExpenseDetail__c objExpDetailTemp;

        //category1 의 본사행정 ,마케팅 선택시 자동으로 입력되는 Id 값
        Project__c projectCommon = [select Id, Name from Project__c where Name = '본사공통' limit 1];
        Project__c projectMarketing = [select Id, Name from Project__c where Name = '마케팅' limit 1];         
        Savepoint preSave = Database.setSavepoint();

        //19.08.07 검색 값 중복issue 분기로직 추가 kmh
        try {
            upsert objExp;

        } catch(DmlException dmlExcep) {
            System.debug('dmlExcep.getMessage() : ' + dmlExcep.getMessage());
            Database.rollback(preSave);
            return 'ERROR/에러가 발생했습니다./'+dmlExcep.getMessage();
        }

        Map<String, Object> mapExpDetail;
        for(Object objExpDetail : listExpDetail){
            mapExpDetail = (Map<String,Object>)Json.deserializeUntyped(Json.serialize(objExpDetail));

            objExpDetailTemp = new ExpenseDetail__c();
            if(objExpDetailTemp.Expense__c == null){
                objExpDetailTemp.Expense__c = objExp.Id;
            }
          
            if(objExpDetailTemp.Category1__c == '마케팅' && projectMarketing != null) {
                objExpDetailTemp.Project_Name__c  = projectMarketing.Id;
            } else if(objExpDetailTemp.Category1__c == '본사행정' && projectCommon != null) {
                objExpDetailTemp.Project_Name__c  = projectCommon.Id;
            }

            objExpDetailTemp.Category1__c = String.valueOf(mapExpDetail.get('Category1__c'));
            if(objExpDetailTemp.Category1__c == '프로젝트') {
                if(mapExpDetail.get('Project_Name__c') == null || String.valueOf(mapExpDetail.get('Project_Name__c')) == '') {
                    throw new AuraHandledException('프로젝트를 선택하세요.');
                }
                objExpDetailTemp.Id = String.valueOf(mapExpDetail.get('Id'));
                objExpDetailTemp.Amount__c = Decimal.valueOf(String.valueOf(mapExpDetail.get('Amount__c')));
                objExpDetailTemp.Project_Name__c = String.valueOf(mapExpDetail.get('Project_Name__c'));
                objExpDetailTemp.Description__c = String.valueOf(mapExpDetail.get('Description__c'));
                objExpDetailTemp.Category2__c = String.valueOf(mapExpDetail.get('Category2__c'));
                objExpDetailTemp.Date__c = Date.valueOf(String.valueOf(mapExpDetail.get('Date__c')));
                objExpDetailTemp.Payment_Type__c = String.valueOf(mapExpDetail.get('Payment_Type__c'));    
                objExpDetailTemp.Opportunity_Name__c = null;

                listExpDetailTemp.add(objExpDetailTemp);

            }
            else if(objExpDetailTemp.Category1__c == '영업') {
                if(mapExpDetail.get('Opportunity_Name__c') == null || String.valueOf(mapExpDetail.get('Opportunity_Name__c')) == '') {
                    throw new AuraHandledException('프로젝트를 선택하세요.');
                }
                objExpDetailTemp.Id = String.valueOf(mapExpDetail.get('Id'));
                objExpDetailTemp.Amount__c = Decimal.valueOf(String.valueOf(mapExpDetail.get('Amount__c')));
                objExpDetailTemp.Opportunity_Name__c = String.valueOf(mapExpDetail.get('Opportunity_Name__c'));
                objExpDetailTemp.Description__c = String.valueOf(mapExpDetail.get('Description__c'));
                objExpDetailTemp.Category2__c = String.valueOf(mapExpDetail.get('Category2__c'));
                objExpDetailTemp.Date__c = Date.valueOf(String.valueOf(mapExpDetail.get('Date__c')));
                objExpDetailTemp.Payment_Type__c = String.valueOf(mapExpDetail.get('Payment_Type__c'));
                objExpDetailTemp.Project_Name__c = null;

                listExpDetailTemp.add(objExpDetailTemp);
            }
            else {
                objExpDetailTemp.Id = String.valueOf(mapExpDetail.get('Id'));
                objExpDetailTemp.Amount__c = Decimal.valueOf(String.valueOf(mapExpDetail.get('Amount__c')));
                objExpDetailTemp.Project_Name__c = String.valueOf(mapExpDetail.get('Project_Name__c'));
                objExpDetailTemp.Opportunity_Name__c = String.valueOf(mapExpDetail.get('Opportunity_Name__c'));
                objExpDetailTemp.Description__c = String.valueOf(mapExpDetail.get('Description__c'));
                objExpDetailTemp.Category2__c = String.valueOf(mapExpDetail.get('Category2__c'));
                objExpDetailTemp.Date__c = Date.valueOf(String.valueOf(mapExpDetail.get('Date__c')));
                objExpDetailTemp.Payment_Type__c = String.valueOf(mapExpDetail.get('Payment_Type__c'));

                listExpDetailTemp.add(objExpDetailTemp);
            }
        }

        try {
            if(!listDel.isEmpty()) {     
                List<ExpenseDetail__c> listExpDetailDel = [SELECT Id FROM ExpenseDetail__c WHERE Id IN : listDel];
                delete listExpDetailDel;
            }
            
            if(!listExpDetailTemp.isEmpty()) {
                upsert listExpDetailTemp;
            }

        } catch(DmlException dmlExcep) {
            System.debug('dmlExcep.getMessage() : ' + dmlExcep.getMessage());
            Database.rollback(preSave);
            return 'ERROR/에러가 발생했습니다./'+dmlExcep.getMessage();
        }

        return 'SUCCESS/성공적으로 저장되었습니다./'+ objExp.Id;
    
    }
}