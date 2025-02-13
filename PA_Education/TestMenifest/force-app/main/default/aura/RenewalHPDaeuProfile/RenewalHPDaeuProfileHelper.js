({
    doSearchCompanyHistory : function(component) {
        var action = component.get("c.doSearchCompanyHistory");
        action.setParams({
            isEnglish : component.get("v.isEnglish")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try{
                    var returnValue = response.getReturnValue();
                    if(returnValue) {
                        const keys = Object.keys(returnValue);
                        const result = [];
                        
                        keys.forEach(function (key) {
                            result.push({
                                year: key,
                                items: returnValue[key]
                            });
                        });
                        
                        result.sort(function (a, b) {
                            if (a.year > b.year) {
                                return -1;
                            } 
                            
                            if (a.year < b.year) {
                                return 1;
                            }
                            
                            return 0;
                        });

                        component.set("v.listCompanyHistory", result);
                    }
                }catch(e){
                    component.set("v.isReady", true);
                    console.log('error : ' + e.message);
                }
            } else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        console.log("error", errors[0].message);
                    }
                } else {
                    console.log("error", "Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    }
});