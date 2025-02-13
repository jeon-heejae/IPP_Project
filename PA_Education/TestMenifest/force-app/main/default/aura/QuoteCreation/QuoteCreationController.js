({
	fnInit : function(component, event, helper){
		component.set('v.toggleSpinner',true);
		helper.QuoteItemFieldLabel(component, event, helper);
		helper.QuoteFieldLabel(component, event, helper);
		helper.InitData(component, event, helper);
		// helper.EmpInitData(component);
		var qMode = component.get('v.qMode');
		console.log('qMode : '+ qMode);
		// console.log('idOppty : '+ idOppty);
		// console.log('nameOppty : '+ nameOppty);
		// console.log('qMode : '+ qMode);
		// console.log('qMode : '+ qMode);


	},

	fnCancel : function(component, event, helper){

		var quoteId = component.get('v.objQuote.Id');
		var opptyid = component.get('v.idOppty');

		if(quoteId){
            var rtnUrl = window.location.href;
            var url = "/lightning/r/" + quoteId+ "/view";
            window.parent.location = url;

		}else if(!quoteId){
            var rtnUrl = window.location.href;
            var url = "/lightning/r/" + opptyid+ "/view";
            window.parent.location = url;

		}else{
            var rtnUrl = window.location.href;
            var url = "/lightning/o/" + "Opportunity__c" + "/list?filterName=Recent";
            window.parent.location = url;

		}

	},

	fnEmpInfo : function(component, event, helper){
		helper.fnCalEmpListPrice(component, event, helper);
	},

    calculateWidth : function(component, event, helper) {
            var childObj = event.target
            var parObj = childObj.parentNode;
            var count = 1;
            //parent element traversing to get the TH
            while(parObj.tagName != 'TH') {
                parObj = parObj.parentNode;
                count++;
            }
            //to get the position from the left for storing the position from where user started to drag
            var mouseStart=event.clientX; 
            component.set("v.mouseStart",mouseStart);
            component.set("v.oldWidth",parObj.offsetWidth);
    },
     
    setNewWidth : function(component, event, helper) {
            var childObj = event.target
            var parObj = childObj.parentNode;
            var count = 1;
            //parent element traversing to get the TH
            while(parObj.tagName != 'TH') {
                parObj = parObj.parentNode;
                count++;
            }
            var mouseStart = component.get("v.mouseStart");
            var oldWidth = component.get("v.oldWidth");
            //To calculate the new width of the column
            var newWidth = event.clientX- parseFloat(mouseStart)+parseFloat(oldWidth);
            parObj.style.width = newWidth+'px';//assign new width to column
    },

	fnValidityCheck : function(component, event, helper){
        var allValid = component.find('inputField').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();

   			return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);

        if(allValid){
        	// 견적 상세까지 같이 저장 할 경우
            helper.fnDoSave(component, event, helper);
            console.log('allValid');
        }else{
        	helper.showToast('ERROR', '에러가 발생 했습니다 : 입력된 값을 확인해주세요.')
            console.log('Not allValid');
        }
        // }
        // else{
        // 	// 견적만 저장 할 경우
        //     helper.fnDoSave(component, event, helper);
        // }


	},


	fnAddRow : function(component, event, helper){
		var currentElem = event.getSource();
		var currentIndex = currentElem.get('v.name');
		var listQuote = component.get('v.list'+ currentIndex);


		if(listQuote == null) {
			listQuote = [];
		}

		//	sort order 계산 
		var iSortOrder = 1;
		if(listQuote.length > 0) {
			iSortOrder = listQuote[listQuote.length - 1].objQuoteItem.QuoteItem_SortOrder__c + 1;
			parseInt(iSortOrder);
		}

		var listQuoteTemp = {
			QuoteItem_ConsultAmount: 0,
			QuoteItem_ConsultDiscountAmount: 0,
			QuoteItem_ConsultListAmount: 0,
			QuoteItem_Discount_Percent: 0,
			QuoteItem_Discount_PercentLicense: 0,
			QuoteItem_Discount_PercentTraining: 0,
			QuoteItem_LicenseAmount: 0,
			QuoteItem_LicenseDiscountAmount: 0,
			QuoteItem_LicenseListAmount: 0,
			QuoteItem_ListPriceFormula: 0,
			QuoteItem_TrainingDiscountAmount: 0,
			QuoteItem_TrainingSalesAmount: 0,
			QuoteItem_TrainingListAmount:0,
			isChecked : false,
			// EmpName : '',
			objQuoteItem : {
						Id: null ,
						Name: null ,						
						QuoteItem_ConsultAmount__c: null, 
						QuoteItem_ConsultDiscountAmount__c: null,
						QuoteItem_ConsultDiscountedPrice__c: null,
						QuoteItem_ConsultLevel__c: "",
						QuoteItem_ConsultListAmount__c: null,
						QuoteItem_ConsultListPrice__c: null,
						QuoteItem_ConsultManMonths__c: null,
						QuoteItem_ConsultName__c: "TBD",						
						//2019-05-29 추가
						// QuoteItem_Emp__c: '' ,
						// QuoteItem_ConsultType__c: "",
						QuoteItem_Discount_Percent__c: 0,
						QuoteItem_License_Percent__c:0,
						QuoteItem_Training_Percent__c:0,
						QuoteItem_FOC__c: false,
						QuoteItem_LicenseAmount__c: 0,
						QuoteItem_LicenseListPrice__c: 0,
						QuoteItem_LicenseDiscountedPrice__c: 0,
						QuoteItem_LicenseNumberOfUser__c: 1,
						QuoteItem_LicenseDiscountAmount__c: 0,
						QuoteItem_LicenseListAmount__c: 0,
						QuoteItem_ListPriceFormula__c: 0,
						//Sort order 계산
						QuoteItem_SortOrder__c: iSortOrder,
						QuoteItem_TrainingStandardPrice__c:0,
						QuoteItem_TrainingDiscountAmount__c: 0,

						//수강인원에 따른 표준금액 계산을 위해 초기값 1로세팅 현재 이벤트없음
						QuoteItem_TrainingCount__c:1,
						QuoteItem_TrainingSalesAmount__c: 0,
			}
		}
	
		listQuote.push(listQuoteTemp);
		component.set('v.list'+ currentIndex , listQuote);
		helper.fnSubtotal(component, event, helper, currentIndex);


	},

	fnDeleteRow : function(component, event, helper) {
		var currentElem = event.getSource();
		var currentIndex = currentElem.get('v.name');

    	var listQuote = component.get("v.list" + currentIndex);
    	var checked = component.find('chk'+currentIndex);    	

    	var flagVal = true;
		var listDel = component.get('v.listDeleted');
		var idx = listQuote.length-1;

    	// var idx = 0;
		for(var i = listQuote.length - 1; i >= 0; i--) { 
			var obj = listQuote[i];
			var objIsChecked = obj.isChecked;
			if(objIsChecked) {
				var detailRecordId = listQuote[i].objQuoteItem.Id;
				listDel.push(detailRecordId);
				component.set('v.listDeleted',listDel);
				listQuote.splice(i, 1);
				flagVal=false;
			}
			
		}
		//체크박스 선택이 안되어있을때 -> 맨마지막 인덱스값의 ROW를 지움		
		if(flagVal){
			// var deleteConfirm = confirm('마지막행을 삭제하시겠습니까?');
			// if(deleteConfirm){
			if(idx>=0){
				var detailRecordIds = listQuote[idx].objQuoteItem.Id;
				listDel.push(detailRecordIds);
				component.set('v.listDeleted', listDel);
				listQuote.splice(i,1);
				flagVal=false
				// }
			}	
		}			

		component.set('v.list'+ currentIndex , listQuote);

		helper.fnSubtotal(component, event, helper, currentIndex);
		helper.fnSortOrderChange(component, event, helper);

	},

	fnMoveUp : function(component, event, helper){
		helper.fnRowMoveUp(component,event,helper);
	},

	fnMoveDown : function(component, event, helper){
		helper.fnRowMoveDown(component,event,helper);
	},
    
	fnCheckAll : function (component, event, helper){
		//체크박스 ALL 선택
		var currentElem = event.getSource();
		var currentIndex = currentElem.get('v.name');
    	var listQuote = component.get("v.list" + currentIndex);
		var checkedAll = component.find('chkAll'+currentIndex).get('v.checked');
		var checked = component.find('chk'+currentIndex);

		if(checked) {
			if($A.util.isArray(checked)) {
				for(var i = 0; i < checked.length; i++){
				 checked[i].set('v.checked', checkedAll);
				}
					
			} else {
				checked.set('v.checked', checkedAll);
			}
		}

		component.set('v.list'+ currentIndex , listQuote);



	},
	
	fnTotalDiscountChange : function (component, event, helper){
		var subPrice = event.getSource().get('v.value');
		subPrice = parseInt(subPrice);
		var objSub = component.get('v.objSumConsulting');
         // 'subQuote' : 0,
         // 'subPercent' : 0,
         // //새로계산되어 보여질 할인액
         // 'disQuote' :0,
         // 'disDisPrice' : 0

		objSub.disQuote = parseInt(objSub.subQuote) - subPrice;
		console.log('type objSub.subDiscount--' + typeof(objSub.subDiscount));
		console.log('type objSub.disDisPrice--' + typeof(objSub.disDisPrice));
		console.log('type subPrice --' + typeof(subPrice));
		


		objSub.disDisPrice = parseInt(objSub.subDiscount) + subPrice;

		console.log('type objSub.disQuote --' + typeof(objSub.disQuote));
		console.log('type disDisPrice --' + typeof(objSub.disDisPrice));
		component.set('v.objSumConsulting',objSub);
	},


	//컨설팅 할인가 계산
	fnConDiscountedPrice : function (component, event, helper){		

		var DiscountedPrice = event.getSource().get("v.value");
		var name = event.getSource().get("v.name"); 
		var type = name.split('-')[0];
		var idx = name.split('-')[1];
		console.log('DiscountedPrice : '+ DiscountedPrice);

		var listData = component.get("v.list" + type);
		var objListData = listData[idx];

		//단가 가져오기
		var ListPrice = objListData.objQuoteItem.QuoteItem_ConsultListPrice__c;
		//할인가 가져오기
		var DiscountPercent =((ListPrice - DiscountedPrice)/ListPrice)*100;

		objListData.QuoteItem_Discount_Percent = DiscountPercent;

		//공수 가져오기
		var Manmonths = objListData.objQuoteItem['QuoteItem_ConsultManMonths__c'];

		//표준금액(컨설팅) 가져오기
		var StandardPriceConsulting = objListData.objQuoteItem['QuoteItem_FOC__c'] ? 0 : objListData.objQuoteItem['QuoteItem_ConsultManMonths__c']*ListPrice;
		objListData.QuoteItem_ConsultListAmount = StandardPriceConsulting;

		//금액(컨설팅) 세팅
		var AmountConsulting = objListData.objQuoteItem['QuoteItem_FOC__c'] ? 0 : (DiscountedPrice==0 ? ListPrice : DiscountedPrice)*Manmonths;
		objListData.QuoteItem_ConsultAmount = AmountConsulting;

		//할인액(컨설팅) 세팅
		objListData.QuoteItem_ConsultDiscountAmount = StandardPriceConsulting - AmountConsulting;

		component.set("v.list" + type, listData);

		/* 소계 세팅 */
		helper.fnSubtotal(component, event, helper, type);


    	
	},

	fnConsultListPrice : function(component, event, helper){
		var consultListPrice = event.getSource().get('v.value');
		var name = event.getSource().get('v.name');
		var type = name.split('-')[0];
		var idx = name.split('-')[1];

		var listData = component.get('v.list'+type);
		var objListData = listData[idx];

		var ListPrice = consultListPrice;
		var DiscountedPrice = objListData.objQuoteItem['QuoteItem_ConsultDiscountedPrice__c'];
		var DiscountPercent =((ListPrice - DiscountedPrice)/ListPrice)*100;
		objListData.QuoteItem_Discount_Percent = DiscountPercent;

		//공수 가져오기
		var Manmonths = objListData.objQuoteItem['QuoteItem_ConsultManMonths__c'];

		//표준금액(컨설팅) 가져오기
		var StandardPriceConsulting = objListData.objQuoteItem['QuoteItem_FOC__c'] ? 0 : objListData.objQuoteItem['QuoteItem_ConsultManMonths__c']*ListPrice;
		objListData.QuoteItem_ConsultListAmount = StandardPriceConsulting;

		//금액(컨설팅) 세팅
		var AmountConsulting = objListData.objQuoteItem['QuoteItem_FOC__c'] ? 0 : (DiscountedPrice==0 ? ListPrice : DiscountedPrice)*Manmonths;
		objListData.QuoteItem_ConsultAmount = AmountConsulting;

		//할인액(컨설팅) 세팅
		objListData.QuoteItem_ConsultDiscountAmount = StandardPriceConsulting - AmountConsulting;

		component.set("v.list" + type, listData);

		/* 소계 세팅 */
		helper.fnSubtotal(component, event, helper, type);
	},

	//컨설팅 할인율 계산
	fnConDiscountPercent : function(component, event, helper) {
		var name = event.getSource().get("v.name");
		var type = name.split('-')[0];
		var idx = name.split('-')[1];
		var listData = component.get("v.list" + type);

		var objListData = listData[idx];

		//단가 가져오기
		var ListPrice = objListData.objQuoteItem['QuoteItem_ConsultListPrice__c'];

		//할인율 가져오기 (입력받기)
		var DiscountPercent = event.getSource().get("v.value") / 100;

		//할인가   단가 - (단가 * 할인율)
		var DiscountedPrice = ListPrice - (ListPrice * DiscountPercent);

		objListData.objQuoteItem.QuoteItem_ConsultDiscountedPrice__c = DiscountedPrice;
		//공수 가져오기
		var Manmonths = objListData.objQuoteItem['QuoteItem_ConsultManMonths__c'];
		//표준금액(컨설팅) 가져오기
		var StandardPriceConsulting = objListData.objQuoteItem['QuoteItem_FOC__c'] ? 0 : objListData.objQuoteItem['QuoteItem_ConsultManMonths__c']*ListPrice;
		objListData.QuoteItem_ConsultListAmount = StandardPriceConsulting;

		//금액(컨설팅) 세팅
		var AmountConsulting = objListData.objQuoteItem['QuoteItem_FOC__c'] ? 0 : (DiscountedPrice==0 ? ListPrice : DiscountedPrice)*Manmonths;
		objListData.QuoteItem_ConsultAmount = AmountConsulting;

		//할인액(컨설팅) 세팅
		objListData.QuoteItem_ConsultDiscountAmount = StandardPriceConsulting - AmountConsulting;


		component.set("v.list" + type, listData);
		/* 소계 세팅 */
		helper.fnSubtotal(component, event, helper, type);
	},
	//컨설팅 투입공수 입력 받기
	fnConManmonth : function (component, event, helper){
		var name = event.getSource().get("v.name");
		var type = name.split('-')[0];
		var idx = name.split('-')[1];
		var listData = component.get("v.list" + type);

		var objListData = listData[idx];
		//공수 가져오기
		var Manmonths = event.getSource().get('v.value');

		//단가 가져오기
		var ListPrice = objListData.objQuoteItem['QuoteItem_ConsultListPrice__c'];
		//할인율 가져오기 (입력받기)
		var DiscountPercent = objListData.QuoteItem_Discount_Percent / 100;

		//할인가   단가 - (단가 * 할인율)
		var DiscountedPrice = ListPrice - (ListPrice * DiscountPercent);

		objListData.objQuoteItem.QuoteItem_ConsultDiscountedPrice__c = DiscountedPrice;


		//표준금액(컨설팅) 가져오기
		var StandardPriceConsulting = objListData.objQuoteItem['QuoteItem_FOC__c'] ? 0 : objListData.objQuoteItem['QuoteItem_ConsultManMonths__c']*ListPrice;
		objListData.QuoteItem_ConsultListAmount = StandardPriceConsulting;

		//금액(컨설팅) 세팅
		var AmountConsulting = objListData.objQuoteItem['QuoteItem_FOC__c'] ? 0 : (DiscountedPrice==0 ? ListPrice : DiscountedPrice)*Manmonths;

		objListData.QuoteItem_ConsultAmount = AmountConsulting;
	
		//할인액(컨설팅) 세팅
		objListData.QuoteItem_ConsultDiscountAmount = StandardPriceConsulting - AmountConsulting;


		component.set("v.list" + type, listData);

		/* 소계 세팅 */
		helper.fnSubtotal(component, event, helper, type);
	},

	//컨설팅 Free Of Charge
	fnConFOC : function (component, event, helper){
		var name = event.getSource().get("v.name");
		var type = name.split('-')[0];
		var idx = name.split('-')[1];
		var listData = component.get("v.list" + type);
		var focChecked = event.getSource().get('v.checked');
		var objListData = listData[idx];

		//단가 가져오기
		var ListPrice = objListData.objQuoteItem['QuoteItem_ConsultListPrice__c'];
		//할인율 가져오기
		var DiscountPercent = objListData.QuoteItem_Discount_Percent/100;

		//할인가   단가 - (단가 * 할인율)
		var DiscountedPrice = ListPrice - (ListPrice * DiscountPercent);
		objListData.objQuoteItem.QuoteItem_ConsultDiscountedPrice__c = DiscountedPrice;
		//공수 가져오기
		var Manmonths = objListData.objQuoteItem['QuoteItem_ConsultManMonths__c'];

		//표준금액(컨설팅) 가져오기
		var StandardPriceConsulting = focChecked ? 0 : objListData.objQuoteItem['QuoteItem_ConsultManMonths__c']*ListPrice;
		objListData.QuoteItem_ConsultListAmount = StandardPriceConsulting;

		//금액(컨설팅) 세팅
		var AmountConsulting = focChecked ? 0 : (DiscountedPrice==0 ? ListPrice : DiscountedPrice)*Manmonths;
		objListData.QuoteItem_ConsultAmount = AmountConsulting;
		
		//할인액(컨설팅) 세팅
		objListData.QuoteItem_ConsultDiscountAmount = StandardPriceConsulting - AmountConsulting;

		component.set("v.list" + type, listData);

		/* 소계 세팅 */
		helper.fnSubtotal(component, event, helper, type);


	},
	//사용료 (월) 입력받기 
	fnLicenseListPrice : function(component, event, helper){
		var name = event.getSource().get("v.name"); 
		var type = name.split('-')[0];
		var idx = name.split('-')[1];

		var listData = component.get('v.list'+type);

		var objListData = listData[idx];

		//사용료(월)
		var licenseListPrice = event.getSource().get("v.value");
		//할인사용료(월)
		var licenseDiscountPrice = objListData.objQuoteItem['QuoteItem_LicenseDiscountedPrice__c'];
		//할인율
		var DiscountPercent = ((licenseListPrice - licenseDiscountPrice)/licenseListPrice)*100;
		//유저수
		var numberOfUser = objListData.objQuoteItem['QuoteItem_LicenseNumberOfUser__c'];

		//할인율 넣기
		objListData.QuoteItem_Discount_PercentLicense = DiscountPercent; 

		//QuoteItem_LicenseDiscountedPrice__c -> 0일경우  -> 사용료(월)  *12 
		//QuoteItem_LicenseDiscountedPrice__c -> 0이아닐 경우 ->할인사용료(월) *12

		/* 금액 년견적사용료 계산 */

		//사용료(년) 계산
		var licenseListPriceYear = (licenseDiscountPrice = 0 ? licenseListPrice : licenseDiscountPrice)*12

		//표준사용료(년)
		var licenseListPrice = licenseListPrice*12;
		//표준금액(라이센스) 년간사용료 = 표준사용료(년) * 유저수
		var licenseStandardPrice = licenseListPrice * numberOfUser;

		//년간사용료 넣기
		objListData.QuoteItem_LicenseListAmount = licenseStandardPrice; 
		

		//금액(라이센스) 년견적사용료 = (Null일경우-> 사용료(년) Null아닐경우-> 표준사용료(년) ) * 유저수
		var licenseAmountYear = (licenseListPriceYear=0 ? licenseListPrice : licenseListPriceYear)* numberOfUser;
		objListData.QuoteItem_LicenseAmount = licenseAmountYear;

		// 할인액(라이센스) = 표준금액(라이센스) - 금액(라이센스)
		var DiscountPriceLicense = licenseStandardPrice-licenseAmountYear;
		objListData.QuoteItem_LicenseDiscountAmount = DiscountPriceLicense;

		component.set("v.list"+type,listData);

		/* 소계 세팅 */
		helper.fnSubtotal(component, event, helper, type);
	},

	//라이센스 할인가 입력받기
	fnLicenseDiscountedPrice : function(component, event, helper){
		var name = event.getSource().get("v.name"); 
		var type = name.split('-')[0];
		var idx = name.split('-')[1];

		var listData = component.get('v.list'+type);

		var objListData = listData[idx];

		//할인사용료(월)
		var licenseDiscountPrice = event.getSource().get("v.value");
		//사용료(월)
		var licenseListPrice = objListData.objQuoteItem['QuoteItem_LicenseListPrice__c'];
		//할인율
		var DiscountPercent = ((licenseListPrice - licenseDiscountPrice)/licenseListPrice)*100;
		//유저수
		var numberOfUser = objListData.objQuoteItem['QuoteItem_LicenseNumberOfUser__c'];

		//할인율 넣기
		objListData.QuoteItem_Discount_PercentLicense = DiscountPercent; 

		//QuoteItem_LicenseDiscountedPrice__c -> 0일경우  -> 사용료(월)  *12 
		//QuoteItem_LicenseDiscountedPrice__c -> 0이아닐 경우 ->할인사용료(월) *12

		/* 금액 년견적사용료 계산 */

		//사용료(년) 계산
		var licenseListPriceYear = (licenseDiscountPrice = 0 ? licenseListPrice : licenseDiscountPrice)*12

		//표준사용료(년)
		var licenseListPrice = licenseListPrice*12;
		//표준금액(라이센스) 년간사용료 = 표준사용료(년) * 유저수
		var licenseStandardPrice = licenseListPrice * numberOfUser;

		//년간사용료 넣기
		objListData.QuoteItem_LicenseListAmount = licenseStandardPrice; 
		

		//금액(라이센스) 년견적사용료 = (Null일경우-> 사용료(년) Null아닐경우-> 표준사용료(년) ) * 유저수
		var licenseAmountYear = (licenseListPriceYear=0 ? licenseListPrice : licenseListPriceYear)* numberOfUser;
		objListData.QuoteItem_LicenseAmount = licenseAmountYear;

		// 할인액(라이센스) = 표준금액(라이센스) - 금액(라이센스)
		var DiscountPriceLicense = licenseStandardPrice-licenseAmountYear;
		objListData.QuoteItem_LicenseDiscountAmount = DiscountPriceLicense;

		component.set("v.list"+type,listData);

		/* 소계 세팅 */
		helper.fnSubtotal(component, event, helper, type);
		
		},
	//라이센스 할인율 입력받기
	fnLicenseDiscountPercent : function(component, event, helper){
		var name = event.getSource().get("v.name"); 
		var type = name.split('-')[0];
		var idx = name.split('-')[1];
		var listData = component.get('v.list'+type);
		var objListData = listData[idx];
		//할인가   단가 - (단가 * 할인율)

		//할인율 입력받기
		var licenseDiscountPercent = event.getSource().get('v.value')/100;
		//할인사용료(월) 받기
		var licenseDiscountPrice = objListData.objQuoteItem['QuoteItem_LicenseDiscountedPrice__c'];
		//사용료(월) 받기
		var licenseListPrice = objListData.objQuoteItem['QuoteItem_LicenseListPrice__c'];
		//할인사용료(월) 계산
		licenseDiscountPrice = licenseListPrice - ( licenseListPrice * licenseDiscountPercent ); 
		objListData.objQuoteItem['QuoteItem_LicenseDiscountedPrice__c'] = licenseDiscountPrice; 

		/* 금액 년견적사용료 계산 */
		//유저수
		var numberOfUser = objListData.objQuoteItem['QuoteItem_LicenseNumberOfUser__c'];
		//사용료(년) 계산
		var licenseListPriceYear = (licenseDiscountPrice = 0 ? licenseListPrice : licenseDiscountPrice)*12

		//표준사용료(년)
		var licenseListPrice = licenseListPrice*12;
		//표준금액(라이센스) 년간사용료 = 표준사용료(년) * 유저수
		var licenseStandardPrice = licenseListPrice * numberOfUser;

		//년간사용료 넣기
		objListData.QuoteItem_LicenseListAmount = licenseStandardPrice; 
		

		//금액(라이센스) 년견적사용료 = (Null일경우-> 사용료(년) Null아닐경우-> 표준사용료(년) ) * 유저수
		var licenseAmountYear = (licenseListPriceYear=0 ? licenseListPrice : licenseListPriceYear)* numberOfUser;
		objListData.QuoteItem_LicenseAmount = licenseAmountYear;
		//변수 저장(소계)
		component.set('v.subtotalLic',licenseAmountYear);

		// 할인액(라이센스) = 표준금액(라이센스) - 금액(라이센스)
		var DiscountPriceLicense = licenseStandardPrice-licenseAmountYear;
		objListData.QuoteItem_LicenseDiscountAmount = DiscountPriceLicense;
		


		component.set("v.list"+type,listData);		

		/* 소계 세팅 */
		helper.fnSubtotal(component, event, helper, type);

	},
	//라이센스 유저수 입력받기
	fnLicenseUser : function(component, event, helper){
		var name = event.getSource().get("v.name"); 
		var type = name.split('-')[0];
		var idx = name.split('-')[1];
		var listData = component.get('v.list'+type);
		var objListData = listData[idx];

		//유저수 입력받기
		var numberOfUser = event.getSource().get('v.value');
		//할인율 입력받기
		var licenseDiscountPercent = objListData.QuoteItem_Discount_PercentLicense/100;
		//할인사용료(월) 받기
		var licenseDiscountPrice = objListData.objQuoteItem['QuoteItem_LicenseDiscountedPrice__c'];
		//사용료(월) 받기
		var licenseListPrice = objListData.objQuoteItem['QuoteItem_LicenseListPrice__c'];
		//할인사용료(월) 계산
		licenseDiscountPrice = licenseListPrice - ( licenseListPrice * licenseDiscountPercent ); 
		objListData.objQuoteItem['QuoteItem_LicenseDiscountedPrice__c'] = licenseDiscountPrice; 

		/* 금액 년견적사용료 계산 */

		//사용료(년) 계산
		var licenseListPriceYear = (licenseDiscountPrice = 0 ? licenseListPrice : licenseDiscountPrice)*12

		//표준사용료(년)
		var licenseListPrice = licenseListPrice*12;
		//표준금액(라이센스) 년간사용료 = 표준사용료(년) * 유저수
		var licenseStandardPrice = licenseListPrice * numberOfUser;

		//년간사용료 넣기
		objListData.QuoteItem_LicenseListAmount = licenseStandardPrice; 
		

		//금액(라이센스) 년견적사용료 = (Null일경우-> 사용료(년) Null아닐경우-> 표준사용료(년) ) * 유저수
		var licenseAmountYear = (licenseListPriceYear=0 ? licenseListPrice : licenseListPriceYear)* numberOfUser;
		objListData.QuoteItem_LicenseAmount = licenseAmountYear;
		//변수 저장(소계)
		component.set('v.subtotalLic',licenseAmountYear);

		// 할인액(라이센스) = 표준금액(라이센스) - 금액(라이센스)
		var DiscountPriceLicense = licenseStandardPrice-licenseAmountYear;
		objListData.QuoteItem_LicenseDiscountAmount = DiscountPriceLicense;
		
		component.set("v.list"+type,listData);

		/* 소계 세팅 */
		helper.fnSubtotal(component, event, helper, type);

	},

	//표준가격 입력받기
	fnTrainingStandardPrice : function(component , event , helper){
		var name = event.getSource().get("v.name"); 
		var type = name.split('-')[0];
		var idx = name.split('-')[1];

		var listData = component.get('v.list'+type);
		var objListData = listData[idx];

		//표준가격
		var StandardPrice = event.getSource().get('v.value');
		//제안단가
		var SuggestedPrice = objListData.objQuoteItem['QuoteItem_TrainingStandardPrice__c'];

		//할인율 세팅
		var DiscountPercent = ((StandardPrice - SuggestedPrice)/StandardPrice)*100;
		objListData.QuoteItem_Discount_PercentTraining = DiscountPercent;

		/*표준금액(교육), 금액(교육), 할인액(교육) 세팅
			수강인원 * 표준가격
		*/
		//수강인원
		var numberOfStudent = objListData.objQuoteItem.QuoteItem_TrainingCount__c;
		var TrainingListAmount =  numberOfStudent * StandardPrice;
		//표준금액(교육) 세팅
		objListData.QuoteItem_TrainingListAmount = TrainingListAmount;
		//금액(교육) 세팅
		var TrainingSalesAmount = SuggestedPrice * numberOfStudent;		
		objListData.QuoteItem_TrainingSalesAmount =  TrainingSalesAmount;
		//할인액(교육) 세팅
		var DiscountPriceTraining = TrainingListAmount - TrainingSalesAmount;
		objListData.QuoteItem_TrainingDiscountAmount =  DiscountPriceTraining;

		component.set('v.list'+type,listData);


		/* 소계 세팅 */
		helper.fnSubtotal(component, event, helper, type);
	},

	fnTrainingDiscountPrice : function (component, event, helper){
		var name = event.getSource().get("v.name"); 
		var type = name.split('-')[0];
		var idx = name.split('-')[1];

		var listData = component.get('v.list'+type);
		var objListData = listData[idx];
		//입력받은 제안단가
		var SuggestedPrice = event.getSource().get('v.value');
		//제안단가를 표준가격을 긁어와 할인율로 계산
		var StandardPrice = objListData.objQuoteItem['QuoteItem_TrainingStandardPrice__c'];
		//할인율 세팅
		var DiscountPercent = ((StandardPrice - SuggestedPrice)/StandardPrice)*100;
		objListData.QuoteItem_Discount_PercentTraining = DiscountPercent;

		/*표준금액(교육), 금액(교육), 할인액(교육) 세팅
			수강인원 * 표준가격
		*/
		//수강인원
		var numberOfStudent = objListData.objQuoteItem.QuoteItem_TrainingCount__c;
		var TrainingListAmount =  numberOfStudent * StandardPrice;
		//표준금액(교육) 세팅
		objListData.QuoteItem_TrainingListAmount = TrainingListAmount;
		//금액(교육) 세팅
		var TrainingSalesAmount = SuggestedPrice * numberOfStudent;		
		objListData.QuoteItem_TrainingSalesAmount =  TrainingSalesAmount;
		//할인액(교육) 세팅
		var DiscountPriceTraining = TrainingListAmount - TrainingSalesAmount;
		objListData.QuoteItem_TrainingDiscountAmount =  DiscountPriceTraining;

		component.set('v.list'+type,listData);


		/* 소계 세팅 */
		helper.fnSubtotal(component, event, helper, type);

	},

	fnTrainingDiscountPercent : function (component, event, helper){
		var name = event.getSource().get("v.name"); 
		var type = name.split('-')[0];
		var idx = name.split('-')[1];

		var listData = component.get('v.list'+type);
		var objListData = listData[idx];
		//입력받은 할인율
		var DiscountPercent = event.getSource().get('v.value')/100;
		//표준가격
		var StandardPrice = objListData.objQuoteItem['QuoteItem_TrainingStandardPrice__c'];
		//표준가격* 할인율 (소수점)
		var SuggestedPrice = StandardPrice - (StandardPrice * DiscountPercent);
		//제안단가 세팅
		objListData.objQuoteItem.QuoteItem_TrainingSalesPrice__c = SuggestedPrice;
		/*표준금액(교육), 금액(교육), 할인액(교육) 세팅
			수강인원 * 표준가격
		*/
		//수강인원
		var numberOfStudent = objListData.objQuoteItem.QuoteItem_TrainingCount__c;
		var TrainingListAmount =  numberOfStudent * StandardPrice;
		//표준금액(교육) 세팅
		objListData.QuoteItem_TrainingListAmount = TrainingListAmount;
		//금액(교육) 세팅
		var TrainingSalesAmount = SuggestedPrice * numberOfStudent;
		objListData.QuoteItem_TrainingSalesAmount =  TrainingSalesAmount;
		//할인액(교육) 세팅
		var DiscountPriceTraining = TrainingListAmount - TrainingSalesAmount;
		objListData.QuoteItem_TrainingDiscountAmount =  DiscountPriceTraining;

		component.set('v.list'+type,listData);


		/* 소계 세팅 */
		helper.fnSubtotal(component, event, helper, type);
	},
	
	//교육 FOC
	fnTrainingFOC : function(component, event, helper){
		var name = event.getSource().get("v.name"); 
		var type = name.split('-')[0];
		var idx = name.split('-')[1];

		var listData = component.get('v.list'+type);
		var objListData = listData[idx];


		//입력받은 할인율
		var DiscountPercent = objListData.QuoteItem_Discount_PercentTraining/100;
		//표준가격
		var StandardPrice = objListData.objQuoteItem['QuoteItem_TrainingStandardPrice__c'];
		//표준가격* 할인율 (소수점)
		//제안단가 세팅
		var SuggestedPrice = objListData.objQuoteItem.QuoteItem_TrainingSalesPrice__c;
		// objListData.objQuoteItem.QuoteItem_TrainingSalesPrice__c = SuggestedPrice;
		/*표준금액(교육), 금액(교육), 할인액(교육) 세팅
			수강인원 * 표준가격
		*/
		// foc
		var focChecked = event.getSource().get('v.checked');
		//수강인원
		var numberOfStudent =  objListData.objQuoteItem['QuoteItem_TrainingCount__c'];
		var TrainingListAmount =  numberOfStudent * StandardPrice;
		//표준금액(교육) 세팅
		objListData.QuoteItem_TrainingListAmount = focChecked ? 0 : TrainingListAmount;
		//금액(교육) 세팅
		var TrainingSalesAmount = focChecked ? 0 : (SuggestedPrice * numberOfStudent);
		objListData.QuoteItem_TrainingSalesAmount =  TrainingSalesAmount;
		//할인액(교육) 세팅
		var DiscountPriceTraining = focChecked ? 0 : TrainingListAmount - TrainingSalesAmount;
		objListData.QuoteItem_TrainingDiscountAmount =  DiscountPriceTraining;

		component.set('v.list'+type,listData);


		/* 소계 세팅 */
		helper.fnSubtotal(component, event, helper, type);
	},

	fnTrainingUser : function(component, event, helper){
		var name = event.getSource().get("v.name"); 
		var type = name.split('-')[0];
		var idx = name.split('-')[1];

		var listData = component.get('v.list'+type);
		var objListData = listData[idx];

		// foc
		var focChecked = event.getSource().get('v.checked');

		//입력받은 할인율
		var DiscountPercent = event.getSource().get('v.value')/100;
		//표준가격
		var StandardPrice = objListData.objQuoteItem['QuoteItem_TrainingStandardPrice__c'];
		//표준가격* 할인율 (소수점)
		var SuggestedPrice = objListData.objQuoteItem.QuoteItem_TrainingSalesPrice__c;
		//제안단가 세팅
		objListData.objQuoteItem.QuoteItem_TrainingSalesPrice__c = SuggestedPrice;
		/*표준금액(교육), 금액(교육), 할인액(교육) 세팅
			수강인원 * 표준가격
		*/
		//수강인원
		var numberOfStudent = objListData.objQuoteItem.QuoteItem_TrainingCount__c;
		var TrainingListAmount =  numberOfStudent * StandardPrice;
		//표준금액(교육) 세팅
		objListData.QuoteItem_TrainingListAmount = focChecked ? 0 : TrainingListAmount;
		//금액(교육) 세팅
		var TrainingSalesAmount = focChecked ? 0 : SuggestedPrice * numberOfStudent;
		objListData.QuoteItem_TrainingSalesAmount =  TrainingSalesAmount;
		//할인액(교육) 세팅
		var DiscountPriceTraining = focChecked ? 0 : TrainingListAmount - TrainingSalesAmount;
		objListData.QuoteItem_TrainingDiscountAmount =  DiscountPriceTraining;

		component.set('v.list'+type,listData);


		/* 소계 세팅 */
		helper.fnSubtotal(component, event, helper, type);
	},

	
})