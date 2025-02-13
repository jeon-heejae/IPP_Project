({
	fnInit : function(component, event, helper) {
		console.log('fnInit Start>>>>>>>>>');
        component.set('v.toggleSpinner',true);
		helper.InitData(component,event,helper);
		helper.ExpFieldLabel(component);
		helper.ExpDetailFieldLabel(component);
		console.log('fnInit End>>>>>>>>>');

	},
    fnChangeState1 : function (component){ 
	   component.set('v.isExp',!component.get('v.isExp'));
	 },	

    fnChangeState2 : function (component){ 
	   component.set('v.isExpDetail', !component.get('v.isExpDetail'));
	 },		 

	fnMouseOver : function(component, event, helper){
		component.set('v.mouseOver', true);

	},

	fnMouseOut : function(component, event, helper){
		component.set('v.mouseOver', false);
		
	},

	fnCloseModal : function(component, event) {
        var modal = component.find("divModal");
        $A.util.removeClass(modal, "slds-show");
        $A.util.addClass(modal, "slds-hide");
        component.set('v.mouseOver', false);
    },


	fnCancel : function(component, event, helper){
		var recordId = component.get('v.recordId');
		if(recordId){
            var rtnUrl = window.location.href;
            var url = "/lightning/r/" + recordId+ "/view";
            window.parent.location = url;

		}
		else{
            var rtnUrl = window.location.href;
            var url = "/lightning/o/" + "Expense__c" + "/list?filterName=Recent";
            window.parent.location = url;

		}

	},


	fnAddRow : function(component, event, helper){
		var listExpDetail =  component.get('v.listExpDetail');

		if(listExpDetail == null || listExpDetail == undefined) {
			listExpDetail = [];
		}

		var lastIdx;
		if(!listExpDetail.length){
			lastIdx = 0;
			listExpDetail = [];
		}else{
			lastIdx = listExpDetail.length-1;
		}

		var listExpDetailTemp = {
				Id: null ,
				Name: null ,				
				Date__c: listExpDetail[lastIdx] === undefined ? $A.localizationService.formatDate(new Date(), "YYYY-MM-DD") : listExpDetail[lastIdx].Date__c,
				Category1__c: listExpDetail[lastIdx] === undefined ?  '본사행정' : listExpDetail[lastIdx].Category1__c,			
				Category2__c: listExpDetail[lastIdx] === undefined ? '식비' : listExpDetail[lastIdx].Category2__c,
				Project_Name__c: listExpDetail[lastIdx] === undefined ? null : listExpDetail[lastIdx].Project_Name__c ,

				Project_Name__r: listExpDetail[lastIdx] === undefined ? { Name : '' } : listExpDetail[lastIdx].Project_Name__r === undefined ? { Name : '' } : { Name : listExpDetail[lastIdx].Project_Name__r.Name },
				
				Opportunity_Name__c: listExpDetail[lastIdx] === undefined ? null : listExpDetail[lastIdx].Opportunity_Name__c,

				Opportunity_Name__r: listExpDetail[lastIdx] === undefined ? { Name : '' } : listExpDetail[lastIdx].Opportunity_Name__r === undefined ? { Name : '' } : { Name : listExpDetail[lastIdx].Opportunity_Name__r.Name },

				Payment_Type__c: listExpDetail[lastIdx] === undefined ? '개인카드' : listExpDetail[lastIdx].Payment_Type__c ,
				Amount__c: listExpDetail[lastIdx] === undefined ? 0 : listExpDetail[lastIdx].Amount__c,
				Description__c: listExpDetail[lastIdx] === undefined ? '' : listExpDetail[lastIdx].Description__c  
		}

		listExpDetail.push(listExpDetailTemp);
		component.set('v.listExpDetail' , listExpDetail);

	},	

	// fnDeleteRow : function(component, event, helper) {
	// 	var listExpDetail = component.get('v.listExpDetail');
	// 	var listDel = component.get('v.listDel');
	// 	if(listExpDetail.length>1){
	// 		var obj = listExpDetail[listExpDetail.length - 1];
	// 		var deletedId = obj.Id;
	// 		listDel.push(deletedId);
	// 		component.set('v.listDel',listDel);
	// 		listExpDetail.splice(listExpDetail.length - 1, 1);
	// 		component.set('v.listExpDetail', listExpDetail);
	// 	}

	// },	

	//To caculate width of Table Column
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
    //New Definition of width
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

    //A selected index Row Remove
	fnDeleteSelectedRow : function(component, event, helper){
		var idx = event.getSource().get('v.name');
		var listExpDetail = component.get('v.listExpDetail');
		var listDel = component.get('v.listDel');

		if(listExpDetail[idx]){
			var obj = listExpDetail[idx];
			var deletedId = obj.Id;
			listDel.push(deletedId);
			component.set('v.listDel',listDel);
			listExpDetail.splice(idx,1);
			component.set('v.listExpDetail',listExpDetail);

		}

		
	},

	fnSave  : function (component, event, helper){
        component.set('v.toggleSpinner',true);
		//경비신청 1차 신청자 set 
		// var name = component.find('user1');
		// var userName = name.selectItem('sId');
		// console.log('userName : '+ userName);
		// component.set('v.objExp.FirstExpenseRequest__c',userName);
        
        helper.fnDoSave(component, event, helper);

	},

	throwIndx : function(component, event, helper) {
		console.log('thowIndx Start_______ ');
		var indexvar = event.getSource().get("v.label");
		console.log('indexvar___ ' + indexvar);
	},
})