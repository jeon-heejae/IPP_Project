/**
 * Object 		: ProcessProduct.trigger
 * Function 	:  
 * Author 		: Yohan.Kang.
 * Date 		: 2015. 5. 10
 * Tester 		: ProcessProductTester.cls
 * Description 	: 
 */
trigger ProcessProduct on ProcessProduct__c (after insert, after update, before insert, before update) {
	if(trigger.isBefore){
		if(trigger.isInsert || trigger.isUpdate){
			//PartListSimple__c에 PartList__c의 250자까지만 저장한다.
			ProcessProductUtil.PartListSample(trigger.new, trigger.oldmap);
			
			//Smtset_Key__c가 null이 아니고, TracebilitySmtSetId__c 가 null 일경우는 2개의 생산공정을 합쳐 하나의 생산공정으로 만들어야 한다. (Partlist에 넣는다.)
			ProcessProductUtil.SumPartListWithSmtset(trigger.new, trigger.oldmap);
		}
	}
	
	if(trigger.isAfter){
		if(trigger.isInsert || trigger.isUpdate){
			//PartList__c가 들어오면 생산공정상세를 생성한다. PartList__c에는 생산공정상세에 들어가는 Lot번호들이 , 를 구분으로 들어가 있다.
			ProcessProductUtil.CreateProcessProductDetail(trigger.new, trigger.oldmap);
		}
	}
}