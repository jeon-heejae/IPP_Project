/************************************************************************************
 * File Name   : QuoteCreation.cls
 * Author      : Jk.lee 
 * Date        : 2019.03.04
 * Target      : QuoteCreation.cls
 * Description : QuoteCreation.cls 
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2019.02.28      JK.LEE        Create
*************************************************************************************/

public class QuoteCreation {



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

///************************************************************************************
///   * 	직책과 직급에 따라 견적 단가 계산
///************************************************************************************/
	@AuraEnabled
	public static Decimal getCalcListPrice(String sDept, String sConsultLevel) {
		// 견적상세관리 Custom Settings
		QuoteItemManage__c objQuoteItemManage = QuoteItemManage__c.getInstance();

		// 포지션과 등급에 따른 단가 산정
		String sListPrice = String.valueOf(objQuoteItemManage.get(sDept + sConsultLevel + '__c'));
		Decimal dListPrice = Decimal.valueOf(sListPrice);

		return dListPrice;
	}


    @AuraEnabled
    public static Map<String, Object> getInitData(Id quoteId, Id opptyId) {




    	//기본 견적 필드
    	Quote__c objQuote = new Quote__c();
    	if(quoteId != null){
		 	objQuote = [SELECT Id, 
								Name, 
								Quote_Opportunity__c, 
								Quote_Subject__c,
								Quote_Date__c, 
								Quote_Account__c, 
								Quote_Contact__c,
								Quote_Opportunity__r.Name, 
								Quote_Contact__r.Name,
								Quote_Account__r.Name,
								Quote_Status__c,
								Quote_ShowVAT__c,
								
								//소계
								Quote_SalesDiscount__c,
								Quote_TrainingListAmount__c,
								Quote_TrainingSubTotal__c,
								Quote_LicenseSubTotal__c,
								Quote_NumberOfUsers__c,
								Quote_TrainingCount__c,
								Quote_ConsultSubTotal__c,
								Quote_TotalManMonths__c,
								Quote_ConsultListSubTotal__c,
								Quote_LicenseListAmount__c,
								Quote_ConsultRemark__c,
								Quote_LicenseRemark__c,
								Quote_TrainingRemark__c
								FROM Quote__c
								WHERE Id = :quoteId];
    	}

    	//Opportunity 필드 조회
    	Opportunity__c objOppty = new  Opportunity__c();
    	if(objQuote.Quote_Opportunity__c != null || opptyId != null){
    		objOppty = [SELECT Id,
    						Name,
    						AccountId__r.Name, 
    						Contact__r.Name , 
    						Contact__c, 
    						AccountId__c
    						FROM Opportunity__c
    						WHERE Id =: objQuote.Quote_Opportunity__c OR Id =:opptyId];    						
    	}
    	system.debug('objOppty 오브젝트 생성됨 : '+ objOppty);


		List<WrapperQuoteItem> listConsulting = new List<WrapperQuoteItem>();
		List<WrapperQuoteItem> listLicense = new List<WrapperQuoteItem>();
		List<WrapperQuoteItem> listTraining = new List<WrapperQuoteItem>();

        List<QuoteItem__c> listQuoteItem = new List<QuoteItem__c>();
        listQuoteItem = [SELECT Id, 
        						Name, 
        						RecordType.DeveloperName,
        						QuoteItem_SortOrder__c,
        						QuoteItem_ConsultType__c,
        						QuoteItem_ConsultLevel__c,
        						QuoteItem_ConsultName__c,
								QuoteItem_ConsultManMonths__c,
								QuoteItem_ConsultListPrice__c,
								QuoteItem_ConsultDiscountedPrice__c,
								QuoteItem_Discount_Percent__c,
								QuoteItem_ConsultListAmount__c,
								QuoteItem_ConsultAmount__c,
								QuoteItem_ConsultDiscountAmount__c,
								
								QuoteItem_LicenseType__c,
								QuoteItem_LicenseListPrice__c,
								QuoteItem_LicenseDiscountedPrice__c,
								QuoteItem_LicenseNumberOfUser__c,
								QuoteItem_LicenseListAmount__c,
								QuoteItem_LicenseAmount__c,
								QuoteItem_LicenseDiscountAmount__c,
								QuoteItem_License_Percent__c,

								QuoteItem_TrainingDescription__c,
								QuoteItem_TrainingStandardPrice__c,
								QuoteItem_TrainingSalesPrice__c,
								QuoteItem_TrainingCount__c,
								QuoteItem_ListPriceFormula__c,
								QuoteItem_TrainingSalesAmount__c,
								QuoteItem_TrainingListAmount__c,
								QuoteItem_TrainingDiscountAmount__c,
								QuoteItem_Training_Percent__c,
						
								QuoteItem_FOC__c,
								QuoteItem_ConsultRemark__c,
								QuoteItem_LicenseRemark__c,
								QuoteItem_TrainingRemark__c

        				 FROM 	QuoteItem__c
        				 WHERE 	QuoteItem_Quote__c = :quoteId
        				 ORDER BY QuoteItem_SortOrder__c];




        for(QuoteItem__c objQuoteItem : listQuoteItem){
        	if(objQuoteItem.RecordType.DeveloperName == 'Consulting'){
        		listConsulting.add(new WrapperQuoteItem(objQuoteItem));
        	}        	
        	else if(objQuoteItem.RecordType.DeveloperName == 'License'){
        		listLicense.add(new WrapperQuoteItem(objQuoteItem));
        	}
        	else if(objQuoteItem.RecordType.DeveloperName == 'Training'){
        		listTraining.add(new WrapperQuoteItem(objQuoteItem));
        	}
        }


			Map<String, Object> mapReturnValue = new Map<String, Object>{
				'Consulting' => listConsulting,
				'License' => listLicense,
				'Training' => listTraining,
				'Quote' => objQuote,
				'Oppty' => objOppty,
				'PicklistStatus' => getPicklistValue('Quote__c', 'Quote_Status__c'),
				'PicklistType' => getPicklistValue('QuoteItem__c', 'QuoteItem_ConsultType__c'),
				'PicklistLevelTraining' => getPicklistValue('QuoteItem__c', 'QuoteItem_ConsultLevel__c'),
				'PicklistLevel' => getPicklistValue('QuoteItem__c', 'QuoteItem_ConsultLevel__c')
			};

		System.debug('mapReturnValue : ' + mapReturnValue);

        return mapReturnValue;  

    }

