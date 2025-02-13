({
    getListApprovalHistory : function(component) {
        var action   = component.get("c.getListApprovalHistory");

        //var cmpEvent = $A.get("e.c:ApprovalHistory_evt");
        
        action.setParams({
            "idTargetObject" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
 
            if(state === "SUCCESS") { 
                var mapReturnValue          = response.getReturnValue();
                var listWrapApprovalHistory = mapReturnValue["listWrapApprovalHistory"];

                component.set("v.listWrapApprovalHistory", listWrapApprovalHistory);
                component.set("v.iRecordCount"           , listWrapApprovalHistory.length);
                component.set("v.bIsPending"             , mapReturnValue["bIsPending"]);
                component.set("v.bIsSubmitter"           , mapReturnValue["bIsSubmitter"]);
                component.set("v.bIsApprover"            , mapReturnValue["bIsApprover"]);

                //sj추가
                component.set("v.userId"                 , mapReturnValue["userId"]);
                component.set("v.sPendingUser"           , mapReturnValue["sPendingUser"]);

      
                var listApprover = [];
                if(mapReturnValue["idApp1"] != null ) { listApprover.push(mapReturnValue["idApp1"]); }
                if(mapReturnValue["idApp2"] != null ) { listApprover.push(mapReturnValue["idApp2"]); }
                if(mapReturnValue["idApp3"] != null ) { listApprover.push(mapReturnValue["idApp3"]); }
                if(mapReturnValue["idApp4"] != null ) { listApprover.push(mapReturnValue["idApp4"]); }             
                component.set("v.listApprover"  , listApprover);        

                var listAppName  = [];
                if(mapReturnValue["sAppName1"] != null ) { listAppName.push(mapReturnValue["sAppName1"]); }
                if(mapReturnValue["sAppName2"] != null ) { listAppName.push(mapReturnValue["sAppName2"]); }
                if(mapReturnValue["sAppName3"] != null ) { listAppName.push(mapReturnValue["sAppName3"]); }
                if(mapReturnValue["sAppName4"] != null ) { listAppName.push(mapReturnValue["sAppName4"]); }
                

                //cmpEvent.setParams({
                //    "listApprover" : listApprover,
                //    "listAppName"  : listAppName,
                //    "sPendingUser" : mapReturnValue["sPendingUser"]
                //});
                //cmpEvent.fire();


                // this.fireComponentEvent(component, cmpEvent);
            }
        });

        $A.enqueueAction(action);
    },


    doProcessWorkitemRequest : function(component, idAssignee) {
        var sComments = component.find("comments").get("v.value");
        var action = component.get("c.doProcessWorkitemRequest");
        var cmpEvent = $A.get("e.c:ApprovalHistory_evt");

        var recordId = component.get("v.recordId");

        action.setParams({
            "idTargetObject" : component.get("v.recordId"),
            "sActionName"    : component.get("v.sActionName"),
            "sComments"      : sComments,
            "idAssignee"     : idAssignee
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            console.log("state : " + state);
            if(state === "SUCCESS") {
                var sReturnValue    = response.getReturnValue();
                var listReturnValue = sReturnValue.split("/");

                // Toast message
                this.showToast(listReturnValue[0], listReturnValue[1]);

                if(listReturnValue[0] === "success") {
                    this.doResetCommentAttribute(component);

                    // window.location.href = "/" + recordId;
                    $A.get('e.force:refreshView').fire();

                    //  cmpEvent.setParams({
                    //     "listApprover" : listApprover,
                    //     "listAppName"  : listAppName,
                    //     "sPendingUser" : mapReturnValue["sPendingUser"]
                    // });
                    // cmpEvent.fire();
                    // $A.get('e.force:refreshView').fire();
                }
            } else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }

            component.set("v.bIsLoading", false);
        });

        $A.enqueueAction(action);
    },

    doResetCommentAttribute : function(component) {
        component.set("v.bIsOpenComment", false);
        component.set("v.bIsShowLookup" , false);
        component.set("v.sActionName"   , "");
        component.set("v.sModalTitle"   , "");
    },

    doCreateConfirmComponent : function(component, param) {
        $A.createComponent(
            "c:CommonConfirm",
            {
                "sHeader"       : param.sHeader,
                "sContent"      : param.sContent,
                "sConfirmBtn"   : param.sConfirmBtn,
                "sCancelBtn"    : param.sCancelBtn,
                "confirmAction" : param.confirmAction
            },
            function(cCommonConfirm, status, errorMessage) {
                if(status === "SUCCESS") {
                    // callback action
                    component.set("v.CommonConfirm", cCommonConfirm);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }   
        );
    },

    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");

        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });

        evt.fire();
    },
})