({
    fnInit : function(component, event, helper) {
    	console.log("fnInit init!");
    	helper.getInitData(component);
    },

    close : function(component, event, helper) {
        helper.closeModal(component, helper);
    },
})