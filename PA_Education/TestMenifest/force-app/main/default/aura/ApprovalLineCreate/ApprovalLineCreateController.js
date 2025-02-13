({
	fnInit  : function(component, event, helper) {
	    console.log('Create Init');
        console.log('test@@::',JSON.stringify(component.get('v.listLabel')));
        console.log('sObjectName@@::',JSON.stringify(component.get('v.sObjectName')));
		var listLabel = component.get("v.listLabel");
		var fieldName = component.get("v.fieldName");


		if (component.get("v.sObjectName") == 'Expense__c'){
            console.log('Expense__c통과')
            helper.checkProject(component, event, helper);
        }

        if (listLabel.label == '' || listLabel.label == null) {
                    listLabel.label = 'Approval Line';
                    component.set('v.listLabel', listLabel);
                }



	},

	fnClose : function(component, event, helper) {
		var modal = component.find('divModal');      /* aura:id 'divModal'찾기*/
        $A.util.removeClass(modal, 'slds-show');	
        $A.util.addClass(modal, 'slds-hide');		
        component.set('v.holidayModalView', false);
        /*scroll 방지 해제*/
		document.body.style.overflow="auto";
	},

	fnAddRow : function(component, event, helper) {
		var listLabel 	   = component.get("v.listLabel");
		var iApproverLimit = component.get("v.iApproverLimit");
		var userobj = {  Id  : null, Name: null };

		if(listLabel.userDatas.length == iApproverLimit){
			return alert("Up to "+ iApproverLimit +" people available for selection.");
		}

		listLabel.userDatas.push(userobj);
		component.set("v.listLabel", listLabel);
	},

	fnDeleteRow : function(component, event, helper) {
		var listLabel = component.get("v.listLabel");
		var listUser    = listLabel.userDatas;
		var idx 		= event.getSource().get("v.name"); //idx  0

		for(var i=listUser.length-1; i>=0; i--){
			var obj = listUser[i];
			if(idx == i){
				listUser.splice(i, 1);
			}
		}

		component.set("v.listLabel", listLabel);
	},

	fnSave : function(component, event, helper) {
		var bValidation = true;
		var listUser 	= component.get("v.listLabel").userDatas;
		var bHistory 	= component.get("v.bHistory");
		var listLabel   = component.get("v.listLabel").label;
		console.log('listLabelcheck::::', JSON.stringify(component.get("v.listLabel")));


        if(bHistory == false && (listLabel == '' || listLabel == null)){
			bValidation = false;
			helper.showToast('error', 'Subject 값을 입력해주세요.');
			return;
		}

		// 중복 및 null 검사
		if(listUser == '' || listUser == null){
			bValidation = false;
			helper.showToast('error', $A.get('$Label.c.ApproverSelectError'));
			return;
		}

        for(var i in listUser){
			i = parseInt(i);

			if(listUser[i].Id == null) {
				bValidation = false;
				helper.showToast('error', $A.get('$Label.c.ApproverSelectError'));
				return;
			}
			for(var j = i + 1; j <= listUser.length - 1; j++) {
				if(i == listUser.length-1) break;
				if(listUser[i].Id === listUser[j].Id){
					bValidation = false;
					helper.showToast('error', $A.get('$Label.c.ApproverDupError'));
					return;
				}
			}
		}

		if(bValidation == true && bHistory == false){
			helper.doSave(component, event, helper);
		}

		else if(bValidation == true && bHistory == true){
			helper.doSubmit(component,event, helper);
		}
	},

})