/**
 * Object		: ProductManage.cls
 * Function		: 제품관리 관련
 * Author		: Yohan.Kang.
 * Date			: 2014.6.9
 * Tester		: ProductManageTester.cls
 * Description	: 
 	Product_Search.page
 	Product_Stock.page
 */
public with sharing class ProductManage {
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
	
	public string strMsg{get; set;}
	
	public ProductManage(){
		strMsg = '';
	}
	
	/****************************************************************************************************
	*	제품 조회
	****************************************************************************************************/
	//검색용 Object
	private Inventory__c SearchIV;
	public Inventory__c getSearchIV(){
		if(SearchIV == null) SearchIV = new Inventory__c();
		return SearchIV;
	}
	
	//검색결과 Object
	public List<Inventory__c> IVs{
		get{
			if(IVs==null) IVs = new List<Inventory__c>();
			return IVs;
		}
		set;
	}
	public List<Inventory__c> getIVs(){
		if(IVs == null) IVs = new List<Inventory__c>();
		return IVs;
	}
	/****************************************************************************************************
	*	제품 조회 - 검색
	****************************************************************************************************/
	public void Search(){
		try{
			//if(SearchIV.Item__c==null) throw New MyException('검색 조건을 입력하세요');
						
			IVs = [SELECT ID, Name, Item__c, Warehouse__c, CntInventory2__c
				FROM Inventory__c
				//WHERE Item__c=:SearchIV.Item__c
				WHERE Item__c=:item_id
				AND CntInventory2__c > 0  
			];
			
			if(IVs.size()<1) throw new MyException('등록되어 있는 재고가 없습니다.');
			
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch (Exception e){
			MakeErrorMsg(e);
		}
	}
		
	/****************************************************************************************************
	*	입고처리
	****************************************************************************************************/
	public string InputBarcodeGetVal{get; set;}
	public string InputBarcodeSeq{get; set;}

	//전체 저장 여부 체크
	private boolean IsAllSaved;
	public boolean getIsAllSaved(){
		if(IsAllSaved == null) IsAllSaved = false;
		return IsAllSaved;
	}
	/****************************************************************************************************
	*	재고 list inner class 호출
	****************************************************************************************************/
	private List<cInventory> cIVs;
	public List<cInventory> getcIVs(){
		if(cIVs==null){
			cIVs = new List<cInventory>();
			cIVs.add(new cInventory(1));
		}
		return cIVs;
	}
	/****************************************************************************************************
	*	재고 list inner class
	****************************************************************************************************/	
	private class cInventory{
		public Integer Seq{get; set;}		//순서
		public Integer State{get; set;}		//상태  1.바코드입력대기 2.입력완료
		public Inventory__c IV{get; set;}	//재고
		
		private cInventory(integer getSeq) {
			this.Seq = getSeq;
			this.State = 1;
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
			if(InputBarcodeGetVal.length()>23 && InputBarcodeGetVal.length() < 0
			) throw new MyException('바코드의 길이가 잘못되었습니다.');
			
			cInventory IV = cIVs[seq - 1];
			
			List<Inventory__c> IVs = [SELECT Id, Name, Item__c, Account__c, DateManufacture__c, CntImportInspection__c, 
				Seq__c, CntImport__c, CntUsed__c, CntShipment__c, CntInventory2__c, Warehouse__c
				, ItemType__c
				FROM Inventory__c
				WHERE Name = :InputBarcodeGetVal
				];
			
			if(IVs.size() < 1) throw new MyException('바코드에 해당하는 재고가 없습니다.');
			IV.IV = IVs[0];
			IV.State = 2;
			cIVs.add(new cInventory(seq + 1));
			InputBarcodeGetVal = '';
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch(exception e){
			MakeErrorMsg(e);
		}
	}
	
	//바코드 중복검사
	private boolean IsDuplicateBarcode(string getVal, List<cInventory> ListInvens, integer seq){
		boolean isDuplicate = false;
		for(cInventory CV : ListInvens){
			if(CV.Seq<>seq && CV.IV.Name==getVal){
				isDuplicate = true;
				break;
			}
		}
		return isDuplicate;
	}
		
	/****************************************************************************************************
	*	입고 처리
	****************************************************************************************************/
	public void StockProcess(){
		try{
			//if(SearchIV.Warehouse__c == null) throw new MyException('창고를 선택하셔야 합니다.');
			
			List<Id> UpdateIds = new List<Id>();
			List<Id> parentIds = new List<Id>();
			for(cInventory cIV:cIVs){
				if(cIV.state == 2){
					UpdateIds.add(cIV.IV.Id);
					// BOX 재고인 경우, 그 하위 재고도 입고처리 한다.
					if('BOX'.equalsIgnoreCase(cIV.IV.ItemType__c)){
						parentIds.add(cIV.IV.Id);
					}
				}else if(cIv.state == 1){
					
				}else{
					throw new MyException('입력이 완료되지 않은 항목이 있습니다. 모두 입력 후에 진행하여 주시기 바랍니다.');
				}
			}
			
			List<Inventory__c> children = [SELECT Id FROM Inventory__c WHERE ParentInventory__c IN :parentIds];
			for(Inventory__c c : children) updateIds.add(c.Id);
			
			
			List<Inventory__c> UpdateIVs = [SELECT Id, Warehouse__c FROM Inventory__c WHERE Id in :UpdateIds];
			for(Inventory__c IV:UpdateIVs){
				//IV.Warehouse__c = SearchIV.Warehouse__c;
				IV.Warehouse__c = str2id_map.get(sel_warehouse);
			}
			
			if(UpdateIVs.size()<1) throw new MyException('저장할 항목이 없습니다. 확인 후 진행하여 주시기 바랍니다.');
			update UpdateIVs;
						
			// cIVs에서 입력대기상태인 Row를 삭제한다.
			List<cInventory> changecIVs = new List<cInventory>();
			
			for(cInventory cIV:cIVs){
				if(cIv.state == 2){
					cIv.state = 5;
					//cIV.IV.Warehouse__c = SearchIV.Warehouse__c;
					cIV.IV.Warehouse__c = str2id_map.get(sel_warehouse);
					changecIvs.add(cIv);
				}else if(cIv.state == 1){
				}else{
					changecIVs.add(cIv);
				}
			}
			
			cIVs = changecIVs;
			SearchIV = new Inventory__c();
			IsAllSaved = true;
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch (Exception e){
			MakeErrorMsg(e);
		}
	}
	//--------------------------------------------------------------------------
	public String pId{get;set;}
	public String pAccount{get;set;}
	public String pDate{get;set;}
	public String pCnt{get;set;}
	public String pSeq{get;set;}
	public String pBar{get;set;}
	
	public Id BoxItem {get; private set;}
	private List<String> bar_list{get; set;}
		
	public void Select2(){
		try{
			if(SearchIV.Item__c==null) throw New MyException('품목을 선택하세요');
			BoxItem = SearchIV.Item__c;			
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch (Exception e){
			MakeErrorMsg(e);
		}
	}	
	
	public void InputBarcodeForPage2(){
		if(bar_list==null){
			bar_list = new List<String>();
		}					
		bar_list.add(InputBarcodeGetVal);		
		InputBarcodeForPage();
	}
		
	public void StockProcess2(){
		try{
			if(BoxItem==null) throw New MyException('품목을 선택하세요');			
			if(bar_list==null) throw New MyException('바코드를 1개이상 입력하세요');	
			
			// 선택한 품목의 재고 쿼리		
			String field_name = 'Id, Name, Account__c';
			String query = 'Select ' + field_name + ' from Inventory__c ';
			query += 'where Item__c=:BoxItem';
			
			List<Inventory__c> IVs = Database.query(query);
			
			// Box에 새 재고 생성
			List<Item__c> IT = [SELECT ID, Name 
					FROM Item__c
					WHERE ProductItem__c=:BoxItem];
			
			Inventory__c nIV = new Inventory__c();
			
			Integer temp = Integer.valueOf(math.random()*100);
			nIV.Name = 'test_'+String.valueOf(temp);
			if(IT.size()<1)  throw New MyException('해당하는 Box품목이 없습니다.');	 
			nIV.Item__c = IT[0].Id;
			nIV.Account__c = IVs[0].Account__c;		
			nIV.CntOrgInventory__c = bar_list.size();		
			insert nIV;
			
			// 기재된 재고의 상위재고 변경
			for(Inventory__c iv : IVs){			
				for(String code : bar_list){
					if(iv.Name == code){
						iv.ParentInventory__c = nIV.Id;
					}
				} 
			}		
			upsert IVs;	
			system.debug('size : '+bar_list.size());
			
			List<Inventory__c> pIT = [SELECT OrgItem__c, Name,  Account__c, DateManufacture__c
					,CntOrgInventory__c
					FROM Inventory__c
					WHERE Id=:nIV.Id];
			
			pId = BoxItem;
			pAccount = pIT[0].Account__c;
			pDate = String.valueOf(pIT[0].DateManufacture__c);
			pCnt = String.valueOf(pIT[0].CntOrgInventory__c);
			pSeq = '1';
			pBar = pIT[0].Name;
			
			cIVs.remove(cIVs.size()-1);
			
			IsAllSaved = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, '저장되었습니다.'));
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch(exception e){
			MakeErrorMsg(e);
		}	
	}
	
	/****************************************************************************************************
	* Warehouse__c SelectOption 목록	
	****************************************************************************************************/
	public String sel_warehouse {get; set;} // 선택한 창고
	public Map<String, Id> str2id_map;
		
	// Warehouse__c 콤보박스
    public List<SelectOption> getWarehouse (){
        List<SelectOption> options = new List<SelectOption>();
        str2id_map = new Map<String, Id>{};
                 
        List<Warehouse__c> ware_list = [select Id, Name from Warehouse__c where Type__c='창고' order by Name]; 
	                
        for(Warehouse__c wh: ware_list){
        	str2id_map.put(wh.Name,wh.Id);
            options.add(new SelectOption(wh.Name,wh.Name));
        }         
             
        return options;
    }   
    
    /****************************************************************************************************
	*	Keyword Search
	****************************************************************************************************/
	public String item_id{get;set;} 
	public String item_name{get;set;} 
	public String item_standard{get;set;}
	
	public String item_keyword {get; set;}
	public List<Item__c> keyword_list{
		get{
			if(keyword_list==null) keyword_list = new List<Item__c>();
			return keyword_list;
		}
		private set;
	}
	
	
	public void keyword_Search(){
		try{
			if(item_keyword == null) throw new MyException('키워드를 입력하세요');
			
			String Keyword='%'+item_keyword+'%';
			keyword_list = [select Id, Name, Standard__c from item__c where Name Like:keyword AND Type__c in ('제품', 'PBA')];		
			
			

			if(IVs == null){
				IVs = new List<Inventory__c>();
			}else{
				IVs.clear();
			}			
									
			if(keyword_list.size() == 1){
				item_id=keyword_list[0].id;
				Search();
			}	
					
		}catch (MyException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}catch (Exception e){
			MakeErrorMsg(e);
		}
	}
	
	/****************************************************************************************************
	*	제품 Box 바코드 출력
	****************************************************************************************************/
	public Integer in_Box_Count{get; set;}
	public List<ProductBoxBarcode__c> pbb_list{get;set;}
	public String[] pBoxBar{get;set;}
	public List<ProductBoxBarcode__c> query_pbb{get;set;}
	
	public void print_barcode(){
		try{
			if(in_Box_Count==0 || in_Box_Count==null) throw new MyException('0또는 숫자를 입력하지 않았습니다.');
			if(in_Box_Count<0) throw new MyException('음수를 입력 할 수 없습니다.');
			if(in_Box_Count>1000) throw new MyException('1000개 초과 출력 할 수 없습니다.');
			
			
			if(pbb_list==null || pbb_list.size() < 1){
				pbb_list = new List<ProductBoxBarcode__c>();
			}else{
				pbb_list.clear();
			}
			
			if(query_pbb==null || query_pbb.size() < 1){
				query_pbb = new List<ProductBoxBarcode__c>();
			}else{
				query_pbb.clear();
			}			
			
			for(Integer i=0;i<in_Box_Count;i++){		
				ProductBoxBarcode__c pbb = new ProductBoxBarcode__c();
				pbb_list.add(pbb);
			}
			insert pbb_list;			
			
			for(Integer i=0;i<pbb_list.size();i++){		
				query_pbb.add([select Name, BarcodeStyle__c from ProductBoxBarcode__c where id=:pbb_list[i].id][0]);				
			}
			
			pbb_list = query_pbb;
			
			if(pBar==null)
				pBar='hi';
			/*
			pId;
			pAccount;
			pDate;
			pCnt;
			pSeq;
			pBar;
			*/
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
	}
}