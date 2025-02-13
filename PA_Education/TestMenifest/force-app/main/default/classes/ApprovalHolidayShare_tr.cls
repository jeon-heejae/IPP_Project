/**
 * ==================================================================================
 * File Name         : ApprovalHolidayShare_tr
 * Author            : Changjoo.Sohn
 * Group             : Daeu Nextier
 * Description       :
 * Modification Logs
 * ==================================================================================
 *   Ver     Date          Author          Modification
 * ==================================================================================
 *   1.0      ?              ?             Initial Version
 *   2.0   2021-12-27     Changjoo.Sohn
**/
public without sharing class ApprovalHolidayShare_tr {
	public ApprovalHolidayShare_tr() {
		
	}
	/**
	 * 2차 승인자 체크여부
	 */
	/*public static Boolean secondCheck = false;*/
	public static String accessLevel = 'Edit';
	public static String rowCause = 'Manual';
	/*public static User user;*/

	/**
	 * 로그인한 user 정보
	 * @return User
	 */
	/*public static User doSelectUser(){
		User user = new user();
		List<User> listUser = [ SELECT Id, Username, LastName, FirstName, Name, ManagerId FROM User WHERE Id = :UserInfo.getUserId() ];
		for(User obj:listUser){
			user.Id = obj.Id;
			user.Username = obj.Username;
			user.LastName = obj.LastName;
			user.FirstName = obj.FirstName;
			user.Name = obj.Name;
			user.ManagerId = obj.ManagerId;
		}
		return user;
	}*/

	/*public static Map<String, String> mapUserInfo{
		get{
			if(mapUserInfo == null){
				List<User> listUser = [ SELECT Id, Username, LastName, FirstName, Name, ManagerId FROM User WHERE Id = :UserInfo.getUserId() ];

				for(User obj:listUser){
					mapUserInfo.put('Id', obj.Id);
					mapUserInfo.put('Username', obj.Username);
					mapUserInfo.put('LastName', obj.LastName);
					mapUserInfo.put('FirstName', obj.FirstName);
					mapUserInfo.put('ManagerId', obj.ManagerId);
					mapUserInfo.put('Name', obj.Name);
				}
			}
			return mapUserInfo;
		}
		set;
	}*/

	public static Map<String, String> doSelectUser(){
		Map<String, String> dataMap = new Map<String, String>();

		List<User> listUser = [ SELECT Id, Username, LastName, FirstName, Name, ManagerId FROM User WHERE Id = :UserInfo.getUserId() ];
		for(User obj:listUser){
			dataMap.put('Id', obj.Id);
			dataMap.put('Username', obj.Username);
			dataMap.put('LastName', obj.LastName);
			dataMap.put('FirstName', obj.FirstName);
			dataMap.put('ManagerId', obj.ManagerId);
			dataMap.put('Name', obj.Name);
		}
		return dataMap;
	}

	/**
	 * 최초 경비 신청시
	 * @param newLists [description]
	 * @param oldMaps  [description]
	 */
 		@AuraEnabled	
 		public static void doApprovalShareInsert(List<HolidayAction__c> newLists, Map<Id, HolidayAction__c> oldMaps){
		HolidayAction__Share holidayActionSh = new HolidayAction__Share();
		List<HolidayAction__Share> holidayActionShares = new List<HolidayAction__Share>();
		Map<String, String> dataMap = new Map<String, String>();
		List<User> listUser = [ SELECT Id, Username, LastName, FirstName, Name, ManagerId FROM User WHERE Id = :UserInfo.getUserId() ];

		for(HolidayAction__c obj:newLists){

			/**
			 * 1차 승인자는 필수이기 때문에 List변수에 담고
			 */
			holidayActionSh.ParentId = obj.Id;
			holidayActionSh.UserOrGroupId = obj.FirstHolidayRequest__c;
			holidayActionSh.AccessLevel = accessLevel;
			holidayActionSh.RowCause = rowCause;
			holidayActionShares.add(holidayActionSh);

			/**
			 * 2차 승인자가 체크 되어 있으면 Share Object 초기화해주고 List변수에 담는다.
			 * 로그인한 User의 Approval Manager를 검색 해온다.
			 */
			System.debug('obj.SecondApproverSelection__c========================='+obj.SecondApproverSelection__c);
			if(obj.SecondApproverSelection__c){
				holidayActionSh = new HolidayAction__Share();

				dataMap = doSelectUser();
				System.debug('dataMap.get(ManagerId)========================='+dataMap.get('ManagerId'));

				if(dataMap.get('ManagerId') != '' && dataMap.get('ManagerId') != null){
					holidayActionSh.ParentId = obj.Id;
					//	2021-12-27 CJ.Sohn 2차 승인자에 대한 레코드 공유는 휴가신청(HolidayAction)개체의 2차 승인자 필드에 해당하는 사용자(User) Id로 설정
					holidayActionSh.UserOrGroupId = obj.SecondApproverRequest__c;
//					holidayActionSh.UserOrGroupId = dataMap.get('ManagerId');
					holidayActionSh.AccessLevel = accessLevel;
					holidayActionSh.RowCause = rowCause;

					holidayActionShares.add(holidayActionSh);
				}	
			}
		}

		System.debug('holidayActionShares============================'+holidayActionShares);
		

		insert holidayActionShares;
		/*HolidayShares.id*/
	}

	/**
	 * Holiday Share Object Exist Check
	 * @param  targetId [description]
	 * @return          [description]
	 */
	public static list<HolidayAction__Share> holidayShareSelect(Set<Id> targetId){
		list<HolidayAction__Share> holidayShareList = new list<HolidayAction__Share>();

		System.debug('Method targetId======================='+targetId);
		holidayShareList = [ SELECT Id FROM HolidayAction__Share WHERE ParentId IN :targetId AND AccessLevel = 'Edit' ];
		return holidayShareList;
	}

	/**
	 * 기존에 Holiday Share Object에 값이 존재하면 삭제하고 다시 Insert
	 * @param newLists [description]
	 * @param oldMaps  [description]
	 */
	public static void doApprovalShareUpdate(List<HolidayAction__c> newLists, Map<Id, HolidayAction__c> oldMaps){
		list<HolidayAction__Share> holidayShareList = new list<HolidayAction__Share>();
		Boolean deleteFlag = false;
		Set<Id> targetId = new Set<Id>();

		for(HolidayAction__c obj : newLists){
			if( obj.FirstHolidayRequest__c != oldMaps.get(obj.Id).FirstHolidayRequest__c ||
				obj.SecondApproverSelection__c != oldMaps.get(obj.Id).SecondApproverSelection__c ){
				targetId.add(obj.Id);
			}
		}

		System.debug('Treigger targetId======================='+targetId);

		if(!targetId.isEmpty()){
			holidayShareList = holidayShareSelect(targetId);
			Delete holidayShareList;
			deleteFlag = true;
		}

		if(deleteFlag){
			doApprovalShareInsert(newLists, oldMaps);
		}
	}
		
}