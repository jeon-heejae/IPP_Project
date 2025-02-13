public without sharing class ApprovalLineCreateController {

	// sharing TEST SJ 0726
	public static String accessLevel = 'Read';
	public static String rowCause    = 'Manual';

	@AuraEnabled
	public static String doSave(String insertValue, String fieldName, User objUser){
		System.debug('insertValue : ' + insertValue);
		System.debug('fieldName : ' + fieldName);
		System.debug('objUser : ' + objUser);
        String returnValue = '';
        try {
        	fieldName = fieldName + '__c';
        	objUser.put( fieldName , insertValue);

        	update objUser;
            returnValue = 'success/성공적으로 저장되었습니다./' + objUser.Id ;
        } catch(Exception e) {
            returnValue = 'error/' + e.getMessage();
        }
        return returnValue;
	}

	@AuraEnabled
	public static String doSubmit(String sObjectName, String sComments, String sHistoryRecordId, List<User> objListUser){
		System.debug('sObjectName : '+ sObjectName + ' / sComments : '+ sComments +' / sHistoryRecordId : '+ sHistoryRecordId );

		//user이름 들어있는 리스트 listApprovalLine 으로 칭함.
		String returnValue;
		try{
			List<String> userList = new List<String>();
			for(Integer i = 0; i < objListUser.size(); i++){
				userList.add(objListUser[i].Id);
			}

			System.debug(userList);

			Integer iUserCnt = userList.size();
			String sQuery   = 'SELECT Id FROM '+ sObjectName +' WHERE Id = \''+ sHistoryRecordId + '\''   ;
			SObject obj = Database.query(sQuery);

			switch on iUserCnt {
				when 1 { obj.put('Approver1__c', userList[0]); obj.put('Approver2__c', ''); 	obj.put('Approver3__c', ''); 	obj.put('Approver4__c', '');}
				when 2 { obj.put('Approver1__c', userList[0]); obj.put('Approver2__c', userList[1]); 	obj.put('Approver3__c', ''); 	obj.put('Approver4__c', '');}
				when 3 { obj.put('Approver1__c', userList[0]); obj.put('Approver2__c', userList[1]); 	obj.put('Approver3__c', userList[2]); 	obj.put('Approver4__c', '');}
				when 4 { obj.put('Approver1__c', userList[0]); obj.put('Approver2__c', userList[1]); 	obj.put('Approver3__c', userList[2]); 	obj.put('Approver4__c', userList[3]);}
			}
			update obj;

			if(sObjectName == 'Expense__c'){
				List<Expense__Share> expenseShares = new List<Expense__Share>();

				for(User u : objListUser) {
					Expense__Share expenseSh = new Expense__Share();
					expenseSh.ParentId       = sHistoryRecordId;
					expenseSh.AccessLevel 	 = accessLevel;
					expenseSh.RowCause	     = rowCause;
					if(u.Id ==  UserInfo.getUserId()) continue;
					expenseSh.UserOrGroupId  = u.Id;

					expenseShares.add(expenseSh);
				}

				if (!expenseShares.isEmpty()) {
					insert expenseShares;
				}
			}else if(sObjectName == 'PriorExpenseApplication__c'){
				List<PriorExpenseApplication__Share> PriorExpenseApplicationShares = new List<PriorExpenseApplication__Share>();

				for(User u : objListUser) {
					PriorExpenseApplication__Share expenseSh = new PriorExpenseApplication__Share();
					expenseSh.ParentId       = sHistoryRecordId;
					expenseSh.AccessLevel 	 = accessLevel;
					expenseSh.RowCause	     = rowCause;
					if(u.Id ==  UserInfo.getUserId()) continue;
					expenseSh.UserOrGroupId  = u.Id;

					PriorExpenseApplicationShares.add(expenseSh);
				}
				if (!PriorExpenseApplicationShares.isEmpty()) {
					insert PriorExpenseApplicationShares;
				}
			}


			Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
	        req1.setComments(sComments);
	        req1.setObjectId(sHistoryRecordId);
	        Approval.ProcessResult result = Approval.process(req1);

			returnValue = 'success/성공적으로 저장되었습니다./' + sHistoryRecordId ;

		} catch (Exception e) {
			returnValue = 'error/' + e.getMessage() + '클래스에러' +sHistoryRecordId;
		}

		return returnValue;
	}

	//2024.11.14 kc
	@AuraEnabled
	public static Map<String, Object> checkProject(String recordId){	//sObjectName가 expense__c 이고 BudgetType__c이 프로젝트 일 때 편의를 위한 approval line default 값 생성

		List<Expense__c> listExp = [
				SELECT 	Id, BudgetType__c, Project__c, Project__r.PM__r.Id, Project__r.PM__r.Name, Project__r.Business__c
				FROM 	Expense__c
				WHERE 	Id = :recordId
				LIMIT 	1
		];

		if (listExp.size() != 1 || listExp[0].BudgetType__c != '프로젝트') {
			System.debug('[Debug] 프로젝트 없음');
			return null;
		}

		List<User> listMd = [
				SELECT 	Id, Name
				FROM 	User
				WHERE 	Name = '경영지원부'
				LIMIT 	1
		];
		if(listMd.size() != 1){
			System.debug('[Debug] 경영지원부 없음');
			return null;
		}
		
		List<Employee__c> listRp = [
				SELECT 	Id, Name, User__r.Id, User__r.Name
				FROM 	Employee__c
				WHERE 	Position__c = '1'
				LIMIT 	1
		];
		if(listRp.size() != 1){
			System.debug('[Debug] 대표이사 없음');
			return null;
		}

		List<Employee__c> listDh = [
				SELECT 	Id, Name, Department__c, User__r.Id, User__r.Name
				FROM 	Employee__c
				WHERE 	Department__c = :listExp[0].Project__r.Business__c
				AND 	DeptPosition__c = 'Department Head'
				LIMIT 	1
		];

		if(listDh.size() != 1){
			System.debug('[Debug] 부서장 없음');
			return null;
		}

		if(listExp[0].Project__r.PM__c == null){
			System.debug('[Debug] PM 없음');
			return null;
		}

		List<User> listMe = [
				SELECT	Id, Name
				FROM	User
				WHERE	Id =: UserInfo.getUserId()
				LIMIT	1
		];

		Map<String, Object> returnVal = new Map<String, Object>{
				'PmId'		=> listExp[0].Project__r.PM__r.Id,		//프로젝트 메니저
				'PmName'	=> listExp[0].Project__r.PM__r.Name,
				'MdId'		=> listMd[0].Id,						//영업지원부
				'MdName'	=> listMd[0].Name,
				'DhId'		=> listDh[0].User__r.Id,				//부서장
				'DhName'	=> listDh[0].User__r.Name,
				'MyId'		=> listMe[0].Id,						//나 자신
				'MyName'	=> listMe[0].Name,
				'RpId'		=> listRp[0].User__r.Id,				//대표이사
				'RpName'	=> listRp[0].User__r.Name
		};

		return returnVal;

	}


}