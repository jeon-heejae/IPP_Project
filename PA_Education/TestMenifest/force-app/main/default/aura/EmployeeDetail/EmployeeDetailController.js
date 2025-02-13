/**
 * Created by attar on 2020-11-17.
 */

({
    fnInit : function(component, event, helper){
        helper.isFirst(component);
    },

    fnCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire()
    },

    fnSave : function(component, event, helper) {
        helper.saveData(component, event, helper);
    }
});