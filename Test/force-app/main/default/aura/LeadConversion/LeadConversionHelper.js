({
    handleSave: function(component, event, helper) {
        var contractData = {
            leadId: component.get("v.recordId"),
            contractPeriod: component.get("v.contractPeriod"),
            paymentMethod: component.get("v.paymentMethod"),
            amount: component.get("v.amount"),
            selectedTeacher: component.get("v.selectedTeacher"),
            selectedTablet: component.get("v.selectedTablet")
        };
        
        var action = component.get("c.saveLead");
        action.setParams({ contractData: contractData });
        
        action.setCallback(this, function(response) {
            component.set("v.isLoading", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("ContractWay created successfully");
                this.showToast("Success", "계약이 성공적으로 진행되었습니다.", "success");
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.error("Error message: " + errors[0].message);
                    this.showToast("Error", errors[0].message, "error");
                } else {
                    console.error("Unknown error");
                    this.showToast("Error", "계약 생성 중 알 수 없는 오류가 발생했습니다.", "error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },

    
    showToast: function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type
        });
        toastEvent.fire();
    }
})