public with sharing class CommonLookupController {
    @AuraEnabled
    public static List<DataWrapper> doGetItemList(String fObj, String fSearchKeyWord){
        List<DataWrapper> listResult = new List<DataWrapper>();

        String strSearchKey = '%' + fSearchKeyWord + '%';
        if(fObj == 'User') {
            List<User> listUserSearch = new List<User>([select Id, Name from User where Name LIKE :strSearchKey AND IsActive = true]);
            
            for (User row: listUserSearch) {
                listResult.add(new DataWrapper(row));
            }
        }
        //else if(fObj == 'Account') {
        //    strSearchKey = fSearchKeyWord + '%';
        //    List<Account> listAcctSearch = new List<Account>([select Id, Name, ShortName__c from Account where ShortName__c LIKE :strSearchKey order by ShortName__c]);
            
        //    for (Account row: listAcctSearch) {
        //        listResult.add(new DataWrapper(row));
        //    }
        //}
        else {
        	String sQuery = '';

        	sQuery += 'SELECT 	Id, Name';
        	sQuery += '  FROM 	' + fObj;
        	sQuery += ' WHERE 	Name LIKE :strSearchKey';

        	for(SObject sObj : Database.query(sQuery)) {
				listResult.add(new DataWrapper(sObj));
        	}
        }

        return listResult;
    }

    public with sharing class DataWrapper {
        @AuraEnabled public string strName    {get; set;}
        @AuraEnabled public string strId      {get; set;}
        //@AuraEnabled public String strSubName {get; set;}

        //@AuraEnabled public String strSub1 {get; set;}
        //@AuraEnabled public String strSub2 {get; set;}
        //@AuraEnabled public String strSub3 {get; set;}

		public DataWrapper(SObject sObj) {
			this.strId = String.valueOf(sObj.get('Id'));
            this.strName = String.valueOf(sObj.get('Name'));
		}        

        //public dataWrapper(String fId, String fName){
        //    this.strId = fId;
        //    this.strName = fName;
        //}

        //// fSubName : 조회 결과 리스트에서 Name 옆에 추가로 보여줄 필드나 설명 등을 추가함
        //public DataWrapper(String fId, String fName, String fSubName) {
        //    this.strId      = fId;
        //    this.strName    = fName;
        //    this.strSubName = fSubName;
        //}

        //public DataWrapper(String fId, String fName, String fSub1, String fSub2, String fSub3) {
        //    this.strId   = fId;
        //    this.strName = fName;
        //    this.strSub1 = fSub1;
        //    this.strSub2 = fSub2;
        //    this.strSub3 = fSub3;
        //}
    }
}