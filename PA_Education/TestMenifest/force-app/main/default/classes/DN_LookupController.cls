/*
* ==================================================================================
*   File Name   : DN_LookupController.cls
*   Author      : Soyoung.Jung
*   Date        : 2019.03.25
*   Tester      : DN_LookupController_Test.cls
*   Description : Daeunextier common lookup component
                (https://docs.google.com/spreadsheets/d/1znDlnBn7TTSguK_zha5WKMdIPuenubTnKGrEKTSoyQc/edit?usp=sharing)
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2019.03.25    Soyoung.Jung    Create
* ==================================================================================
*/

public with sharing class DN_LookupController {

    @AuraEnabled
	public static List<SObject> querySalesforceRecord(String queryString) {
		return Database.query(queryString);
	}

	@AuraEnabled
	public static Map<String, Object> getLookupDatas(String query, String sObjectName, String[] fieldSet) {
		Map<String, Schema.SObjectField> mapFields = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();

		List<Map<String, String>> listColumns = new List<Map<String, String>>();
		for(String field : fieldSet) {
			Schema.DescribeFieldResult describe = mapFields.get(field).getDescribe();
			listColumns.add(new Map<String, String>{
				'label' => describe.getLabel(),
				'fieldName' => describe.getName(),
				'type' => String.valueOf(describe.getType())
			});
		}

		Map<String, Object> mapReturnValue = new Map<String, Object>{
			'listDatas' => Database.query(query),
			'listColumns' => listColumns
		};
		System.debug('mapReturnValue : ' + mapReturnValue);
		return mapReturnValue;
	}

}