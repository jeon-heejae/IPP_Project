({
    fnFirstPage: function(component, event, helper) {
        component.set("v.currentPageNumber", 1);
    },

    fnPrevPage: function(component, event, helper) {
        component.set("v.currentPageNumber", Math.max(component.get("v.currentPageNumber") - 1, 1));
    },

    fnNextPage: function(component, event, helper) {
        component.set("v.currentPageNumber", Math.min(component.get("v.currentPageNumber") + 1, component.get("v.maxPageNumber")));
    },

    fnLastPage: function(component, event, helper) {
        component.set("v.currentPageNumber", component.get("v.maxPageNumber"));
    },
})