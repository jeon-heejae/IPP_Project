({

    fnCalEmpListPrice : function(component, event, helper){
        var name = event.getSource().get("v.name"); 
        //등급
        var value = event.getSource().get('v.value');
        var type = name.split('-')[0];
        var idx = name.split('-')[1];
        var listData = component.get("v.list" + type);
        var objListData = listData[idx];
        var consultType;
        //구분        
        var typeData = objListData.objQuoteItem.QuoteItem_ConsultType__c;
        var levelData = objListData.objQuoteItem.QuoteItem_ConsultLevel__c;

        if(typeData.includes('Consultant')){
            consultType = 'Consultant';
        }else if(typeData.includes('Developer')){
            consultType = 'Developer';
        }
        console.log('sDept : '+ consultType);
        console.log('sConsultLevel : '+ levelData);

        var action = component.get("c.getCalcListPrice");
        action.setParams({
            "sDept" : consultType ,
            "sConsultLevel" : levelData
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            objListData.objQuoteItem.QuoteItem_ConsultListPrice__c = result;
            component.set("v.list"+type,listData);
        });
        $A.enqueueAction(action);
    },

    QuoteItemFieldLabel : function(component, event, helper){
        var action = component.get("c.getObjectFieldLabel");

	    action.setParams({
	        "sObjectName" : "QuoteItem__c"
	      });
	        action.setCallback(this, function(response) {
            var result = response.getReturnValue(); // return 값 
            component.set("v.QuoteItemLabelMap", result);
        }); 
        $A.enqueueAction(action);
    },
    
    QuoteFieldLabel : function(component, event, helper){
        var action = component.get("c.getObjectFieldLabel");

        action.setParams({
            "sObjectName" : "Quote__c"
          });
            action.setCallback(this, function(response) {
            var result = response.getReturnValue(); // return 값 
            component.set("v.QuoteLabelMap", result);
        }); 
        $A.enqueueAction(action);
    },

    fnRowMoveDown : function(component, event, helper, name){
        var name = event.getSource().get('v.name');
        var listQuote = component.get('v.list'+name);
        var count = 0;
        // var consultingList = component.get('v.listConsulting');

        for(var i=0; i<listQuote.length; i++){
            var obj = listQuote[i];
            var objIsChecked = obj.isChecked;
            let newIndex = i+1;
            if(objIsChecked){

                if(i == -1){
                    this.showToast('ERROR', '레코드 인덱스가 없습니다.');
                    return null;
                }
                if(newIndex >= listQuote.length){
                    newIndex = listQuote.length;
                    this.showToast('ERROR', '마지막 행입니다.');
                    return null;
                }
                count++;
                if(count > 1){
                    helper.showToast('ERROR', '행은 하나만 선택해 주세요.');
                }

                const newContents = JSON.parse(JSON.stringify(listQuote));                        
                newContents.splice(i,1);
                newContents.splice(newIndex,0,listQuote[i]);
                component.set('v.list'+name,newContents );
            }

        }
        helper.fnSortOrderChange(component, event, helper);
        
    },

    fnRowMoveUp : function(component, event, helper){

        var name = event.getSource().get('v.name');
        var listQuote = component.get('v.list'+name);
        var count = 0;
        // var consultingList = component.get('v.listConsulting');

        for(var i=0; i<listQuote.length; i++){
            var obj = listQuote[i];
            var objIsChecked = obj.isChecked;
            let newIndex = i-1;

            if(objIsChecked){

                if(newIndex == -1){
                    this.showToast('ERROR', '처음 행입니다.');
                    return null;
                }
                count++;
                if(count > 1){
                    helper.showToast('ERROR', '행은 하나만 선택해 주세요.');
                }

                const newContents = JSON.parse(JSON.stringify(listQuote));                        
                newContents.splice(i,1);
                newContents.splice(newIndex,0,listQuote[i]);
                // var temp = consultingList[i];
                // var objtemp = consultingList[i+1];
                // objtemp = temp;

                component.set('v.list'+name,newContents );
                

            }                  

                 

        }

        helper.fnSortOrderChange(component, event, helper);
    },    

    InitData : function(component, event, helper){
        // var consultRemark = "1. 유효기간 : 견적일 기준 1주일입니다." + 
        //                     "2. 결제조건 : 현금 결제 조건입니다." +
        //                     "3. 투입기간 : 고객과 협의하에 변경될 수 있습니다."
        // var LicenseRemark = "1. 라이선스는 년 단위 계약 갱신이 필요합니다. /r/n 2. 결제조건: 현금 결제 조건이고 통화는 USD입니다. /r/n 3. 사용자 라이선스 수량은 RFP를 기초로 작성되었고 사용자의 증가에 따라 변경될 수 있습니다."
        // var TrainingRemark = "1. 교육은 등급에 따라 단가 책정이 다르고 년 단위 갱신이 필요합니다. /r/n 2. 결제조건은: 현금 결제조건이며 통화는 KRW으로 합니다. /r/n 3. 교육 기간이 길어질수록 비용 책정이 늘어납니다."
        var action = component.get("c.getInitData");
        action.setParams({
            "quoteId" : component.get('v.recordId'),
            "opptyId" : component.get('v.idOppty')

        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue(); // return 값 
            var state = response.getState();

            if(state==="SUCCESS"){
                component.set("v.listConsulting", result['Consulting']);
                component.set("v.listLicense", result['License']);
                component.set("v.listTraining", result['Training']);
                component.set("v.objQuote", result['Quote']);
                component.set("v.objOppty", result['Oppty']);
                component.set("v.QuoteStatus", result['PicklistStatus']);
                component.set("v.QuoteItemType", result['PicklistType']);
                component.set("v.QuoteItemLevel", result['PicklistLevel']);
                component.set("v.QuoteItemLevelTraining", result['PicklistLevelTraining']);
                helper.fnAccordionActive(component, event, helper);
                helper.fnSubtotal(component, event, helper, "Consulting");
                helper.fnSubtotal(component, event, helper, "License");
                helper.fnSubtotal(component, event, helper, "Training");
                helper.fnInitLookupSet(component, event, helper);


            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            //소계 계산 Init

            // Quote Date 값 없을 시 오늘로 설정            
            var quoteDate = component.get('v.objQuote.Quote_Date__c');        
                if(quoteDate == null){
                    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                    component.set('v.objQuote.Quote_Date__c',today);
             }

            component.set('v.toggleSpinner',false);

        }); 
    

        $A.enqueueAction(action);




    },

    // EDIT 시 각각의 컨설팅, 라이센스, 교육 의 데이터가 있는 Accordion 만 표시
    fnAccordionActive : function(component, event, helper){
        // var listCon = component.get('v.listConsulting[0]');
        // var listLic = component.get('v.listLicense[0]');
        // var listTra = component.get('v.listTraining[0]');
        // if(listCon && listLic && listTra){
            component.set('v.activeSection',['A','B','C']);
        // }else if(listCon && listLic){
        //     component.set('v.activeSection',['A','B']);
        // }else if(listCon && listTra){
        //     component.set('v.activeSection',['A','C']);
        // }else if(listLic && listTra){
        //     component.set('v.activeSection',['B','C']);
        // }else if(listCon){
        //     component.set('v.activeSection',['A']);
        // }else if(listLic){
        //     component.set('v.activeSection',['B']);
        // }else if(listTra){
        //     component.set('v.activeSection',['C']);
        // }

    },

    fnSortOrderChange : function(component, event, helper){
        var name = event.getSource().get('v.name');
        var listQuoteSort = component.get('v.list'+name);
        var newObj = listQuoteSort;
        for(var index = 0, maxLength = newObj.length ; index < maxLength ; index++) {
                newObj[index].objQuoteItem.QuoteItem_SortOrder__c = index+1;                
        }

        component.set('v.list'+name,newObj);

        

    },

    fnDoSave : function(component, event , helper){        
        //1. 저장전 JSON객체로 되어있는 QuoteItem_Emp__r 을 Null값으로 세팅
        // var listCon = component.get('v.listConsulting');
        // for(var i = 0; i<listCon.length; i++){
        //     var list = listCon[i];
        //     list.objQuoteItem['QuoteItem_Emp__r'] = null;
        // }
        // component.set('v.listConsulting', listCon);

        //2 저장전, 견적 개체의  Account , Contact , Opportunity 값 세팅
        var cmpAccountLookup = component.find("AccountLookup");
        var cmpContactLookup = component.find("ContactLookup");
        var cmpOpptyId = component.get("v.idOppty");

        if(cmpAccountLookup) {
            var sId = cmpAccountLookup.selectItem("sId");
            var sName = cmpAccountLookup.selectItem("sName");
            // var sNm = cmpAccountLookup.get("v.selectedRecord").strName;
            if(sId){
                component.set('v.objQuote.Quote_Account__c',sId);
            }
        }

        if(cmpContactLookup) {
            var sId = cmpContactLookup.selectItem("sId");
            var sName = cmpContactLookup.selectItem("sName");
            if(sId){
                component.set('v.objQuote.Quote_Contact__c',sId);               
            }
        }

        component.set('v.objQuote.Quote_Opportunity__c',cmpOpptyId);
        component.set('v.toggleSpinner',true);


        var isApproved = component.get('v.objQuote.Quote_Status__c');
        var qMode = component.get('v.qMode');
        var opptyId = component.get('v.objOppty.Id');  


        //견적 -> 승인된 경우 저장을 위해 Clone 후 Id 값을 Null 로 세팅 후 저장 
        if(isApproved == 'Approved' && qMode == 'clone'){
            var subjectCopy = component.get('v.objQuote.Quote_Subject__c');
            component.set('v.objQuote.Id',null);
            component.set('v.objQuote.Quote_Opportunity__c',opptyId);            
            component.set('v.objQuote.Quote_Status__c','Draft');
            var listCon = component.get('v.listConsulting');
            var listLic = component.get('v.listLicense');
            var listTra = component.get('v.listTraining');

            for(var i =0; i<listCon.length; i++ ){
                console.log('listCon Ids : '+ listCon[i].objQuoteItem.Id);

                listCon[i].objQuoteItem.Id = null;
                listCon[i].objQuoteItem.QuoteItem_Quote__c = null;

            }
            for(var i =0; i<listLic.length; i++ ){
                listLic[i].objQuoteItem.Id = null;
                listLic[i].objQuoteItem.QuoteItem_Quote__c = null;
            }
            for(var i =0; i<listTra.length; i++ ){
                listTra[i].objQuoteItem.Id = null;
                listTra[i].objQuoteItem.QuoteItem_Quote__c = null;
            }
            console.table('listCon : '+ listCon);
            console.log('listLic : '+ listLic);
            console.log('listTra : '+ listTra);

            component.set('v.listConsulting',listCon);            
            component.set('v.listLicense',listLic);            
            component.set('v.listTraining',listTra);            
        }

        helper.doSave(component,helper);
    },

    doSave : function(component,helper) {
        var action = component.get('c.doSave');

        action.setParams({
            'listConsulting' : component.get('v.listConsulting'),
            'listLicense' : component.get('v.listLicense'),
            'listTraining' : component.get('v.listTraining'),
            'listDel' : component.get('v.listDeleted'),
            'objQuote' : component.get('v.objQuote')
            // 'idOppty' : component.get('v.idOppty')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("state : " + state);
    
            if(state === 'SUCCESS') {
                var sReturnValue    = response.getReturnValue();                
                var resultArray = [];            
                resultArray = sReturnValue.split('/');
                //Message Display
                var rtnUrl = window.location.href;
                var url = "/lightning/r/" + resultArray[2] + "/view";
                var url2 = "/lightning/o/" + "Opportunity__c" + "/list?filterName=Recent";

                console.log('resultArray[2] : '+resultArray[2]);
                if(resultArray[2].includes('error')){
                    helper.showToast(resultArray[0], resultArray[1] + resultArray[2]);
                    window.parent.location = url2;
                    
                }else{
                    helper.showToast(resultArray[0], resultArray[1]);
                    window.parent.location = url;
                }


            }else if(state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {                        
                        console.log("Error message: " +errors[0].message);
                        this.showToast("ERROR"+errors[0].message);
                    }

                } else {
                    this.showToast("ERROR"+errors[0].message);
                    console.log("Unknown error");

                }

            }
            component.set('v.toggleSpinner',false);
        });
        
        $A.enqueueAction(action);
    },


    fnInitLookupSet : function (component, event, helper){
        //EDIT 일경우 ObjQuote에 저장된 Account ID 갖고오기
        var quote = component.get('v.recordId');
        var opptyAcc = component.get('v.objOppty.AccountId__c');
        var listConsulting = component.get('v.listConsulting');
        console.log('opptyAcc : '+ opptyAcc);
        $A.createComponent(
                 "c:CommonLookup",
                 {
                     "aura:id" : "AccountLookup" ,
                     // "selectedRecord" : component.get('v.objQuote.Quote_Opportunity__c'),
                     "sId":  quote ?   component.get('v.objQuote.Quote_Account__c')  : component.get('v.objOppty.AccountId__c'),
                     "sNm" :  quote ?  component.get('v.objQuote.Quote_Account__r.Name') : component.get('v.objOppty.AccountId__r.Name')  ,
                     "sLabel" : "고객사" ,
                     "sObj" : "Account" ,
                     "sIconName" : "standard:account" ,
                     "bShowSearchIcon" : false ,
                     "bRequired" : false ,


                 },function(newCmp){
                    component.set("v.customLookupAcc", newCmp);
                    
                 }
             );

        $A.createComponent(
                 "c:CommonLookup",
                 {
                     "aura:id" : "ContactLookup" ,
                     // "selectedRecord" : component.get('v.objQuote.Quote_Opportunity__c'),
                     "sId": quote ?  component.get('v.objQuote.Quote_Contact__c')  : component.get('v.objOppty.Contact__c') ,
                     "sNm" : quote ?  component.get('v.objQuote.Quote_Contact__r.Name') : component.get('v.objOppty.Contact__r.Name') ,
                     "sLabel" : "고객담당자" ,
                     "sObj" : "Contact" ,
                     "sIconName" : "standard:contact" ,
                     "bShowSearchIcon" : false ,
                     "bRequired" : false ,                     

                 },function(newCmp){
                    component.set("v.customLookupCon", newCmp);
                 }
             );


    },


    fnSubtotal : function(component, event, helper, type){
        
        var listData = component.get("v.list" + type);
        var objQuote = component.get('v.objQuote');

        var objQuoteSub = {
         'subtotalAmount' : 0,
         'subNumber' : 0,
         'subManmonth' : 0,
         'subStandardPrice' : 0,
         'subQuote' : 0,
         'subDiscount' : 0,
         'subPercent' : 0,
         //새로계산되어 보여질 할인액
         'disQuote' :0,
         'disDisPrice' : 0,

        };

        var indexCon = 0;
        var indexLic = 0;
        var indexTra = 0;
        if(type=='Consulting'){
            for(var i in listData){
                var obj = listData[i];
                objQuoteSub.subNumber += indexCon+1;
                objQuoteSub.subtotalAmount += obj.QuoteItem_ConsultAmount;
                objQuoteSub.subManmonth += parseFloat(obj.objQuoteItem.QuoteItem_ConsultManMonths__c);
                objQuoteSub.subStandardPrice += obj.QuoteItem_ConsultListAmount;
                objQuoteSub.subQuote += parseInt(obj.QuoteItem_ConsultAmount);
                objQuoteSub.subDiscount += parseInt(obj.QuoteItem_ConsultDiscountAmount); 
                objQuoteSub.subPercent += parseInt(obj.QuoteItem_Discount_Percent)/listData.length;
                // arrayCon[i].subConQuote += objQuoteSub.QuoteItem_ConsultAmount;
                // arrayCon[i].subConDiscount +=  objQuoteSub.QuoteItem_ConsultAmount;
                // arrayCon[i].subConPercent += objQuoteSub.QuoteItem_ConsultAmount;
            }
             objQuoteSub.disQuote = objQuote.Quote_SalesDiscount__c ? objQuoteSub.subQuote - parseInt(objQuote.Quote_SalesDiscount__c) : objQuoteSub.subQuote;
             objQuoteSub.disDisPrice = objQuote.Quote_SalesDiscount__c ? objQuoteSub.subDiscount + parseInt(objQuote.Quote_SalesDiscount__c) : objQuoteSub.subDiscount;


        }else if(type=='License'){
            for(var i in listData){
                var obj = listData[i];
                objQuoteSub.subNumber += indexLic+1;
                objQuoteSub.subtotalAmount += obj.QuoteItem_LicenseListAmount;
                objQuoteSub.subManmonth += parseInt(obj.objQuoteItem.QuoteItem_LicenseNumberOfUser__c);
                objQuoteSub.subStandardPrice += obj.QuoteItem_LicenseListAmount;
                objQuoteSub.subQuote += parseInt(obj.QuoteItem_LicenseAmount);
                objQuoteSub.subDiscount += parseInt(obj.QuoteItem_LicenseDiscountAmount);
                objQuoteSub.subPercent += parseInt(obj.QuoteItem_Discount_PercentLicense)/listData.length;
                // arrayCon[i].subConQuote += objQuoteSub.QuoteItem_ConsultAmount;
                // arrayCon[i].subConDiscount +=  objQuoteSub.QuoteItem_ConsultAmount;
                // arrayCon[i].subConPercent += objQuoteSub.QuoteItem_ConsultAmount;
            }

        }else if(type=='Training'){
            for(var i in listData){
                var obj = listData[i];
                objQuoteSub.subNumber += indexTra+1;
                objQuoteSub.subtotalAmount += obj.QuoteItem_TrainingListAmount;
                objQuoteSub.subManmonth += parseInt(obj.objQuoteItem.QuoteItem_TrainingCount__c);
                objQuoteSub.subStandardPrice += obj.QuoteItem_TrainingListAmount;
                objQuoteSub.subQuote += parseInt(obj.QuoteItem_TrainingSalesAmount);
                objQuoteSub.subDiscount += parseInt(obj.QuoteItem_TrainingDiscountAmount);
                objQuoteSub.subPercent += parseInt(obj.QuoteItem_Discount_PercentTraining)/listData.length;
            }
        }

        component.set('v.objSum' + type, objQuoteSub);


    },



    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");

        evt.setParams({
            duration : 5000,
            key      : "info_alt",            
            type     : type,
            message  : message
        });

        evt.fire();
    },
})