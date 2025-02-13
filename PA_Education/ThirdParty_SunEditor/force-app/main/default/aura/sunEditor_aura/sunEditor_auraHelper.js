({
    handleGetSunEditor:function(component,event){
        var action=component.get("c.getSunEditor");
        var recordId=component.get("v.recordId");
        action.setParams({"fRecordId":recordId});
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                console.log('result: '+result);
                component.set("v.objSunEditor",result);

                var richText=component.get("v.objSunEditor");
                component.set("v.message",richText);
                var message = component.get("v.message");
                console.log('message: '+message);
            }
            else {
                console.error("Action failed: " + state);
            }
        });

        $A.enqueueAction(action);
    },

    getDomainHostName: function(component, event) {
        return new Promise((resolve, reject) => {
            var action=component.get("c.getDomainHost");
            
            action.setCallback(this,function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var vfHost=response.getReturnValue();
                    console.log('vfHost: ' + vfHost);
                    component.set("v.vfHost",vfHost);
                    
                    var vfOrigin = "https://" + component.get("v.vfHost");
                    console.log('vfOrigin: '+vfOrigin);
                    component.set("v.vfOrigin",vfOrigin);
                    resolve(vfOrigin);
                }
                else {
                    console.error("Action failed: " + state);
                    reject(response.getError());
                }
            });

            $A.enqueueAction(action);
        });  
    },

    saveSunEditor:function(component, event){
        var action=component.get("c.doSaveRichText");
        var recordId=component.get("v.recordId");
        var message=component.get("v.message");
        console.log('save message: '+message);
        
        action.setParams({"fRecordId":recordId, "fStrRichText":message});
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                console.log('result: '+result);
            }
            else {
                console.error("Action failed: " + state);
            }
        });

        $A.enqueueAction(action);
        
    }
})