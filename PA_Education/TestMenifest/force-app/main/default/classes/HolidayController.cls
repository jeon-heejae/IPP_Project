/**
 * Component Name                : MyHolidayInfoLightning.cmp
 * Component Controller          : MyHolidayInfoLightningController.js
 * Component Helper              : MyHolidayInfoLightningHelper.js
 * Component Contorlller Class   : HolidayController.cls
 * Test Class                    : HolidayController_Test.cls
 * Description                   : 휴가정보 Detail Class
 * Modification Log
 * ===============================================================
 * Ver     Date          Author           Modification
 * ===============================================================
   1.0   2018.08.27     MH.Kwak           Create
   2.0	 2019.04.12		JK.LEE			  Modified
   3.0   2021.12.28		CJ.Sohn           Holiday 조회하는 SOQL에서 전년도 연차일수 관련 필드 추가
*/


public without sharing class HolidayController{


	//Parent Role Id 체크
	public static Set<Id> getRoleId(Set<Id> listRoleIds , List<UserRole> listUserRole){
		Set<Id> currentIds = new Set<Id>();

		for (Id objIds : listRoleIds) {
			for (UserRole objUserRole : listUserRole) {
				if (objUserRole.ParentRoleId == objIds) {
					currentIds.add(objUserRole.Id);
					//Parent Role == 현재 유저 Role Id 랑 같은 경우
				}
			}
		}

		if (!currentIds.isEmpty()) {
			currentIds.addAll(getRoleId(currentIds, listUserRole));
		}

		system.debug('currentIds :' + currentIds);
		return currentIds;
	}


	//모든 Parent Role 조회
	/*
    public static Set<ID> getParentRoleId(Set<ID> roleIds) {

        Set<ID> currentRoleIds = new Set<ID>();
    
        
        for(UserRole ur :[select Id, ParentRoleId from UserRole where Id IN: roleIds]) {
            currentRoleIds.add(ur.ParentRoleId);
        }
    
        if(!currentRoleIds.isEmpty()) {
            currentRoleIds.addAll(getParentRoleId(currentRoleIds));
        }
    
        return currentRoleIds;
    }
	*/
	

	@AuraEnabled
	public static boolean getPermissionCheck(String userId){
		//리턴해 Permission 체크할 값
		Boolean holidayCheck = true;
		
		//1. 세션아이디로 User Role 조회
		//2. ParentRoleID를 조회해 
		//3. UserRole -> Role LIst 에 담아
		//4. UserId ->  ParentRoldId  조회
		//5. 자기 Role 아래에 있는 모든 RoleId  userRole id 쿼리
		//6. Where 절에 HAs RecordId 넣는다
		//7. 같은 Role 또는 본인이 아닌 조건
		//8. 생성자가 나인 조건 

		//현재 접속중인 세션 ID
		String systemUserId = UserInfo.getUserId();

		//현재 접속중인 Role ID
		Id roleId = UserInfo.getUserRoleId();
		Set<Id> listRoleIds = new Set<Id>();
		listRoleIds.add(roleId);

		//현재 접속중인 프로필
		User sessionProfile = [SELECT Id, Profile.Name FROM USER WHERE Id=: systemUserId ];
		String profileName = sessionProfile.Profile.Name;

		//모든 Role을 조회
        List<UserRole> listAllUserRole = [SELECT Id, ParentRoleId FROM UserRole];
        //해당 Role ID가 Role ID 값을 조회해 ParentRoleId 인지 조회
		Set<Id> listIdsRoleId = getRoleId(listRoleIds, listAllUserRole);

		////모든 Parent role 조회 
		//Set<Id> listParentRoleIds = getParentRoleId(listRoleIds);

		//HasRecordId로 불러온 유저
		User objHasRecIdUser = [SELECT Id, UserRoleId FROM User WHERE Id =: userId];

		//HasRecordId 유저의 Role 조회
       	//List<UserRole> listUserRole = [SELECT Id, ParentRoleId FROM UserRole WHERE Id =: objHasRecIdUser.UserRoleId];

		//Session Role과 HasRecord Role Id 가 같으면 안보이게.

		if (!listIdsRoleId.isEmpty()) {
			for (Id objRoleId : listIdsRoleId) {
				if (profileName == 'System Administrator' || profileName == 'System Admin') {
					holidayCheck = true;
				} else if (systemUserId == userId) {
					holidayCheck = true;
				} else if (objRoleId == objHasRecIdUser.UserRoleId) {
					holidayCheck = true;
				} else {
					holidayCheck = false;
				}
			}
		} else if (systemUserId == userId) {
			holidayCheck = true;
		} else {
			holidayCheck = false;
		}

		return holidayCheck;
	}

	@AuraEnabled
	public static List<Holiday__c> getHoliday(String userId) {
		List<Holiday__c> holiday = [SELECT Id, Holiday_NoticeLevel__c, Holiday_JoinDate__c, Holiday_LastActivity__c ,Holiday_WorkingYears__c, Holiday_PeriodEnd__c,
										   Holiday_IsAnnualleave__c, Holiday_Calculated__c, Holiday_GivenHolidays__c, Holiday_UseDays__c, Holiday_Remain__c,
										   Holiday_Uncountable__c, Holiday_Unpaid__c, CarriedOverOfLastYear__c, UseDaysOfLastYear__c, RemainOfLastYear__c,
										   Holiday_User__r.id, Holiday_User__c, Holiday_User__r.UserRole.Name, Holiday_User__r.ManagerId, Holiday_Monthly_Calculated__c,
										   Holiday_Annual_Calculated__c, Holiday_Total_Remain__c, Holiday_FamilyEvent_Count__c, Holiday_SickLeave_Count__c,
										   Holiday_WomenHoliday_Count__c, Holiday_PublicWorks_Count__c, MonthlyOfLastYear__c, HolidayRemainOfLastYear__c, Holiday_rewardDays__c,
										   Holiday_Total_Count__c, fm_Holiday_rewardRemainDays__c, Holiday_reward_Total_Count__c, Holiday_BenefitPaymentDays__c,
									       RewardHolidayTotalOfLastYear__c, RewardHolidayUseDaysOfLastYear__c, RewardHolidayRemainOfLastYear__c, RewardHolidayPaymentDaysOfLastYear__c

							FROM Holiday__c 
							WHERE Holiday_User__c =: userId
							//OR Holiday_User__r.UserRole.ParentRoleId =: users.ParentRoleId;
							];
		system.debug('holiday : ' + holiday);

		return holiday;								
	}

	@AuraEnabled
	public static List<HolidayAction__c> getHolidayAction(String userId, Boolean holidayPerm) {

		String systemUserId = UserInfo.getUserId();	
		User users  = [SELECT Id , UserRoleId, UserRole.Name, UserRole.ParentRoleId FROM USER WHERE Id =: systemUserId ];

		String strQry = 'SELECT Id, name, CreatedDate, HolidayAction_Type__c, HolidayAction_IsConfirm__c, ';
			   strQry +='HolidayAction_Approver__r.LastName, CreatedById, HolidayAction_Days__c,FirstHolidayRequest__c, SecondApproverRequest__c,';
//			   strQry +='FirstHolidayRequest__r.Name, SecondApproverSelection__c, HolidayAction_Parent__r.Holiday_User__c ';
		       strQry +='FirstHolidayRequest__r.Name, SecondApproverRequest__r.Name, HolidayAction_Parent__r.Holiday_User__c ';
			   strQry +='FROM HolidayAction__c ';

		List<HolidayAction__c> holidayAction = Database.query(strQry);

		//권한이 있는 경우 모두 조회
		if(holidayPerm){			
			strQry += 'WHERE HolidayAction_Parent__r.Holiday_User__c  = ' + '\'' + userId + '\' ';
			strQry += 'ORDER BY CreatedDate DESC';
			system.debug('1. isAccessible------------------------');
		}else{

		/*
		권한이 없는 경우 
		1. CreatedById 가 세션 유저  
		2. 레코드 Owner가 HasrecordId 유저
		3. 승인된 레코드는 보이지 않는다. 
		*/
			system.debug('2. isAccessible------------------------');
			strQry += 'WHERE CreatedById = ' + '\'' + systemUserId  + '\'  AND OwnerId  = ' + '\'' + userId  + '\' ' + ' AND HolidayAction_IsConfirm__c = false ';					
			strQry += 'ORDER BY CreatedDate DESC';
		}

		List<HolidayAction__c> returnStrQry = Database.query(strQry);
		system.debug('returnStrQry : '+returnStrQry);

		return returnStrQry;
	}


	@AuraEnabled
	public static List<Holiday__History> getHolidayHistory(String userId) {
		List<Holiday__c> h = [SELECT Id, Holiday_Calculated__c, Holiday_GivenHolidays__c, Holiday_IsAnnualleave__c, Holiday_JoinDate__c, Holiday_LastActivity__c,
									Holiday_NoticeLevel__c, Holiday_PeriodEnd__c, Holiday_Remain__c, Holiday_Uncountable__c, Holiday_Unpaid__c, Holiday_UseDays__c,
									Holiday_User__c, Holiday_WorkingYears__c, CarriedOverOfLastYear__c, UseDaysOfLastYear__c, RemainOfLastYear__c, Holiday_Monthly_Calculated__c,
									Holiday_Annual_Calculated__c, Holiday_Total_Remain__c, Holiday_FamilyEvent_Count__c, Holiday_SickLeave_Count__c, Holiday_WomenHoliday_Count__c,
									Holiday_PublicWorks_Count__c, MonthlyOfLastYear__c, HolidayRemainOfLastYear__c, Holiday_rewardDays__c, Holiday_Total_Count__c, fm_Holiday_rewardRemainDays__c,
									Holiday_reward_Total_Count__c, Holiday_BenefitPaymentDays__c
							FROM Holiday__c 
							WHERE Holiday_User__c = :userId limit 1];
		string hldId;
		for(Holiday__c objHoliday : h) {
			if(!h.isEmpty()) {
				hldId = objHoliday.Id;
			}
		}

		List<Holiday__History> returnHistoryInfo = [SELECT CreatedBy.Name, CreatedDate, Field, Id, NewValue, OldValue FROM Holiday__History WHERE ParentId = :hldId ORDER BY CreatedDate DESC Limit 50];
		system.debug('returnHistoryInfo =' + returnHistoryInfo);

		return returnHistoryInfo;
	}

	/*
	@AuraEnabled
	public static List<User> getUserCreatedDate(String userId){
		//String userId = UserInfo.getUserId();
		List<User> UserCreatedDate = [SELECT Id, CreatedDate 
		                              FROM User 
		                              WHERE Id NOT IN (SELECT Holiday_User__c FROM Holiday__c) 
		                              AND IsActive = true 
		                              AND UserType = 'Standard'];
		return UserCreatedDate;

	}
	

	@AuraEnabled
	public static List<ProcessInstance> getProcessInstance(String recordId){
  		system.debug('recordId :: ' + recordId);
		String userId = UserInfo.getUserId();
		//ProcessInstance Object에서 
		Id searchId = Id.valueOf(recordId);
		List<ProcessInstance> returnProcessInstance= [SELECT Id,ProcessDefinitionId,TargetObjectId,TargetObject.name
		 FROM ProcessInstance where TargetObjectId in (select id from HolidayAction__c where id=:searchId)];
		 return returnProcessInstance;
	}
	*/


	@AuraEnabled
    public static Map<String, String> getObjectFieldLabel(String sObjectName) {
		Schema.SObjectType schemaObject = Schema.getGlobalDescribe().get(sObjectName); 
		Schema.DescribeSobjectResult schemaObjectResult = schemaObject.getDescribe();
		Map<String, Schema.SObjectField> mapSchemaObjectResult = schemaObjectResult.fields.getMap();        

		Map<String, String> mapFieldLabel = new Map<String, String>();
		for(Schema.SObjectField obj : mapSchemaObjectResult.values()){                            
			Schema.DescribeFieldResult f = mapSchemaObjectResult.get(obj.getDescribe().getName()).getDescribe();
			system.debug('mapFieldLabel :: ' + mapFieldLabel);
			mapFieldLabel.put(f.getName(), f.getLabel());
		}

		return mapFieldLabel;
	}
}