({
	doSave : function(component, event, helper) {
		var objUser 	= component.get("v.objUser");
		var listLabel   = component.get("v.listLabel");
		var listUser  	= listLabel.userDatas;
		var fieldName  	= listLabel.fieldName;
		var insertValue = '';

		// new
		if(fieldName == '' || fieldName == null){
			if(objUser.ApprovalLine1__c == null){
                insertValue = listLabel.label + '/ApprovalLine1/';
				fieldName = 'ApprovalLine1';
			} else if (objUser.ApprovalLine2__c == null) {
                insertValue = listLabel.label + '/ApprovalLine2/';
				fieldName = 'ApprovalLine2';
			} else if (objUser.ApprovalLine3__c == null) {
                insertValue = listLabel.label + '/ApprovalLine3/';
				fieldName = 'ApprovalLine3';
			} else if (objUser.ApprovalLine4__c == null) {
                insertValue = listLabel.label + '/ApprovalLine4/';
				fieldName = 'ApprovalLine4';
			} else {
			    this.showToast('ERROR', 'Approval Line은 최대 4개까지 설정할 수 있습니다.');
			    return;
            }

			// insertValue(승인자들) 만들기
			for(var u in listUser){
				insertValue = (u == listUser.length-1) ? insertValue + listUser[u].Id : insertValue + listUser[u].Id + '/' ;
			}
		}
		//edit
		else {
			insertValue = listLabel.label + '/' + fieldName + '/';
			for(var u in listUser){
				insertValue = (u == listUser.length-1) ? insertValue + listUser[u].Id : insertValue + listUser[u].Id + '/' ;
			}
		}

		var action = component.get("c.doSave");
		action.setParams({
			"insertValue" : insertValue,
			"fieldName"   : fieldName,
			"objUser" 	  : component.get("v.objUser")
		});

		action.setCallback(this, function(response) {
			var state = response.getState();

			if(state === "SUCCESS") {
				var returnValue = response.getReturnValue();
				var values = returnValue.split('/');

				this.showToast(values[0], values[1]);

				if(values[0] == "success"){
					this.doNavigateSObject(values[2]);
	            }
			}
		});

		$A.enqueueAction(action);
		/*scroll 방지 해제*/
		document.body.style.overflow="auto";
	},

	doSubmit : function(component,event, helper) {
		var sComments = component.find("comments").get("v.value"); //comment 값 가져오겠지..?
		var listLabel = component.get("v.listLabel");
		var action    = component.get("c.doSubmit");

		var recordId = component.get("v.recordId");

		action.setParams({
			'sObjectName' 		: component.get("v.sObjectName"),
			'sComments'    		: sComments,
			'sHistoryRecordId'  : component.get("v.sHistoryRecordId"),
			'objListUser'   	: listLabel.userDatas
		});
		
		action.setCallback(this, function(response) {
			var state = response.getState();

			if(state === "SUCCESS") {
				var returnValue = response.getReturnValue();
				var values = returnValue.split('/');

				$A.get('e.force:refreshView').fire();
				this.showToast(values[0], values[1]);

				if(values[0] == "success"){
					this.doNavigateSObject(values[2]);
	            }
			}
		});
		$A.enqueueAction(action);
		/*scroll 방지 해제*/
		document.body.style.overflow="auto";
	},

	checkProject : function(component, event, helper) {
        var action      = component.get("c.checkProject");
        //var recordId    = component.get("v.sId");
        var recordId    = component.get("v.sRecordId");
        action.setParams({
            'recordId' : recordId,
        });
        console.log('checkProjectParamsRid', recordId);
        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log('state success');
                if (returnValue == null){
                    console.log('checkproject returns fail');
                }else {
                    //console.log('checkproject returns success');
                    console.log("returnValues ::", JSON.stringify(returnValue));
                    var listLabel   = component.get('v.listLabel');
                    var MyId        = returnValue['MyId'];
                    var MyName      = returnValue['MyName'];

                    if (MyId != returnValue['MdId'] && MyId != returnValue['DhId']){
                        if (MyId == returnValue['PmId']){
                            listLabel.userDatas.push(
                                {"Id":returnValue['MdId'], "Name":returnValue['MdName']},
                                {"Id":returnValue['DhId'], "Name":returnValue['DhName']}
                            );
                        }else {
                            listLabel.userDatas.push(
                                {"Id":returnValue['PmId'], "Name":returnValue['PmName']},
                                {"Id":returnValue['MdId'], "Name":returnValue['MdName']},
                                {"Id":returnValue['DhId'], "Name":returnValue['DhName']}
                            );
                        }
                        component.set('v.listLabel', listLabel);
                    }else if(MyId == returnValue['DhId']){
                        listLabel.userDatas.push(
                            {"Id":returnValue['MdId'], "Name":returnValue['MdName']},
                            {"Id":returnValue['RpId'], "Name":returnValue['RpName']}
                        );
                        component.set('v.listLabel', listLabel);
                    }
                    //console.log('userdatas 제대로들어갔을까..?', JSON.stringify(listLabel.userDatas));
                }

            }else{
                console.log('apex실패');
            }
        });
        $A.enqueueAction(action);

        //return newData;
    },



	showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");

        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });

        evt.fire();
    }, 

    doNavigateSObject : function(recordId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            recordId : recordId
        });
        navEvt.fire();
    }

})