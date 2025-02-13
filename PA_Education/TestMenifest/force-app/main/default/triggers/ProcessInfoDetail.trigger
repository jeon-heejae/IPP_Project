/**
 * Object       : ProcessInfoDetail__c 트리거
 * Function     : 
 * Author       : yohan.kang
 * Date         : 2015.3.21
 * Tester 		: ProcessInfoTester.cls
 * page			: 
 * Description  : 
 */
trigger ProcessInfoDetail on ProcessInfoDetail__c (before insert, before update, before delete) {
	if(trigger.isBefore){
		if(trigger.isInsert || trigger.isUpdate){
			//공정정보 활성화 여부(IsActive__c)가 체크되어 있으면 수정할 수 없음
			ProcessInfoUtil.CheckIfIsActive(trigger.new);
		}
		if(trigger.isDelete){
			ProcessInfoUtil.CheckIfIsActive(trigger.old);
		}
	}
}