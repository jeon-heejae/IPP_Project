({
	getApprovalLines : function(component) {
		var action   = component.get("c.getApprovalLines");
		var bHistory = component.get("v.bHistory");
		var recordId = component.get("v.recordId");

		if(bHistory == true){
			recordId = component.get("v.userId");
		}

        action.setParams({
            recordId : recordId
        });

		action.setCallback(this, function(response) {
			var state = response.getState();
            
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set("v.mapReturnValue", returnValue);
                component.set("v.listLabel", 	  returnValue["listLabel"]);
                component.set("v.objUser",  	  returnValue["objUser"]);
                component.set("v.iLineLimit",     returnValue["iLineLimit"]);
                component.set("v.iApproverLimit", returnValue["iApproverLimit"]);
                component.set("v.isNew",          returnValue["listLabel"].length < 4 ? true : false);
            }
		});

		$A.enqueueAction(action);
	},

	doCreate : function(component, event, helper) {
		var recordId  	   = component.get("v.recordId");
		var listLabel 	   = component.get("v.listLabel");
		var bHistory  	   = component.get("v.bHistory");
		var iLineLimit     = component.get("v.iLineLimit");
		var iApproverLimit = component.get("v.iApproverLimit");

		console.log(recordId + ' / ' + listLabel);

		var newData = {
			fieldName : '',
			label: '',
			userDatas:[]
		};

		if(listLabel.length == iLineLimit && bHistory == false) {
			this.showToast('error','ApprovalLine 생성은 최대 '+ iLineLimit + '개까지만 가능합니다.');
		} else {
			$A.createComponent(
				"c:ApprovalLineCreate",
				{
					'sId'       	   : recordId ,
					'listLabel'		   : newData,
					'objUser'		   : component.get("v.objUser"),
					'bHistory'		   : component.get("v.bHistory"),
					'sObjectName'	   : component.get("v.sObjectName"),
					'sHistoryRecordId' : component.get("v.sHistoryRecordId"),
					'iApproverLimit'   : component.get("v.iApproverLimit"),
					'sRecordId'        : component.get("v.sRecordId")
				}, 
				function(cApprovalLineCreate, status, errorMessage) {
					if(status === "SUCCESS") {
						component.set("v.LineCraetCmp", cApprovalLineCreate),
						document.body.style.overflow = "hidden";
					} else if (status === "INCOMPLETE") {
                    	console.log("No response from server or client is offline.");
                    } else if (status === "ERROR") {
						console.log("Error : " + errorMessage);
					}
				}
			);
		}
	},

	doEdit : function(component, event, helper, listData){
		var fieldName = event.getSource().get("v.name");
		var listLabel = component.get("v.listLabel");
		
		$A.createComponent(
            "c:ApprovalLineCreate",
            {
                'sId'       	    : component.get("v.recordId") ,
                'fieldName'		    : fieldName,
                'listLabel'		    : listData,
                'objUser'		    : component.get("v.objUser"),
                'bHistory'		    : component.get("v.bHistory"),
                'sObjectName'	    : component.get("v.sObjectName"),
                'sHistoryRecordId'	: component.get("v.sHistoryRecordId")
            },

            function(cApprovalLineCreate, status, errorMessage) {
                if(status === "SUCCESS") {
                    component.set("v.LineCraetCmp", cApprovalLineCreate),
                    document.body.style.overflow = "hidden";
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error : " + errorMessage);
                }
            }
        );
	},

	doDelete : function(component, event, helper){
		var fieldName = event.getSource().get("v.name");
		var action = component.get("c.doDelete");

		action.setParams({
			'objUser'		 : component.get("v.objUser"),
			'fieldName' 	 : fieldName
		});

		action.setCallback(this, function(response){
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
    },
})