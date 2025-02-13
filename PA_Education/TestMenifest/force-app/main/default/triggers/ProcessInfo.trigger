/**
 * Object       : ProcessInfo__c 트리거
 * Function     : 
 * Author       : yohan.kang
 * Date         : 2015.3.16
 * Tester 		: ProcessInfoTester.cls
 * page			: 
 * Description  : 
 */
trigger ProcessInfo on ProcessInfo__c (before update, before delete) {
	if(trigger.isBefore){
		if(trigger.isUpdate){
			//공정정보 활성화 여부(IsActive__c)가 체크되어 있으면 수정할 수 없음
			//IsSendTrace__c가 false에서 true로 변경될때에는 가능 (연계항목임)
			//공정정보를 비활성화하게 되면 IsSendTrace__c는 false로 변경 (다시 연계하기 위함)
			ProcessInfoUtil.CheckIfIsActive(trigger.new, trigger.oldmap);
		}
	}
}