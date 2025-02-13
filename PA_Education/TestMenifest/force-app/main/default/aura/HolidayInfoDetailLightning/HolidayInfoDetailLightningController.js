({
	doInit : function(component, event, helper) {
       helper.getHoilday(component, event, helper);
       var action = component.get('c.getObjectFieldLabel');
		action.setParams({
			"sObjectName" : "Holiday__c"
		});
		action.setCallback(this,function(reponse){
			var state = reponse.getState();
			var result = reponse.getReturnValue();
			console.log('-----result------/ '+result);			
			component.set('v.holidayMapLabel',result);
			helper.getActionLabel(component,event,helper);
		

		});

		$A.enqueueAction(action);
    },
    
    clickStatus : function(component, event, helper) {
	var x = document.getElementById("myDIV");
		if (x.style.display === "none") {
		    x.style.display = "block";
		    component.set('v.clickType', true);	
		} else {
		    x.style.display = "none";
		    component.set('v.clickType', false);
		}
	},
    
    clickStatus2 : function(component, event, helper) {
	var y = document.getElementById("myDIV2");
		if (y.style.display === "none") {
		    y.style.display = "block";
		    component.set('v.clickType2', true);
		} else {
		    y.style.display = "none";
		    component.set('v.clickType2', false);
		}
	},

	clickStatus3 : function(component, event, helper) {
	var y = document.getElementById("myDIV3");
		if (y.style.display === "none") {
		    y.style.display = "block";
		    component.set('v.clickType3', true);
		} else {
		    y.style.display = "none";
		    component.set('v.clickType3', false);
		}
	},

	clickStatus4 : function(component, event, helper) {
	var y = document.getElementById("myDIV4");
		if (y.style.display === "none") {
		    y.style.display = "block";
		    component.set('v.clickType4', true);
		} else {
		    y.style.display = "none";
		    component.set('v.clickType4', false);
		}
	},

	// onReproduce: function(component, event, helper){
	// 	// 1. HolidayAction의 아이디를 가지고 온다. (a tag에 있는 id를 가지고 온다.)
	// 	console.log('onReproduce');
	// 	var recordId = event.target.getAttribute("data-recId");
	// 	console.log("recordId:" + recordId);
	// 	helper.goProcessAprroval(component, event, helper,recordId);
	// }
});