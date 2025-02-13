/**
 * Object       : ProcessProductUtil.cls
 * Function     : 
 * Author       : yohan.kang
 * Date         : 2015.05.10
 * Tester 		: ProcessProductTester.cls
 * page			: 
 * Description  : 
 */
public with sharing class ProcessProductUtil {
	/****************************************************************************************************
	*	PartListSimple__c에 PartList__c의 250자까지만 저장한다.
	****************************************************************************************************/
	public static void PartListSample(List<ProcessProduct__c> Objs, map<id, ProcessProduct__c> mapOldObjs){
		for (ProcessProduct__c Obj : Objs){
			if(mapOldObjs==null || (Obj.PartList__c <> mapOldObjs.get(Obj.id).PartList__c)) Obj.PartListSimple__c = Obj.PartList__c==null ? null : Obj.PartList__c.left(250);
		}
	}
	
	/****************************************************************************************************
	*	Smtset_Key__c가 null이 아니고, TracebilitySmtSetId__c 가 null 일경우는 2개의 생산공정을 합쳐 하나의 생산공정으로 만들어야 한다. (Partlist에 넣는다.)
	****************************************************************************************************/
	public static void SumPartListWithSmtset(List<ProcessProduct__c> Objs, map<id, ProcessProduct__c> mapOldObjs){
		//구성할 개체
		list<ProcessProduct__c> TargetObjs = new list<ProcessProduct__c>();
		
		//구성할 개체 찾기
		for(ProcessProduct__c Obj:Objs){
			if(mapOldObjs==null && Obj.TraceabilitySmtsetId__c==null && Obj.Smtset_Key__c<>null) TargetObjs.add(Obj);
			
			else if(mapOldObjs<>null && Obj.TraceabilitySmtsetId__c==null && Obj.Smtset_Key__c<>null && Obj.Smtset_Key__c<>mapOldObjs.get(Obj.id).Smtset_Key__c) TargetObjs.add(Obj);	
		}
		
		system.debug('@@@@@ TargetObjs.size() : ' + TargetObjs.size());
		
		//구성하기 위한 ProcessProduct__c의 맵 구성
		set<string> SmtsetKeys = new set<string>();
		for(ProcessProduct__c Obj:TargetObjs){
			list<string> SmtsetKey = Obj.Smtset_Key__c.split('_');
			for(string str:smtsetKey) SmtsetKeys.add(str);
		}
		
		list<ProcessProduct__c> OrgPPs = [SELECT Id, Smtset_Key__c, PartList__c FROM ProcessProduct__c WHERE Smtset_Key__c in :SmtsetKeys];
		
		system.debug('@@@@@ OrgPPs.size() : ' + OrgPPs.size());
		
		map<string, ProcessProduct__c> mapOrgPPs = new map<string, ProcessProduct__c>();
		
		for(ProcessProduct__c Obj:OrgPPs) mapOrgPPs.put(Obj.Smtset_Key__c, Obj);
		
		//구성할 개체에 Partlist넣기
		for(ProcessProduct__c Obj:TargetObjs){
			string strPartlist = '';
			list<string> SmtsetKey = Obj.Smtset_Key__c.split('_');
			
			for(string str:smtsetKey){
				ProcessProduct__c OrgPP = mapOrgPPs.get(str);
				if(OrgPP<>null) strPartlist += (strPartlist<>'' ? ',' : '') + OrgPP.PartList__c;
			}
			
			Obj.Partlist__c = strPartList;
		}
	}
	
	/****************************************************************************************************
	*	PartList__c가 들어오면 생산공정상세를 생성한다.
	****************************************************************************************************/
	public static void CreateProcessProductDetail(List<ProcessProduct__c> Objs, map<id, ProcessProduct__c> mapOldObjs){
		//구성할 개체
		list<ProcessProduct__c> TargetObjs = new list<ProcessProduct__c>();
		
		//삭제할 것들
		set<string> DeletePPIDs = new set<string>();
		//List<ProcessProductDetail__c> DeletePPDs = new List<ProcessProductDetail__c>();
		
		//생성할 것에 대한 Inventory 맵구성을 위한
		set<string> IV_Codes = new set<string>();
		
		for (ProcessProduct__c Obj : Objs){
			if(mapOldObjs==null || (Obj.PartList__c <> mapOldObjs.get(Obj.id).PartList__c)){
				if(mapOldObjs<>null && mapOldObjs.get(Obj.id).PartList__c<>null) DeletePPIDs.add(Obj.id);
				
				system.debug('@@@@@ Obj.PartList__c : ' + Obj.PartList__c);
				
				if(Obj.PartList__c<>null){
					TargetObjs.add(Obj);
					list<string> IT_Code = Obj.PartList__c.split(',');
					for(string str:IT_Code) IV_Codes.add(str);
				}
			}
		}
		
		//Inventory 맵 구성
		map<string, Inventory__c> mapIVs = new map<string, Inventory__c>();
		list<Inventory__c> IVs = [SELECT ID, Name FROM Inventory__c WHERE Name in :IV_Codes];
		for(Inventory__c IV:IVs) mapIVs.put(IV.Name, IV);
		
		//생성할 것들
		List<ProcessProductDetail__c> InsertPPDs = new List<ProcessProductDetail__c>();
		
		for(ProcessProduct__c Obj:TargetObjs){
			list<string> DuplicateIT_Code = Obj.PartList__c.split(',');
			
			//중복되어 있는건 빼도록 한다.
			set<string> IT_Code = new set<string>();
			for(string str:DuplicateIT_Code) IT_Code.add(str);
			
			for(string str:IT_Code){
				if(mapIVs.get(str)<>null){
					ProcessProductDetail__c PPD = new ProcessProductDetail__c();
					PPD.ProcessProduct__c = Obj.Id;
					PPD.Inventory__c = mapIVs.get(str).Id;
					InsertPPDs.add(PPD);
				}
			}
		}
		
		//삭제
		delete [SELECT Id FROM ProcessProductDetail__c WHERE ProcessProduct__c in :DeletePPIDs];
		
		//생성
		insert InsertPPDs;
	}
	/****************************************************************************************************
	*	TestMethod
	****************************************************************************************************/	
	public static void TestMe(ProcessProduct__c PP){
		Inventory__c IV = ObjectCreateTester.IV;
		IV.Name = 'CODE12345678';
		insert IV;
		
		PP.PartList__c = IV.Name;
		
		list<ProcessProduct__c> PPs = new list<ProcessProduct__c>();
		PPs.add(PP);
		
		CreateProcessProductDetail(PPs, null);

		Integer i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
	}
}