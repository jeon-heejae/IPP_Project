public with sharing class ViewHRInfoController {

	/*라이트닝에서 식별할 수 있도록 해주는 어노테이션*/
	@AuraEnabled
	public static Map<String, Object> getInitData(String idEmployee, String pFromDt, String pToDt) {
		/*System.debug('param1 : ' + param1); Id 받을애*/

		Date dFromDt = Date.valueOf(pFromDt);
        Date dToDt   = Date.valueOf(pToDt);
 

		/*프로젝트에서 프로젝트명, 기간, 비율(/100해야함), 이름, 사원테이블의 롤*/
		List<PerformProject__c> pjList = new List<PerformProject__c>();
		pjList = [SELECT    Id, Project__r.Name,  fm_Term__c, Ratio__c, EmpNm__c, Employee__r.MainRole__c
				  FROM      PerformProject__c
				  WHERE     Employee__c = :idEmployee 
				  AND       fm_FromDate__c <= :dToDt
                  AND       fm_ToDate__c   >= :dFromDt
                  ORDER BY 	fm_FromDate__c];
		System.debug('pjList : ' + pjList);

		Employee__c emUser = [SELECT User__c, Name
				  			  FROM   Employee__c
				  			  WHERE  Id = :idEmployee];


		/*휴가 Table에서 휴가명, 휴가일, 휴가날짜1-5, 휴가타입 받아오기*/

		/*where조건*/
		/*Employee__c에 있는 Id가 오너ID랑 일치할 경우*/
		/*parma1이 지금 Employee__c에 Id값을 대입한거잖아*/
		  
		List<HolidayAction__c> haList = new List<HolidayAction__c>(); 
		haList = [SELECT 	HolidayAction_UserName__c, HolidayAction_Days__c, Name, Holiday_Date_Detail__c, HolidayAction_Type__c
				  FROM 		HolidayAction__c
				  WHERE  	OwnerId = :emUser.User__c
				  AND 	 	HolidayAction_IsConfirm__c = true
				  AND       fm_MinDate__c <= :dToDt
                  AND       fm_MaxDate__c >= :dFromDt
				  ORDER BY  Holiday_Date_Detail__c ASC ];
		System.debug('haList : ' + haList);


 		/*리턴해줄 맵 생성*/
 		/*object는 최상위 객체 이니까 list/map 다 가능가능*/
 		/*'key' => value  ('key'의 값은 value로 하겠다)*/    
		Map<String, Object> mapReturnValue = new Map<String, Object> {
			'pjList' => pjList,
			'haList' => haList,
			'emUser' => emUser
		};

		return mapReturnValue;
	}//getInitData

}//ViewHRInfoController