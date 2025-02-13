({  
	getInit : function(component, event, helper) {
		var action 	  = component.get("c.getInit");

		action.setParams({
			'recordId' : component.get("v.recordId")
		});

		action.setCallback(this, function(response) {
			var state = response.getState();
			if(state === "SUCCESS") {
				var returnValue  = response.getReturnValue();
				component.set("v.objExpense",        returnValue["objExpense"]);
				console.log('objExpense : ', returnValue["objExpense"].BudgetType__c);
				component.set("v.listExpenseDetail", returnValue["listExpenseDetail"]);
				component.set("v.listExpenseEdit", 	 returnValue["listExpenseDetail"]);
                component.set("v.toggleSpinner", false);
			}
		});

		$A.enqueueAction(action);
	},

	// object의 label가져오기 
	getObjectFieldLabel : function (component,helper) {
        var action = component.get("c.getObjectFieldLabel");

        action.setParams({
            "sObjectName" : "ExpenseDetail__c"
        });

        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            component.set("v.mapEDLabel", result);
        });

        $A.enqueueAction(action);
    },
})