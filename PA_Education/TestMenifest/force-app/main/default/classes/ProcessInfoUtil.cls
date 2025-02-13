/**
 * Object       : ProcessInfoUtil.cls
 * Function     : 
 * Author       : yohan.kang
 * Date         : 2015.03.21
 * Tester 		: ProcessInfoTester.cls
 * page			: 
 * Description  : 
 */
public with sharing class ProcessInfoUtil {
	/****************************************************************************************************
	*	공정정보 활성화 여부(IsActive__c)가 체크되어 있으면 수정할 수 없음
	*	IsSendTrace__c가 false에서 true로 변경될때에는 가능 (연계항목임)
	*	공정정보를 비활성화하게 되면 IsSendTrace__c는 false로 변경 (다시 연계하기 위함)
	*		공정정보는 품목구분이 제품.PBA인경우만 활성화 가능
	****************************************************************************************************/	
	public static void CheckIfIsActive(List<ProcessInfo__c> Objs, map<id, ProcessInfo__c> mapOldObjs){
		for (ProcessInfo__c Obj : Objs){
			if(Obj.IsActive__c && Obj.Type__c<>'제품' && Obj.Type__c<>'PBA') Obj.addError('제품 및 PBA만 활성화할 수 없습니다.');
			
			if(mapOldObjs.get(Obj.id).IsActive__c && Obj.IsActive__c && Obj.IsSendTrace__c==mapOldObjs.get(Obj.id).IsSendTrace__c) Obj.addError('활성화여부가 체크되어 있으면 수정할 수 없습니다.');
			
			if(mapOldObjs.get(Obj.id).IsActive__c && !Obj.IsActive__c && Obj.IsSendTrace__c==true) Obj.IsSendTrace__c = false;
		}
	}
	
	public static void CheckIfIsActive(List<ProcessInfoDetail__c> Objs){
		//ProcessInfo__c id set
		set<id> PIIDs = new set<id>();
		for (ProcessInfoDetail__c Obj : Objs) PIIDs.add(Obj.ProcessInfo__c);
		
		//map 구성
		map<Id, ProcessInfo__c> mapPIs = new map<id, ProcessInfo__c>();
		mapPIs.putAll([SELECT ID, IsActive__c FROM ProcessInfo__c WHERE ID in :PIIDs]);
		
		//체크
		for (ProcessInfoDetail__c Obj : Objs){
			if(mapPIs.get(Obj.ProcessInfo__c).IsActive__c) Obj.addError('공정정보가 활성화 되어 있으면 수정 및 삭제를 할 수 없습니다.');
		}
	}

	/****************************************************************************************************
	*   테스트메소드
	****************************************************************************************************/
	@TestVisible private static void TestMe(ProcessInfo__c gObjProcessInfo, ProcessInfoDetail__c gObjProcessInfoDetail){
		ProcessInfo__c objProcessInfoOld = gObjProcessInfo.clone();

		List<ProcessInfo__c> objs = new List<ProcessInfo__c>();
		objs.add(gObjProcessInfo);

		Map<Id, ProcessInfo__c> mapOldObjs = new Map<Id, ProcessInfo__c>();
		mapOldObjs.put(gObjProcessInfo.Id, objProcessInfoOld);

		CheckIfIsActive(objs, mapOldObjs);

		List<ProcessInfoDetail__c> listProcessInfoDetail = new List<ProcessInfoDetail__c>();
		listProcessInfoDetail.add(gObjProcessInfoDetail);
		
		CheckIfIsActive(listProcessInfoDetail);
	}
}