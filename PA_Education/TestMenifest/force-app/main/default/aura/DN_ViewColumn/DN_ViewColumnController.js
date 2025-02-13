({
    fnInit : function(component, event, helper) {
        var header = component.get("v.header");
        var data = component.get("v.data");

        component.set("v.columnValue", data[header.fieldName]);
    },
})