    //컨설팅, 라이센스, 교육리스트 각각저장
	@AuraEnabled
	public static String doSave(List<WrapperQuoteItem> listConsulting, List<WrapperQuoteItem> listLicense, List<WrapperQuoteItem> listTraining, List<Id> listDel, Quote__c objQuote ) {



		Savepoint preSave = Database.setSavepoint();
		QuoteItem__c objQuoteItems;
		QuoteItem__c objQuoteItemsTemp;

		Integer cnt = 1;
		try {

			
			upsert objQuote;

			List<QuoteItem__c> quoteItemList = new List<QuoteItem__c>();
			List<QuoteItem__c> quoteItemListTemp = new List<QuoteItem__c>();
			cnt = 1;

			for(WrapperQuoteItem objWrapper : listConsulting){
				objQuoteItems = objWrapper.objQuoteItem;
				if(objQuoteItems.Id == null){
					objQuoteItems.QuoteItem_Quote__c = objQuote.Id;
				}
				Id objectRecordTypeId = Schema.SObjectType.QuoteItem__c.getRecordTypeInfosByDeveloperName().get('Consulting').getRecordTypeId();
				objQuoteItems.RecordTypeId = objectRecordTypeId; 
				objQuoteItems.QuoteItem_SortOrder__c = cnt;

				quoteItemList.add(objQuoteItems);

				cnt++;
			}
			cnt = 1;
			//Record Type : License
			for(WrapperQuoteItem objWrapper : listLicense){
				objQuoteItems = objWrapper.objQuoteItem;
				if(objQuoteItems.Id == null){
					objQuoteItems.QuoteItem_Quote__c = objQuote.Id;
				}
				Id objectRecordTypeId = Schema.SObjectType.QuoteItem__c.getRecordTypeInfosByDeveloperName().get('License').getRecordTypeId();
				objQuoteItems.RecordTypeId = objectRecordTypeId; 
				objQuoteItems.QuoteItem_SortOrder__c = cnt;
				quoteItemList.add(objQuoteItems);
				
				cnt++;
			}

			cnt = 1;
			//Record Type : Training
			for(WrapperQuoteItem objWrapper : listTraining){
				objQuoteItems = objWrapper.objQuoteItem;
				if(objQuoteItems.Id == null){
					objQuoteItems.QuoteItem_Quote__c = objQuote.Id;
				}
				Id objectRecordTypeId = Schema.SObjectType.QuoteItem__c.getRecordTypeInfosByDeveloperName().get('Training').getRecordTypeId();
				system.debug('objectRecordTypeId : ' +objectRecordTypeId );
				objQuoteItems.RecordTypeId = objectRecordTypeId; 
				objQuoteItems.QuoteItem_SortOrder__c = cnt;
				quoteItemList.add(objQuoteItems);
				cnt++;
			}


			if(!listDel.isEmpty()){		
				List<QuoteItem__c> listQuoteItemDel = [SELECT Id FROM QuoteItem__c WHERE Id IN : listDel];
				delete listQuoteItemDel;
			}
			
			if(!quoteItemList.isEmpty()){
				upsert quoteItemList;
			}
			
			return 'SUCCESS/성공적으로 저장되었습니다./'+ objQuote.Id;		

		} catch(DMLException dmlExcep) {
			System.debug('dmlExcep.getMessage() : ' + dmlExcep.getMessage());
			Database.rollback(preSave);
			return 'ERROR/에러가 발생했습니다./'+dmlExcep.getMessage();
		} 
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



	public class WrapperQuoteItem {
		public WrapperQuoteItem(){			
		}
		@AuraEnabled public QuoteItem__c objQuoteItem {get; set;}
		//할인율 Percent
		@AuraEnabled public Decimal QuoteItem_Discount_Percent{
			get{
				if(QuoteItem_Discount_Percent==null) 
				QuoteItem_Discount_Percent = 0;

				return QuoteItem_Discount_Percent;

			} 

			set;
		}

		@AuraEnabled public Decimal QuoteItem_Discount_PercentLicense{
			get{
				if(QuoteItem_Discount_PercentLicense==null)
				QuoteItem_Discount_PercentLicense = 0;

				return QuoteItem_Discount_PercentLicense;

			} 

			set;
		}


		@AuraEnabled public Decimal QuoteItem_Discount_PercentTraining{
			get{
				if(QuoteItem_Discount_PercentTraining==null)
				QuoteItem_Discount_PercentTraining = 0;

				return QuoteItem_Discount_PercentTraining;

			} 

			set;
		}
		//표준금액
		@AuraEnabled public Decimal QuoteItem_ListPriceFormula {get; set;}
		//표준금액(라이센스)
		@AuraEnabled public Decimal QuoteItem_LicenseListAmount {get; set;}
		//할인액(라이센스)
		@AuraEnabled public Decimal QuoteItem_LicenseDiscountAmount {get; set;}
		//금액(라이센스)
		@AuraEnabled public Decimal QuoteItem_LicenseAmount {get; set;}
		//표준금액(컨설팅)
		@AuraEnabled public Decimal QuoteItem_ConsultListAmount {get; set;}
		//할인액(컨설팅)
		@AuraEnabled public Decimal QuoteItem_ConsultDiscountAmount {get; set;}		
		//금액(컨설팅)
		@AuraEnabled public Decimal QuoteItem_ConsultAmount {get; set;}	
		//표준금액(교육)
		@AuraEnabled public Decimal QuoteItem_TrainingListAmount {get; set;}
		//금액(교육)
		@AuraEnabled public Decimal QuoteItem_TrainingSalesAmount {get; set;}
		//할인액(교육)
		@AuraEnabled public Decimal QuoteItem_TrainingDiscountAmount {get; set;}		
		// row Checkbox
		@AuraEnabled public Boolean isChecked {get; set;}
		//Lookup QuoteName
		//@AuraEnabled public String EmpName {get; set;}
		//Lookup or Text field
		//@AuraEnabled public Boolean LookupOrText {get; set;}

		public WrapperQuoteItem(QuoteItem__c objQuoteItem){
			this.objQuoteItem = objQuoteItem;
			//Lookup 사용시 해당 Wrapper변수 주석 해제
			//EmpName = objQuoteItem.QuoteItem_Emp__r.Name;
			//LookupOrText = false;
			QuoteItem_Discount_PercentLicense = objQuoteItem.QuoteItem_License_Percent__c;
			QuoteItem_Discount_PercentTraining = objQuoteItem.QuoteItem_Training_Percent__c;
			QuoteItem_Discount_Percent = objQuoteItem.QuoteItem_Discount_Percent__c;
			QuoteItem_ListPriceFormula = objQuoteItem.QuoteItem_ListPriceFormula__c;
			QuoteItem_LicenseListAmount = objQuoteItem.QuoteItem_LicenseListAmount__c;
			QuoteItem_LicenseDiscountAmount = objQuoteItem.QuoteItem_LicenseDiscountAmount__c;
			QuoteItem_LicenseAmount = objQuoteItem.QuoteItem_LicenseAmount__c;
			QuoteItem_ConsultListAmount = objQuoteItem.QuoteItem_ConsultListAmount__c;
			QuoteItem_ConsultDiscountAmount = objQuoteItem.QuoteItem_ConsultDiscountAmount__c;
			QuoteItem_ConsultAmount = objQuoteItem.QuoteItem_ConsultAmount__c;
			QuoteItem_TrainingSalesAmount = objQuoteItem.QuoteItem_TrainingSalesAmount__c;
			QuoteItem_TrainingListAmount = objQuoteItem.QuoteItem_TrainingListAmount__c;
			QuoteItem_TrainingDiscountAmount = objQuoteItem.QuoteItem_TrainingDiscountAmount__c;			

			isChecked = false;
		}
	}


}