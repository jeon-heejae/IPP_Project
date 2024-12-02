({
    fnInit : function(component, event, helper) {
        
        helper.loadAddressData(component);
    },
    
    handleAddressReset : function(component, event, helper) {
        component.set("v.objAddress", { 'PostalCode__c': '', 'RoadAddress__c': '', 'DetailAddress__c': '' });
        helper.saveAddress(component);
    },
    
    handleAddressSearch : function(component, event, helper) {
        component.set("v.showAddressSearch", true);
    },
    
    handleAddressSaved : function(component, event, helper) {
        component.set("v.showAddressSearch", false);
        helper.showToast("성공", "주소 설정이 완료되었습니다.");
        $A.get("e.force:refreshView").fire();
        //location.reload();
        //helper.loadAddressData(component);
        
    },
    
    handleAddressSearchClose : function(component, event, helper) {
        component.set("v.showAddressSearch", false);
    }
})