/**
 * Created by yeonlim on 2023-12-15.
 */

({
    fnClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    fnSubmit : function(component, event, helper) {
        helper.doApproval(component, event);
    }
});