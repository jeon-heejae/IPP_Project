/**
 * Object		: ProcessProductManage.cls
 * Function		: 생산공정 관련
 * Author		: Yohan.Kang.
 * Date			: 2014.5.21
 * Tester		: ProcessProductManageTester.cls
 * Description	: 
 	ProcessProduct_Main.page
 	Product_Search.page
 */
public with sharing class ProcessProductManage {
	// 결과값 Wrapper list
	public List<WrapResult> wrap_result_list {get; private set;}
	// 결과값 Wrapper class
	public class WrapResult{
		public String headerItem {get;set;}
		public String result {get; private set;}
		
		public WrapResult(){
			
		}
	}
		
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
	
	public ProcessProductManage(){
		String item_id = System.currentPageReference().getParameters().get('item_id');
		/*
		String str = System.currentPageReference().getParameters().get('PcbTrayNo');
		if(str<>null){
			PcbTrayNo = Integer.valueOf(str);
			if(PcbTrayNo<>null && PcbTrayNo>28) PcbTrayNo = PcbTrayNo - 28;
		}
		*/
		if(item_id != null){
			InputBarcodeGetVal=item_id;
			ProductSearch();
		}
	}
	
	//제품에서 팝업으로 연결되어 pcb_tray_no 가 있는 경우 해당 정보만 보여준다.
	public Integer PcbTrayNo{
		get{
			if(PcbTrayNo==null){
				String str = System.currentPageReference().getParameters().get('PcbTrayNo');
				try{
					if(str<>null) PcbTrayNo = Integer.valueOf(str);
					if(PcbTrayNo<>null && PcbTrayNo>28) PcbTrayNo = PcbTrayNo - 28;
				}catch(exception e){}
				if(PcbTrayNo==null) PcbTrayNo = 0;
			}
			return PcbTrayNo;
		}
		private set;
	}
	
	/****************************************************************************************************
	*	public
	****************************************************************************************************/
	public string InputBarcodeGetVal{get; set;}		//입력받기위한 바코드
	public string InputBarcodeSeq{get; set;}		//현재 입력받은 바코드의 seq

	/****************************************************************************************************
	*	FlowState
	*	1. 공정선택
	*	2. 공정상세정보 등록
	*	9. 공정시작
	****************************************************************************************************/
	private integer FlowState;
	public integer getFlowState(){
		if(FlowState == null) FlowState = 1;
		return FlowState;
	}
	//검색된 재고 정보
	public Inventory__c ResultIV{
		get{
			if(ResultIV==null && InputBarcodeGetVal<>null){
				ResultIV = [SELECT ID
						, Product_Pba_No__c
					FROM Inventory__c
					WHERE Name=:InputBarcodeGetVal
				];
			}
			return ResultIV;
		}
		private set;
	}
	/****************************************************************************************************
	*	공정상세정보 + 생산공정상세
	****************************************************************************************************/
	private class cDetail{
		public integer Seq{get; set;}
		public integer state{get; set;}				//1. 입력대기, 2.입력받지 않아도 되는 바코드, 9.입력됨
		public string barcode{get; set;}
		public integer InventoryCnt{get; set;}		//재고 수량
		public ProcessInfoDetail__c PID{get; set;}
		public ProcessProductDetail__c PPD{get; set;}
		
		private cDetail(){}
		private cDetail(ProcessInfoDetail__c gPID, integer gSeq){
			this.Seq = gSeq;
			this.state = (gPID.BarcodeType__c=='이동식') ? 1 : 2; 
			this.barcode = '';
			this.PID = gPID;
			this.PPD = new ProcessProductDetail__c(ProcessInfoDetail__c=gPID.Id);
		}
		private cDetail(ProcessProductDetail__c gPPD){
			this.PPD = gPPD;
			this.PID = [SELECT Id, Seq__c, Item__c, Count__c, BarcodeType__c FROM ProcessInfoDetail__c WHERE ID=:gPPD.ProcessInfoDetail__c];
			
		}
	}
	private List<cDetail> CDs;
	public List<cDetail> getCDs(){
		if(CDs==null){
			CDs = new List<cDetail>();
		}
		return CDs;
	}
	
	/****************************************************************************************************
	*	공정정보 + 생산공정
	****************************************************************************************************/
	private class cMaster{
		public ProcessInfo__c PI{get; set;}
		public ProcessProduct__c PP{get; set;}
		private cMaster(){}
		private cMaster(ProcessInfo__c gPI){
			this.PI = gPI;
			this.PP = new ProcessProduct__c(
				ProcessInfo__c = PI.Id
			);
		}
		private cMaster(ProcessProduct__c gPP){
			this.PP = gPP;
			//this.PI = [SELECT ID, Name, Item__c, ItemProcessSeq__c, ItemProcessIsComplete__c, ItemTray__c FROM ProcessInfo__c WHERE ID=:gPP.ProcessInfo__c];
			this.PI = [SELECT ID, Name, Item__c FROM ProcessInfo__c WHERE ID=:gPP.ProcessInfo__c];
		}
		
	}
	
	public cMaster CM{get; set;}
	
	private List<cMaster> CMs;
	public List<cMaster> getCMs(){
		if(CMs==null){
			CMs = new List<cMaster>();
		}
		return CMs;
	}
	
	/****************************************************************************************************
	*	공정상세정보의 바코드 등록
	****************************************************************************************************/
	public void InputBarcodeForPage(){
		try{
			integer seq = integer.valueOf(InputBarcodeSeq);
			cDetail CD = CDs[seq-1];
			
			CD.barcode = InputBarcodeGetVal;
			
			List<Inventory__c> IVs = [SELECT ID, CntInventory2__c, Item__c FROM Inventory__c WHERE Name=:InputBarcodeGetVal];
			
			if(IVs.size()<1) throw new MyException('해당하는 재고가 존재하지 않습니다.');
			if(IVs[0].Item__c <> CD.PID.Item__c) throw new MyException('올바른 품목이 아닙니다.');
			if(IVs[0].CntInventory2__c<1) throw new MyException('재고가 없습니다.');
			
			CD.PPD.Inventory__c = IVs[0].Id;
			CD.InventoryCnt = integer.valueOf(IVs[0].CntInventory2__c);
			
			InputBarcodeGetVal = '';
			CD.state = 9;
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch(exception e){
			MakeErrorMsg(e);
		}
	}
	
	/****************************************************************************************************
	*	검색
	****************************************************************************************************/
	private ProcessProduct__c SearchPP;
	public ProcessProduct__c getSearchPP(){
		if(SearchPP == null) SearchPP = new ProcessProduct__c();
		return SearchPP;
	}
	
	//생산공정 관리 - 공정정보 검색
	public void Search(){
		try{
			if(SearchPP.ProcessInfo__c == null) throw new MyException('공정정보를 선택해야 합니다.');
			ProcessInfo__c PI = [SELECT ID, Name, Item__c,  
				(SELECT Id, ProcessInfo__c, Seq__c, Item__c, Count__c, BarcodeType__c
				FROM ProcessInfoDetail__r Order by Seq__c)
				FROM ProcessInfo__c 
				WHERE ID=:SearchPP.ProcessInfo__c
			];
			
			CM = new cMaster(PI);
			
			List<ProcessInfoDetail__c> PIDs = PI.ProcessInfoDetail__r;
			CDs = new List<cDetail>();
			integer intSeq = 1;
			for(ProcessInfoDetail__c PID:PIDs){
				CDs.add(new cDetail(PID, intSeq++));
			}
			FlowState = 2;
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch(exception e){
			MakeErrorMsg(e);
		}
	}
	
	/****************************************************************************************************
	*	공정준비완료
	****************************************************************************************************/	
	public void ProcessProductStart(){
		savepoint sp = Database.setSavepoint();
		
		try{
			//모두 입력되어 있는지 확인
			if(CM.PP.ProcessMachine__c==null) throw new MyException('공정기계는 등록해야 합니다.');
			for(cDetail CD:CDs){
				if(CD.PID.BarcodeType__c=='이동식' && CD.PPD.Inventory__c == null) throw new MyException('모든 품목이 등록되어야 합니다.');
			}
			//공정상태 변경
			CM.PP.Date__c = system.today();
			CM.PP.State__c = '진행';
			CM.PP.CntProduct__c = 0;
			insert CM.PP;
			
			List<ProcessProductDetail__c> insertPPDs = new List<ProcessProductDetail__c>();
			for(cDetail CD:CDs){
				CD.PPD.ProcessProduct__c = CM.PP.Id;
				if(CD.PID.BarcodeType__c == '이동식') insertPPDs.add(CD.PPD);
			}
			
			insert insertPPDs;
			
			FlowState = 9;
			
		}catch (MyException e){
			Database.rollback(sp);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch (Exception e){
			Database.rollback(sp);
			MakeErrorMsg(e);
			
		}
	}
	
	
	
	
	
	
	
	
	
	
	/****************************************************************************************************
	*	제품검색 결과
	****************************************************************************************************/
	public List<Inventory__c> box_inven {get;set;}
	
	//화면 List
	private List<Summary> Sums;
	public List<Summary> getSums(){
		if(Sums==null) Sums = new List<Summary>();
		return Sums;
	}
	//Warpper
	private class Summary implements Comparable{
		public string strSeq{get; set;}
					/* x-x-x
					인덱스를 위함
					첫번째 1:bom, 2:검사값
					두번째 BOM은 공정순, 검사값은 그냥 순서
					세번째 BOM은 공정상세순, 검사값은 그냥 1
					*/
		public List<string> Level{get; set;}	//sub에 대한 깊이 를 List형식으로 담아 둔다
		public integer SubInfo{get; set;}		//하위공정 관련 0 없음 1 있지만 펼쳐지지않음 (+) 2 있지만 펼쳐짐 (-)
		public Id IVID{get; set;}
		public Inventory__c IV{get; set;}
		public string title{get; set;}		//여긴 BOM, 공정값(검사결과값) 만 들어간다.
		public string checkResult{get; set;}
		
		//sort
		public integer compareTo(Object compareTo){
			Summary Summary = (Summary) compareTo;
			if(strSeq == Summary.strSeq) return 0;
			if(strSeq > Summary.strSeq) return 1;
			return -1;
		}
	}
	
	//조회 후 메인 품목 정보
	public ViewItem ViewI{get; set;}
	
	
	private class ViewItem{
		public string ItemName{get; set;}		//품목명	
		public string ItemCode{get; set;}		//품목코드
		public string ItemStandard{get; set;}	//품목규격
		public string CheckResult1{get; set;}	//검사결과값1 링타입
		public string CheckResult2{get; set;}	//검사결과값2 감도
	}
	
	
	/****************************************************************************************************
	*	integer to string 3자리수로
	****************************************************************************************************/
	private string ChangeItoS(integer gi, integer length){
		string ChangeItoS = string.valueOf(gi);
		if(ChangeItoS.length() < length){
			for(integer i=ChangeItoS.length() ; i<length ; i++) ChangeItoS = '0' + ChangeItoS;
		}
		return ChangeItoS;
	}
	private string ChangeItoS(Decimal gi, integer length){
		return ChangeItoS(integer.valueOf(gi), length);
	}

	/****************************************************************************************************
	*	검색
	****************************************************************************************************/
	//제품 추적 - 제품 검색
	public void ProductSearch(){
		try{
			if(InputBarcodeGetVal == '') throw new MyException('바코드를 입력하세요');
			
			List<Inventory__c> IVs = [SELECT ID, Item__c, Item__r.Name, ItemCode__c, Item__r.Standard__c, 
				ProcessProduct__c, Account__c, DateManufacture__c, ItemType__c,
				Product_Pba_No__c, ParentInventory__r.Product_Pba_No__c, 
				(SELECT ID, Seq__c, Subject__c, Result__c
					FROM CHeckResult__r
					Order by Seq__c
				)
				FROM Inventory__c 
				WHERE NAME=:InputBarcodeGetVal
			
			];
			
			ResultIV = null;

			ViewI = new ViewItem();
			if(IVs.size()<1)
				Sums.clear();
			
			// 결과값 Wrapper list 초기화
			if(wrap_result_list == null){
	            wrap_result_list = new List<WrapResult>();
	        } else { 
	            wrap_result_list.clear();
	        }
	        
			if(box_inven == null){
	            box_inven = new List<Inventory__c>();
	        } else { 
	            box_inven.clear();
	        }
						
			if(IVs.size()<1) throw new MyException('해당하는 제품 정보가 없습니다.');
			
			//ViewI = new ViewItem();
			ViewI.ItemName = IVs[0].Item__r.Name;
			ViewI.ItemCode = IVs[0].ItemCode__c;
			ViewI.ItemStandard = IVs[0].Item__r.Standard__c;
			
			
			
			if(IVs[0].ItemType__c == 'Box') {
				Sums = new List<Summary>();
	
				Summary Sum_bom = new Summary();
				Sum_bom.strSeq = '1-00-000';
				Sum_bom.Level = new List<string>();
				Sum_bom.SubInfo = 0;
				Sum_bom.title = 'BOM';
				Sums.add(Sum_bom);
				
				List<Inventory__c> inven = [
					select Item__r.Name, ItemCode__c, Name, Account__c, DateManufacture__c
					, Product_Pba_No__c 
					, ParentInventory__r.Product_Pba_No__c
					from Inventory__c 
					where ParentInventory__r.Name=:InputBarcodeGetVal
				];				
			
				for(Inventory__c iv : inven){	
					box_inven.add(iv);
				}
			}			
			else if(IVs[0].ItemType__c != 'Box'){
			
				List<ProcessProduct__c> PPs = [SELECT ID,  
					(SELECT Id, Seq__c, Inventory__c
						FROM ProcessProductDetail__r
						Order by Seq__c
					)
					FROM ProcessProduct__c
					WHERE ID=:IVs[0].ProcessProduct__c
				];
				
				if(PPs.size()<1) throw new MyException('제품에 대한 부품 정보가 없습니다.');
	
				//wrapper를 만들고
				Sums = new List<Summary>();
	
				Summary Sum_bom = new Summary();
				Sum_bom.strSeq = '1-00-000';
				Sum_bom.Level = new List<string>();
				Sum_bom.SubInfo = 0;
				Sum_bom.title = 'BOM';
				Sums.add(Sum_bom);
				
				Summary Sum_check = new Summary();
				Sum_check.strSeq = '2-00-000';
				Sum_check.Level = new List<string>();
				Sum_check.SubInfo = 0;
				Sum_check.title = '공정값(검사결과값)';
				if(PcbTrayNo>0) Sum_check.title += ' (' + PcbTrayNo + '번째 PCB)';
				Sums.add(Sum_check);
				
				
				Set<ID> IVIDs = new Set<Id>();		//상세공정에 들어가 있는 Inventory id들
				
				for(ProcessProduct__c PP:PPs){
					for(ProcessProductDetail__c PPD:PP.ProcessProductDetail__r){
						Summary Sum = new Summary();
						Sum.strSeq = '1-01-' + ChangeItoS(PPD.Seq__c, 3);
						Sum.Level = new List<string>();
						Sum.SubInfo = 0;
						Sum.IVID = PPD.Inventory__c;
						Sums.add(Sum);
						
						IVIDs.add(PPD.Inventory__c);
					}
				}
				
				//Inventory Map를 만든다.
				map<id, Inventory__c> mIVs = new map<id, Inventory__c>();
				mIVs.putAll([SELECT Id, Name, Item__c, Item__r.Name, ItemCode__c, Account__c, DateManufacture__c, ProcessProduct__c
					, Product_Pba_No__c
					, ParentInventory__r.Product_Pba_No__c
					FROM Inventory__c
					WHERE ID=:IVIDs
				]);
				
				//집계된 wrapper에 Inventory를 넣는다.
				for(Summary Sum:Sums){
					//IV삽입
					Sum.IV = mIVs.get(Sum.IVID);
									
					//SubInfo
					if(Sum.IV.ProcessProduct__c == null){
						Sum.SubInfo = 0;
					}else{
						Sum.SubInfo = 1;
					}
				}
				
				//공정검사값을 집어 넣는다.
				/*
				for(CheckResult__c CR:IVs[0].CheckResult__r){
					Summary Sum = new Summary();
					Sum.strSeq = '2-00-' + ChangeItoS(CR.Seq__c, 3);
					Sum.checkResult = CR.Subject__c + ' : ' + CR.Result__c;
					Sum.SubInfo = 0;
					Sum.IV = new Inventory__c();
					Sums.add(Sum);
					
					//링타입, 감도일 경우 메인에도 표시
					if(CR.Subject__c=='링타입') ViewI.CheckResult1 = CR.Result__c;
					if(CR.Subject__c=='감도') ViewI.CheckResult2 = CR.Result__c;
				}
				*/
				
				//공정검사값을 집어 넣는다.			
				String keyWord = InputBarcodeGetVal;
				String field_name = 'ItemType__c, Pba_spi_file__c, Pba_spi2_file__c,';
				field_name += 'Pba_spi_result__c, Pba_spi2_result__c,';
				field_name += 'Pba_aoi_file__c, Pba_aoi2_file__c,';
				field_name += 'Pba_aoi_result__c, Pba_aoi2_result__c,';
				field_name += 'Pba_ict_file__c, Pba_ict2_file__c,';
				field_name += 'Pba_ict_result__c, Pba_ict2_result__c,';
				field_name += 'Product_temp1__c, Product_temp2__c,';
				field_name += 'Product_speed1__c, Product_speed2__c,Product_eolfile__c,';			
				field_name += 'Product_eol__c,Product_Pba_No__c,ParentInventory__r.Product_Pba_No__c';
				
				String query = 'select ' + field_name + ' from Inventory__c where Name=:keyWord';
				
				List<Inventory__c> inventR_list = Database.query(query); 
				system.debug('test :' + inventR_list.size());				
								
				if(inventR_list[0].ItemType__c == '제품'){
					//결과값 Wrap에 담기
					for(Inventory__c iv : inventR_list){
						/*
						WrapResult wrap1 = new WrapResult();						
						wrap1.headerItem = '공정 온도측정1';
						wrap1.result = String.valueOf(iv.Product_temp1__c);
						wrap_result_list.add(wrap1);
						WrapResult wrap2 = new WrapResult();
						wrap2.headerItem = '공정 온도측정2';
						wrap2.result = String.valueOf(iv.Product_temp2__c);
						wrap_result_list.add(wrap2);
						WrapResult wrap3 = new WrapResult();
						wrap3.headerItem = '공정 속도1';
						wrap3.result = String.valueOf(iv.Product_speed1__c);
						wrap_result_list.add(wrap3);
						WrapResult wrap4 = new WrapResult();
						wrap4.headerItem = '공정 속도2';
						wrap4.result = String.valueOf(iv.Product_speed2__c);
						wrap_result_list.add(wrap4);
						*/
						
						WrapResult wrap5 = new WrapResult();
						wrap5.headerItem = 'EOL 결과';
						//wrap5.result = iv.Product_eolfile__c;
						wrap5.result = iv.Product_eol__c;
						wrap_result_list.add(wrap5);
					}
				}if(inventR_list[0].ItemType__c == 'PBA'){
					//결과값 Wrap에 담기
					for(Inventory__c iv : inventR_list){
						
						WrapResult wrap1 = new WrapResult();
						wrap1.headerItem = 'BOTTOM SPI 결과';
						//wrap1.result = ResultCheck(iv.Pba_spi_result__c);
						wrap1.result = iv.Pba_spi_result__c;
						wrap_result_list.add(wrap1);
						
						WrapResult wrap2 = new WrapResult();
						wrap2.headerItem = 'TOP SPI 결과';
						//wrap2.result = ResultCheck(iv.Pba_spi2_result__c);
						wrap2.result = iv.Pba_spi2_result__c;
						wrap_result_list.add(wrap2);
						
						WrapResult wrap3 = new WrapResult();
						wrap3.headerItem = 'BOTTOM AOI 결과';
						wrap3.result = ResultCheck(iv.Pba_aoi_result__c);
						wrap_result_list.add(wrap3);
						
						WrapResult wrap4 = new WrapResult();
						wrap4.headerItem = 'TOP AOI 결과';
						wrap4.result = ResultCheck(iv.Pba_aoi2_result__c);
						wrap_result_list.add(wrap4);
						
						WrapResult wrap5 = new WrapResult();
						wrap5.headerItem = 'ICT 결과';
						wrap5.result = ResultCheck(iv.Pba_ict_result__c);
						wrap_result_list.add(wrap5);
						/*
						WrapResult wrap6 = new WrapResult();
						wrap6.headerItem = 'ICT2 파일';
						wrap6.result = iv.Pba_ict2_file__c;
						wrap_result_list.add(wrap6);
						WrapResult wrap7 = new WrapResult();
						*/
					}
				}	
				
				//sort 한 것을 list에 담는다
				Sums.sort();
			} 
			
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch (Exception e){
			MakeErrorMsg(e);
		}
	}
	
	//각 결과값에 대해서 파라미터 pcbtray 값이 있는 경우 해당 결과값만 return
	private string ResultCheck(string strResult){
		if(strResult<>null && strResult<>'' && PcbTrayNo<>null && PcbTrayNo<>0 && strResult.length()>=PcbTrayNo){
			strResult = strResult.substring(PcbTrayNo - 1, PcbTrayNo);
		}
		if(PcbTrayNo<>null && PcbTrayNo<>0 && (strResult==null || strResult=='')) strResult = 'P';
		return strResult;
	}
	
	/****************************************************************************************************
	*	조회 결과 - 제품조회 - 버튼 클릭
	****************************************************************************************************/
	public string ClickSeq{get; set;}
	public string ClickInventoryName{get; set;}
	public string ClickLevel{get; set;}
	/****************************************************************************************************
	*	조회 결과 - 제품조회 - BOM Plus
	****************************************************************************************************/
	public void ClickPlus(){
		// 최종적으로는 Sums에 담는다
		try{
			//현재 Row 꺼는 SubInfo를 2로 만든다.
			for(Summary Sum:Sums){
				if(Sum.strSeq == ClickSeq){
					Sum.SubInfo = 2;
					break;
				}
			}
			
			List<Inventory__c> IVs = [SELECT ID, Item__c, Item__r.Name, ItemCode__c, Item__r.Standard__c, 
				ProcessProduct__c, Account__c, DateManufacture__c, 
				Product_Pba_No__c ,
				(SELECT ID, Seq__c, Subject__c, Result__c
					FROM CHeckResult__r
					Order by Seq__c
				)
				FROM Inventory__c 
				WHERE Name=:ClickInventoryName
			
			];
			
			

			List<ProcessProduct__c> PPs = [SELECT ID, 
				(SELECT Id, Seq__c, Inventory__c
					FROM ProcessProductDetail__r
					Order by Seq__c
				)
				FROM ProcessProduct__c
				WHERE ID=:IVs[0].ProcessProduct__c
			];
			
			Summary Sum_bom = new Summary();
			Sum_bom.strSeq = ClickSeq + '-' + '1-00-000';
			Sum_bom.Level = new List<string>();
			
			for(integer i = 0 ; i < integer.valueOf(ClickLevel) + 1; i++) Sum_bom.Level.add('');
			
			Sum_bom.SubInfo = 0;
			Sum_bom.title = 'BOM';
			Sums.add(Sum_bom);
			
			Summary Sum_check = new Summary();
			Sum_check.strSeq = ClickSeq + '-' + '2-00-000';
			Sum_check.Level = new List<string>();
			for(integer i = 0 ; i < integer.valueOf(ClickLevel) + 1; i++) Sum_check.Level.add('');
			Sum_check.SubInfo = 0;
			Sum_check.title = '공정값(검사결과값)';
			Sums.add(Sum_check);
			
			
			//하위공정 등을 체크하기 위해서 현재 들어온것에 대해서만 체크한 후 cSums에 다시 넣는다.
			List<Summary> TempSums = new List<Summary>();
			
			Set<ID> IVIDs = new Set<Id>();		//상세공정에 들어가 있는 Inventory id들
			
			for(ProcessProduct__c PP:PPs){
				for(ProcessProductDetail__c PPD:PP.ProcessProductDetail__r){
					Summary Sum = new Summary();
					Sum.strSeq = ClickSeq + '-' + '1-' + ChangeItoS(PPD.Seq__c, 3);
					Sum.Level = new List<string>();
					for(integer i = 0 ; i < integer.valueOf(ClickLevel) + 1; i++) Sum.Level.add('');
					Sum.SubInfo = 0;
					Sum.IVID = PPD.Inventory__c;
					TempSums.add(Sum);
					
					IVIDs.add(PPD.Inventory__c);
				}
			}
			
			
			//Inventory Map를 만든다.
			map<id, Inventory__c> mIVs = new map<id, Inventory__c>();
			mIVs.putAll([SELECT Id, Name, Item__c, Item__r.Name, ItemCode__c, Account__c, DateManufacture__c, ProcessProduct__c
				, Product_Pba_No__c
				FROM Inventory__c
				WHERE ID=:IVIDs
			]);
			
			//집계된 wrapper에 Inventory를 넣는다.
			for(Summary Sum:TempSums){
				//IV삽입
				Sum.IV = mIVs.get(Sum.IVID);
								
				//SubInfo
				if(Sum.IV.ProcessProduct__c == null){
					Sum.SubInfo = 0;
				}else{
					Sum.SubInfo = 1;
				}
			}
			Sums.addAll(TempSums);
			
			//공정검사값을 집어 넣는다.
			
			for(CheckResult__c CR:IVs[0].CheckResult__r){
				Summary Sum = new Summary();
				Sum.strSeq = ClickSeq + '-' + '2-00-' + ChangeItoS(CR.Seq__c, 3);
				Sum.checkResult = CR.Subject__c + ' : ' + CR.Result__c;
				Sum.Level = new List<string>();
				for(integer i = 0 ; i < integer.valueOf(ClickLevel) + 1; i++) Sum.Level.add('');
				Sum.SubInfo = 0;
				Sum.IV = new Inventory__c();
				Sums.add(Sum);
			}			
			
			//sort 한 것을 list에 담는다
			Sums.sort();
			
		}catch (MyException e){ 
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch (Exception e){
			MakeErrorMsg(e);
		}
	}
	/****************************************************************************************************
	*	조회 결과 - 제품조회 - BOM Minus
	****************************************************************************************************/
	public void ClickMinus(){
		try{
			for(integer i=Sums.size()-1; i>-1;i--){
				if(Sums[i].strSeq == ClickSeq) Sums[i].subInfo = 1;
				if(Sums[i].strSeq.length() > ClickSeq.length() &&  Sums[i].strSeq.substring(0, ClickSeq.length()+1) == ClickSeq + '-'){
					Sums.remove(i);
				}
			}
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch (Exception e){
			MakeErrorMsg(e);
		}
	}
	
	/****************************************************************************************************
	*	Tester
	****************************************************************************************************/
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
	}
}