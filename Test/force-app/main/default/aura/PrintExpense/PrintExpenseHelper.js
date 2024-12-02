({
    saveAction : function(component) {
        console.log('Action start');
        component.set('v.showSpinner',true);
    try {
        var action = component.get("c.doSavePdf");
        console.log('Action created successfully');
        action.setParams({
            "strRecordId": component.get("v.recordId")
        });
        console.log('param setting');
        console.log(component.get("v.recordId"));
    } catch (error) {
        console.error('Error in handleSave:', error);
    }

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Action state:', state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result === 'success') {
                    component.set('v.showSpinner',false);
                    // 성공 메시지 표시
                    this.showToast('Success', 'PDF file saved successfully', 'success');
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get("e.force:refreshView").fire();
                } else {
                    // 오류 메시지 표시
                    this.showToast('Error', 'Failed to save PDF file', 'error');
                }
            } else {
                // 오류 메시지 표시
                this.showToast('Error', 'Failed to save PDF file', 'error');
                var errors = response.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    console.error("Error message: " + errors[0].message);
                }
                if (errors[0] && errors[0].pageErrors) {
                    console.error("Page error: " + JSON.stringify(errors[0].pageErrors));
                }
                if (errors[0] && errors[0].fieldErrors) {
                    console.error("Field errors: " + JSON.stringify(errors[0].fieldErrors));
                }
            } else {
                console.error("Unknown error");
            }
            }
        });
        
        $A.enqueueAction(action);
    },
    
  
    showToast : function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
})