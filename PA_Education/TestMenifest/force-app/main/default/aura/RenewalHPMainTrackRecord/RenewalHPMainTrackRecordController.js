({
    init : function(component, event, helper) {
        let isEnglish = event.getParam('isEnglish')
        isEnglish ? component.set('v.isEnglish', isEnglish) :
            component.set('v.isEnglish', false)
        helper.doSearchTrekRecords(component);
    },
    loadMore: function (component, event, helper) {
        helper.loadMoreTrekRecords(component);
    },
    showRecordModal: function (component, event, helper) {
        helper.getRecordById(component, event.target.id);
        $A.util.addClass(component.find("modal"), "active");
    },
    hideRecordModal: function (component, event) {
        if (event.target == event.currentTarget) {
            $A.util.removeClass(component.find("modal"), "active");
        }
    }
})