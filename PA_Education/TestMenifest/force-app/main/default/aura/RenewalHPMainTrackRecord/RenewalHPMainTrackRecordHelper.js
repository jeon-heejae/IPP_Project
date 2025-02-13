({
    doSearchTrekRecords: function (component) {
        var action = component.get("c.doSearchTrekRecords");
        action.setParams({
            isEnglish: component.get('v.isEnglish')
        })

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                try {
                    var returnValue = response.getReturnValue();

                    if (returnValue) {
                        component.set("v.trekRecords", returnValue);

                        if (returnValue.length === 9) {
                            component.set("v.hasMore", true);
                        }
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
    },
    getRecordById: function (component, id) {
        var action = component.get("c.getRecordById");

        action.setParams({ recordId: id, isEnglish: component.get('v.isEnglish') });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                try {
                    var returnValue = response.getReturnValue();

                    if (returnValue) {
                        component.set("v.trekRecordItem", returnValue);
                    }
                } catch (e) {
                    console.log('error: ' + e.message);
                }
            }
        });

        $A.enqueueAction(action);
    },
    loadMoreTrekRecords: function (component) {
        var action = component.get("c.loadMoreTrekRecords");

        action.setParams({ isEnglish: component.get('v.isEnglish') });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                try {
                    var returnValue = response.getReturnValue();

                    if (returnValue) {
                        component.set("v.trekRecords", returnValue);
                        component.set("v.hasMore", false);
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