({
    doInit: function(component, event, helper) {
        // isCheck 호출
        var action = component.get("c.isCheck");
        action.setParams({
            recordId: component.get("v.recordId")
        });
   
        // isCheck에 대한 콜백 처리
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isCorrectUser = response.getReturnValue();
                component.set("v.isCorrectUser", isCorrectUser);
                console.log('check: ', component.get("v.isCorrectUser"));
   
                if (isCorrectUser) {
                    // isCorrectUser가 true일 때만 다음 로직 실행
                    helper.getRecordData(component);
                    helper.getPicklistOptions(component);
   
                    // 권한 확인 호출
                    var permAction = component.get("c.hasPermissionSet");
                    console.log('permcheck before: ', component.get("v.hasPermission"));
                    permAction.setCallback(this, function(permResponse) {
                        var permState = permResponse.getState();
                        console.log('permchecking: ', permState);
                        if (permState === "SUCCESS") {
                            var hasPermission = permResponse.getReturnValue();
                            console.log('hasPermission ::', hasPermission);
                            component.set("v.hasPermission", hasPermission);
                           
                        } else {
                            helper.showToast(component, "error", permResponse.getReturnValue());
                        }
                    });
                    $A.enqueueAction(permAction);
   
                } else {
                    // isCorrectUser가 false인 경우에 대한 처리
                    console.log("User does not have correct permissions or role");
                }
            } else {
                helper.showToast(component, "error", response.getReturnValue());
            }
        });
   
        // isCheck를 호출
        $A.enqueueAction(action);
    },
   
   
 
    handleEdit: function(component,event,helper){
        component.set("v.isEditMode",true);
    },
 
    handleSave:function(component,event,helper){
        helper.updateRecordData(component);
        component.set("v.isEditMode",false);
    },
 
    handleCancel:function(component,event,helper){
        helper.cancelEdit(component);
        component.set("v.isEditMode",false);
    }
})
 
 

 
 