/************************************************************************************
 * File Name   : QuoteItemNewController.cls
 * Author      : Soyoung.Jung 
 * Date        : 2019.01.14
 * Tester      : QuoteItemNewController_test.cls
 * Description : 견적 상세 생성 모달 컴포넌트 컨트롤러
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2019.01.14      Soyoung.Jung        Create
*************************************************************************************/

public with sharing class QuoteItemNewController {

	@AuraEnabled
	public static Map<String, Object> getInitData() {
		// 현재 유저가 사용 가능한 레코드 타입 조회
		Set<Id> setIdRecordTypeAvailable = new Set<Id>();
		List<Schema.RecordTypeInfo> listRecordTypes = QuoteItem__c.SObjectType.getDescribe().getRecordTypeInfos();

		for(Schema.RecordTypeInfo objRecordTypeInfo : listRecordTypes) {
			if(objRecordTypeInfo.isAvailable()) {
				setIdRecordTypeAvailable.add(objRecordTypeInfo.getRecordTypeId());
			}
		}

		// QuoteItem__c Record type list
		List<RecordType> listRecordTypeQI = [SELECT 	Id, Name, DeveloperName, Description
											 FROM 		RecordType
											 WHERE 		SObjectType = 'QuoteItem__c'
											 AND 		Id IN :setIdRecordTypeAvailable
											 ORDER BY 	DeveloperName];

		List<Map<String, String>> listRecordTypeReturn = new List<Map<String, String>>();
		Map<String, String> mapRecordTypeId = new Map<String, String>();
		for(RecordType objRecordType : listRecordTypeQI) {
			String sLabel = objRecordType.Name + ' (' + objRecordType.Description + ')';

			listRecordTypeReturn.add(new Map<String, String>{'label' => sLabel, 'value' => objRecordType.DeveloperName});
			mapRecordTypeId.put(objRecordType.DeveloperName, objRecordType.Id);
		}

		// Return map
		Map<String, Object> mapReturnValue = new Map<String, Object>{
			'listRecordTypeQI' => listRecordTypeReturn,
			'mapRecordTypeId' => mapRecordTypeId
		};

		return mapReturnValue;
	}

	@AuraEnabled
	public static Map<String, Object> getDefaultValue(Id idEmployee) {
		// Employee__c Info
		Employee__c objEmployee = [SELECT 	Id, Name, DeptPosition__c, Position__c, Fm_Level__c, MainRole__c
								   FROM 	Employee__c
								   WHERE 	Id = :idEmployee];

		System.debug('objEmployee : ' + objEmployee.Fm_Level__c);

		WrapperEmployee wrapEmployee = new WrapperEmployee(objEmployee);

		// Return map
		Map<String, Object> mapReturnValue = new Map<String, Object>{
			'wrapEmployee' => wrapEmployee
		};

		return mapReturnValue;
	}
	
	/************************************************************************************
    * 	직책과 직급에 따라 견적 단가 계산
    *************************************************************************************/
	private static Decimal doCalcListPrice(String sDept, String sConsultLevel) {
		// 견적상세관리 Custom Settings
		QuoteItemManage__c objQuoteItemManage = QuoteItemManage__c.getInstance();

		// 포지션과 등급에 따른 단가 산정
		String sListPrice = String.valueOf(objQuoteItemManage.get(sDept + sConsultLevel + '__c'));
		Decimal dListPrice = Decimal.valueOf(sListPrice);

		return dListPrice;
	}


	public class WrapperEmployee {
		@AuraEnabled public Employee__c objEmployee {get; set;}
		@AuraEnabled public Decimal dConsultListPrice {get; set;}

		public WrapperEmployee(Employee__c objEmployee) {
			this.objEmployee = objEmployee;
			this.dConsultListPrice = doCalcListPrice(objEmployee.MainRole__c, objEmployee.Fm_Level__c);
		}
	}

}