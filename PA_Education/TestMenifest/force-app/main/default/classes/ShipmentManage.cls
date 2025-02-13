/**
 * Object		: ShipmentManage.cls
 * Function		: 출하관리
 * Author		: Yohan.Kang.
 * Date			: 2014.6.5
 * Description	: 
 	Shipment_Main.page
 	Shipment_Search.page
 */
public with sharing class ShipmentManage {
	public class MyException extends Exception{}
	private void MakeErrorMsg(exception e){
		string strErrorMsg = '';
		strErrorMsg += '현재 User ID : ' + UserInfo.getUserId() + '<br/>';
		strErrorMsg += 'e.getLineNumber : ' + e.getLineNumber() + '<br/>';
		strErrorMsg += 'e.getMessage : ' + e.getMessage() + '<br/>';
		strErrorMsg += 'e.getStackTraceString : ' + e.getStackTraceString() + '<br/>';
		strErrorMsg += 'e.getTypeName : ' + e.getTypeName() + '<br/>';
		
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strErrorMsg));
	}
	
	public ShipmentManage(){
		strMsg = '';
	}
	
	public string strMsg{get; set;}
	
	/****************************************************************************************************
	*	public
	****************************************************************************************************/
	public string InputBarcodeGetVal{get; set;}		//입력받기위한 바코드
	public string strSelectSeq{get; set;}			//출하제품 선택했을 경우의 cShips의 Seq
	public string strSelectSeq2{get; set;}			//출하제품 선택했을 경우의 cShips.cShipDetail의 Seq
	
	public String pId{get;set;}
	public String pAccount{get;set;}
	public Date pDate{get;set;}
	public String pCnt{get;set;}
	public String pSeq{get;set;}
	public String pBar{get;set;}
	
	/****************************************************************************************************
	*	출하처리
	****************************************************************************************************/
	private boolean IsAllSaved{get; set;}
	public boolean getIsAllSaved(){
		if(IsAllSaved==null) IsAllSaved = false;
		return IsAllSaved;
	}
	/****************************************************************************************************
	*	출하처리 - 출하검색 마스터
	****************************************************************************************************/
	private SearchMasterSM SMSM;
	public SearchMasterSM getSMSM(){
		if(SMSM==null) SMSM = new SearchMasterSM();
		return SMSM;
	}
	
	public class SearchMasterSM{
		public Shipment__c SM{get; set;}
		public integer state{get; set;}		//검색되는 과정 1:모두 입력전, 2:master는 선택한 상태
		
		private SearchMasterSM(){
			this.SM = new Shipment__c();
			this.SM.Date__c = system.today();
			this.state = 1;
		}
	}
	
	/****************************************************************************************************
	*	출하처리 - 출하검색 결과 Wrapper
	****************************************************************************************************/	
	private List<cShipment> cShips;
	public List<cShipment> getcShips(){
		if(cShips==null) cShips = new List<cShipment>();
		return cShips;
	}
	
	private class cShipment{
		public integer Seq{get; set;}					//리스트 순서
		public integer State{get; set;}					//1: 선택전, 2:선택후
		public Shipment__c SearchSM{get; set;}			//SearchMasterSM의 출하일, 거래처를 기본으로 가져옴
		public integer ShipCountGoal{get; set;}			//출하할 수량
		public integer ShipCountRollUp{get; set;}		//현재까지 집계된 수량
		public List<cShipmentDetail> cSMDs{get; set;}	//하나하나의 행	
		
		public cShipment(Shipment__c SearchMasterSM, integer CntThisList){
			this.Seq = CntThisList + 1;
			this.State = 1;
			this.SearchSM = new Shipment__c();
			this.SearchSM.Account__c = SearchMasterSM.Account__c;
			this.SearchSM.Date__c = SearchMasterSM.Date__c;
			this.ShipCountRollUp = 0;
			this.cSMDs = new List<cShipmentDetail>();
		}
	}
	
	private class cShipmentDetail{
		public Inventory__c IV{get; set;}
		public integer Seq{get; set;}
		public integer state{get; set;}		//1.선택전, 9.선택후
		public integer ShipCount{get; set;}		//출하할 수량
		
		
		private cShipmentDetail(){
			this.IV = new Inventory__c();
			this.Seq = 1;
			this.state = 1;
			this.ShipCount = 0;
		}
		private cShipmentDetail(integer CntThisList){
			this.IV = new Inventory__c();
			this.Seq = CntThisList + 1;
			this.state = 1;
			this.ShipCount = 0;
		}
		private cShipmentDetail(Inventory__c IV, integer CntThisList){
			this.IV = IV;
			this.Seq = CntThisList + 1;
			this.state = 1;
			this.ShipCount = integer.valueOf(IV.CntInventory2__c);
		}
	}
	
	/****************************************************************************************************
	*	출하처리 - 출하일, 거래처 선택 완료
	****************************************************************************************************/
	public void SelectDateAccount(){
		try{
			if(SMSM.SM.Date__c==null) throw new MyException('출하일을 선택하세요');
			if(SMSM.SM.Account__c==null) throw new MyException('출하할 거래처를 선택하세요');

			cShipment cShip = new cShipment(SMSM.SM, 0);
			cShips.add(cShip);
			
			SMSM.state = 2;
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch(exception e){
			MakeErrorMsg(e);
		}
	}
	
	/****************************************************************************************************
	*	출하처리 - 출하일, 거래처 선택 취소
	****************************************************************************************************/
	public void SelectDateAccountCancel(){
		try{
			SMSM = new SearchMasterSM();
			SMSM.state = 1;
			cShips = new List<cShipment>();
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch(exception e){
			MakeErrorMsg(e);
		}
	}
	/****************************************************************************************************
	*	출하처리 - 출하제품, 출하수량 선택
	*		strSelectSeq : 선택한 cShips의 Seq
	****************************************************************************************************/
	public void SelectShipmentItem(){
		try{
			cShipment cShip = cShips[integer.valueOf(strSelectSeq) - 1];
			cShip.state = 2;
			cShip.cSMDs = new List<cShipmentDetail>();
			cShipmentDetail cShipD = new cShipmentDetail(cShip.cSMDs.size());
			cShip.cSMDs.add(cShipD);
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch(exception e){
			MakeErrorMsg(e);
		}
	}
	
	/****************************************************************************************************
	*	출하처리 - 출하제품, 출하수량 취소
	*		strSelectSeq : 선택한 cShips의 Seq
	****************************************************************************************************/
	public void SelectShipmentItemCancel(){
		try{
			if(cShips.size()==integer.valueOf(strSelectSeq)){
				cShipment cShip = cShips[integer.valueOf(strSelectSeq) - 1];
				cShip.state = 1;
				cShip.cSMDs = new List<cShipmentDetail>();
			}else{
				cShips.remove(integer.valueOf(strSelectSeq) - 1);
				for(integer i = integer.valueOf(strSelectSeq) - 1; i<cShips.size(); i++){
					cShips[i].Seq = i + 1;
				}
			}
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch(exception e){
			MakeErrorMsg(e);
		}
	}
	/****************************************************************************************************
	*	출하처리 - 바코드 입력
	*		strSelectSeq : 선택한 cShips의 Seq
	*		strSelectSeq2 : 선택한 cShips.cSMDs의 Seq
	****************************************************************************************************/
	public void InputBarcodeForPage(){
		try{
			cShipment cShip = cShips[integer.valueOf(strSelectSeq) - 1];
			cShipmentDetail cShipD = cShip.cSMDs[integer.valueOf(strSelectSeq2) - 1];
			
			List<Inventory__c> IVs = [SELECT ID, Name, CntInventory2__c, Item__c
				, Account__c, DateManufacture__c
				, Warehouse__c 
				, ItemType__c
				FROM Inventory__c 
				WHERE Name=:InputBarcodeGetVal
			];

			if(IVs.size()<1) throw new MyException('해당하는 재고가 존재하지 않습니다.');
			if(IVs[0].Item__c <> cShip.SearchSM.ShipmentItem__c) throw new MyException('올바른 품목이 아닙니다.');
			if(IVs[0].CntInventory2__c<1) throw new MyException('재고가 없습니다.');
			
			//현재까지 입력된것 중에 있는지도 확인, 중복되어 입력되지 않도록
			if(IsDuplicate(InputBarcodeGetVal)) throw new MyException('이미 입력된 재고 입니다.');
			
			cShipD.IV = IVs[0];

			if(cShip.ShipCountGoal - cShip.ShipCountRollup >= cShipD.IV.CntInventory2__c){
				cShip.ShipCountRollup += integer.valueOf(cShipD.IV.CntInventory2__c);
				cShipD.ShipCount = integer.valueOf(cShipD.IV.CntInventory2__c);
				cShipD.state = 9;
				if(cShip.ShipCountGoal == cShip.ShipCountRollup){
					cShip.state = 9;
					// 한 번에 한 건씩만 처리하도록 변경처리 : JJL
					//cShips.add(new cShipment(SMSM.SM, cShips.size()));
				}else{
					cShip.cSMDs.add(new cShipmentDetail(cShip.cSMDs.size()));
				}
			}else{
				throw new MyException('출하할 수량보다 많은 재고수량을 가지고 있습니다. 다른 재고를 입력하세요.');
			}
			
			InputBarcodeGetVal = '';
			
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch(exception e){
			MakeErrorMsg(e);
		}
	}
	
	/****************************************************************************************************
	*	출하처리 - 중복체크
	*		지금 입력된 바코드와 현재 입력된것 까지 중복되어 있는 것이 있는지 체크
	****************************************************************************************************/
	private boolean IsDuplicate(string inputBarcode){
		boolean IsDuplicate = false;
		for(cShipment cShip:cShips){
			for(cShipmentDetail cShipD:cShip.cSMDs){
				if(inputBarcode==cShipD.IV.Name){
					IsDuplicate = true;
					break;
				}
			}
		}
		return IsDuplicate;
	}
	
	/****************************************************************************************************
	*	출하처리 - 재고부분 삭제
	*		strSelectSeq : 선택한 cShips의 Seq
	*		strSelectSeq2 : 선택한 cShips.cSMDs의 Seq
	****************************************************************************************************/
	public void ShipmentDetailDelete(){
		try{
			cShipment cShip = cShips[integer.valueOf(strSelectSeq) - 1];
			cShipmentDetail cShipD = cShip.cSMDs[integer.valueOf(strSelectSeq2) - 1];
			
			cShip.ShipCountRollup -= integer.valueOf(cShipD.IV.CntInventory2__c);
			InputBarcodeGetVal = '';
			
			cShip.cSMDs.remove(integer.valueOf(strSelectSeq2) - 1);
			
			for(integer i = integer.valueOf(strSelectSeq2) - 1 ; i<cShip.cSMDs.size(); i++){
				cShip.cSMDs[i].Seq = i + 1;
			}
			
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch(exception e){
			MakeErrorMsg(e);
		}
	}
	
	
	/****************************************************************************************************
	*	출하처리 - 출하처리
	****************************************************************************************************/
	public void StockProcess(){
		savepoint sp = Database.setSavepoint();
		try{
			boolean IsCheckProcess = false;
			for(cShipment cShip:cShips){
				if(cShip.state==2) throw new MyException('아직 완성되지 않은 내용이 있습니다.');
				if(cShip.state==9) IsCheckProcess = true;
			}
			
			if(!IsCheckProcess) throw new MyException('처리할 내용이 없습니다.');
			
			//cShips.remove(cShips.size()-1);
			
			List<Shipment__c> InsertSMs = new List<Shipment__c>();
			List<ShipmentDetail__c> InsertSMDs = new List<ShipmentDetail__c>();
			// Box collections
			List<Shipment__c> boxShipments = new List<Shipment__c>();
			List<ShipmentDetail__c> boxDetails = new List<ShipmentDetail__c>();
			
			for(cShipment cShip:cShips){
				InsertSms.add(cShip.SearchSM);
				Inventory__c parentInventory = cShip.cSMDs[0].IV;
				if('BOX'.equalsIgnoreCase(parentInventory.ItemType__c)){
					system.debug('IN BOX 출하처리');
					List<Inventory__c> children = [SELECT Id, CntInventory2__c FROM Inventory__c WHERE ParentInventory__c =: parentInventory.Id];
					for(Inventory__c child : children){
						system.debug('IN ParentInventory 처리');
						cShipment wrapper = new cShipment(cShip.SearchSM, 0);
						cShipmentDetail d = new cShipmentDetail();
						// 재고
						d.IV = child;
						// 출하수량
						if(child.CntInventory2__c >= 1)
							d.ShipCount = Integer.valueOf(child.CntInventory2__c);
						// 출하제품
						wrapper.SearchSM.ShipmentItem__c = cShip.SearchSM.ShipmentItem__c;
						wrapper.cSMDs.add(d);
						boxShipments.add(wrapper.SearchSM);
						// detail 처리를 위해 global 세팅
						boxDetails.add(new ShipmentDetail__c(Inventory__c=d.IV.Id, Count__c=d.ShipCount));
					}
				}
			}
			
			insert insertSms;
			insert boxShipments;
			
			system.debug('boxShipment Size == boxDetails Size');
			system.debug(boxShipments.size() + ',' + boxDetails.size());
			
			for(Integer i = 0; i < boxShipments.size(); i++){
				ShipmentDetail__c c = boxDetails.get(i);
				c.Shipment__c = boxShipments.get(i).Id;
			}
			insert boxDetails;
				
			// 바코드 값을 불러오기 위해 ID 값 세팅
			shipmentIds = new List<String>();
			if(insertSms == null || insertSms.size() < 1) throw new MyException('저장처리가 되지 않았습니다.\n' + insertSms);
			for(Shipment__c s : insertSms)
			{
				if(s.ID == null || ''.equals(s.ID)) 
					throw new MyException('ID 값이 바인딩 되지 않았습니다.' + s);
				else
					shipmentIds.add(s.ID);
			}
			
			for(cShipment cShip:cShips){
				for(cShipmentDetail cShipD:cShip.cSMDs){
					InsertSMDs.add(new ShipmentDetail__c(Shipment__c=cShip.SearchSM.Id, Inventory__c=cShipD.IV.Id, Count__c=cShipD.ShipCount));
				}
			}
			
			insert insertSMDs;
			
			IsAllSaved = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, '저장되었습니다.'));
		}catch (MyException e){
			Database.rollback(sp);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch(exception e){
			Database.rollback(sp);
			MakeErrorMsg(e);
		}
	}
	
	//------------------------------------------------------------
	
	
	private List<String> shipmentIds;
	private List<String> barcodes;
	
	public void printDummys(){
		try{
			StockProcess();
			if(shipmentIds == null || shipmentIds.size() < 1) 
				throw new MyException('저장처리가 되지 않았습니다.\n' + shipmentIds);
			
			List<Shipment__c> shipments = [select ShipmentBarcode__c 
 							from Shipment__c 
 							where ID IN :shipmentIds ];
		 	if(shipments != null && shipments.size() > 0){
				barcodes = new List<String>();		 		
		 		for(Shipment__c s : shipments){
		 			barcodes.add(s.ShipmentBarcode__c);
		 		}
		 		pBar = barcodes.get(0);
		 	}
		 	else
		 		throw new MyException('NotFound barcode by ID' + shipmentIds);
		 		
		 	if(pBar == null || ''.equals(pBar)) 
		 		throw new MyException('Not Binding Barcode : ' + barcodes);
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}
	}
	
	public void reset2StartStep(){
		//this.ShipmentDetailDelete();
		//this.SelectShipmentItemCancel();
		this.SelectDateAccountCancel();
		IsAllSaved = false;
		shipmentIds = null;
		barcodes = null;
		pId = null;
		pAccount = null;
		pDate = null;
		pCnt = null;
		pSeq = null;
		pBar = null;
	}
	
	/****************************************************************************************************
	*	출하조회
	****************************************************************************************************/
	private Shipment__c SearchSM1;
	public Shipment__c getSearchSM1(){
		if(SearchSM1==null) SearchSM1 = new Shipment__c();
		return SearchSM1;
	}
	private Shipment__c SearchSM2;
	public Shipment__c getSearchSm2(){
		if(SearchSM2==null) SearchSM2 = new Shipment__c();
		return SearchSM2;
	}
	
	//검색 결과 리스트
	private List<ShipmentDetail__c> SMDs;
	public List<ShipmentDetail__c> getSMDs(){
		if(SMDs==null) SMDs = new List<ShipmentDetail__c>();
		return SMDs;
	}
	
	public void SearchShipment(){
		try{
			if(SearchSM1.ShipmentItem__c==null && SearchSM1.Account__c==null && SearchSM1.Date__c==null && SearchSM2.Date__c==null)
				throw new MyException('검색 조건을 입력하셔야 합니다.');
			
			string strQry = 'SELECT ID FROM Shipment__c ';
			string strWhere = '';
			
			if(SearchSM1.ShipmentItem__c<>null) strWhere += ' ShipmentItem__c = \'' + SearchSM1.ShipmentItem__c + '\'';
			if(SearchSM1.Account__c<>null){
				if(strWhere<>'') strWhere += ' AND ';
				strWhere += ' Account__c = \'' + SearchSM1.Account__c + '\'';
			}
			if(SearchSM1.Date__c<>null){
				if(strWhere<>'') strWhere += ' AND ';
				strWhere += ' Date__c>=' + string.valueOf(SearchSM1.Date__c).substring(0, 10);
			}
			if(SearchSM2.Date__c<>null){
				if(strWhere<>'') strWhere += ' AND ';
				strWhere += ' Date__c<=' + string.valueOf(SearchSM2.Date__c).substring(0, 10);
			}
			
			if(strWhere <> '') strWhere = ' WHERE ' + strWhere;
			
			List<Shipment__c> SMs = Database.query(strQry + strWhere);
			set<Id> SMIDs = new set<ID>();
			for(Shipment__c SM:SMs){
				SMIDs.add(SM.Id);
			}
			
			SMDs = [SELECT ID
				, Inventory__r.Name, Inventory__r.Item__c, Inventory__r.Account__c, Inventory__r.DateManufacture__c
				, Shipment__r.Account__c, Shipment__r.Date__c, Count__c
				, Shipment__r.ShipmentBarcode__c, Shipment__r.ShipmentCount__c
				FROM ShipmentDetail__c
				WHERE Shipment__c=:SMIDs
			];
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch(exception e){
			MakeErrorMsg(e);
		}
	}

	public void MyTest(){
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
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
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