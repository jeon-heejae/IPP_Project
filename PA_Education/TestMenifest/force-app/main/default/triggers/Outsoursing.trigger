/**
 * Object       : Outsoursing__c 트리거
 * Function     : 
 * Author       : yohan.kang
 * Date         : 2015.5.29
 * Tester 		: OutsoursingUtilTester.cls
 * page			: 
 * Description  : 
 */
trigger Outsoursing on Outsoursing__c (before insert, before update) {
	if(trigger.isBefore){
		if(trigger.isInsert || trigger.isUpdate){
			//외주처리 품목필드 자동 설정
			OutsoursingUtil.AutoFieldUpdateItem(trigger.new, trigger.oldmap);
		}
	}
}