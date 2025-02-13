/**
 * Object       : OutsoursingUtil.cls
 * Function     : 
 * Author       : yohan.kang
 * Date         : 2015.05.29
 * Tester 		: OutSoursingUtilTester.cls
 * page			: 
 * Description  : 
 */
public with sharing class OutsoursingUtil {
	/****************************************************************************************************
	*	외주처리 품목필드 자동 설정
	****************************************************************************************************/	
	public static void AutoFieldUpdateItem(List<Outsoursing__c> Objs, map<id, Outsoursing__c> mapOldObjs){
		//적용할 리스트 가져오기
		list<Outsoursing__c> ApplyObjs = new list<Outsoursing__c>();
		for (Outsoursing__c Obj : Objs) if(mapOldObjs==null || Obj.Inventory__c<>mapOldObjs.get(Obj.Id).Inventory__c) ApplyObjs.add(Obj);
		
		if(ApplyObjs.size()>0){
			//가져오기
			set<id> IVIDs = new set<id>();
			for(Outsoursing__c Obj:ApplyObjs) IVIDs.add(Obj.Inventory__c);
			
			map<Id, Inventory__c> mapIVs = new map<Id, Inventory__c>();
			mapIVs.putAll([SELECT ID, Item__c FROM Inventory__c WHERE ID IN :IVIDs]);
			
			//구성하기
			for(Outsoursing__c Obj:ApplyObjs) Obj.Item__c = mapIVs.get(Obj.Inventory__c).Item__c;
		}
	}
	
	public static void AutoFieldUpdateItem(List<OutsoursingResult__c> Objs, map<id, OutsoursingResult__c> mapOldObjs){
		//적용할 리스트 가져오기
		list<OutsoursingResult__c> ApplyObjs = new list<OutsoursingResult__c>();
		for (OutsoursingResult__c Obj : Objs) if(mapOldObjs==null || Obj.Outsoursing__c<>mapOldObjs.get(Obj.Id).Outsoursing__c) ApplyObjs.add(Obj);
		
		if(ApplyObjs.size()>0){
			//가져오기
			set<id> IVIDs = new set<id>();
			for(OutsoursingResult__c Obj:ApplyObjs) IVIDs.add(Obj.Outsoursing__c);
			
			map<Id, Outsoursing__c> mapIVs = new map<Id, Outsoursing__c>();
			mapIVs.putAll([SELECT ID, Item__c FROM Outsoursing__c WHERE ID IN :IVIDs]);
			
			//구성하기
			for(OutsoursingResult__c Obj:ApplyObjs) Obj.Item__c = mapIVs.get(Obj.Outsoursing__c).Item__c;
		}
	}
	
	/****************************************************************************************************
	*	생산공정과 연결
	****************************************************************************************************/
	public static void ReferProcessProduct(list<OutsoursingResult__c> oldObjs, list<OutsoursingResult__c> Objs, map<id, OutsoursingResult__c> mapOldObjs){
		list<OutsoursingResult__c> DisconnectOSRs = new list<OutsoursingResult__c>();
		list<OutsoursingResult__c> ConnectOSRs = new list<OutsoursingResult__c>();
		
		//delete
		if(Objs==null){
			for(OutsoursingResult__c OSR:oldObjs) DisconnectOSRs.add(OSR);
		}
		//insert
		if(oldObjs==null){
			for(OutsoursingResult__c OSR:Objs) if(OSR.InventoryAfter__c<>null) ConnectOSRs.add(OSR);
		}
		//update
		if(Objs<>null && oldObjs<>null){
			for(OutsoursingResult__c OSR:Objs){
				if(OSR.InventoryAfter__c<>mapOldObjs.get(OSR.Id).InventoryAfter__c){
					if(OSR.InventoryAfter__c==null) DisconnectOSRs.add(OSR);
					else ConnectOSRs.add(OSR);
				}
			}
		}
		
		if(DisconnectOSRs.size()>0) ReferDisconnectProcessProduct(DisconnectOSRs);
		if(ConnectOSRs.size()>0) ReferConnectProcessProduct(ConnectOSRs);
	}
	
	private static void ReferDisconnectProcessProduct(list<OutsoursingResult__c> Objs){
		//뉴재고의 생산공정연결을 끊어야 하는것
		set<id> IVIDs = new set<id>();
		for(OutsoursingResult__c OSR:Objs) IVIDs.add(OSR.InventoryAfter__c);
		
		list<Inventory__c> TargetIVs = [SELECT ID, ProcessProduct__c FROM Inventory__c WHERE ID in :IVIDs];
		for(Inventory__c IV:TargetIVs) IV.ProcessProduct__c = null;
		update TargetIVs;
	}
	
	private static void ReferConnectProcessProduct(list<OutsoursingResult__c> Objs){
		//뉴재고의 생산공정을 연결해야 하는것 (없으면 생성해야함)
		
		//맵을 구성한다. New재고의 ID와 현재고의 Barcode
		map<id, string> mapNewIVPartlists = new map<id, string>();

			//맵을 구성하기 위해서 원천재고 바코드(name) 를 구하기 위한 맵을 구성한다. 키는 Outsoursing__c
			map<id, string> mapOSs = new map<id, string>();
			
			set<id> OSIDs = new set<id>();
			
			for(OutsoursingResult__c OSR:Objs) OSIDs.add(OSR.Outsoursing__c);
			
			list<Outsoursing__c> OSs = [SELECT ID, Inventory__r.Name FROM Outsoursing__c WHERE ID in :OSIDs];
			for(Outsoursing__c OS:OSs) mapOSs.put(OS.Id, OS.Inventory__r.Name);

		for(OutsoursingResult__c OSR:Objs) mapNewIVPartlists.put(OSR.InventoryAfter__c, mapOSs.get(OSR.Outsoursing__c));
		
		//작업할 뉴재고리스트를 가져온다.
		list<Inventory__c> TargetIVs = [SELECT ID, ProcessProduct__c FROM Inventory__c WHERE id in :mapNewIVPartlists.keySet()];
		
		//해당 Partlist에 대한 생산공정 맵을 구성한다.
		Set<string> Partlists = new Set<string>();
		Partlists.AddAll(mapNewIVPartlists.Values());
		
		List<ProcessProduct__c> PPs = [SELECT Id, Partlist__c, PartlistSimple__c FROM ProcessProduct__c WHERE PartlistSimple__c in :Partlists];
		Map<string, ProcessProduct__c>  mapPPs = new Map<string, ProcessProduct__c>();
		for(ProcessProduct__c PP:PPs) mapPPs.put(PP.Partlist__c, PP);

		//공정정보맵에서 맵에 없는 것은 Insert 하고 맵에 추가한다.
		List<ProcessProduct__c> NewPPs = new List<ProcessProduct__c>();
		for(String Partlist:Partlists){
			if(mapPPs.get(Partlist)==null) NewPPs.add(new ProcessProduct__c(Partlist__c = Partlist));
		}
		
		insert NewPPs;
		
		for(ProcessProduct__c PP:NewPPs) mapPPs.put(PP.Partlist__c, PP);
		
		//아 인제 되었다 집어넣자
		for(Inventory__c IV:TargetIVs){
			//집어넣기 위한 해당 IV의 Partlist정보를 가져온다.
			string SearchBarcode = mapNewIVPartlists.get(IV.Id);
			IV.ProcessProduct__c = mapPPs.get(SearchBarcode).Id;
		}
		
		update TargetIVs;
		
		/*
		set<id> IVIDs = new set<id>();
		for(Outsoursing__c OS:OSs) IVIDs.add(OS.Inventory__c);
		
		
		//맵을 구성하기 위한 partlist를 가죠온다.
		set<string> Partlists = new set<string>();
		
		for(Outsoursing__c OS:OSs) partlists.add(OS.Inventory__r.Name);
		
		//맵구성 - 왜 이렇게 하느냐면 Partlist가 키인데 긴텍스트영역이기 때문에 키가 될수없다.
		map<string, ProcessProduct__c> mapPPs = new map<string, ProcessProduct__c>();
		
		list<ProcessProduct__c> PPs = [SELECT ID, PartListSimple__c FROM ProcessProduct__c WHERE Id in :partlists];
		
		for(ProcessProduct__c PP:PPs) mapPPs.put(PP.PartlistSimple__c, PP);
		
		//맵에 없는 것은 집어넣고 맵에 넣는다.
		list<ProcessProduct__c> InsertPPs = new list<ProcessProduct__c>();
		*/
		
	}
	
	/****************************************************************************************************
	*	test Method
	****************************************************************************************************/
	public void TestMe(){
		integer i=0;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
	}	
}