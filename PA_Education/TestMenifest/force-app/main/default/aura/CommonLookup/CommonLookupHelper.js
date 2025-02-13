({
    searchList : function(component,event,getInputkeyWord) {
        // call the apex class method 
        var action = component.get("c.doGetItemList");
        // set param to method  
        action.setParams({
            'fObj': component.get("v.sObj"),
            'fSearchKeyWord': getInputkeyWord
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.sMessage", 'No Result Found...');
                } else {
                    component.set("v.sMessage", 'Search Result...');
                }
                console.log(storeResponse);
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
            
        });
        // enqueue the Action  
        $A.enqueueAction(action);
        
    },

    searchListWithAcct : function(component,event,getInputkeyWord) {
        // call the apex class method 
        console.log(">>>>>>" + component.get("v.accountId"));
        var action = component.get("c.doGetItemListWithAcct");
        // set param to method  
        action.setParams({
            'fObj': component.get("v.sObj"),
            'fSearchKeyWord': getInputkeyWord,
            'fAccountId' : component.get("v.accountId")
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.sMessage", 'No Result Found...');
                } else {
                    component.set("v.sMessage", 'Search Result...');
                }
                console.log(storeResponse);
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }else{
                console.log(state);
                console.log(response.getError());
            }
            
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    }
})