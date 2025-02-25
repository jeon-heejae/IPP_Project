({
    refreshBudget : function(component,event,helper,listSelectId) {
        var action=component.get("c.executeBatchProcess");
        //action.setParams({"listSelectId":listSelectId});

        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state: '+state);
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                console.log('result:'+result);
                this.showToast('Success',result,'Success');
                window.history.back(); // 브라우저 히스토리에서 이전 페이지로 이동
            } else {
                let errors = response.getError();
                let message = "알 수 없는 오류가 발생했습니다.";
                if (errors && errors[0] && errors[0].message) {
                    message = errors[0].message;
                }
                console.log('error: '+message);
                this.showToast('Error',message,'Error');
                window.history.back(); // 브라우저 히스토리에서 이전 페이지로 이동
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