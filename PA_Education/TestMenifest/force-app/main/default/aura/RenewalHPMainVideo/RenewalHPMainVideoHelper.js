({
    getNotice: function (component) {
        var action = component.get("c.getUrgentNotice");
        action.setParams({ isEnglish: component.get('v.isEnglish') })

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                try {
                    var returnValue = response.getReturnValue();
                    if (returnValue) {
                        component.set("v.listNoticeItem", returnValue);
                    }
                } catch (e) {
                    component.set("v.isReady", true);
                    console.log('error : ' + e.message);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("error", errors[0].message);
                    }
                } else {
                    console.log("error", "Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    }
});