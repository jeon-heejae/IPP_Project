/**
 * Created by Kwanwoo.Jeon on 2024-02-16.
 */

({
    /**
     * @description get event data
     */
    getEvents : function(component, event) {
        var action = component.get("c.getEvents");

        action.setParams({
            mapCheckboxValue : component.get("v.mapCheckboxValue"),
            selectedPick : component.get("v.SelectedPick")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result', result);
                component.set("v.eventsMap", result.listEventObj);
                component.set("v.isCreateActive", result.isCreateActive);
                component.set("v.DateNextMonth", result.DateNextMonth);
                console.log('DateNextMonth', component.get("v.DateNextMonth"));

            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
	},

	showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });

        evt.fire();
    },
})