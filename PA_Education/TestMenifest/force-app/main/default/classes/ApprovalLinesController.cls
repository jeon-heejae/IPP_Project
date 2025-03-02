public with sharing class ApprovalLinesController {
	
	@AuraEnabled
	public static Map<String, Object> getApprovalLines(Id recordId) {
		Map<String, Schema.SObjectField> mapFields = Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap();
		Map<String, String> mapColumns = new Map<String, String>();
		for(String key : mapFields.keySet()) {
			Schema.DescribeFieldResult describe = mapFields.get(key).getDescribe();
			mapColumns.put(describe.getName(), describe.getLabel());
		}

		List<String> ApprovalLine1 = new List<String>();
		List<String> ApprovalLine2 = new List<String>();
		List<String> ApprovalLine3 = new List<String>();
		List<String> ApprovalLine4 = new List<String>();

		User objUser = [
			SELECT Id, Name, ApprovalLine1__c, ApprovalLine2__c, ApprovalLine3__c, ApprovalLine4__c
		   	FROM User
		  	WHERE Id =: recordId
		];

		//각 필드별 데이터를 리스트화
		if(objUser.ApprovalLine1__c != null) ApprovalLine1 = objUser.ApprovalLine1__c.split('/');
		if(objUser.ApprovalLine2__c != null) ApprovalLine2 = objUser.ApprovalLine2__c.split('/');
		if(objUser.ApprovalLine3__c != null) ApprovalLine3 = objUser.ApprovalLine3__c.split('/');
		if(objUser.ApprovalLine4__c != null) ApprovalLine4 = objUser.ApprovalLine4__c.split('/');

		//중복 아이디 제거
		Set<String> setApprover = new Set<String>();
		if(!ApprovalLine1.isEmpty()) setApprover.addAll(ApprovalLine1);
		if(!ApprovalLine2.isEmpty()) setApprover.addAll(ApprovalLine2);
		if(!ApprovalLine3.isEmpty()) setApprover.addAll(ApprovalLine3);
		if(!ApprovalLine4.isEmpty()) setApprover.addAll(ApprovalLine4);

		List<Map<String, Object>> listLabel  = new List<Map<String, Object>>();
		listLabel = setApprovalLine(listLabel, setApprover, ApprovalLine1, mapColumns);
		listLabel = setApprovalLine(listLabel, setApprover, ApprovalLine2, mapColumns);
		listLabel = setApprovalLine(listLabel, setApprover, ApprovalLine3, mapColumns);
		listLabel = setApprovalLine(listLabel, setApprover, ApprovalLine4, mapColumns);

        ApprovalLine__c objCustomSet =  ApprovalLine__c.getOrgDefaults();
        Decimal iLineLimit 	   = objCustomSet.LineLimit__c; 	//ApprovalLine 제한
        Decimal iApproverLimit = objCustomSet.ApproverLimit__c; //Approver 수 제한

		Map<String, Object> mapReturnValue = new Map<String, Object>{
			'listLabel' 	 => listLabel,
			'objUser'		 => objUser,
			'iLineLimit' 	 => iLineLimit,
			'iApproverLimit' => iApproverLimit
		};

		return mapReturnValue;
	}

	private static List<Map<String, Object>> setApprovalLine(List<Map<String, Object>> listLabel, Set<String> setApprover, List<String> listAppLine, Map<String, String> mapColumns) {
		Map<Id, User> mapUser = new Map<Id, User>([
				SELECT Id, Name
				FROM User
				WHERE Id IN :setApprover
		]);

		List<User> listUser = new List<User>();
		Map<String, Object> data = new Map<String, Object>();
		Integer cnt = 0;
		for (String s : listAppLine){
			if (cnt == 0) {
				data.put('label', s);
			} else if (mapColumns.containsKey('ApprovalLine1__c') && cnt == 1){
				data.put('fieldName', s);
			} else {
				listUser.add(mapUser.get(s));
			}
			cnt++;
		}
		if(cnt > 0){
			data.put('userDatas', listUser);
			listLabel.add(data);
		}

		return listLabel;
	}

	@AuraEnabled
	public static String doDelete(User objUser, String fieldName){
		String returnValue;

		try {
			objUser.put(fieldName+'__c', null);
			update objUser;

			returnValue = 'success/성공적으로 삭제 되었습니다./' + objUser.Id;
		} catch(Exception e) {
			returnValue = 'error/' + e.getMessage();
		}
		return returnValue;
	}

}