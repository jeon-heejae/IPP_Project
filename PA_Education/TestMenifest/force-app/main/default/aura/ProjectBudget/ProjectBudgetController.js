({
   init: function(component, event, helper) {
        console.log("init");
        var pageRef = component.get("v.pageReference");
       console.log(JSON.stringify(pageRef));
        var state = pageRef.state; // state holds any query params
        var base64Context = state.inContextOfRef;
       console.log("64!!!!!!!!!!!");
       console.log(base64Context);
        //sj수정
       if(base64Context === undefined ) {
           component.set("v.parentId", pageRef.attributes.recordId); 
       } else {
            // For some reason, the string starts with "1.", if somebody knows why,
            // this solution could be better generalized.
            if (base64Context.startsWith("1\.")) {
                base64Context = base64Context.substring(2);
            }
           
            var addressableContext = JSON.parse(window.atob(base64Context));
            console.log("log ~~");
            console.log(addressableContext);
            component.set("v.parentId", addressableContext.attributes.recordId);
       }

       helper.getInitData(component, helper);
    },
    fnDeleteRow : function(component, event, helper) {
    	var listData = component.get("v.prjBgtDtlLst");
        if(listData != undefined){		
            for(var i = listData.length-1; i>=0; i--) {
                var obj = listData[i];
                if(obj.isChecked) {
                    listData.splice(i, 1);
                }
            }
        }
		component.set("v.prjBgtDtlLst", listData);
	},
	fnAddRow : function(component, event, helper) {
    	var prjBgtId = component.get("v.recordId");
        var listData = component.get("v.prjBgtDtlLst");
    	if ( listData == null ) listData = [];

		var tempWrapper = {
			//wrapper에 선언한 포뮬라 필드
			isChecked: false,
            Amount__c: 0,
            ProjectBudget__c: prjBgtId
		};
		// console.log(tempWrapper);
		listData.push(tempWrapper);
		// console.log(listData);

		component.set("v.prjBgtDtlLst", listData);
	},
    fnDoSave : function(component, event , helper){
		component.set('v.toggleSpinner',true);
		helper.doSave(component);
	},
    fnCancel : function(component, event, helper) {
		helper.doClose(component);
	},
    fnCheckAll : function(component, event , helper){
        var ischecked = event.getSource().get("v.checked");
		var listData = component.get("v.prjBgtDtlLst");
        if(listData != undefined){
            for(var i = 0; i<listData.length; i++){
                listData[i].isChecked = ischecked;
            }
            component.set("v.prjBgtDtlLst", listData);
        }
	},
    fnChangeAmount : function(component, event, helper) {
		var name = event.getSource().get("v.name");
		var idx = name.split('-')[1];
		var listData = component.get("v.prjBgtDtlLst");

		var objListData = listData[idx];

		//단가 가져오기
		var unitPrice = objListData.UnitPrice__c;
		var qty = objListData.Quantity__c;
        
        objListData.Amount__c = unitPrice * qty;
        if(unitPrice == undefined || qty == undefined ){
        	objListData.Amount__c = 0;
        }
        
		component.set("v.prjBgtDtlLst", listData);
        var totAmt = 0;//objListData.Amount__c;
		for(var i = 0; i<listData.length; i++){
            totAmt += listData[i].Amount__c;
		}
		component.set("v.totAmt", totAmt);
		
	},
    fnModalOpen : function (component, event, helper) {
        component.set("v.modalYn", true);
    },

    fnModalClose :function(component, event, helper){
        component.set("v.modalYn", false);

    },
})