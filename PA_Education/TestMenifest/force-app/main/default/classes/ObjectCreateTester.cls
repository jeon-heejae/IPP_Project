/**
 * Object		: ObjectCreateTester.cls
 * Function		: 
 * Author		: Yohan.Kang.
 * Date			: 2015.2.28
 * Description	: 
 		Trigger 테스트에서 생성되는 개체 모음
 */
public with sharing class ObjectCreateTester {
    public static Account AC{
    	get{
    		if(AC==null){
		    	AC = new Account();
		    	AC.Name = 'Test Account';
		    	AC.Code__c = 'XZ';
				AC.ShortName__c = 'Test short Name';
    		}
	    	return AC;
    	}
    	private set;
    }
    //창고
    public static Warehouse__c WH{
    	get{
    		if(WH==null){
    			WH = new Warehouse__c();
    			WH.Name = '테스트 창고';
    		}
    		return WH;
    	}
    	private set;
    }
    //품목 Item__c
    public static Item__c IT{
    	get{
    		if(IT==null){
    			IT= new Item__c();
    			IT.Name = 'Test 품목';
    			IT.Code__c = 'Z99999911';
    			IT.BarcodeStructure__c = '{제품명}{수량(4)}{제조사}{제조일}{00}';
    		}
    		return IT;
    	}
    	private set;
    }
	
    public static Item__c subIT{
    	get{
    		if(subIT==null){
    			subIT= new Item__c();
    			subIT.Name = 'Test 품목2';
    			subIT.Code__c = 'Z99999912';
    			subIT.BarcodeStructure__c = '{제품명}{수량(4)}{제조사}{제조일}{00}';
    		}
    		return subIT;
    	}
    	private set;
    }	
	
    //재고 Inventory__c
    public static Inventory__c IV{
    	get{
    		if(IV==null){
    			IV = new Inventory__c();
    			
    			if(AC.ID==null) insert AC;
    			IV.Account__c = AC.Id;
    			
    			if(WH.Id==null) insert WH;
    			IV.Warehouse__c = WH.ID;
    			
    			if(IT.ID==null) insert IT;
    			IV.Item__c = IT.Id;
    		}
    		return IV;
    	}
    	private set;
    }
    
    //공정정보 ProcessInfo__c
    public static ProcessInfo__c PI{
    	get{
    		if(PI==null){
    			PI = new ProcessInfo__c();
    			
    			if(IT.Id==null) insert IT;
    			PI.Item__c = IT.Id;
    		}
    		return PI;
    	}
    	private set;
    }
    
    //공정상세정보 ProcessInfoDetail__c
    public static ProcessInfoDetail__c PID{
    	get{
    		if(PID==null){
    			PID = new ProcessInfoDetail__c();
    			
    			if(PI.Id==null) insert PI;
    			PID.ProcessInfo__c = PI.Id;
    			
    			if(SubIT.Id==null) insert SubIT;
    			PID.Item__c = SubIT.Id;
    			
    			PID.Seq__c = 1;
    		}
    		return PID;
    	}
    	private set;
    }
    
    //생산공정
    public static ProcessProduct__c PP{
    	get{
    		if(PP==null){
    			PP = new ProcessProduct__c();
    			PP.Date__c = system.today();
    		}
    		return PP;
    	}
    	private set;
    }
}