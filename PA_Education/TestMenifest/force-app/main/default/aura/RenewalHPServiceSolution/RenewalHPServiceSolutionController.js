({
	init : function(component, event, helper) {
        helper.getDeliveries(component);
        let isEnglish = event.getParam('isEnglish')
        isEnglish ? component.set('v.isEnglish', isEnglish) :
            component.set('v.isEnglish', false)
    },
    showRecordModal: function (component, event, helper) {
        helper.getDeliveryById(component, event.target.id);
        $A.util.addClass(component.find("modal"), "active");
    },
    hideRecordModal: function (component, event) {
        if (event.target == event.currentTarget) {
            $A.util.removeClass(component.find("modal"), "active");
        }
    }
})