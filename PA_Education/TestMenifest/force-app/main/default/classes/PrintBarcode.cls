/**
 * Object		: PrintBarcode.cls
 * Function		: 바코드 출력
 * Author		: Yohan.Kang.
 * Date			: 2014.5.12
 * Tester		: PrintBarcodeTester.Cls
 * Description	: 
 			PrintBarcode.page
 */
public with sharing class PrintBarcode {
	public PrintBarcode(){
	}
	
	/****************************************************************************************************
	*	Parameter정리
	****************************************************************************************************/
	public string ItemId{
		get{
			if(ItemId==null){
				ItemId = System.currentPageReference().getParameters().get('ItemId');
				if(ItemId==null) ItemId = '';
			}
			return ItemId;
		}
		private set;
	}
	
	public string AccountId{
		get{
			if(AccountId==null){
				AccountId = System.currentPageReference().getParameters().get('AccountId');
				if(AccountId==null) AccountId = '';
			}
			return AccountId;
		}
		private set;
	}
	
	public string DateManufacture{
		get{
			if(DateManufacture == null){
				DateManufacture = System.currentPageReference().getParameters().get('DateManufacture');
				if(DateManufacture==null) DateManufacture = '';
			}
			return DateManufacture;
		}
		private set;
	}
	
	public string CntImportInspection{
		get{
			if(CntImportInspection == null){
				CntImportInspection = System.currentPageReference().getParameters().get('CntImportInspection');
				if(CntImportInspection==null) CntImportInspection = '';
			}
			return CntImportInspection;

		}
		private set;
	}
	
	public string Seq{
		get{
			if(Seq == null){
				Seq = System.currentPageReference().getParameters().get('Seq');
				if(Seq==null) Seq = '';
			}
			return Seq;
		}
		private set;
	}
	
	public string barcode{
		get{
			if(barcode == null){
				barcode = System.currentPageReference().getParameters().get('barcode');
				if(barcode==null) barcode = '';
			} 
			return barcode;
		}
		private set;
	}
	
	//바코드 출력시 수량을 제외하면 barcode에서 짤라서 넣는다.
	//MA510201700100Z415G1901
	//12345678901234567890123
	public string barcodeWithIsPrintCnt{
		get{
			if(barcodeWithIsPrintCnt==null){
				if(IsPrintCnt=='Y') barcodeWithIsPrintCnt = barcode;
				else barcodeWithIsPrintCnt = barcode.substring(0, 9) + barcode.substring(14, 23);
				//barcodeWithIsPrintCnt = barcode.substring(9, 14);
			}
			return barcodeWithIsPrintCnt;
		}
		private set;
	}

	//축소모드인지 Y/N
	public string IsDownScaleMode{
		get{
			if(IsDownScaleMode==null) IsDownScaleMode = System.currentPageReference().getParameters().get('IsDownScaleMode');
			if(IsDownScaleMode==null) IsDownScaleMode = '';
			return IsDownScaleMode;
		}
		private set;
	}
	
	//수량은 제외하고 출력할지
	public string IsPrintCnt{
		get{
			if(IsPrintCnt==null) IsPrintCnt = System.currentPageReference().getParameters().get('IsPrintCnt');
			if(IsPrintCnt==null) IsPrintCnt = 'Y';
			return IsPrintCnt;
		}
		private set;
	}

	
	//ItemId, AccountId, DateManufacture, CntImportInspection, Seq, barcode
	private Item__c IT{
		get{
			if(IT==null){
				if(ItemId<>''){
					List<Item__c> ITs = [SELECT Code__c, Name FROM Item__c WHERE ID=:ItemId];
					if(ITs.size()>0) IT = ITs[0];
				}else{
					IT = new Item__c();
				}
			}
			
			return IT;
		}
		private set;
	}
	
	public string ItemCode{
		get{
			if(ItemCode==null) ItemCode = IT.Code__c;
			return ItemCode;
		}
		private set;
	}
	
	public string ItemName{
		get{
			if(ItemName == null) ItemName = IT.Name;
			return ItemName;
		}
		private set;
	}
	
	public string AccountName{
		get{
			if(AccountName == null){
				if(AccountId<>''){
					List<Account> ACs = [SELECT Name FROM Account WHERE ID=:AccountId];
					if(ACs.size()>0) AccountName = ACs[0].Name;
				}
				if(AccountName==null) AccountName = '';
			}
			return AccountName;
		}
		private set;
	}
	
	public void MyTest(){
		system.debug(ItemName);
		system.debug(AccountName);
		system.debug(DateManufacture);
		system.debug(CntImportInspection);
		system.debug(Seq);
		system.debug(barcode);
		system.debug(IsDownScaleMode);
		system.debug(ItemCode);
		
		ItemId = 'asdf';
		IT = null;
		Item__c tIT = IT;
		
		AccountId = 'asdf';
		AccountName = null;
		system.debug(AccountName);
		
	}
}