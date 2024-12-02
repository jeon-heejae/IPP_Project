({
    doInit : function(component, event, helper) {
        helper.loadContactInfo(component);
    },
    
    generatePDF : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var url = '/apex/PrintPDF?recordId=' + recordId;
        window.open(url, '_blank');
    }
})

