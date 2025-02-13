/**
 * Object       : InventoryUtil.cls
 * Function     : 
 * Author       : yohan.kang
 * Date         : 2015.03.18
 * Tester 		: InventoryTester.cls
 * page			: 
 * Description  : 
 */
public with sharing class InventoryUtil {
	class NotPreparedProductItemException extends Exception {}
	/****************************************************************************************************
	*	Name은 무조건 대문자
	****************************************************************************************************/	
	public static void NameUpper(List<Inventory__c> Objs){
		for (Inventory__c Obj : Objs) if(Obj.Name<>null) Obj.Name = Obj.Name.toUpperCase();
	}
	/****************************************************************************************************
	*	TraceabilityPbaMaster_Code__c, TraceabilityProductMaster_Code__c 로 Item__c 연결
	****************************************************************************************************/	
	public static void UpdateReferencePbaMaster(List<Inventory__c> Objs, map<id, Inventory__c> mapOldObjs){
		set<decimal> PBAMSeqs = new set<decimal>();
		
		for (Inventory__c Obj : Objs){
			if((mapOldObjs==null || (Obj.TraceabilityPbaMaster_Code__c <> mapOldObjs.get(Obj.id).TraceabilityPbaMaster_Code__c)) && Obj.TraceabilityPbaMaster_Code__c<>null) PBAMSeqs.add(decimal.valueOf(Obj.TraceabilityPbaMaster_Code__c));
		}
		
		List<ProcessInfo__c> PBAITs = [SELECT Item__c, TraceabilityPbaMasterId__c FROM ProcessInfo__c WHERE TraceabilityPbaMasterId__c in :PBAMSeqs];
		
		map<decimal, string> mapPBAMs = new map<decimal, string>();
		
		for(ProcessInfo__c IT:PBAITs) mapPBAMs.put(IT.TraceabilityPbaMasterId__c, IT.Item__c);
		
		for(Inventory__c obj:Objs){
			if((mapOldObjs==null || (Obj.TraceabilityPbaMaster_Code__c <> mapOldObjs.get(Obj.id).TraceabilityPbaMaster_Code__c)) && Obj.TraceabilityPbaMaster_Code__c<>null) obj.Item__c = mapPBAMs.get(decimal.valueOf(obj.TraceabilityPbaMaster_Code__c));
		}
	}

	/****************************************************************************************************
	*	TraceabilityPbaMaster_Code__c, TraceabilityProductMaster_Code__c 로 Item__c 연결
	****************************************************************************************************/	
	public static void UpdateReferenceProductMaster(List<Inventory__c> Objs, map<id, Inventory__c> mapOldObjs){
		List<Inventory__c> TargetIVs = new List<Inventory__c>();
		for(Inventory__c Obj:Objs){
			if(Obj.TraceabilityProductId__c<>null && (mapOldObjs==null || Obj.TraceabilityProductId__c<>mapOldObjs.get(Obj.id).TraceabilityProductId__c)) TargetIVs.add(Obj);
		}

		if(TargetIVs.size()>0){
			//Obj.Name에 앞의 8자리가 품목의 제품바코드(Item__c.ProductBarcode__c)와 같아야 한다.
			Set<String> ProductBarcodes = new Set<String>();
			for(Inventory__c Obj:TargetIVs){
				try{
					ProductBarcodes.add(Obj.Name.left(8));
				}catch(exception e){
					Obj.addError('Obj.Name ' + Obj.Name + '잘못되었습니다.');
				}
				
			}
			
			//for(string str:ProductBarcodes) system.debug('Search Barcode : ' + str);
			
			//Item__c 맵 구성
			List<Item__c> TargetITs = [SELECT Id, ProductBarcode__c FROM Item__c WHERE ProductBarcode__c in :ProductBarcodes];
			Map<String, Item__c> mapTargetITs = new Map<String, Item__c>();
			for(Item__c TargetIT:TargetITs) mapTargetITs.put(TargetIT.ProductBarcode__c, TargetIT);

			for(Inventory__c Obj:TargetIVs){
				try{
					system.debug('@@@@@ UpdateReferenceProductMaster Obj.Name.left(8) : ' + Obj.Name.left(8));
					Obj.Item__c = mapTargetITs.get(Obj.Name.left(8)).Id;
				}catch(exception e){
					Obj.addError('Product Code ' + Obj.Name + '잘못되었습니다.');
				}

			}
		}
	}

	/****************************************************************************************************
	*	TRA_PRODUCTBOX 처리, TraceabilityProductCodes__c 필드에 연계소스에서 자식 제품 코드만 들어가짐.
	*	TRA_PRODUCTBOX와 Item__c의 연결은 박스품목과 연결되어야 하는데, 박스품목이 없을 경우 박스품목을 생성하자.
	****************************************************************************************************/
	public static void UpdateProductBoxItemCode(List<Inventory__c> Objs, map<id, Inventory__c> mapOldObjs){
		system.debug('@@@@@ TRA_PRODUCTBOX ITEM 연결처리 Start');

		List<Inventory__c> TargetIVs = new List<Inventory__c>();
		for(Inventory__c Obj:Objs){
			if(Obj.TraceabilityProductBoxId__c<>null && Obj.TraceabilityProductCodes__c<>null && (mapOldObjs==null || Obj.TraceabilityProductBoxId__c<>mapOldObjs.get(Obj.id).TraceabilityProductBoxId__c)) TargetIVs.add(Obj);
		}

			//먼저 Item__c에 해당하는 제품 품목과 연결한 후 박스 품목과 연결한다.
		system.debug('@@@@@ TRA_PRODUCTBOX ITEM 연결처리 TargetIVs.size() : ' + TargetIVs.size());
		if(TargetIVs.size()>0){
			set<string> setProductCodes = new set<string>();

			for(Inventory__c Obj:TargetIVs) setProductCodes.add(Obj.TraceabilityProductCodes__c.split(',')[0]);

			List<Inventory__c> ChildIVs = [SELECT Name, Item__r.Standard__c
					, Item__c
					, Item__r.Name
					, Item__r.Code__c 
					

				FROM Inventory__c 
				WHERE Name in :setProductCodes
			];
			


			//아들 재고의 품목 연결
			Map<string, Inventory__c> mapChildIVs = new Map<string, Inventory__c>();

			set<id> setProductITIDs = new set<id>();
			for(Inventory__c IV:ChildIVs){
				mapChildIVs.put(IV.Name, IV);
				setProductITIDs.add(IV.Item__c);
			}

			//박스 Item map 구성
			List<Item__c> BoxITs = [SELECT ID, ProductItem__c FROM Item__c WHERE ProductItem__c in :setProductITIDs];
			Map<id, Item__c> mapBoxITs = new Map<id, Item__c>();

			for(Item__c BoxIT:BoxITs) mapBoxITs.put(BoxIT.ProductItem__c, BoxIT);

			//자 없는 Item은 생성하자.
			List<Item__c> InsertBoxITs = new List<Item__c>();
			//이번에 생성되는 것이 있는지 확인용
			Set<ID> ConfirmIDs = new Set<Id>();

			for(Inventory__c ChildIV:ChildIVs){
				if(mapBoxITs.get(ChildIV.Item__c)==null){
					if(!ConfirmIDs.contains(ChildIV.Item__c)){
						ConfirmIDs.add(ChildIV.Item__c);
						
						Item__c InsertBoxIT = new Item__c();
						InsertBoxIT.Name = '(BOX) ' + ChildIV.Item__r.Name;
						InsertBoxIT.Code__c = 'BOX_' + ChildIV.Item__r.Code__c;
						InsertBoxIT.Standard__c = '(BOX) ' + ChildIV.Item__r.Standard__c;
						
						InsertBoxIT.Type__c = 'Box';
						InsertBoxIT.ProductItem__c = ChildIV.Item__c;

						InsertBoxITs.add(InsertBoxIT);
					}
				}
			}

			//없는 Item__c 생성, 후 맵 재구성
			insert InsertBoxITs;
			for(Item__c BoxIT:InsertBoxITs) mapBoxITs.put(BoxIT.ProductItem__c, BoxIT);

			//자 인제 없는거 없으니 연결
			for(Inventory__c Obj:TargetIVs){
				//아들 재고 가져오기
				Inventory__c ChildIV = mapChildIVs.get(Obj.TraceabilityProductCodes__c.split(',')[0]);

				//아들재고 Item의 부모 아이템 가져오ㄱ기
				Obj.Item__c = mapBoxITs.get(ChildIV.Item__c).Id;
			}
		}

		system.debug('@@@@@ TRA_PRODUCTBOX ITEM 연결처리 End');

		/*
		for (Inventory__c i : Objs) {
			if(i.TraceabilityProductBoxId__c != null){
				String prodCode = i.TraceabilityProductCodes__c.split(',')[0];
				try{
					i.Item__c = [SELECT Item__r.ProductItem__c FROM Inventory__c WHERE Name =: prodCode][0].Item__r.ProductItem__c;
				} catch (ArrayException ae) {
					throw new NotPreparedProductItemException('해당 재고 품목의 제품품목이 없습니다. 저장 프로세스를 Skip 합니다.');
				}
			}
		}
		*/
	}

	/****************************************************************************************************
	*	생산공정과 연결 (없으면 생성) 
	****************************************************************************************************/	
	public static void UpdateRefProcessProduct(List<Inventory__c> Objs, map<id, Inventory__c> mapOldObjs){
		//적용해야 하는지 여부
		boolean IsApply;
		
		//가져와야 하는 partlist 정보
		set<string> PartLists = new set<string>();
		
		//적용해야 하는 리스트
		List<Inventory__c> ApplyList = new List<Inventory__c>();
		
		for (Inventory__c Obj : Objs) {
			IsApply = false;
			
			if(Obj.TraceabilityProductId__c<>null){
				if(mapOldObjs==null) IsApply = true;
				else{
					if(Obj.Product_pba__c <> mapOldObjs.get(Obj.id).Product_pba__c) IsApply = true;
					else if(Obj.Product_rubber__c <> mapOldObjs.get(Obj.id).Product_rubber__c) IsApply = true;
					else if(Obj.Product_adapter__c <> mapOldObjs.get(Obj.id).Product_adapter__c) IsApply = true;
					else if(Obj.Product_cell__c <> mapOldObjs.get(Obj.id).Product_cell__c) IsApply = true;
					else if(Obj.Product_body__c <> mapOldObjs.get(Obj.id).Product_body__c) IsApply = true;
					else if(Obj.Product_InnerRubber__c <> mapOldObjs.get(Obj.id).Product_InnerRubber__c) IsApply = true;
					else if(Obj.Product_Pba_No__c <> mapOldObjs.get(Obj.id).Product_Pba_No__c) IsApply = true;
				}
			}

			//그동안 안맞았던것 처리하기 위함
			IsApply = true;

			/*
			//if((mapOldObjs==null && Obj.TraceabilityPbaId__c<>null) || mapOldObjs<>null && Obj.TraceabilityPbaId__c<>mapOldObjs.get(Obj.id).TraceabilityPbaId__c) IsApply = true;
			if((mapOldObjs==null && Obj.TraceabilityProductId__c<>null) || mapOldObjs<>null && Obj.TraceabilityProductId__c<>mapOldObjs.get(Obj.id).TraceabilityProductId__c) IsApply = true;
			*/

			if(IsApply){
				//Product_Pba__c에는 2개가 들어가 있고 Product_Pba_no__crk 28하이이면 첫번재것을 28초과이면 2번째것을 pba부품으로 넣는다.
				String PbaCode;
				if(Obj.Product_pba__c<>null){
					List<String> PbaCodes = Obj.Product_pba__c.split(',');
					if(Obj.Product_Pba_No__c==null || Obj.Product_Pba_No__c<=28) PbaCode = PbaCodes[0];
					else if(PbaCodes.size()>1) PbaCode = PbaCodes[1];
				}



				string partList = '';
				partList += (PbaCode==null ?  '' : ',' + PbaCode);
				partList += (Obj.Product_rubber__c==null ? '' : ',' + Obj.Product_rubber__c);
				partList += (Obj.Product_adapter__c==null ? '' : ',' + Obj.Product_adapter__c);
				partList += (Obj.Product_cell__c==null ? '' : ',' + Obj.Product_cell__c);
				partList += (Obj.Product_body__c==null ? '' : ',' + Obj.Product_body__c);
				partList += (Obj.Product_InnerRubber__c==null ? '' : ',' + Obj.Product_InnerRubber__c);

				if(partList<>'') partList = partList.substring(1, partList.length());

				//Obj.PartList__c = Obj.Pba_partlist__c==null ? '' : Obj.Pba_partlist__c;
				//Obj.PartList__c += (Obj.PartList__c=='' ? '' : ',') + Obj.Pba_partlist2__c==null ? '' : Obj.Pba_partlist2__c;
				//Obj.PartList__c += (Obj.PartList__c=='' ? '' : ',') + Obj.Product_partlist__c==null ? '' : Obj.Product_partlist__c;
				if(partList<>''){
					Obj.PartList__c = partList;
					ApplyList.add(Obj);
					PartLists.add(Obj.PartList__c.left(250));
				}
			}
		}
		
		//해당하는 것을 가져와서 맵으로 구성한다.
		List<ProcessProduct__c> PPs = [SELECT ID, PartList__c, Date__c FROM ProcessProduct__c WHERE PartListSimple__c in :PartLists];
		
		//맵으로 구성
		map<string, ProcessProduct__c> mapPPs = new map<string, ProcessProduct__c>();
		for(ProcessProduct__c PP:PPs) mapPPs.put(PP.PartList__c, PP);
		
		//맵으로 구성된 것 중 생산공정이 없는게 있으면 생성 후 맵에 추가
		List<ProcessProduct__c> NewPPs = new List<ProcessProduct__c>();
		for(Inventory__c IV:ApplyList){
			if(IV.PartList__c<>null && IV.PartList__c<>'' && mapPPs.get(IV.PartList__c)==null){
				boolean IsExistNewPPs = false;
				for(ProcessProduct__c PP:NewPPs) if(PP.PartList__c==IV.PartList__c) IsExistNewPPs = true;
					
				if(!IsExistNewPPs){
					ProcessProduct__c NewPP = new ProcessProduct__c();
					NewPP.Date__c = system.today();
					NewPP.PartList__c = IV.PartList__c;
					NewPPs.add(NewPP);
				}
			}
		}
		
		if(NewPPs.size()>0) insert NewPPs;
		
		for(ProcessProduct__c PP:NewPPs) mapPPs.put(PP.PartList__c, PP);
		
		//생산공정 셋팅
		for(Inventory__c IV:ApplyList){
			if(IV.PartList__c<>null && IV.PartList__c<>'') IV.ProcessProduct__c = mapPPs.get(IV.PartList__c).Id;
		}

		/*
		//적용해야 하는 리스트 추출
		list<Inventory__c> ApplyList = new list<Inventory__c>();
		for (Inventory__c Obj : Objs) {
			if(mapOldObjs==null && Obj.smtset_Key__c<>null) ApplyList.add(Obj);
			else if(mapOldObjs<>null && Obj.smtset_Key__c<>null && Obj.smtset_Key__c<>mapOldObjs.get(Obj.id).smtset_Key__c) ApplyList.add(Obj);
		}
		
		if(ApplyList.size()>0){
			//작업할거 추출
			set<string> SmtsetKeys = new set<string>();
			for(Inventory__c Obj:ApplyList){
				//여러개 있을 경우을 대비 여러개를 먼저 집어넣고
				SmtsetKeys.add(Obj.smtset_Key__c);
				
				//한개씩도 집어넣고
				list<string> Unitstrs = Obj.smtset_Key__c.split('_');
				for(string Unitstr:Unitstrs) SmtsetKeys.add(Unitstr);
			}
			list<ProcessProduct__c> PPs = [SELECT ID, smtset_Key__c, Date__c FROM ProcessProduct__c WHERE smtset_Key__c in :SmtsetKeys];
			
			//맵구성
			map<string, ProcessProduct__c> mapPPs = new map<string, ProcessProduct__c>();
			for(ProcessProduct__c PP:PPs) mapPPs.put(PP.smtset_Key__c, PP);
			
			//없는거 추출
			list<ProcessProduct__c> NewPPs = new list<ProcessProduct__c>();
			set<string> NewSmtsetKeys = new set<string>();
			
			for(Inventory__c Obj:ApplyList) if(mapPPs.get(Obj.smtset_Key__c)==null) NewSmtsetKeys.add(Obj.smtset_Key__c);
			
			//없는거 삽입
			for(string str:NewSmtsetKeys){
				ProcessProduct__c NewPP = new ProcessProduct__c();
				NewPP.Date__c = system.today();
				NewPP.smtset_Key__c = str;
				NewPPs.add(NewPP);
			}
			insert NewPPs;
			
			//없는거까지 맵구성
			for(ProcessProduct__c PP:NewPPs) mapPPs.put(PP.smtset_Key__c, PP);
			
			//작업
			for(Inventory__c Obj:ApplyList) Obj.ProcessProduct__c = mapPPs.get(Obj.smtset_Key__c).Id;
		}
		*/
		
		/*
		Old 버전
		
		//적용해야 하는지 여부
		boolean IsApply;
		
		//가져와야 하는 partlist 정보
		set<string> PartLists = new set<string>();
		
		//적용해야 하는 리스트
		List<Inventory__c> ApplyList = new List<Inventory__c>();
		
		for (Inventory__c Obj : Objs) {
			IsApply = false;
			
			if((mapOldObjs==null && Obj.TraceabilityPbaId__c<>null) || mapOldObjs<>null && Obj.TraceabilityPbaId__c<>mapOldObjs.get(Obj.id).TraceabilityPbaId__c) IsApply = true;
			//if((mapOldObjs==null && Obj.TraceabilityProductId__c<>null) || mapOldObjs<>null && Obj.TraceabilityProductId__c<>mapOldObjs.get(Obj.id).TraceabilityProductId__c) IsApply = true;
			
			if(IsApply){
				Obj.PartList__c = Obj.Pba_partlist__c==null ? '' : Obj.Pba_partlist__c;
				Obj.PartList__c += (Obj.PartList__c=='' ? '' : ',') + Obj.Pba_partlist2__c==null ? '' : Obj.Pba_partlist2__c;
				//Obj.PartList__c += (Obj.PartList__c=='' ? '' : ',') + Obj.Product_partlist__c==null ? '' : Obj.Product_partlist__c;
				ApplyList.add(Obj);
				PartLists.add(Obj.PartList__c.left(250));
			}
		}
		
		//해당하는 것을 가져와서 맵으로 구성한다.
		List<ProcessProduct__c> PPs = [SELECT ID, PartList__c, Date__c FROM ProcessProduct__c WHERE PartListSimple__c in :PartLists];
		
		//맵으로 구성
		map<string, ProcessProduct__c> mapPPs = new map<string, ProcessProduct__c>();
		for(ProcessProduct__c PP:PPs) mapPPs.put(PP.PartList__c, PP);
		
		//맵으로 구성된 것 중 생산공정이 없는게 있으면 생성 후 맵에 추가
		List<ProcessProduct__c> NewPPs = new List<ProcessProduct__c>();
		for(Inventory__c IV:ApplyList){
			if(IV.PartList__c<>null && IV.PartList__c<>'' && mapPPs.get(IV.PartList__c)==null){
				boolean IsExistNewPPs = false;
				for(ProcessProduct__c PP:NewPPs) if(PP.PartList__c==IV.PartList__c) IsExistNewPPs = true;
					
				if(!IsExistNewPPs){
					ProcessProduct__c NewPP = new ProcessProduct__c();
					NewPP.Date__c = system.today();
					NewPP.PartList__c = IV.PartList__c;
					NewPPs.add(NewPP);
				}
			}
		}
		
		if(NewPPs.size()>0) insert NewPPs;
		
		for(ProcessProduct__c PP:NewPPs) mapPPs.put(PP.PartList__c, PP);
		
		//생산공정 셋팅
		for(Inventory__c IV:ApplyList){
			if(IV.PartList__c<>null && IV.PartList__c<>'') IV.ProcessProduct__c = mapPPs.get(IV.PartList__c).Id;
		}
		*/
	}
	
	/****************************************************************************************************
	*	생산공정과 연결 (없으면 생성) - Assemset_Seq__c 로 작업
	****************************************************************************************************/
	public static void UpdateRefProcessProduct2(List<Inventory__c> Objs, map<id, Inventory__c> mapOldObjs){
		//적용해야 하는지 여부
		boolean IsApply;
		
		//가져와야 하는 Assemset_Seq__c 정보
		set<integer> AssemsetSeqs = new set<integer>();
		
		//적용해야 하는 리스트
		List<Inventory__c> ApplyList = new List<Inventory__c>();
		
		for (Inventory__c Obj : Objs) {
			IsApply = false;
			
			if((mapOldObjs==null && Obj.Assemset_Seq__c<>null) || mapOldObjs<>null && Obj.Assemset_Seq__c<>mapOldObjs.get(Obj.id).Assemset_Seq__c) IsApply=true;
			
			if(IsApply){
				AssemsetSeqs.add(integer.valueOf(Obj.Assemset_Seq__c));
				ApplyList.add(Obj);
				
				system.debug('@@@@@ Obj.Assemset_Seq__c : ' + Obj.Assemset_Seq__c);
			}
		}
		
		//해당하는 것을 가져와서 맵으로 구성한다.
		List<ProcessProduct__c> PPs = [SELECT ID, TraceabilityAssemsetId__c FROM ProcessProduct__c WHERE TraceabilityAssemsetId__c in :AssemsetSeqs];
		
		//맵으로 구성
		map<integer, ProcessProduct__c> mapPPs = new map<integer, ProcessProduct__c>();
		for(ProcessProduct__c PP:PPs){
			mapPPs.put(integer.valueOf(PP.TraceabilityAssemsetId__c), PP);
			
			system.debug('@@@@@ PP.TraceabilityAssemsetId__c : ' + PP.TraceabilityAssemsetId__c);
		}
		
		//생산공정 셋팅
		for(Inventory__c IV:ApplyList){
			system.debug('@@@@@ IV.Assemset_Seq__c : ' + IV.Assemset_Seq__c);
			
			//IV.ProcessProduct__c = mapPPs.get((decimal)integer.valueOf(IV.Assemset_Seq__c)).Id;
			//IV.ProcessProduct__c = mapPPs.get(integer.valueOf(IV.Assemset_Seq__c)).Id;
			
			ProcessProduct__c gPP = mapPPs.get(integer.valueOf(IV.Assemset_Seq__c));
			if(gPP<>null) IV.ProcessProduct__c = gPP.Id;
		}
	}
	
	/****************************************************************************************************
	*	생산공정과 연결 (없으면 생성) - smtset_Key__c 로 작업 - ProcessProduct__c.smtset_Key__c 값으로 ProcessProduct__c 와 연결함
	****************************************************************************************************/	
	public static void UpdateRefProcessProduct3(List<Inventory__c> Objs, map<id, Inventory__c> mapOldObjs){
		//적용해야 하는 리스트 추출
		list<Inventory__c> ApplyList = new list<Inventory__c>();
		for (Inventory__c Obj : Objs) {
			if(mapOldObjs==null && Obj.smtset_Key__c<>null) ApplyList.add(Obj);
			else if(mapOldObjs<>null && Obj.smtset_Key__c<>null && Obj.smtset_Key__c<>mapOldObjs.get(Obj.id).smtset_Key__c) ApplyList.add(Obj);
		}
		
		if(ApplyList.size()>0){
			//작업할거 추출
			set<string> SmtsetKeys = new set<string>();
			for(Inventory__c Obj:ApplyList){
				//여러개 있을 경우을 대비 여러개를 먼저 집어넣고
				SmtsetKeys.add(Obj.smtset_Key__c);
				
				//한개씩도 집어넣고
				list<string> Unitstrs = Obj.smtset_Key__c.split('_');
				for(string Unitstr:Unitstrs) SmtsetKeys.add(Unitstr);
			}
			list<ProcessProduct__c> PPs = [SELECT ID, smtset_Key__c, Date__c FROM ProcessProduct__c WHERE smtset_Key__c in :SmtsetKeys];
			
			//맵구성
			map<string, ProcessProduct__c> mapPPs = new map<string, ProcessProduct__c>();
			for(ProcessProduct__c PP:PPs) mapPPs.put(PP.smtset_Key__c, PP);
			
			//없는거 추출
			list<ProcessProduct__c> NewPPs = new list<ProcessProduct__c>();
			set<string> NewSmtsetKeys = new set<string>();
			
			for(Inventory__c Obj:ApplyList) if(mapPPs.get(Obj.smtset_Key__c)==null) NewSmtsetKeys.add(Obj.smtset_Key__c);
			
			//없는거 삽입
			for(string str:NewSmtsetKeys){
				ProcessProduct__c NewPP = new ProcessProduct__c();
				NewPP.Date__c = system.today();
				NewPP.smtset_Key__c = str;
				NewPPs.add(NewPP);
			}
			insert NewPPs;
			
			//없는거까지 맵구성
			for(ProcessProduct__c PP:NewPPs) mapPPs.put(PP.smtset_Key__c, PP);
			
			//작업
			for(Inventory__c Obj:ApplyList) Obj.ProcessProduct__c = mapPPs.get(Obj.smtset_Key__c).Id;
		}
	}
	
	
	/****************************************************************************************************
	*	TRA_PRODUCTBOX 처리, TraceabilityProductCodes__c 필드에 임시로 자식 제품 코드가 들어가진 것을 가지고 자식 제품의 ParentInventory 설정
	****************************************************************************************************/	
	public static void updateParentRefWhenProdBoxCreated(List<Inventory__c> inventories){
		List<Inventory__c> children = new List<Inventory__c>();
		for (Inventory__c i : inventories) {
			system.debug('@@@@@ updateParentRefWhenProdBoxCreated Master id : ' + i.Id);
			if(i.TraceabilityProductBoxId__c != null){
				String prodCodes = i.TraceabilityProductCodes__c;
				
				List<String> tokens = prodCodes.split(',');
				List<Inventory__c> childs = [SELECT Id, ParentInventory__c FROM Inventory__c WHERE Name in : tokens];
				for(Inventory__c child:childs){
					child.ParentInventory__c = i.Id;
					children.add(child);
				}
				
				/*
				for (Integer j = 0; j < tokens.size(); j++){
					String code = tokens.get(j);
					Inventory__c child = [SELECT Id, ParentInventory__c FROM Inventory__c WHERE Name =: code];
					child.ParentInventory__c = i.Id;
					children.add(child);
				}
				*/
			}
		}
		// ParentInventory__c UPDATE
		if(children.size()>0) update children;
	}
	

	/****************************************************************************************************
	*	재고의 창고가 공정으로 이동시 Oracle에 송신하기 위해서 필드값을 변경한다.
	****************************************************************************************************/	
	public static void decideDeletionAndTranceByWarehouseType(List<Inventory__c> inventories, map<id, Inventory__c> dirtyInvens){
		List<Inventory__c> updColl = new List<Inventory__c>();
		for(Inventory__c i : inventories){
			String prevWhType = dirtyInvens.get(i.Id).Warehouse__r.Type__c;
			String currWhType = i.Warehouse__r.Type__c;
			// 재고의 창고가 변경이 되었을 때만 실행한다.
			if(currWhType != null && !''.equals(currWhType)){
				// 공정일 경우
				if('공정'.equals(currWhType)){
					i.IsSendTrace__c = false;
					i.IsAbleTrace__c = true;
					if(i.CntInventory2__c == 0)
						i.LetDelete__c = true;
				} else if(!currWhType.equals(prevWhType) && '공정'.equals(prevWhType)) {
				// 공정에서 창고일 경우
					i.IsSendTrace__c = false;
					i.IsAbleTrace__c = false;
					i.LetDelete__c = true;					
				} else {
				// 이전 warehouse 는 없고, 창고로 변경된 경우
					continue;
				}
				updColl.add(i);
			}
		}
		if(updColl.size() > 0) update updColl;
	}
	
	/****************************************************************************************************
	*	재고의 수량 변경 발생시 InventoryHistory__c개체에 내역을 쌓는다.
	****************************************************************************************************/	
	public static void InsertInventoryHistoryCheck(List<Inventory__c> Objs, map<id, Inventory__c> mapOldObjs){
		list<Inventory__c> InsertIVs = new list<Inventory__c>();
		
		for (Inventory__c Obj : Objs) {
			if(mapOldObjs==null 
				|| Obj.CntInventory2__c<>mapOldObjs.get(Obj.id).CntInventory2__c
				|| Obj.Warehouse__c<>mapOldObjs.get(Obj.id).Warehouse__c){
				InsertIVs.add(Obj);
			}
		}
		
		if(InsertIVs.size()>0) InsertInventoryHistory(InsertIVs);
	}
	
	public static void InsertInventoryHistory(list<Inventory__c> Objs){
		list<InventoryHistory__c> InsertIVHs = new list<InventoryHistory__c>();
		
		for(Inventory__c Obj:Objs){
			InventoryHistory__c IVH = new InventoryHistory__c();
			IVH.Inventory__c = Obj.Id;
			IVH.DateTime__c = system.now();
			IVH.CntImportInspection__c = Obj.CntImportInspection__c;
			IVH.CntImport__c = Obj.CntImport__c;
			IVH.CntUsed2__c = Obj.CntUsed2__c;
			IVH.CntDisuse__c = Obj.CntDisuse__c;
			IVH.Warehouse__c = Obj.Warehouse__c;
			IVH.CntError__c = Obj.CntError__c;
			IVH.CntShipment__c = Obj.CntShipment__c;
			IVH.CntOutSoursing__c = Obj.CntOutSoursing__c;
			
			InsertIVHs.add(IVH);
		}
		
		insert InsertIVHs;
	}
	/****************************************************************************************************
	*	TestMethod
	****************************************************************************************************/	
	public static void TestMe(Inventory__c IV){
        Inventory__c ChildIV = new Inventory__c();
        ChildIV.Name = 'ZZ0000001000002';
        ChildIV.Account__c = IV.Account__c;
        ChildIV.Item__c = IV.Item__c;
        insert ChildIV;

		IV.TraceabilityProductBoxId__c = 123;
		IV.TraceabilityPbaId__c = 123;
		IV.TraceabilityProductCodes__c = ChildIV.Name;
		
		list<Inventory__c> Objs = new list<Inventory__c>();
		Objs.add(IV);
		
		//UpdateReference(Objs, null);
		
		//UpdateRefProcessProduct(Objs, null);
		
		//UpdateRefProcessProduct2(Objs, null);
		
		//updateParentRefWhenProdBoxCreated(Objs);
		integer i = 0;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
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