({
    loadContactInfo : function(component) {
        var action = component.get("c.getContactInfo");
        action.setParams({
            "contactId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.contact", result.contact);
                component.set("v.skills", result.skills);
            } else {
                console.error('Error loading contact information');
            }
        });
        $A.enqueueAction(action);
    }
})