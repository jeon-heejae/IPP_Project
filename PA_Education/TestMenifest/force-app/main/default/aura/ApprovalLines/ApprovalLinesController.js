({
	fnInit : function(component, event, helper) {
		helper.getApprovalLines(component);

		console.log('APHexpnse? ::',component.get('v.sObjectName'));
	},

	fnClickNew : function(component, event, helper) {
		helper.doCreate(component,event, helper);
	},

	handleSelect : function(component, event, helper) {
		var selectItem = event.getParams("v.value");
		var temp = event.getSource().get("v.class");
		var list = component.get("v.listLabel");
		
		if (selectItem.value === 'Edit') {
			helper.doEdit(component, event, helper, list[temp]);
		} else if (selectItem.value === 'Delete') {
			helper.doDelete(component, event, helper);
		}
	},

	fnEdit : function(component, event, helper) {
		var temp = event.getSource().get("v.value");
		var list = component.get("v.listLabel");
		helper.doEdit(component, event, helper, list[temp]);
	},

	fnClose : function(component, event, helper) {
		var modal = component.find('divModal');      /* aura:id 'divModal'찾기*/
        $A.util.removeClass(modal, 'slds-show');	
        $A.util.addClass(modal, 'slds-hide');		
        // component.set('v.holidayModalView', false);
        /*scroll 방지 해제*/
		document.body.style.overflow="auto";
	},
})