/**
 * Created by attar on 2020-11-17.
 */

({
    isFirst : function(component) {
//        var action = component.get("c.doFind");
//        action.setParams({
//            "recordId" : component.get("v.recordId")
//        });
//        action.setCallback(this, function(response) {
//            var state = response.getState();
            var recordId = component.get("v.recordId");
//            if(state === "SUCCESS") {
//                var result = response.getReturnValue();
//                console.log(result);
                    $A.get("e.force:closeQuickAction").fire();

                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                         "url": "/apex/EmployeeDetailPage?recordId=" + component.get("v.recordId"),
                         "isredirect": "true"
                    });
                    urlEvent.fire();

                    function goBack(){
                        var url = location.href;
                        var baseURL = url.substring(0, url.indexOf('/', 14));

                        history.back(baseURL + '/lightning/r/Employee__c/' + recordId + "/view");
                    }

                    var clearNum = 1;
                    var myTimer = setInterval(function(){
                        clearNum--;

                        if(clearNum == 0) {
                            clearInterval(myTimer);
                            goBack();
                        }
                    }, 1000);
//                }
//
//        });
//        $A.enqueueAction(action);
    },

    saveData : function(component) {
        var action = component.get("c.doSaveData");
        action.setParams({
           /* "paramReason" : component.get("v.reason"),
            "paramClear" : component.get("v.clear"),*/
            "recordId" : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            var recordId = component.get("v.recordId");

            if(state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();

                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                     "url": "/apex/EmployeeDetailPage?recordId=" + component.get("v.recordId"),
                     "isredirect": "true"
                });
                urlEvent.fire();

                function goBack(){
                    var url = location.href;
                    var baseURL = url.substring(0, url.indexOf('/', 14));

                    history.back(baseURL + '/lightning/r/Employee__c/' + recordId + "/view");
                }

                var clearNum = 1;
                var myTimer = setInterval(function(){
                    clearNum--;

                    if(clearNum == 0) {
                        clearInterval(myTimer);
                        goBack();
                    }
                }, 1000);

/*                var urlEvent2 = $A.get("e.force:navigateToURL");
                var url = location.href;
                var baseURL = url.substring(0, url.indexOf('/', 14));
                console.log(baseURL);
                urlEvent2.setParams({
                     "url": baseURL + "/lightning/r/Employee__c/" + component.get("v.recordId") + "/view",
                     "isredirect": "true"
                });
                urlEvent2.fire();
                console.log('ddddd');*/
            }
        });
        $A.enqueueAction(action);
    }
});