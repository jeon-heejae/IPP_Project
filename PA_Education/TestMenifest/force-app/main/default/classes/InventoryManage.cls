/**
 * Object       : InventoryManage.cls
 * Function     : 자재관리 관련
 * Author       : Yohan.Kang.
 * Date         : 2014.2
 * Tester       : InventoryManageTester.Cls
 * page			:
 *           Inventory_Search.page
 *           Inventory_Search_Product.page
 *           Inventory_Stock.page
 *           Inventory_Delivery.page
 * Description  : 
 */
public with sharing class InventoryManage  {
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
    
    public InventoryManage(){
        strMsg = '';
        garbege_check = 'N';
    }
    
    /****************************************************************************************************
    *   조회
    ****************************************************************************************************/
    //검색용 Object
    public Inventory__c SearchIV{
        get{
            if(SearchIV == null) SearchIV = new Inventory__c();
            return SearchIV;
        }
        set;
    }
    
    /****************************************************************************************************
    *   조회 결과 - 부품조회
    ****************************************************************************************************/
    public void Search(){
        try{
            //if(SearchIV.Item__c == null) throw new MyException('품목을 선택하세요');
            
            List<ProcessInfo__c> PIs = [SELECT ID, 
                (SELECT id, Item__c, Seq__c, Count__c, IsCommon__c, InjectPart__c, Item__r.Standard__c
                        , Item__r.CntOptimalInventory__c
                    FROM ProcessInfoDetail__r
                    Order by InjectPart__c , Seq__c 
                )  
                //FROM ProcessInfo__c WHERE Item__c=:SearchIV.Item__c
                FROM ProcessInfo__c WHERE Item__c=:item_id                          
            ];
            
            
            
            //wrapper를 만들고
            if(cSums == null){
                cSums = new List<cSummaryIV>();
            }else{
                cSums.clear();
            }
            
            if(cSums2 == null){
                cSums2 = new List<cSummaryIV2>();
            }else{
                cSums2.clear();
            }
            
            List<Inventory__c> temp_iv = [select Name, CntInventory2__c, Warehouse__c 
                                            from Inventory__c 
                                            where Item__c=:item_id 
                                            and Warehouse__r.Type__c = '창고' 
                                            and CntInventory2__c > 0]; 
            
            Set<ID> IMs2 = new Set<Id>();
            IMs2.add(item_id);
            map<string, List<cSummaryByWare>> mWHs2 = MakeMapBW(IMs2);
            cSummaryIV2 csiv2 = new cSummaryIV2();
            csiv2.item_name = item_name;
            csiv2.BWs = mWHs2.get(item_id);
            
            if(temp_iv.size() > 0){
                cSums2.add(csiv2);      
            }
                        
            //if(PIs.size()<1) throw new MyException('등록되어 있는 부품 또는 공정정보가 없습니다.');
            
            
            Set<ID> ITIDs = new Set<Id>();        //상세공정에 들어가 있는 Item id들
            
            for(ProcessInfo__c PI:PIs){
                for(ProcessInfoDetail__c PID:PI.ProcessInfoDetail__r){
                    cSummaryIV cSum = new cSummaryIV();
                    cSum.strSeq = ChangeItoS(PID.Seq__c, 3);
                    cSum.Level = new List<string>();
                    cSum.SubInfo = 0;
                    cSum.PID = PID;
                    //cSum.InventoryCnt = 0;
                    //cSum.CntLineInventory = 0;
                    cSum.CntOptimalInventory = integer.valueOf(PID.Item__r.CntOptimalInventory__c);
                    cSum.BWs = new List<cSummaryByWare>();                  
                    cSums.add(cSum);
                    
                    ITIDs.add(PID.Item__c);
                }
            }
            
            //집계된 IV를 부르고 IMs를 가지고
            map<string, List<cSummaryByWare>> mWHs = MakeMapBW(ITIDs);

            //하위공정이 있는지 확인한다.
            //private map<string, List<ProcessInfo__c>> MakeMapIsProcess(Set<ID> ItemIDs){
            map<string, List<ProcessInfo__c>> mapSubProcess = MakeMapIsProcess(ITIDs);

            
            //집계된 wrapper에 넣는다.
            for(cSummaryIV cSum:cSums){
                //IV삽입
                cSum.BWs = mWHs.get(cSum.PID.Item__c);
                /*
                if(cSum.BWs<>null) for(cSummaryByWare BW:cSum.BWs) cSum.InventoryCnt += BW.Cnt;             
                */
                
                //하위공정여부 삽입
                List<ProcessInfo__c> CheckSub = mapSubProcess.get(cSum.PID.Item__c);
                
                
                if(CheckSub<>null && CheckSub.size()>0) cSum.SubInfo = 1;
                
                else cSum.SubInfo = 0;
                
            }
            
            //cSums2 = [select Name, CntInventory2__c, Warehouse__c from Inventory__c where Item__c=:item_id];
            //sort 한 것을 list에 담는다
            //cSums.sort();
        }catch (MyException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }catch (Exception e){
            MakeErrorMsg(e);
        }
    }   
    
    //화면에 뿌려지는 List
    public List<cSummaryIV> cSums{
        get{
            if(cSums==null) cSums = new List<cSummaryIV>();
            return cSums;
        }
        set;
    }
    
    public List<cSummaryIV2> cSums2{
        get{
            if(cSums2==null) cSums2 = new List<cSummaryIV2>();
            return cSums2;
        }
        set;
    }
    
    //조회 결과 Wrapper
    private class cSummaryIV2{      
        public String item_name{get; set;}      
        public List<cSummaryByWare> BWs{get; set;}      //창고별 재고 집계     
    }
    
    //조회 결과 Wrapper
    private class cSummaryIV implements Comparable{
        //private string Target;
        public string strSeq{get; set;}         //index 1-1, 1-2, 1-2-1-1, 1-2-1-2, 1-3  공정순 + 공정상세순
        //public integer Level{get; set;}           //sub에 대한 깊이 를 List형식으로 담아 둔다
        public List<string> Level{get; set;}    //sub에 대한 깊이 를 List형식으로 담아 둔다
        public integer SubInfo{get; set;}       //하위공정 관련 0 없음 1 있지만 펼쳐지지않음 (+) 2 있지만 펼쳐짐 (-)
        public ProcessInfoDetail__c PID{get; set;}
        //public List<Inventory__c> IVs{get; set;}      //창고별 재고 집계
        public List<cSummaryByWare> BWs{get; set;}      //창고별 재고 집계 - 창고별로 집계를 하기 위함
        
        //인벤토리에 있는 걸 구하려고 loop를 돌리니 sort가 안되서 일단 잠정보류
        public integer InventoryCnt{
            get{
                if(BWs<>null){
                    InventoryCnt = 0;
                    for(cSummaryByWare BW:BWs) if(BW.Type=='창고') InventoryCnt += BW.Cnt;
                }else InventoryCnt = 0;
                return InventoryCnt;
            }
            private set;
        }

        //라인에 투입된 재고수량
        public integer CntLineInventory{
            get{
                if(BWs<>null){
                    CntLineInventory = 0;
                    for(cSummaryByWare BW:BWs) if(BW.Type=='공정') CntLineInventory += BW.Cnt;
                }else CntLineInventory = 0;
                return CntLineInventory;
            }
            private set;
        }

        //적정재고수량
        public integer CntOptimalInventory{
            get{
                if(PID<>null && PID.Item__c<>null) CntOptimalInventory = integer.valueOf(PID.Item__r.CntOptimalInventory__c);
                return CntOptimalInventory;
            }
            private set;
        }    
        
        //sort
        public integer compareTo(Object compareTo){
            cSummaryIV cSummaryIV = (cSummaryIV) compareTo;
            if(strSeq == cSummaryIV.strSeq) return 0;
            if(strSeq > cSummaryIV.strSeq) return 1;
            return -1;
        }
    }
    
    private class cSummaryByWare implements Comparable{
        public string Warehouse{get; set;}
        public integer Cnt{get; set;}
        public string Type{get; set;}       //구분 : 창고, 공정

        //sort
        public integer compareTo(Object compareTo){
            cSummaryByWare cSummaryByWare = (cSummaryByWare) compareTo;
            if(Warehouse == cSummaryByWare.Warehouse) return 0;
            if(Warehouse > cSummaryByWare.Warehouse) return 1;
            return -1;
        }
    }
    
    //map<string, List<Inventory__c>> 만들기 - Item 별로



    //map<string, List<cSummaryByWare>> 만들기 - Item 별로
    private map<string, List<cSummaryByWare>> MakeMapBW(Set<ID> ItemIDs){
        map<string, List<cSummaryByWare>> mWHs = new map<string, List<cSummaryByWare>>();       //Item__c별로 cSummaryByWare를 만듬
        try{
            map<Id, Warehouse__c> mapWarehouse = new map<Id, Warehouse__c>();
             mapWarehouse.putAll([select ID, Name FROM Warehouse__c]);
            
            List<AggregateResult> GRs = [SELECT Item__c, Warehouse__r.Type__c Type, Warehouse__c, Sum(CntInventory2__c) Sum
                FROM Inventory__c
                WHERE Item__c=:ItemIDs
                AND Warehouse__c<>null
                Group by Item__c, Warehouse__r.Type__c, Warehouse__c
            ];
            //AND Warehouse__r.Type__c = '창고'

            for(AggregateResult ar:GRs){
                
                string strI = string.valueOf(ar.get('Item__c'));
                string strT = string.valueOf(ar.get('Type'));
                string strW = mapWarehouse.get( string.valueOf(ar.get('Warehouse__c')) ).Name;
                integer intCnt = integer.valueOf(ar.get('Sum'));
                
                List<cSummaryByWare> cBWs;
                
                if(mWHs.get(strI)<>null){
                    cBWs = mWHs.get(strI);
                }else{
                    cBWs = new List<cSummaryByWare>();
                }
    
                cSummaryByWare cBW = new cSummaryByWare();
                cBW.Warehouse = strW;
                cBW.Cnt = intCnt;
                cBW.Type = strT;

                cBWs.add(cBW);
                
                cBWs.sort();
                mWHs.put(strI, cBWs);
                
            }
        }catch (MyException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }catch (Exception e){
            MakeErrorMsg(e);
        }
        return mWHs;
    }
    
    //하위공정이 있는지 확인하는 map 만들기 - Item 별로 
    private map<string, List<ProcessInfo__c>> MakeMapIsProcess(Set<ID> ItemIDs){
        map<string, List<ProcessInfo__c>> returnValue = new map<string, List<ProcessInfo__c>>();
        
        try{
            List<Item__c> ITs = [SELECT ID,
                    (SELECT ID
                        FROM ProcessInfo__r
                    )
                FROM Item__c
                WHERE ID=:ItemIds 
            ];
            
            for(Item__c IT:ITs){
                returnValue.put(IT.Id, IT.ProcessInfo__r);
            }
        }catch (MyException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }catch (Exception e){
            MakeErrorMsg(e);
        }
        return returnValue;
    }
    
    /****************************************************************************************************
    *   조회 결과 - 부품조회 - 버튼 클릭
    ****************************************************************************************************/
    public string ClickSeq{get; set;}
    public string ClickItemId{get; set;}
    public string ClickLevel{get; set;}
    /****************************************************************************************************
    *   조회 결과 - 부품조회 - Plus
    ****************************************************************************************************/
    public void ClickPlus(){
        // 최종적으로는 cSums에 담는다
        try{
            //현재 Row 꺼는 SubInfo를 2로 만든다.
            for(cSummaryIV cSum:cSums){
                if(cSum.strSeq == ClickSeq){
                    cSum.SubInfo = 2;
                    break;
                }
            }
            
            List<ProcessInfo__c> PIs = [SELECT ID, 
                (SELECT id, Item__c, Seq__c, Count__c, IsCommon__c, InjectPart__c, Item__r.Standard__c
                        , Item__r.CntOptimalInventory__c 
                    FROM ProcessInfoDetail__r
                    Order by Seq__c DESC
                )  
                FROM ProcessInfo__c WHERE Item__c=:ClickItemId
            ];
            
            

            //wrapper를 만들고
            Set<ID> IMs = new Set<Id>();        //상세공정에 들어가 있는 Item id들
            
            
            //하위공정 등을 체크하기 위해서 현재 들어온것에 대해서만 체크한 후 cSums에 다시 넣는다.
            List<cSummaryIV> TempcSums = new List<cSummaryIV>();
            
            
            
            for(ProcessInfo__c PI:PIs){
                for(ProcessInfoDetail__c PID:PI.ProcessInfoDetail__r){
                    cSummaryIV cSum = new cSummaryIV();
                    //여기가 위에꺼에서 변경
                    cSum.strSeq = ClickSeq + '-' + ChangeItoS(PID.Seq__c, 3);
                    cSum.Level = new List<string>();
                    for(integer i = 0 ; i < integer.valueOf(ClickLevel) + 1; i++) cSum.Level.add('');
                    
                    cSum.SubInfo = 0;
                    cSum.PID = PID;
                    //cSum.InventoryCnt = 0;
                    cSum.BWs = new List<cSummaryByWare>();
                    TempcSums.add(cSum);
                    
                    IMs.add(PID.Item__c);
                }
            }
            
            //집계된 IV를 부르고 IMs를 가지고
            map<string, List<cSummaryByWare>> mWHs = MakeMapBW(IMs);

            //하위공정이 있는지 확인한다.
            //private map<string, List<ProcessInfo__c>> MakeMapIsProcess(Set<ID> ItemIDs){
            map<string, List<ProcessInfo__c>> mapSubProcess = MakeMapIsProcess(IMs);

            
            //집계된 wrapper에 넣는다.
            for(cSummaryIV cSum:TempcSums){
                //IV삽입
                cSum.BWs = mWHs.get(cSum.PID.Item__c);
                /*
                if(cSum.BWs<>null){
                    for(cSummaryByWare BW:cSum.BWs){
                        cSum.InventoryCnt += BW.Cnt;
                    }
                }
                */
                //하위공정여부 삽입
                List<ProcessInfo__c> CheckSub = mapSubProcess.get(cSum.PID.Item__c);
                
                
                if(CheckSub<>null && CheckSub.size()>0){
                    cSum.SubInfo = 1;
                }else{
                    cSum.SubInfo = 0;
                }
            }
            
            cSums.addAll(TempcSums);
            //sort 한 것을 list에 담는다
            cSums.sort();
        }catch (MyException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }catch (Exception e){
            MakeErrorMsg(e);
        }
    }
    
    /****************************************************************************************************
    *   integer to string 3자리수로
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
    *   조회 결과 - 부품조회 - Minus
    ****************************************************************************************************/
    public void ClickMinus(){
        try{
            for(integer i=cSums.size()-1; i>-1;i--){
                if(cSums[i].strSeq == ClickSeq) cSums[i].subInfo = 1;
                if(cSums[i].strSeq.length() > ClickSeq.length() &&  cSums[i].strSeq.substring(0, ClickSeq.length()+1) == ClickSeq + '-'){
                    cSums.remove(i);
                }
            }
        }catch (MyException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }catch (Exception e){
            MakeErrorMsg(e);
        }
    }
    
    

    /****************************************************************************************************
    *   입고 출고 처리
    ****************************************************************************************************/
    public string InputBarcodeGetVal{get; set;}
    public string InputBarcodeSeq{get; set;}

    public String returnSeq{get; set;}
    public String returnQty{get; set;}
    
    public String gcSeq{get; set;}
    public String gcRecode{get; set;}
    
    //전체 저장 여부 체크
    private boolean IsAllSaved;
    public boolean getIsAllSaved(){
        if(IsAllSaved == null){
            IsAllSaved = false;
        }
        return IsAllSaved;
    }

    /****************************************************************************************************
    *   재고 list inner class 호출
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
    *   재고 list inner class
    ****************************************************************************************************/   
    private class cInventory{
        public Integer Seq{get; set;}       //순서
        public Integer State{get; set;}     //상태  1.바코드입력대기 2.입력완료
        public Inventory__c IV{get; set;}   //재고
        public Integer returnQty {get; set;} // 반납수량
         // 재고수량 (수식필드가 자동 업데이트가 되지 않아 쿼리 한 번 더 날리는 것보다 property 로 처리하는 게 나아 보여서 이렇게 구현함)
        public Integer currQty{get; set;}
        
        private cInventory(integer getSeq) {
            this.Seq = getSeq;
            this.State = 1;
            //this.returnQty = 0;
            //this.currQty = 0;
            this.IV = new Inventory__c();
        }
    }
    
    /****************************************************************************************************
    *   반납수량 등록
    ****************************************************************************************************/
    public void bindReturnQty(){
        Integer seq = Integer.valueOf(returnSeq);
        Integer val = Integer.valueOf(returnQty);
        
        cInventory IV = cIVs[seq - 1];
        if(IV.IV.CntInventory2__c - val < 1)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Seq : ' + seq + ') 반납수량[' + val + ']이 재고수량[' + IV.IV.CntInventory2__c + '] 보다 큽니다.'));
        
        IV.returnQty = val;
        
        returnSeq = '';
    }
    
    /****************************************************************************************************
    *   폐기처리
    ****************************************************************************************************/
    public String garbege_check {get; set;}
    public List<String> garbege_list{
        get{
            if(garbege_list==null)garbege_list = new List<String>();
            return garbege_list;
        }
        set;
    }   
    
    public void garbege_list_clear(){
        if(garbege_list!=null || garbege_list.size()>0)
            garbege_list.clear();
        
        if(garbege_check=='Y'){
            if(cIVs.size() > 1){
                cIVs.remove(cIVs.size()-2);
                cIVs[cIVs.size()-1].seq -= 1;
                /*      
                for(cInventory ivs : cIVs){
                    ivs.seq = ivs.seq - 1; 
                }
                */  
            }
        }
        garbege_check = 'N';
    }
    
    /*
    * 폐기처리
    */
    public void transferToGarbege(){
        
        if(gcRecode != null && !''.equals(gcRecode)){
            Inventory__c iv = [select CntDisuse__c, Pba_delete__c, Pba_deletedate__c,CntInventory2__c from Inventory__c where Name=:gcRecode];
           	// 폐기수량을 현재 재고수량으로 바인딩; 재고수량은 수식필드 이므로 따로 수정 해 주지 않아도 됨;
            iv.CntDisuse__c = iv.CntInventory2__c;
            iv.Pba_delete__c = 'Y';
            iv.Pba_deletedate__c = System.today();      
            update iv;
            garbege_check = 'N';
            
            
            
            for(integer i=0;i<garbege_list.size();i++){
                List<String> str = String.valueOf(garbege_list[i]).split('\\|');
                
                if(gcRecode.equals(str.get(0))){
                    garbege_list.remove(i);
                    i--;
                    system.debug('삭제완료');
                }           
                else
                {   
                    system.debug('삭제실패');   
                }           
            }
        }
        else {
            // 폐기처리가 한 건일 경우.
            integer seq = integer.valueOf(gcSeq);
            cInventory IV = cIVs[seq - 1];
            IV.IV.CntDisuse__c = IV.IV.CntInventory2__c;
            IV.IV.Pba_delete__c = 'Y';
            IV.IV.Pba_deletedate__c = System.today();
            update IV.IV;
            cIVs.remove(seq - 1);
        }
    }
    
    /****************************************************************************************************
    *   바코드 등록
    ****************************************************************************************************/
    public void InputBarcodeForPage(){
        try{
            integer seq = integer.valueOf(InputBarcodeSeq);
            
            if(IsDuplicateBarcode(InputBarcodeGetVal, cIVs, seq)) throw new MyException('중복되는 바코드입니다.');
            if(InputBarcodeGetVal.length()<>23) throw new MyException('바코드의 길이가 잘못되었습니다.');
            
            cInventory IV = cIVs[seq - 1];
            
            List<Inventory__c> IVs = [SELECT Id, Name, Item__c, Account__c, DateManufacture__c, CntImportInspection__c, 
                Seq__c, CntImport__c, CntUsed__c, CntUsed2__c, CntShipment__c, CntInventory__c, CntInventory2__c, Warehouse__c
                , Item__r.Prescription__c, CntDisuse__c, Pba_delete__c, Pba_deletedate__c, DateImportInspection__c
                , Item__r.Name, Account__r.Name, Warehouse__r.Name
                FROM Inventory__c
                WHERE Name = :InputBarcodeGetVal
                ];
            
            if(IVs.size() < 1) throw new MyException('바코드에 해당하는 재고가 없습니다.');
            
            IV.IV = IVs[0];
            IV.State = 2;
            
            // 생산라인 투입일 경우 필요한 처리루틴 추가
            if('공정'.equals(warehouse_category)){
                // 2. 재고 바코드 리딩시 해당 품목의 시효기간이 있는 경우 제조일로부터 시효기간을 계산하여 지난 경우는 메시지를 출력한다.
                
                Date makeDate = IV.IV.DateManufacture__c;
                Integer limitMonth = Integer.valueOf(IV.IV.Item__r.Prescription__c);
                if(limitMonth != null
	                && limitMonth > 0
	                && makeDate.addMonths(limitMonth) < System.today()
	                && !'Y'.equals(IV.IV.Pba_delete__c)
                ){
                    garbege_list.add(InputBarcodeGetVal);

                    String str = '';
                    str += IV.IV.Name.replace('|', '/').replace(',', '.');
                    str += '|' + IV.IV.Item__r.Name.replace('|', '/').replace(',', '.');
                    str += '|' + IV.IV.Account__r.Name.replace('|', '/').replace(',', '.');
                    str += '|' + String.valueOf(IV.IV.DateManufacture__c).replace('|', '/').replace(',', '.');
                    str += '|' + String.valueOf(IV.IV.DateImportInspection__c).replace('|', '/').replace(',', '.');
                    str += '|' + (IV.IV.CntImportInspection__c==null ? 0 : IV.IV.CntImportInspection__c);
                    str += '|' + (IV.IV.CntImport__c==null ? 0 : IV.IV.CntImport__c);
                    str += '|' + (IV.IV.CntUsed2__c==null ? 0 : IV.IV.CntUsed2__c);
                    str += '|' + (IV.IV.CntShipment__c==null ? 0 : IV.IV.CntShipment__c);
                    str += '|' + (IV.IV.CntInventory2__c==null ? 0 : IV.IV.CntInventory2__c);
                    str += '|' + (IV.IV.Warehouse__r.Name==null ? '' : IV.IV.Warehouse__r.Name.replace('|', '/').replace(',', '.'));
                    
                    garbege_list.add(str);

                    cIVs.remove(seq - 1);
                    
                    // 다음 row 입력창이 나와야 하므로 추가
                    cIVs.add(new cInventory(seq));          
                    InputBarcodeGetVal = '';
                    garbege_check = 'Y';
                    //IV.State = 9;
                    throw new MyException('시효기간이 지난 부품입니다. 폐기처리해야 합니다.');
                }
                // 1. 재고 바코드 리딩시 해당 품목의 다른 재고가 있고, 그 다른 재고가 수입검사일시가 빠른 경우 메시지를 출력한다.
                // 생산라인 재고도 제외 한다.
                list<Inventory__c> children = new list<Inventory__c>();
                
                List<Inventory__c> children2 = [SELECT Id, Name, Item__c, Item__r.Name, Account__c, Account__r.Name, DateManufacture__c, CntImportInspection__c, 
                    Seq__c, CntImport__c, CntUsed__c, CntUsed2__c, CntShipment__c, CntInventory__c, CntInventory2__c, Warehouse__c, Warehouse__r.Name
                    , Item__r.Prescription__c, CntDisuse__c, Pba_delete__c, Pba_deletedate__c, DateImportInspection__c
                    FROM Inventory__c 
                    WHERE Inventory__c.Item__c =: IV.IV.Item__c 
                    AND WarehouseType__c<>'공정'
                    AND CntInventory2__c>0 
                    AND DateImportInspection__c<:IV.IV.DateImportInspection__c];
                    
                Integer gcSize = 0;  
                            
                boolean gabege_check = false;
                
                //현재 투입에 등록되어 있는 재고는 제외시킨다.
                set<id> cIVIDs = new set<id>();
                for(cInventory cIV:cIVs) cIVIDs.add(cIV.IV.Id);
                
                for(Inventory__c child:children2){
                	if(!cIVIDs.contains(child.Id)) children.add(child);
                	
                }
                
                
                for(Inventory__c child : children){
                    //if(child.DateManufacture__c < IV.IV.DateManufacture__c && !'Y'.equals(child.Pba_delete__c)){
                    
                        if(gabege_check == false){
                            garbege_list.add(InputBarcodeGetVal);
                            gabege_check=true;
                        }
                        String str = '';
                        str += child.Name.replace('|', '/').replace(',', '.');
                        str += '|' + child.Item__r.Name.replace('|', '/').replace(',', '.');
                        str += '|' + child.Account__r.Name.replace('|', '/').replace(',', '.');
                        str += '|' + String.valueOf(child.DateManufacture__c).replace('|', '/').replace(',', '.');
                        str += '|' + String.valueOf(child.DateImportInspection__c).replace('|', '/').replace(',', '.');
                        str += '|' + (child.CntImportInspection__c==null ? 0 : child.CntImportInspection__c);
                        str += '|' + (child.CntImport__c==null ? 0 : child.CntImport__c);
                        str += '|' + (child.CntUsed2__c==null ? 0 : child.CntUsed2__c);
                        str += '|' + (child.CntShipment__c==null ? 0 : child.CntShipment__c);
                        str += '|' + (child.CntInventory2__c==null ? 0 : child.CntInventory2__c);
                        str += '|' + (child.Warehouse__r.Name==null ? '' : child.Warehouse__r.Name.replace('|', '/').replace(',', '.'));
                        garbege_list.add(str);
                        gcSize++;
                    //}
                }
                if(gcSize > 0) {
                    cIVs.add(new cInventory(++seq));
                    InputBarcodeGetVal = '';
                    garbege_check = 'Y';
                    throw new MyException('현재 투입할 재고보다 선입된 재고가 아래와 같이 있습니다.');
                }
            }
            
            cIVs.add(new cInventory(++seq));            
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
    *   수동 등록
    ****************************************************************************************************/
    public void InputCustom(){
        integer seq = integer.valueOf(InputBarcodeSeq);
        cInventory IV = cIVs[seq-1];
        IV.State = 4;
    }
    
    /****************************************************************************************************
    *   등록
    ****************************************************************************************************/
    public void InputForError(){
        try{
            integer seq = integer.valueOf(InputBarcodeSeq);
            cInventory IV = cIVs[seq-1];
            
            if(IV.IV.Item__c==null) throw new MyException(Schema.sObjectType.Inventory__c.fields.Item__c.Label + '을 선택하셔야 합니다.');
            
            if(IV.IV.Account__c==null){
                if(SearchIV.Account__c == null)
                    throw new MyException(Schema.sObjectType.Inventory__c.fields.Account__c.Label + '를 선택하셔야 합니다.');
                else
                    IV.IV.Account__c = SearchIV.Account__c;
            }
            
            if(IV.IV.DateManufacture__c==null) throw new MyException(Schema.sObjectType.Inventory__c.fields.DateManufacture__c.Label + '을 입력해야 합니다.');
            if(IV.IV.CntImportInspection__c==null) throw new MyException(Schema.sObjectType.Inventory__c.fields.CntImportInspection__c.Label + '을 입력해야 합니다.');
            if(IV.IV.Seq__c==null) throw new MyException(Schema.sObjectType.Inventory__c.fields.Seq__c.Label + '을 입력해야 합니다.');
            
            string Item = [SELECT Code__c FROM Item__c WHERE ID=: IV.IV.Item__c].Code__c;
            string Acc = [SELECT Code__c FROM Account WHERE ID=: IV.IV.Account__c].Code__c;
            
            BarcodeGenerator BC = new BarcodeGenerator(Item, integer.valueOf(IV.IV.CntImportInspection__c), Acc, IV.IV.DateManufacture__c, IV.IV.Seq__c);
            
            if(IsDuplicateBarcode(BC.barcode, cIVs, seq)) throw new MyException('중복되는 바코드입니다.');
            
            IV.IV.Name = BC.Barcode;
             
            if(IV.IV.Name.length() <> 23){
                IV.State = 3;
                IV.IV.Name = '';
                throw new MyException('Barcode : ' + IV.IV.Name);
            }else{
                IV.State = 2;
                insert IV.IV;
                cIVs.add(new cInventory(seq + 1));
            }
            
            InputBarcodeGetVal = '';
        }catch (MyException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ExceptionHandler.MakeErrorStr(e)));
        }
    }
    
    /****************************************************************************************************
    *   취소
    ****************************************************************************************************/
    public void RowCancel(){
        integer seq = integer.valueOf(InputBarcodeSeq);
        cInventory IV = cIVs[seq-1];
        IV.IV = new Inventory__c();
        IV.State = 1;
    }
    
    /****************************************************************************************************
    *   행 삭제
    ****************************************************************************************************/
    public void DeleteRow(){
        try{
            integer seq = integer.valueOf(InputBarcodeSeq);
            
            //레코드를 삭제하면 안된다.
            //if(cIVs[seq-1].IV.ID<>null) delete [SELECT Id FROM Inventory__c WHERE ID=:cIVs[seq-1].IV.ID];
            
            for(integer i = seq; i<cIVs.size(); i++) cIVs[i].Seq = cIVs[i].Seq - 1;
            
            cIVs.remove(seq - 1);
            
        }catch (MyException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ExceptionHandler.MakeErrorStr(e)));
        }
    }

    /****************************************************************************************************
    *   생산라인 투입
    ****************************************************************************************************/
    public void GoProductLine(){
        try{
            List<Id> UpdateIds = new List<Id>();
            for(cInventory cIV:cIVs){
                if(cIV.state == 2){
                    UpdateIds.add(cIV.IV.Id);
                }else if(cIv.state == 1){
                    
                }else{
                    throw new MyException('입력이 완료되지 않은 항목이 있습니다. 모두 입력 후에 진행하여 주시기 바랍니다.');
                }
            }
            
            List<Inventory__c> UpdateIVs = [SELECT Id, Warehouse__c, IsAbleTrace__c FROM Inventory__c WHERE Id in :UpdateIds];
            for(Inventory__c IV:UpdateIVs){
                //IV.Warehouse__c = SearchIV.Warehouse__c;
                IV.Warehouse__c = str2id_map.get(sel_warehouse);
                IV.IsAbleTrace__c = true;
            }
            
            if(UpdateIVs.size()<1) throw new MyException('저장할 항목이 없습니다. 확인 후 진행하여 주시기 바랍니다.');
            update UpdateIVs;
            
            // cIVs에서 입력대기상태인 Row를 삭제한다.
            List<cInventory> changecIVs = new List<cInventory>();
            
            for(cInventory cIV:cIVs){
                if(cIv.state == 3 || cIv.state == 2){
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
    
    
    /****************************************************************************************************
    *   자재창고 반납
    ****************************************************************************************************/
    public void StockProcess(){
        try{
            //if(SearchIV.Warehouse__c == null) throw new MyException('창고를 선택하셔야 합니다.');
                        
            List<Id> UpdateIds = new List<Id>();
            Map<Id, Map<String, Decimal>> updQtys = new Map<Id, Map<String, Decimal>>();
            for(cInventory cIV:cIVs){
                if(cIV.state == 2){
                    UpdateIds.add(cIV.IV.Id);
                    Integer rQty = Integer.valueOf(cIV.returnQty);
                    if(cIV.IV.CntInventory2__c - rQty < 0)
                    	throw new MyException('반납수량이 재고수량보다 클 수 없습니다.');
                    	
                    //if(rQty > 0){
                        Map<String, Decimal> tm = new Map<String, Decimal>();
                        Decimal used2 = (cIV.IV.CntUsed2__c == null ? 0 : cIV.IV.CntUsed2__c) + (cIV.IV.CntInventory2__c - rQty);
                        //tm.put('CntInventory2__c', cIV.IV.CntInventory2__c - cIV.returnQty);
                        cIV.IV.CntUsed2__c = used2;
                        cIV.currQty = rQty;
                        cIV.state = 3;
                        tm.put('CntUsed2__c', used2);
                        updQtys.put(cIV.IV.Id, tm);
                    //}
                }else if(cIv.state == 1){
                    
                }else{
                    throw new MyException('입력이 완료되지 않은 항목이 있습니다. 모두 입력 후에 진행하여 주시기 바랍니다.');
                }
            }
            
            List<Inventory__c> UpdateIVs = [SELECT Id, Warehouse__c, CntInventory2__c, CntUsed2__c, IsAbleTrace__c FROM Inventory__c WHERE Id in :UpdateIds];
            for(Inventory__c IV:UpdateIVs){
                //IV.Warehouse__c = SearchIV.Warehouse__c;
                IV.Warehouse__c = str2id_map.get(sel_warehouse);
                Map<String, Decimal> tm = updQtys.get(IV.Id);
                if(tm != null){
                    //IV.CntInventory2__c = tm.get('CntInventory2__c');
                    IV.CntUsed2__c = tm.get('CntUsed2__c');
                }
                
                IV.IsAbleTrace__c = true;
            }
            
            if(UpdateIVs.size()<1) throw new MyException('저장할 항목이 없습니다. 확인 후 진행하여 주시기 바랍니다.');
            update UpdateIVs;
            
            // cIVs에서 입력대기상태인 Row를 삭제한다.
            List<cInventory> changecIVs = new List<cInventory>();
            
            for(cInventory cIV:cIVs){
                if(cIv.state == 3 || cIv.state == 2){
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
    
    /****************************************************************************************************
    * Warehouse__c SelectOption 목록  
    ****************************************************************************************************/
    public String warehouse_category {get; set;}
    public String sel_warehouse {get; set;} // 선택한 창고
    public Map<String, Id> str2id_map;
    
    // Warehouse__c 콤보박스
    public void Warehouse(){
        
    }
    
    // Warehouse__c 콤보박스
    public List<SelectOption> getWarehouse (){
        List<SelectOption> options = new List<SelectOption>();
        str2id_map = new Map<String, Id>{};
                 
        List<Warehouse__c> ware_list = [select Id, Name from Warehouse__c where Type__c=:warehouse_category order by Name]; 
                    
        for(Warehouse__c wh: ware_list){
            str2id_map.put(wh.Name,wh.Id);
            options.add(new SelectOption(wh.Name,wh.Name));
        }         
             
        return options;
    }   
    
    /****************************************************************************************************
    *   Keyword Search
    ****************************************************************************************************/
    public String item_id{get;set;} 
    public String item_name{get;set;} 
    public String item_standard{get;set;}
    
    public String item_keyword {get; set;}
    public List<Item__c> keyword_list {get; private set;}
    
    public void keyword_Search(){
        try{
            if(item_keyword == null) throw new MyException('키워드를 입력하세요');
            item_id='';
            String Keyword='%'+item_keyword+'%';
            keyword_list = [
                            select Id, Name, Type__c, Standard__c
                            from item__c 
                            where (Name Like:keyword OR Code__c Like:keyword)
                            and (type__c = '제품' OR type__c = '부품') 
                            order by type__c, Name];        
            
                            

            if(cSums == null){
                cSums = new List<cSummaryIV>();
            }else{
                cSums.clear();
                cSums2.clear();
            }
            
            if(keyword_list.size() == 1){
                item_id=keyword_list[0].id;
                item_name=item_keyword;
                Search();
            }
            if(keyword_list.size() < 1) throw new MyException('조회 결과가 없습니다.');          
        }catch (MyException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }catch (Exception e){
            MakeErrorMsg(e);
        }
    }
    
    /*
    이전 버전
    
    private string SearchType;
    private string getSearchType(){
        if(SearchType==null) SearchType = '부품';
        return SearchType;
    }
    private void setSearchType(string str){
        SearchType = str;
    }
    
    public void Search_Product(){
        SearchType = '제품';
        Search();
    }
    
    public void Search(){
        try{
            SearchcIVs = new List<Inventory__c>();
            if(SearchIV.Item__c == null){
                throw new MyException('검색 조건을 입력하셔야 합니다.');
            }

            string strQry = 'SELECT Id, Name, ';
            strQry += ' Item__c, Account__c, DateManufacture__c, CntImportInspection__c, Seq__c, ';
            strQry += ' CntImport__c, CntUsed__c, CntShipment__c, CntInventory2__c, Warehouse__c';
            strQry += ' FROM Inventory__c';
            
            string strQryWhere = '';
            
            if(SearchIV.Item__c <> null){
                strQryWhere += ' AND Item__c = \'' + SearchIV.Item__c + '\'';
            }
            
            strQryWhere = ' WHERE ItemType__c=\'' + getSearchType() +'\' AND CntInventory2__c > 0' + strQryWhere;
            
            strQry += strQryWhere;
            strQry += ' Order by DateRequestImportInspection__c DESC';
            strQry += ' Limit 100';
            
            //throw new MyException(strQry); 
            
            SearchcIVs = Database.query(strQry);
        }catch (MyException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }catch(exception e){
            MakeErrorMsg(e);
        }
    }
    */
    
    
    /****************************************************************************************************
    *   Tester
    ****************************************************************************************************/
    public void MyTest(Item__c IT){
        try{
            throw new MyException('error');
        }catch(MyException e){
            MakeErrorMsg(e);
        }
        
        //조회 결과 - 부품조회
        SearchIV.Item__c = IT.Id;
        Search();
        
        List<cSummaryIV> tcSums = cSums;
        //tcSums[0].compareTo(tcSums[0]);
        
        system.debug('tcSums.size() : ' + tcSums.size());
        
        cSummaryByWare cSum = new cSummaryByWare();
        cSum.Warehouse = '창고1';
        cSum.Cnt=100;
        
        //tcSums[0].BWs = new List<cSummaryByWare>();
        //tcSums[0].BWs.add(cSum);
        //tcSums[0].BWs[0].compareTo(tcSums[0].BWs[0]);
        
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
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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