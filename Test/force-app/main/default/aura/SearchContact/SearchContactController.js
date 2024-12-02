({
    init: function(component, event, helper) {
        
        helper.initColumns(component);
    },

    
    handleSearch: function(component, event, helper) {
        var searchLastName = component.get("v.searchLastName");
        var searchAccountName = component.get("v.searchAccountName");
        var searchEmail = component.get("v.searchEmail");
        console.log(searchLastName);
        
        if (!searchLastName && !searchAccountName && !searchEmail) {
            helper.showToast("Warning", "조건을 하나 이상 입력하시오.");
            return;
        }
        component.set("v.currentPage",0);
        component.set("v.pageNumber",1);
        component.set("v.totalPages",0);
        helper.searchContacts(component);
        
    },
    
    handleRowAction: function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        
        switch (action.name) {
            case 'view_details':
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": row.Id,
                    "slideDevName": "detail"
                });
                navEvt.fire();
                break;
        }
    },
    fnNext:function(component,event,helper){
        var currentPageNumber=component.get("v.currentPage");
        var nextPage=parseInt(currentPageNumber,10)+1;
        var totalPages=component.get("v.totalPages");
        console.log(currentPageNumber);
        console.log(nextPage);
        console.log(totalPages);
        if(nextPage<=totalPages){
            component.set("v.currentPage",nextPage);
            component.set("v.pageNumber",nextPage);
            helper.nextContacts(component,nextPage);
        }
    },
    fnPrev:function(component,event,helper){
        var currentPageNumber = component.get("v.currentPage");
        var prevPage=parseInt(currentPageNumber,10)-1;
        var totalPages=component.get("v.totalPages");
        console.log(currentPageNumber);
        console.log(prevPage);
        console.log(totalPages);
        if(prevPage>0){
            component.set("v.currentPage",prevPage);
            component.set("v.pageNumber",prevPage);
            helper.prevContacts(component,prevPage);
        }
    }
})
