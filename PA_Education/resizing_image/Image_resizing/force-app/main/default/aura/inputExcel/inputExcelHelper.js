({
    handleSave:function(component,event,helper){
        let datas=component.get("v.tableData");
        let recordId=component.get("v.recordId");

        var action = component.get("c.saveData");
        action.setParams({
            "datas":datas,
            "recordId":recordId
        });
    
        action.setCallback(this, (response) => {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result: ' + result);
                this.showToast('SUCCESS', '성공적으로 저장');
                $A.get("e.force:closeQuickAction").fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.error("Error message: " + errors[0].message);
                } else {
                    console.error("Unknown error");
                }
            } else {
                console.error("Action failed: " + state);
            }
        });
    
        $A.enqueueAction(action);
    },

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