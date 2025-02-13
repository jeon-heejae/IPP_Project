({
	fnInit : function(component, event, helper) {
		if(!component.get('v.bIsEdit')){
			helper.getInit(component, event, helper);
			helper.getObjectFieldLabel(component, helper);
		}

	},

	handleSaveEdition: function (component, event, helper) {
        var draftValues = event.getParam('draftValues');
        helper.saveEdition(component, draftValues);
    },

//    fnNewEdit : function (component, event, helper) {
//    	var bIsEdit = component.get("v.bIsEdit");
//    	console.log("bIsEdit>>> " + bIsEdit);
//    	if(bIsEdit == false){
//    		component.set("v.bIsEdit", true);
//    	}
//    },

    fnGoToRelatedView : function(component, event, helper) {
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId"  : "ExpenseDetail__r",
            "parentRecordId" : component.get("v.recordId")
        });
        relatedListEvent.fire();
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


})