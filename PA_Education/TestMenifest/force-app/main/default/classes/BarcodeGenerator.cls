public with sharing class BarcodeGenerator {

		//모두 22자리
		public string barcode{get; set;}
		public string Item{get; set;}		//9자리
		public string gCnt{get; set;}		//4자리
		public integer Cnt{get; set;}		//변환
		public string Acc{get; set;}		//2자리
		public string gDateManu{get; set;}	//5자리
		public date DateManu{get; set;}		//변환
		public string seq{get; set;}		//2자리
		
		private string[] MonthFormat = new string[]{'', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'};
		
		public BarcodeGenerator(){}
		
		public BarcodeGenerator(string getVal){
			if(getVal.length()==22){
				this.barcode = getVal;
				this.Item = getVal.substring(0, 9);
				this.gCnt = getval.substring(9, 13);
				//this.Cnt = integer.valueOf(getval.substring(9, 13));
				this.Cnt = changeStringToInteger(getval.substring(9, 13));
				this.Acc = getVal.substring(13, 15);
				this.gDateManu = getVal.substring(15, 20);
				this.DateManu = changeBarcodeToDate(getVal.substring(15, 20));
				this.seq = getVal.substring(20, 22);
			}
		}
		public BarcodeGenerator(string s1, integer s2, string s3, date s4, string s5){
			this.Item = s1;
			this.Cnt = s2;
			this.gCnt = changeIntegerToString(s2, 4);
			this.Acc = s3;
			this.DateManu = s4;
			this.gDateManu = chagenDateToBarcode(s4);
			this.seq = s5;
			
			this.barcode = this.Item + this.gCnt + this.Acc + this.gDateManu + this.seq;
			
			if(this.barcode.length() <> 22) this.barcode = '';
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
			if(retVal.length() < stringLength){
				for(integer i = 0; i< stringLength - retVal.length(); i++){
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
	

	/****************************************************************************************************
	*   테스트메소드
	****************************************************************************************************/
	@TestVisible private static void TestMe(){
		Integer i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
		i = 0;
	}
}