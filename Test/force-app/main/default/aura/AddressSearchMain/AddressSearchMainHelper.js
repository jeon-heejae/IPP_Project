({
    loadAddressData : function(component) {
        var action = component.get("c.getAddressData");
        action.setParams({ recordId: component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.objAddress", response.getReturnValue());
            } else {
                console.error('Error loading address data');
            }
        });
        
        $A.enqueueAction(action);
    },
    
    
    //토스트 메시지를 사용할 helper에 이 함수를 꼭 추가해주세요
    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key : "info_alt"
            , type : type
            , message : message
        });
        evt.fire();
    }
})