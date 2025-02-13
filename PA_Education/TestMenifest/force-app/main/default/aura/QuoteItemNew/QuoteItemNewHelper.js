({
	getInitData : function(component) {
		var action = component.get("c.getInitData");

		action.setParams({
		});
		action.setCallback(this, function(response) {
			var state = response.getState();

			if(state === "SUCCESS") {
				var result = response.getReturnValue();

				console.table(result.listRecordTypeQI);
				component.set("v.listRecordTypeQI", result.listRecordTypeQI);
				component.set("v.mapRecordTypeId", result.mapRecordTypeId);
			}
		});

		$A.enqueueAction(action);
	},

	doCreateRecord : function(component, params) {
		var createRecordEvt = $A.get("e.force:createRecord");

		createRecordEvt.setParams({
			"entityApiName": "QuoteItem__c",
            "recordTypeId" : params["idRecordType"],
            "defaultFieldValues": {
                "QuoteItem_Quote__c" : component.get("v.idParentRecord")
            },
            "panelOnDestroyCallback": function(event) {
                var rtnUrl = window.location.href;
                console.log("rtnUrl : " + rtnUrl);
                // if(rtnUrl.indexOf("lightning/r/Agreement__c") < 0){
                //     var url = "/lightning/r/" + component.get("v.idParentRecord") + "/view";
                //     window.parent.location = url;
                // }

                var url = "/lightning/r/" + component.get("v.idParentRecord") + "/view";
                window.parent.location = url;
            }
		});	

		createRecordEvt.fire();

		this.doModalHide(component);
	},

	doCreateRecordAuto : function(component, params) {
		var action = component.get("c.getDefaultValue");

		action.setParams({
			"idEmployee" : params["idEmployee"]
		});
		action.setCallback(this, function(response) {
			var state = response.getState();

			if(state === "SUCCESS") {
				var result = response.getReturnValue();
				var wrapEmployee = result["wrapEmployee"];

				var createRecordEvt = $A.get("e.force:createRecord");

				createRecordEvt.setParams({
					"entityApiName": "QuoteItem__c",
		            "recordTypeId" : params["idRecordType"],
		            "defaultFieldValues": {
		                "QuoteItem_Quote__c" : component.get("v.idParentRecord"),
		                "QuoteItem_ConsultName__c" : wrapEmployee.objEmployee.Name,
		                "QuoteItem_ConsultType__c" : wrapEmployee.objEmployee.DeptPosition__c,
		                "QuoteItem_ConsultLevel__c" : wrapEmployee.objEmployee.Fm_Level__c,
		                "QuoteItem_ConsultListPrice__c" : wrapEmployee.dConsultListPrice
		            },
		            "panelOnDestroyCallback": function(event) {
		                var rtnUrl = window.location.href;
		                console.log("rtnUrl : " + rtnUrl);
		                // if(rtnUrl.indexOf("lightning/r/Agreement__c") < 0){
		                //     var url = "/lightning/r/" + component.get("v.idParentRecord") + "/view";
		                //     window.parent.location = url;
		                // }

		                var url = "/lightning/r/" + component.get("v.idParentRecord") + "/view";
                		window.parent.location = url;
		            }
				});	

				createRecordEvt.fire();

				this.doModalHide(component);
			}
		});

		$A.enqueueAction(action);
	},

	doModalHide : function(component) {
		$A.util.toggleClass(component.find("modalContainer"), "slds-hide");
	},

	doClose : function(component) {
		var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({ 
            "recordId": component.get("v.idParentRecord")
        });
        navigateEvent.fire();	
	},
})