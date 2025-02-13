public with sharing class ApprovalExpenseShare_tr {
	public ApprovalExpenseShare_tr() {
		
	}
	/**
	 * 2차 승인자 체크여부
	 */
	public static Boolean secondCheck = false;
	public static String accessLevel = 'Read';
	public static String rowCause = 'Manual';
	public static String testColumn = 'testColumn';
	public static User user;


    // public static String strTest00 {get; set;}
    // public static String strTest000 {get; set;}
	// public static String strTest {get; set;}
    // public static String strTest2 {get; set;}
    // public static String strTest3 {get; set;}
    // public static String strTest4 {get; set;}
    // public static String strTest5 {get; set;}
    // public static String strTest6 {get; set;}
    // public static String strTest7 {get; set;}

	// /**
	//  * 로그인한 user 정보
	//  * @return User
	//  */
	// /*public static User doSelectUser(){
	// 	User user = new user();
	// 	List<User> listUser = [ SELECT Id, Username, LastName, FirstName, Name, ManagerId FROM User WHERE Id = :UserInfo.getUserId() ];
	// 	for(User obj:listUser){
	// 		user.Id = obj.Id;
	// 		user.Username = obj.Username;
	// 		user.LastName = obj.LastName;
	// 		user.FirstName = obj.FirstName;
	// 		user.Name = obj.Name;
	// 		user.ManagerId = obj.ManagerId;
	// 	}
	// 	return user;
	// }*/

	// /*public static Map<String, String> mapUserInfo{
	// 	get{
	// 		if(mapUserInfo == null){
	// 			List<User> listUser = [ SELECT Id, Username, LastName, FirstName, Name, ManagerId FROM User WHERE Id = :UserInfo.getUserId() ];

	// 			for(User obj:listUser){
	// 				mapUserInfo.put('Id', obj.Id);
	// 				mapUserInfo.put('Username', obj.Username);
	// 				mapUserInfo.put('LastName', obj.LastName);
	// 				mapUserInfo.put('FirstName', obj.FirstName);
	// 				mapUserInfo.put('ManagerId', obj.ManagerId);
	// 				mapUserInfo.put('Name', obj.Name);
	// 			}
	// 		}
	// 		return mapUserInfo;
	// 	}
	// 	set;
	// }*/

	// public static Map<String, String> doSelectUser(){
	// 	Map<String, String> dataMap = new Map<String, String>();

	// 	List<User> listUser = [ SELECT Id, Username, LastName, FirstName, Name, ManagerId FROM User WHERE Id = :UserInfo.getUserId() ];

	// 	for(User obj:listUser){
	// 		dataMap.put('Id', obj.Id);
	// 		dataMap.put('Username', obj.Username);
	// 		dataMap.put('LastName', obj.LastName);
	// 		dataMap.put('FirstName', obj.FirstName);
	// 		dataMap.put('ManagerId', obj.ManagerId);
	// 		dataMap.put('Name', obj.Name);
	// 	}
	// 	return dataMap;
	// }

	// /**
	//  * 최초 경비 신청시
	//  * @param newLists [description]
	//  * @param oldMaps  [description]
	//  */
	// public static void doApprovalShareInsert(List<Expense__c> newLists, Map<Id, Expense__c> oldMaps){
	// 	Expense__Share expenseSh = new Expense__Share();
	// 	List<Expense__Share> expenseShares = new List<Expense__Share>();
	// 	Map<String, String> dataMap = new Map<String, String>();

	// 	for(Expense__c obj:newLists){

	// 		/**
	// 		 * 1차 승인자는 필수이기 때문에 List변수에 담고
	// 		 */
	// 		expenseSh.ParentId = obj.Id;
	// 		//expenseSh.UserOrGroupId = obj.FirstExpenseRequest__c;
	// 		// expenseSh.UserOrGroupId = obj.Approver1__c	;
	// 		// expenseSh.UserOrGroupId = obj.Approver2__c	;
	// 		// expenseSh.UserOrGroupId = obj.Approver3__c	;
	// 		// expenseSh.UserOrGroupId = obj.Approver4__c	;
	// 		expenseSh.AccessLevel = accessLevel;
	// 		expenseSh.RowCause = rowCause;

	// 		expenseShares.add(expenseSh);

	// 		/**
	// 		 * 2차 승인자가 체크 되어 있으면 Share Object 초기화해주고 List변수에 담는다.
	// 		 * 로그인한 User의 Approval Manager를 검색 해온다.
	// 		 */
	// 		System.debug('obj.SecondApproverSelection__c========================='+obj.SecondApproverSelection__c);
	// 		if(obj.SecondApproverSelection__c){
	// 			expenseSh = new Expense__Share();

	// 			dataMap = doSelectUser();
	// 			System.debug('dataMap.get(ManagerId)========================='+dataMap.get('ManagerId'));

	// 			if(dataMap.get('ManagerId') != '' && dataMap.get('ManagerId') != null){
	// 				expenseSh.ParentId = obj.Id;
	// 				expenseSh.UserOrGroupId = dataMap.get('ManagerId');
	// 				expenseSh.AccessLevel = accessLevel;
	// 				expenseSh.RowCause = rowCause;

	// 				expenseShares.add(expenseSh);
	// 			}
	// 		}
	// 	}

	// 	insert expenseShares;
	// 	/*expenseShares.id*/
	// }

	// /**
	//  * Expense Share Object Exist Check
	//  * @param  targetId [description]
	//  * @return          [description]
	//  */
	// public static list<Expense__Share> expenseShareSelect(Set<Id> targetId){
	// 	list<Expense__Share> expenseShareList = new list<Expense__Share>();

	// 	System.debug('Method targetId======================='+targetId);
	// 	expenseShareList = [ SELECT Id FROM Expense__Share WHERE ParentId IN :targetId AND AccessLevel = 'Edit' ];
	// 	return expenseShareList;
	// }

	// /**
	//  * 기존에 Expense Share Object에 값이 존재하면 삭제하고 다시 Insert
	//  * @param newLists [description]
	//  * @param oldMaps  [description]
	//  */
	// public static void doApprovalShareUpdate(List<Expense__c> newLists, Map<Id, Expense__c> oldMaps){
	// 	list<Expense__Share> expenseShareList = new list<Expense__Share>();
	// 	Boolean deleteFlag = false;
	// 	Set<Id> targetId = new Set<Id>();

	// 	for(Expense__c obj : newLists){
	// 		if( obj.FirstExpenseRequest__c != oldMaps.get(obj.Id).FirstExpenseRequest__c ||
	// 			obj.SecondApproverSelection__c != oldMaps.get(obj.Id).SecondApproverSelection__c ){
	// 			targetId.add(obj.Id);
	// 		}
	// 	}

	// 	System.debug('Treigger targetId======================='+targetId);

	// 	if(!targetId.isEmpty()){
	// 		expenseShareList = expenseShareSelect(targetId);
	// 		Delete expenseShareList;
	// 		deleteFlag = true;
	// 	}

	// 	if(deleteFlag){
	// 		doApprovalShareInsert(newLists, oldMaps);
	// 	}
	// }
		
}