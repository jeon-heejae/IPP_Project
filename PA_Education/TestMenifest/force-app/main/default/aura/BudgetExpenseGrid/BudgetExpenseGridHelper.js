/**
 * Created by Kwanwoo.Jeon on 2024-01-15.
 */

({
    /**
     * @description doInit
     */
    gfnInit: function(component, event, helper){
        var recordId = component.get("v.recordId");
        console.log(recordId);
        var action   = component.get("c.doInit");
        action.setParams({
            recordId : recordId
        });

        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set("v.objBudget", 	  returnValue["objBudget"]);
                component.set("v.listExp",  	  returnValue["listExp"]);
            }
        });

        $A.enqueueAction(action);

    }
});