public with sharing class GoogleContactController {
	@AuraEnabled
	public static Map<String, Object> getInitialData(){
		Map<String, Object> mapResult = new Map<String, Object>();
		GoogleAuthentication__c objConfig = [SELECT Id, ClientId__c, ApiKey__c, AccessToken__c, AccessTokenUpdated__c
                                               FROM GoogleAuthentication__c
                                              WHERE User__c =: UserInfo.getUserId()];
        
        Datetime accessTokenUpdatedDate = objConfig.AccessTokenUpdated__c;
        if(accessTokenUpdatedDate == null || accessTokenUpdatedDate.addDays(1) <= System.now()) objConfig.AccessToken__c = null;
		
        mapResult.put('objConfig', objConfig);

		String sUserEmail = UserInfo.getUserEmail();
		mapResult.put('userEmail', sUserEmail);
		return mapResult;
	}

    @AuraEnabled
    public static void doUpdateAuthentication(String accessToken){
        GoogleAuthentication__c objConfig = [SELECT Id, AccessToken__c
                                               FROM GoogleAuthentication__c
                                              WHERE User__c =: UserInfo.getUserId()];
        if(objConfig != null){
            objConfig.AccessToken__c = accessToken;
            objConfig.AccessTokenUpdated__c = System.now();
            update objConfig;
        }
    }
    
    @AuraEnabled
    public static String createContact(String datas){
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(datas);
        System.debug(result);

        String companyName = String.valueOf(result.get('companyName'));
        List<Account> objAccount = [SELECT Id, Name   FROM Account   WHERE Name =: companyName ];       
        //google remember에 설정되어 있는 이름 (ex: 김이박 사원 (대유넥스티어))에서 이름만 추출
        //remember에서 google연동할 때 이름 설정하는 방식이 총5가지
        //1.이름 
        //2.이름(회사명)
        //3.이름 직책
        //4.이름 직책(회사명)
        //5.회사명 이름 직책
        
        //구글 remember에 저장된 name 가져와서 공백으로 잘라서 list화
        System.debug('결과값이름 >>> ' + String.valueOf(result.get('name')));
        List<String> listGRName  = String.valueOf(result.get('name')).split(' ');

        Contact objCont  = new Contact();
        if(listGRName.size() == 1) {
            if(listGRName[0].contains('(')){
                List<String> listTemp = listGRName[0].split('\\(');
                objCont.LastName = listTemp[0];
            } else {
                objCont.LastName = listGRName[0];
            }
        } else {
            objCont.LastName = (listGRName.size() == 2) ? listGRName[0] : listGRName[1];
        } 

        // Account가 없으면 Account 생성
        if(objAccount.size() == 0) {
            Account objAcc = new Account();
            objAcc.Name    = companyName;
            objAcc.ShortName__c     = companyName; 
            objAcc.StateDistrict__c = String.valueOf(result.get('address'));
            objAcc.BillingState	    = String.valueOf(result.get('billingAddress_state'));
            objAcc.BillingStreet    = String.valueOf(result.get('billingAddress_street'));
            objAcc.BillingCity      = String.valueOf(result.get('billingAddress_city'));
            
            if(String.valueOf(result.get('companyFax'))   != null)  objAcc.Fax   = String.valueOf(result.get('companyFax'));
            if(String.valueOf(result.get('companyPhone')) != null)  objAcc.Phone = String.valueOf(result.get('companyPhone'));
            insert objAcc;

            Account acc = [SELECT Id FROM Account WHERE Name =: companyName ];
            objCont.AccountId = acc.Id;
        }   
        else {
            objCont.AccountId = objAccount[0].Id;
        }
        
        objCont.Phone    = String.valueOf(result.get('phone'));
        objCont.Email    = String.valueOf(result.get('email'));
        objCont.Title    = String.valueOf(result.get('position'));
        objCont.GoogleContactId__c = String.valueOf(result.get('googleId'));
        

        insert objCont;
        return objCont.Id;
    }
    
    @AuraEnabled
    public static List<Contact> getContact(String fSearchDate){
        Date convDate = Date.valueOf(fSearchDate);
        Integer d = convDate.day();
        Integer mon = convDate.month();
        Integer yr = convDate.year();
        DateTime srhDt = DateTime.newInstanceGMT(yr, mon, d);
        System.debug(srhDt);
        List<Contact> listContact = new List<Contact>([
            select Id, GoogleContactId__c
              from Contact
             where CreatedDate >= :srhDt
               and GoogleContactId__c != null
        ]);
        return listContact;
    }
}