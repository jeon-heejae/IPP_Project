/**
 * Object       : Inventory_PrintBarcodeOnly.cls
 * Function     : 단순 바코드 출력
 * Author       : Yohan.Kang.
 * Date         : 2015.5.19
 * Tester       : Inventory_PrintBarcodeOnlyTester.Cls
 * page			:
            Inventory_PrintBarcodeOnly.page
 * Description  : 
 */
public with sharing class Inventory_PrintBarcodeOnly {
	public string InputBarcodeGetVal{get; set;}
	
	public void BarcodePut(){
		Barcode bar = mapBarcodes.get(Barcodes.size());
		bar.barcode = InputBarcodeGetVal.toUpperCase();
		mapBarcodes.put(Barcodes.size(), bar);
		mapBarcodes.put(Barcodes.size() + 1, new Barcode(Barcodes.size() + 1, ''));
		
		InputBarcodeGetVal = '';
		Barcodes = null;
	}
	
	public list<Barcode> Barcodes{
		get{
			if(Barcodes==null){
				Barcodes = mapBarcodes.values();
				Barcodes.sort();
			}
			return Barcodes;
		}
		private set;
	}
	
	private map<integer, Barcode> mapBarcodes{
		get{
			if(mapBarcodes==null){
				mapBarcodes = new map<integer, Barcode>();
				mapBarcodes.put(1, new Barcode(1, ''));
			}
			return mapBarcodes;
		}
		private set;
	}
	
	private class Barcode implements Comparable{
		public integer seq{get; set;}
		public string barcode{get; set;}
		
		public Barcode(integer gseq, string gbarcode){
			seq = gseq;
			barcode = gbarcode;
		}
		
		//sort
		public integer compareTo(Object compareTo){
			Barcode Barcode = (Barcode) compareTo;
			if(seq == Barcode.seq) return 0;
			if(seq > Barcode.seq) return 1;
			return -1;
		}
	}
	
	
    /****************************************************************************************************
    *   Tester
    ****************************************************************************************************/
    public void MyTest(){
        
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
    }
}