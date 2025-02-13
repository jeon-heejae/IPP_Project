/**
 * Object       : OutsoursingResult__c 트리거
 * Function     : 
 * Author       : yohan.kang
 * Date         : 2015.5.29
 * Tester 		: OutsoursingUtilTester.cls
 * page			: 
 * Description  : 
 */
trigger OutsoursingResult on OutsoursingResult__c (before insert, before update, after insert, after update, after delete) {
	if(trigger.isBefore){
		if(trigger.isInsert || trigger.isUpdate){
			//외주처리 품목필드 자동 설정
			OutsoursingUtil.AutoFieldUpdateItem(trigger.new, trigger.oldmap);
		}
	}
	
	if(trigger.isAfter){
		//생산공정과 연결
		if(trigger.isInsert || trigger.isUpdate || trigger.isDelete){
			OutsoursingUtil.ReferProcessProduct(trigger.old, trigger.new, trigger.oldmap);
			
		}
	}
}