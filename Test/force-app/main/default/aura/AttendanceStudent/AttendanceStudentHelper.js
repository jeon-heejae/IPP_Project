({
    loadStudents : function(component) {
        var action = component.get("c.getAttendingStudents");
        action.setParams({
            OfflineClassId: component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.students", response.getReturnValue());
            } else {
                console.error('Error loading students');
            }
        });
        
        $A.enqueueAction(action);
    }
})