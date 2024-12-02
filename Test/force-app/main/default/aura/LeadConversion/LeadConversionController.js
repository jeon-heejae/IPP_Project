({
    fnInit: function(component, event, helper) {
        // 초기 로드 시 금액을 0으로 설정
        component.set("v.amount", 0);

        var action = component.get("c.getTeachersAndTablets");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.teachers", result.teachers);
                component.set("v.tablets", result.tablets);
            } else if (state === "ERROR") {
                helper.showToast("오류", "선생님과 태블릿 정보를 가져오는 데 실패했습니다.", "error");
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    calculateAmount: function(component, event, helper) {
        var contractPeriod = component.get("v.contractPeriod");
        var paymentMethod = component.get("v.paymentMethod");
        var amount = 0;

        if (contractPeriod && paymentMethod) {
            if (paymentMethod === "monthly") {
                if (contractPeriod === "1") {
                    amount = 149000;
                } else if (contractPeriod === "2") {
                    amount = 119000;
                }
            } else if (paymentMethod === "onetime") {
                if (contractPeriod === "1") {
                    amount = 1788000;
                } else if (contractPeriod === "2") {
                    amount = 2856000;
                }
            }
        }

        component.set("v.amount", amount);
    },

    fnSave: function(component, event, helper) {
        component.set("v.isLoading", true);
        if(component.get("v.selectedTeacher")==null || component.get("v.selectedTablet")==null){
                helper.showToast("Error","선생님과 태블릿을 입력해주세요.","error");
                component.set("v.isLoading", false);
                return;
        }
        
        helper.handleSave(component, event, helper);
    },

    fnCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})