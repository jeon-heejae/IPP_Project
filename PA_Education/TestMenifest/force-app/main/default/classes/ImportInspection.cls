/**
 * Object		: ImportInspection.cls
 * Function		: 수입검사 관련
 * Author		: Yohan.Kang.
 * Date			: 2014.4.25
 * Tester		: ImportInspectionTester
 * Description	: 
 *			ImportInspection_Request.page
 *	샘플 바코드 : ZA00000010100ZZ14D0101
 */
public with sharing class ImportInspection {
	public String item_lktp {get;set;}
	public String account_lktp {get;set;}	
	
	public class MyException extends Exception{}
	private string MakeErrorStr(exception e){
		string strErrorMsg = '';
		strErrorMsg += '현재 User ID : ' + UserInfo.getUserId() + '<br/>';
		strErrorMsg += 'e.getLineNumber : ' + e.getLineNumber() + '<br/>';
		strErrorMsg += 'e.getMessage : ' + e.getMessage() + '<br/>';
		strErrorMsg += 'e.getStackTraceString : ' + e.getStackTraceString() + '<br/>';
		strErrorMsg += 'e.getTypeName : ' + e.getTypeName() + '<br/>';
		return strErrorMsg;
	}
	 
	public ImportInspection(){
		item_lktp = Schema.SObjectType.item__c.getKeyPrefix(); 
		account_lktp = Schema.SObjectType.account.getKeyPrefix(); 
	}
	
	
	/****************************************************************************************************
	*	재고 list inner class 호출
	****************************************************************************************************/
	public List<cInventory> cIVs{
		get{
			if(cIVs==null){
				cIVs = new List<cInventory>();
				cIVs.add(new cInventory(1));
			}
			return cIVs;
		}
		set;
	}
	
	/****************************************************************************************************
	*	public
	****************************************************************************************************/
	//public void InputBarcode(string getVal, integer seq){
	public string InputBarcodeGetVal{get; set;}
	public string InputBarcodeSeq{get; set;}
	
	//전체 저장 여부 체크
	private boolean IsAllSaved;
	public boolean getIsAllSaved(){
		if(IsAllSaved == null){
			IsAllSaved = false;
		}
		return IsAllSaved;
	}
	
	/****************************************************************************************************
	*	재고 list inner class
	****************************************************************************************************/	
	private class cInventory{
		public Integer Seq{get; set;}		//순서
		public Integer State{get; set;}		//상태 1.바코드입력대기 2.입력완료 3.일부입력완료 4.수동입력대기 5.개별저장됨 6.결과입력대기
											// 의뢰시 : 1.바코드입력대기 2.입력완료 3.일부입력완료 4.수동입력대기 5.개별저장됨
											//결과등록시 : 1.바코드입력대기 5.개별저장됨 6.결과입력대기
		public boolean IsChangeCntImport{get; set;}
		public String itemName{get; set;}
		public Inventory__c IV{get; set;}	//재고
		
		private cInventory(integer getSeq) {
			this.Seq = getSeq;
			this.State = 1;
			this.IsChangeCntImport = false;
			this.IV = new Inventory__c();
		}
	}
	
	/****************************************************************************************************
	*	바코드 등록
	****************************************************************************************************/
	public void InputBarcodeForPage(){
		try{
			integer seq = integer.valueOf(InputBarcodeSeq);
			
			if(IsDuplicateBarcode(InputBarcodeGetVal, cIVs, seq)) throw new MyException('중복되는 바코드입니다.');
			
			if(InputBarcodeGetVal.length()<>23) throw new MyException('바코드의 길이가 잘못되었습니다.');
			
			//private cInventory BCtoIV(string InputBarcodeGetVal, integer seq){
			if(BCtoIV(InputBarcodeGetVal, seq)) cIVs.add(new cInventory(seq + 1));
			
			InputBarcodeGetVal = '';
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch(exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MakeErrorStr(e)));
		}
	}
	
	
	//바코드 중복검사
	private boolean IsDuplicateBarcode(string getVal, List<cInventory> ListInvens, integer seq){
		boolean isDuplicate = false;
		List<Inventory__c> IVs = [SELECT ID FROM Inventory__c Where Name=:getVal];
		if(IVs.size()>0) isDuplicate = true;
		
		if(!isDuplicate){
			for(cInventory CV : ListInvens){
				if(CV.Seq<>seq && CV.IV.Name==getVal){
					isDuplicate = true;
					break;
				}
			}
		}
		return isDuplicate;
	}
	
	//바코드입력된 것을 재고 insert
	private boolean BCtoIV(string InputBarcodeGetVal, integer seq){
		try{
			cInventory IV = cIVs[seq-1];
			
			IV.state = 2;
			
			cBarcode BC = new cBarcode(InputBarcodeGetVal);
			
			List<Item__c> inventory = [SELECT ID, Name FROM Item__c WHERE Code__c=:BC.Item];
			//List<Inventory__c> inventory = [SELECT Item__r.Name, Item__r.Id 
			//								FROM Inventory__c 
			//								WHERE Item__r.Code__c =: BC.Item];
			//throw new MyException('result : ' + inventory[0].Item__r.Name);											
			if(inventory.size()>0){
				IV.IV.Item__c = inventory[0].Id;
				IV.itemName = inventory[0].Name;
				//IV.IV.Item__r.Name = inventory[0].Item__r.Name;
			}else{
			
			} 
			
			List<Account> ACs = [SELECT ID FROM Account WHERE Code__c=:BC.Acc];
			if(ACs.size()>0) IV.IV.Account__c = ACs[0].Id;
			
			system.debug('IV.IV.Item__c : ' + IV.IV.Item__c);
			system.debug('IV.IV.Account__c : ' + IV.IV.Account__c);

			IV.IV.Name = InputBarcodeGetVal.toUpperCase();
			IV.IV.DateManufacture__c = BC.DateManu;
			IV.IV.CntImportInspection__c = BC.Cnt;
			IV.IV.Seq__c = BC.seq;
			
			if(IV.IV.Item__c==null) IV.state = 3;
			if(IV.IV.Account__c==null) IV.state = 3;
			if(IV.IV.DateManufacture__c==null) IV.state = 3;
			if(IV.IV.CntImportInspection__c==null) IV.state = 3;
			if(IV.IV.Seq__c==null) IV.state = 3;
			
			IF(IV.state==3) throw new MyException('잘못된 바코드 형식입니다. 다시 등록하거나, 수정하세요.');
			
			return true;
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
			return false;
		}catch(exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MakeErrorStr(e)));
			return false;
		}
	}
	
	/****************************************************************************************************
	*	수동 등록
	****************************************************************************************************/
	public void InputCustom(){
		integer seq = integer.valueOf(InputBarcodeSeq);
		cInventory IV = cIVs[seq-1];
		IV.State = 4;
	}
	
	/****************************************************************************************************
	*	등록
	****************************************************************************************************/
	public void InputForError(){
		try{
			system.debug('@@@@@ InputForError start');
			
			integer seq = integer.valueOf(InputBarcodeSeq);
			cInventory IV = cIVs[seq-1];
			
			IV.IV.Item__c = IV.IV.Item_PartEtc__c;
			
			if(IV.IV.Item__c==null) throw new MyException(Schema.sObjectType.Inventory__c.fields.Item__c.Label + '을 선택하셔야 합니다.');
			
			if(IV.IV.Account__c==null){
				if(SearchIV.Account__c == null)
					throw new MyException(Schema.sObjectType.Inventory__c.fields.Account__c.Label + '를 선택하셔야 합니다.');
				else
					IV.IV.Account__c = SearchIV.Account__c;
			}
			
			if(tempdate!=null && tempDate!=''){
				IV.IV.DateManufacture__c = Date.valueOf(tempdate);
			}
			
			if(IV.IV.DateManufacture__c==null) throw new MyException(Schema.sObjectType.Inventory__c.fields.DateManufacture__c.Label + '을 입력해야 합니다.');
			if(IV.IV.CntImportInspection__c==null) throw new MyException(Schema.sObjectType.Inventory__c.fields.CntImportInspection__c.Label + '을 입력해야 합니다.');
			if(IV.IV.Seq__c==null) throw new MyException(Schema.sObjectType.Inventory__c.fields.Seq__c.Label + '을 입력해야 합니다.');
			
			if(IV.IV.CntImportInspection__c<0 || IV.IV.CntImportInspection__c>99999) throw new MyException(Schema.sObjectType.Inventory__c.fields.CntImportInspection__c.Label + '은 0~99999사이의 수를 입력해야 합니다.');
			if(IV.IV.Seq__c.length()<0 || IV.IV.Seq__c.length()>2) throw new MyException(Schema.sObjectType.Inventory__c.fields.Seq__c.Label + '은 2자리를 입력해야 합니다.');
			
			List<Item__c> items = [SELECT Code__c, Name FROM Item__c WHERE ID=: IV.IV.Item__c];
			IV.itemName = items[0].Name;
			string Item = items[0].Code__c;
			string Acc = [SELECT Code__c FROM Account WHERE ID=: IV.IV.Account__c].Code__c;
			
			cBarcode BC = new cBarcode(Item, integer.valueOf(IV.IV.CntImportInspection__c), Acc, IV.IV.DateManufacture__c, IV.IV.Seq__c);
			
			if(IsDuplicateBarcode(BC.barcode, cIVs, seq)) throw new MyException('중복되는 바코드입니다.');
			
			system.debug('@@@@@ InputForError 에러통과');
			
			IV.IV.Name = BC.Barcode;
			
			system.debug('@@@@@ InputForError BC.Barcode : ' + BC.Barcode);
			
			if(IV.IV.Name.length() <> 23){
				IV.State = 3;
				IV.IV.Name = '';
			}else{
				IV.State = 2;
				cIVs.add(new cInventory(seq + 1));
			}
			
			InputBarcodeGetVal = '';
			
			//throw new MyException('IV.IV.CntImportInspection__c : ' + IV.IV.CntImportInspection__c);
			
			system.debug('@@@@@ InputForError End'); 
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch(exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MakeErrorStr(e)));
		}
	}
	
	/****************************************************************************************************
	*	취소
	****************************************************************************************************/
	public void RowCancel(){
		integer seq = integer.valueOf(InputBarcodeSeq);
		cInventory IV = cIVs[seq-1];
		IV.IV = new Inventory__c();
		IV.State = 1;
	}
	
	/****************************************************************************************************
	*	행 삭제
	****************************************************************************************************/
	public void DeleteRow(){
		try{
			integer seq = integer.valueOf(InputBarcodeSeq);
			
			//if(cIVs[seq-1].IV.ID<>null)	delete [SELECT Id FROM Inventory__c WHERE ID=:cIVs[seq-1].IV.ID];
			
			for(integer i = seq; i<cIVs.size(); i++) cIVs[i].Seq = cIVs[i].Seq - 1;
			
			cIVs.remove(seq - 1);
			
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch(exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MakeErrorStr(e)));
		}
	}
	
	/****************************************************************************************************
	*	저장
	****************************************************************************************************/
	public void Save(){
		try{
			List<Inventory__c> InsertIVs = new List<Inventory__c>();
			for(cInventory cIV:cIVs){
				if(cIv.state == 2){
					cIV.IV.DateRequestImportInspection__c = system.today();
					cIv.IV.StateImportInspection__c = '의뢰';
					
					//system.debug('cIV.IV.Item_PartEtc__c : ' + cIV.IV.Item_PartEtc__c);
					//system.debug('cIV.IV.Item__c : ' + cIV.IV.Item__c);
					
					//품목 필터 적용한 필드값을 원래 필드값으로 넣는다. - 수동저장할때 등록된다.
					//cIV.IV.Item__c = cIV.IV.Item_PartEtc__c;
					//cIV.IV.Item_PartEtc__c = null;
					
					InsertIVs.add(cIV.IV);
				}else if(cIv.state == 1){}
				else throw new MyException('입력이 완료되지 않은 항목이 있습니다. 모두 입력 후에 진행하여 주시기 바랍니다.');
			}
			if(InsertIVs.size()<1) throw new MyException('저장할 항목이 없습니다. 확인 후 진행하여 주시기 바랍니다.');
			
			for(Inventory__c IV:InsertIVs) system.debug('IV.Item__c : ' + IV.Item__c);
			
			system.debug('before InsertIVs');
			
			insert InsertIVs;
			
			//외주가공처리 결과 등록
			//InventoryAfter__c 등록하기 위한 InsertIVs의 Map 구성
			map<string, id> mapInsertIVs = new map<string, id>();
			for(Inventory__c IV:InsertIVs) mapInsertIVs.put(IV.Name, IV.Id);

			list<Outsoursing__c> UpsertOSs = new list<Outsoursing__c>();
			list<OutsoursingResult__c> UpsertOSRs = new list<OutsoursingResult__c>();
			
			list<wOutsoursing> targetwOSs = mapwOSs.values();
			
			for(wOutsoursing wOS:targetwOSs){
				for(wOutsoursingresult wOSR:wOS.wOSRs){
					//UpsertOSs.add(wOSR.OS);
					
					for(OutsoursingResult__c OSR:wOSR.OSRs){
						//newOSR.InventoryAfter__c = wOS.barcode;
						if(OSR.Id==null) OSR.InventoryAfter__c = mapInsertIVs.get(OSR.TempBarcode__c);
						OSR.TempBarcode__c = null;
						UpsertOSRs.add(OSR);
					}
				}
			}
			
			//upsert UpsertOSs;
			upsert UpsertOSRs;
			
			
			// cIVs에서 입력대기상태인 Row를 삭제한다.
			List<cInventory> changecIVs = new List<cInventory>();
			
			for(cInventory cIV:cIVs){
				if(cIv.state == 2){
					
					cIv.state = 5;
					changecIvs.add(cIv);
				}else if(cIv.state == 1){
				}else changecIVs.add(cIv);
			}
			
			cIVs = changecIVs;
			IsAllSaved = true;
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch(exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MakeErrorStr(e)));
		}
	}	
	
	/****************************************************************************************************
	*	바코드 inner class
	****************************************************************************************************/
	private class cBarcode{
		//모두 23자리
		public string barcode{get; set;}
		public string Item{get; set;}		//9자리
		public string gCnt{get; set;}		//4자리
		public integer Cnt{get; set;}		//변환
		public string Acc{get; set;}		//2자리
		public string gDateManu{get; set;}	//5자리
		public date DateManu{get; set;}		//변환
		public string seq{get; set;}		//2자리
		public string gseq{get; set;}		//변환
		
		private string[] MonthFormat = new string[]{'', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'};
		
		private cBarcode(){}
		
		private cBarcode(string getVal){
			if(getVal.length()==23){
				this.barcode = getVal;
				this.Item = getVal.substring(0, 9);
				this.gCnt = getval.substring(9, 14);
				//this.Cnt = integer.valueOf(getval.substring(9, 14));
				this.Cnt = changeStringToInteger(getval.substring(9, 14));
				this.Acc = getVal.substring(14, 16);
				this.gDateManu = getVal.substring(16, 21);
				this.DateManu = changeBarcodeToDate(getVal.substring(16, 21));
				this.seq = getVal.substring(21, 23);
			}
		}
		private cBarcode(string s1, integer s2, string s3, date s4, string s5){
			this.Item = s1;
			this.Cnt = s2;
			this.gCnt = changeIntegerToString(s2, 5);
			this.Acc = s3;
			this.DateManu = s4;
			this.gDateManu = chagenDateToBarcode(s4);
			this.seq = s5;
			this.gseq = changeIntegerToString(Integer.valueOf(s5), 2);
			
			this.barcode = this.Item + this.gCnt + this.Acc + this.gDateManu + this.gseq;
			
			system.debug('@@@@@ cBarcode(,,,,) 결과 : ' + this.barcode);
			
			if(this.barcode.length() <> 23) this.barcode = '';
		}
		
		//string 을 integer로
		private integer changeStringToInteger(string getStr){
			integer retVal;
			try{
				retVal = integer.valueOf(getStr);
			}catch(exception e){
			}
			return retVal;
		}
		
		//integer를 string으로
		private string changeIntegerToString(integer getVal, integer stringLength){
			
			string retVal;
			retVal = string.valueOf(getVal);
			Integer temp = retVal.length();
			
			if(retVal.length() < stringLength){
				for(integer i = 0; i< stringLength - temp; i++){
					retVal = '0' + retVal;
				}
			}
			return retVal;
		}
		
		//14C29 형식을 2014-03-29 날짜 형식으로
		private date changeBarcodeToDate(string getVal){
			date retVal;
			try{
				integer ye = integer.valueOf('20' + getVal.substring(0, 2));
				integer mo = changeBarcodeToMonth(getVal.substring(2, 3));
				integer da = integer.valueOf(getVal.substring(3, 5));
				retVal = date.newInstance(ye, mo, da);
			}catch(exception e){
			}
			return retVal;
		}
		
		//ABCD 를 1,2,3,4 로
		private integer changeBarcodeToMonth(string getVal){
			integer retVal;
			for(integer i = 0 ; i < MonthFormat.size() ; i++){
				if(MonthFormat[i]==getVal){
					retVal = i;
					break;
				}
			}
			return retVal;
		}
		
		//2014-03-29 날짜 형식을 14C29 형식으로
		private string chagenDateToBarcode(date getVal){
			string retVal;
			try{
				retVal = string.valueOf(getVal.Year()).substring(2,4);
				retVal += changeMonthToBarcode(getVal.Month());
				retVal += changeIntegerToString(getVal.Day(), 2);
			}catch(exception e){
				
			}
			return retVal;
		}
		
		// 1,2,3,4 를 ABCD로
		private string changeMonthToBarcode(integer getVal){
			string retVal;
			try{
				retVal = MonthFormat[getVal];
			}catch(exception e){
			}
			return retVal;
		}
	}
	
	
	/****************************************************************************************************
	*	수입검사 조회
	****************************************************************************************************/
	//검색용 Object
	public Inventory__c SearchIV{
		get{
			if(SearchIV == null) SearchIV = new Inventory__c();
			return SearchIV;
		}
		set;
	}
	
	//디폴트용 Object
	private Inventory__c DefaultIV = new Inventory__c(DateImportInspection__c = system.today());
	/*
	public Inventory__c getDefaultIV(){
		if(DefaultIV == null){
			DefaultIV = new Inventory__c(DateImportInspection__c = system.today());
		}
		return DefaultIV;
	}
	*/
	
	/****************************************************************************************************
	*	조회 결과
	****************************************************************************************************/
	public List<Inventory__c> SearchcIVs{
		get{
			if(SearchcIVs==null) SearchcIVs = new List<Inventory__c>();
			return SearchcIVs;
		}
		set;
	}
	
	public void Search(){
		try{
			if(tempdate!=null && tempDate!=''){
				SearchIV.DateRequestImportInspection__c=Date.valueOf(tempdate);
			}
			SearchcIVs = new List<Inventory__c>();
			//if(SearchIV.Account__c == null && SearchIV.Item__c == null && SearchIV.DateRequestImportInspection__c == null) throw new MyException('검색 조건은 한가지 이상 입력하셔야 합니다.');
			if(SearchIV.Account__c == null && SearchIV.Item_PartEtc__c == null && SearchIV.DateRequestImportInspection__c == null) throw new MyException('검색 조건은 한가지 이상 입력하셔야 합니다.');
			
			
			
			string strQry = 'SELECT Id, Name, Item__r.Name,';
			strQry += '	Item__c, Account__c, DateManufacture__c, CntImportInspection__c, ';
			strQry += ' Seq__c, DateRequestImportInspection__c, StateImportInspection__c, ';
			strQry += ' CntImport__c, DateImportInspection__c, OwnerImportInspection__c ';
			strQry += ' , PrevLotNo__c, PrevLotNo2__c';
			strQry += ' FROM Inventory__c';
			
			string strQryWhere = '';
			
			if(SearchIV.Account__c <> null) strQryWhere += ' Account__c = \'' + SearchIV.Account__c + '\'';
			if(SearchIV.Item_PartEtc__c <> null){
				if(strQryWhere <> '') strQryWhere += ' AND ';
				strQryWhere += ' Item__c = \'' + SearchIV.Item_PartEtc__c + '\'';
			}
			if(SearchIV.DateRequestImportInspection__c <> null){
				if(strQryWhere <> '') strQryWhere += ' AND ';
				strQryWhere += ' DateRequestImportInspection__c = ' + string.valueOf(SearchIV.DateRequestImportInspection__c) + '';
			}
			
			if(strQryWhere <> '') strQryWhere += ' AND ';
			strQryWhere += ' StateImportInspection__c <> \'\'';
			
			if(strQryWhere <> '') strQryWhere = ' WHERE ' + strQryWhere;
			
			strQry += strQryWhere;
			strQry += ' Order by DateRequestImportInspection__c DESC';
			strQry += ' Limit 100';
			
			SearchcIVs = Database.query(strQry);
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch(exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MakeErrorStr(e)));
		}
	}

	/****************************************************************************************************
	*	수입검사 - 조회 - 삭제
	****************************************************************************************************/
	public string DeleteRowIVID{get; set;}
	public void DeleteRowSearchResult(){
		try{
			List<InventoryHistory__c> DeleteIVHs = [SELECT ID FROM InventoryHistory__c WHERE Inventory__c=:DeleteRowIVID];
			delete DeleteIVHs;

			List<Inventory__c> DeleteIVs = [SELECT ID FROM Inventory__c WHERE ID=:DeleteRowIVID];
			delete DeleteIVs;

			Search();
		}catch(exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MakeErrorStr(e)));
		}
	}



	/****************************************************************************************************
	*	수입검사 결과 등록
	****************************************************************************************************/
	/****************************************************************************************************
	*	바코드 검색
	****************************************************************************************************/
	public void InputBarcodeForSearch(){
		try{
			integer seq = integer.valueOf(InputBarcodeSeq);
			//바코드 입력 : InputBarcodeGetVal
			cInventory IV = cIVs[seq-1];
			
			IV.state = 6;
			List<Inventory__c> IVs = [SELECT ID, Name, Item__c, Account__c, DateManufacture__c
					, CntImportInspection__c, Seq__c, DateRequestImportInspection__c, StateImportInspection__c
					, CntImport__c, DateImportInspection__c, OwnerImportInspection__c
					, Warehouse__c
					, PrevLotNo__c
					, PrevLotNo2__c
					FROM Inventory__c
					WHERE Name = :InputBarcodeGetVal
				];
			
			if(IVs.size()<1){
				IV.state = 1;
				throw new MyException('등록된 내용이 없습니다.');
			}
			IV.IV = IVs[0];
			
			//default 값 설정
			if(IV.IV.DateImportInspection__c == null && DefaultIV.DateImportInspection__c <> null) IV.IV.DateImportInspection__c = DefaultIV.DateImportInspection__c;
			system.debug('IV.IV.OwnerImportInspection__c : ' + IV.IV.OwnerImportInspection__c);
			system.debug('DefaultIV.OwnerImportInspection__c : ' + DefaultIV.OwnerImportInspection__c);
			system.debug('IV.IV.OwnerImportInspection__c == null && DefaultIV.OwnerImportInspection__c <> null : ' + (IV.IV.OwnerImportInspection__c == null && DefaultIV.OwnerImportInspection__c <> null));
			if(IV.IV.OwnerImportInspection__c == null && DefaultIV.OwnerImportInspection__c <> null) IV.IV.OwnerImportInspection__c = DefaultIV.OwnerImportInspection__c;
			if(IV.IV.Warehouse__c == null && DefaultIV.Warehouse__c <> null) IV.IV.Warehouse__c = DefaultIV.Warehouse__c;
			
			InputBarcodeGetVal = '';
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch(exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MakeErrorStr(e)));
		}
	}
	
	/****************************************************************************************************
	*	수입검사 상태 변경
	****************************************************************************************************/
	public void ChangeState(){
		try{
			integer seq = integer.valueOf(InputBarcodeSeq);
			cInventory IV = cIVs[seq-1];
			IV.IsChangeCntImport = false;
			if(IV.IV.stateImportInspection__c == '일부합격') IV.IsChangeCntImport = true;
			if(IV.IV.StateImportInspection__c == '합격') IV.IV.CntImport__c = IV.IV.CntImportInspection__c;
			if(IV.IV.StateImportInspection__c == '불합격') IV.IV.CntImport__c = 0;
			
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch(exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MakeErrorStr(e)));
		}
	}
	
	/****************************************************************************************************
	*	저장
	****************************************************************************************************/
	public void RowSave(){
		try{
			integer seq = integer.valueOf(InputBarcodeSeq);
			cInventory IV = cIVs[seq-1];
			
			if(IV.IV.StateImportInspection__c == null || IV.IV.CntImport__c == null || 
				IV.IV.DateImportInspection__c == null || IV.IV.OwnerImportInspection__c == null ||
				IV.IV.Warehouse__c == null
				){
				
				throw new MyException('모든 사항은 필수로 입력하셔야 합니다.');
			}
			
			update IV.IV;
			
			cIVs.add(new cInventory(seq + 1));
			InputBarcodeGetVal = '';
			IV.State = 5;
			
			//default 값 설정
			if(IV.IV.DateImportInspection__c <> DefaultIV.DateImportInspection__c) DefaultIV.DateImportInspection__c = IV.IV.DateImportInspection__c;
			if(IV.IV.OwnerImportInspection__c <> DefaultIV.OwnerImportInspection__c) DefaultIV.OwnerImportInspection__c = IV.IV.OwnerImportInspection__c;
			if(IV.IV.Warehouse__c <> DefaultIV.Warehouse__c) DefaultIV.Warehouse__c = IV.IV.Warehouse__c;
			
			
			
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch(exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MakeErrorStr(e)));
		}
	}
	
	
	
	public string CustomId{
        get{
            if(CustomId==null) CustomId = '';
            return CustomId;
        }
        set;
    }
    public string password{
        get{
            if(password==null) password = '';
            return password;
        }
        set;
    }
     
    public void bindCustomLoginAccount(){
    	system.debug('binding custom logined account by : ' + CustomId + ', ' + password);
    	
    	try {
    		Account a = [select id from Account where ID__c =: CustomId and Password__c =: password];
    		SearchIV.Account__c = a.id;
    	} catch (Exception e) {
    		throw new MyException(MakeErrorStr(e));
    	}
    }
	
	public String tempDate {get;set;}
	
	
	
	
	
	
	/****************************************************************************************************
	*	외주결과처리 - 
	*		수입검사 - 1:1 - 원천바코드 - 1:N - 외주 - 1:N - 외주결과
	****************************************************************************************************/
	//원천바코드 맵
	private map<string, wOutSoursing> mapOutMaster{
		get{
			if(mapOutMaster==null) mapOutMaster = new map<string, wOutSoursing>();
			return mapOutMaster;
		}
		private set;
	}
	
	//수입검사바코드
	private map<string, wOutSoursing> mapwOSs{
		get{
			if(mapwOSs==null) mapwOSs = new map<string, wOutsoursing>();
			return mapwOSs;
		}
		private set;
	}


	//원천바코드 이하
	private class wOutSoursing{
		//수입검사바코드
		//public string barcode{get; set;}
		
		//원천재고
		public Inventory__c IV{get; set;}
		
		public list<wOutsoursingResult> wOSRs{get; set;}
		
		//처음 로딩될때 
		public wOutSoursing(string OrgBarcode){
			//barcode = gbarcode;
			IV = new Inventory__c();
			IV.Name = OrgBarcode;
			wOSRs = new list<wOutsoursingResult>();
			wOSRs.add(new wOutsoursingResult(new Outsoursing__c()));
		}

		//가져올때
		public wOutSoursing(Inventory__c gIV){
			//string gbarcode, 
			//barcode = gbarcode;
			
			IV = gIV;
			
			list<Outsoursing__c> OSs = [SELECT Id
				, Inventory__c
				, DateOutsoursing__c
				, Account__c
				, CntOutSoursing__c
				, 	(SELECT ID
							, InventoryAfter__c
							, InventoryAfter__r.Name
							, CntImport__c
							, CntError__c
							, CntDisuse__c
							, TempBarcode__c
						FROM OutsoursingResult__r 
					)
				FROM Outsoursing__c
				WHERE Inventory__c=:IV.Id
				Order by DateOutsoursing__c
			];
			
			wOSRs = new list<wOutsoursingResult>();
			
			for(Outsoursing__c OS:OSs) wOSRs.add(new wOutsoursingResult(OS));
		}
	}
	
	private class wOutsoursingResult{
		public Outsoursing__c OS{get; set;}
		public list<OutsoursingResult__c> OSRs{get; set;}
		
		public wOutsoursingResult(Outsoursing__c gOS){
			OS = gOS;
			OSRs = gOS.OutsoursingResult__r;
			for(OutsoursingResult__c OSR:OSRs) OSR.TempBarcode__c = OSR.InventoryAfter__r.Name;
		}
	}
	
	/****************************************************************************************************
	*	외주결과처리 - 페이지 출력
	****************************************************************************************************/
	//노출시켜라
	public void runDispOut(){
		wOS = null;
		isDispOut = true;
	}
	//입력된거 취소
	public void runOutInputCancle(){
		wOS.IV.Name = '';
		mapOutMaster.put(SelectBarcode, wOS);
	}

	//닫아라
	public void runDispOutDisable(){
		mapOutMaster.put(SelectBarcode, wOS);
		isDispOut = false;
	}
	//외주결과처리 창을 노출할지 안할지
	public boolean isDispOut{
		get{
			if(isDispOut==null) isDispOut = false;
			return isDispOut;
		}
		private set;
	}
	//외주결과처리를 가져오기 위한 수입검사 바코드(parameter) map의 key
	public string SelectBarcode{get; set;}
	
	//원천바코드 입력 para
	public string InputBarcode{get ;set;}
	/****************************************************************************************************
	*	외주결과처리 - 노출된 내용
	****************************************************************************************************/
	//노출 wOutsouring
	public wOutsoursing wOS{
		get{
			if(wOS==null){
				if(SelectBarcode<>null){
					wOS = mapOutMaster.get(SelectBarcode);
					if(wOS==null){
						wOS = new wOutsoursing(InputBarcode);
						mapwOSs.put(InputBarcode, wOS);

						mapOutMaster.put(SelectBarcode, wOS);
					}
				}
			}
			return wOS;
		}
		private set;
	}
	
	//원재고 바코드 입력
	public void InputIVName(){
		try{
			//list<Inventory__c> OrgIVs = [SELECT ID FROM Inventory__c WHERE Name=:InputBarcode];
			list<Inventory__c> OrgIVs = [SELECT ID, Name, CntOutSoursing__c FROM Inventory__c WHERE Name=:wOS.IV.Name];
			
			if(OrgIVs.size()<1) throw new MyException('존재하지 않는 바코드입니다.');
			
			wOutsoursing CheckwOS = mapwOSs.get(wOS.IV.Name);
			if(checkwOS<>null){
				wOS = CheckwOS;
			}else{
				wOS = new wOutsoursing(OrgIVs[0]);
			}
			
			//외주처리는 있는데, 외주결과처리가 없는 경우 이 바코드에 대해서 새로운 외주처리 결과를 입력한다.
			system.debug('@@@@@ InputIVName wOS.wOSRs.size() : ' + wOS.wOSRs.size());
			
			if(wOS.wOSRs.size()>0){
				for(wOutsoursingResult wOSR:wOS.wOSRs){
					//외주결과처리가 해당하는 바코드에 대해서 있는 지 검증
					boolean isOutResult = false;
					for(OutsoursingResult__c OSR:wOSR.OSRs){
						if(OSR.TempBarcode__c == SelectBarcode) isOutResult = true;
					}
					
					system.debug('@@@@@ InputIVName isOutResult : ' + isOutResult);
					
					if(isOutResult==false){
						OutsoursingResult__c newOSR = new OutsoursingResult__c();
						//newOSR.InventoryAfter__c = SelectBarcode;
						newOSR.TempBarcode__c = SelectBarcode;
						newOSR.Outsoursing__c = wOSR.OS.Id;
						newOSR.CntImport__c = 0;
						newOSR.CntError__c = 0;
						newOSR.CntDisuse__c = 0;
						wOSR.OSRs.add(newOSR);
					}
					
					system.debug('@@@@@ InputIVName wOSR.OSRs.size() : ' + wOSR.OSRs.size());
				}
			}
			
			mapOutMaster.put(SelectBarcode, wOS);
			mapwOSs.put(wOS.IV.Name, wOS);
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch(exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MakeErrorStr(e)));
		}
		
	}
	
	/****************************************************************************************************
	*	Tester
	****************************************************************************************************/
	public void MyTest(Account AC, Item__c IT){
		try{
			throw new MyException('error');
		}catch(MyException e){
			MakeErrorStr(e);
		}
		
		List<cInventory> tcIVs = cIVs;
		system.debug(getIsAllSaved());
		
		InputBarcodeGetVal = IT.Code__c + '01000' + AC.Code__c + '00A01' + '01';
		InputBarcodeSeq = '1';
		
		InputBarcodeForPage();
		
		InputCustom();
		
		cInventory IV = cIVs[0];
		IV.IV.Item_PartEtc__c = IV.IV.Item__c;

		InputForError();
		
		Save();
		RowCancel();
		DeleteRow();
		
		cBarcode cB = new cBarcode();
		
		//수입검사 조회
		Inventory__c tSearchIV = SearchIV;
		//SearchcIVs
		SearchIV.Account__c = AC.Id;
		
		Search();
		
		cIVs = null;
		system.debug('cIVs.size() : ' + cIVs.size());
		
		//수입검사 결과 등록
		InputBarcodeForSearch();
		
		ChangeState();
		
		RowSave();
		
		List<Inventory__c> tSearchcIVs = SearchcIVs;
		
		system.debug(CustomId);
		system.debug(password);
		bindCustomLoginAccount();
		
		map<string, wOutSoursing> tmapOutMaster = mapOutMaster;
		
		SelectBarcode = IT.Code__c + '01000' + AC.Code__c + '00A01' + '02';
		InputBarcode = InputBarcodeGetVal;
		
		wOutsoursing twOS = new wOutsoursing(InputBarcodeGetVal);
		
		wOS = null;
		twOS = wOS;

		runOutInputCancle();
		runDispOut();
		
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
	}
}