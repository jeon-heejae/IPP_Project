({
    fnInit : function(component, event, helper) {
        helper.getListApprovalHistory(component);
    },

    fnGoToRelatedView : function(component, event, helper) {
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId"  : "ProcessSteps",
            "parentRecordId" : component.get("v.recordId")
        });
        relatedListEvent.fire();  
    },

    fnDoActionApprove : function(component, event, helper) {
        var sModalTitle = "";
        var sActionName = "";
        var recordId = component.get("v.recordId");

        if(event.getParam("value")) sActionName = event.getParam("value");
        else sActionName = event.getSource().get("v.name");

        switch(sActionName) {
            case "Approve" :
                sModalTitle = $A.get("$Label.c.Approval_Approve");
                break;

            case "Reject" : 
                sModalTitle = $A.get("$Label.c.Approval_Reject");
                break;

            case "Reassign" :
                sModalTitle = $A.get("$Label.c.Approval_Reassign");
                component.set("v.bIsShowLookup", true);
                break;

            case "Removed" : 
                sModalTitle = $A.get("$Label.c.Approval_Recall");
                break;
        }

        component.set("v.sActionName"   , sActionName);
        component.set("v.sModalTitle"   , sModalTitle);
        component.set("v.bIsOpenComment", true);

    },

    fnConfirm : function(component, event, helper) {
        component.set("v.bIsLoading", true);

        var idAssignee;
        var userLookupElem = component.find("UserLookup");

        var bIsValid = true;

        if(userLookupElem && userLookupElem.selectItem("sId")) {
            idAssignee = userLookupElem.selectItem("sId");
        } else {
            if(userLookupElem) {
                component.set("v.bIsLoading", false);

                userLookupElem.errorCheck('이 필드를 완료하십시오.');

                bIsValid = false;
            } 

            idAssignee = null;
        }

        console.log("idAssignee : " + idAssignee);
        if(bIsValid) helper.doProcessWorkitemRequest(component, idAssignee);
    },

    fnCancel : function(component, event, helper) {
        helper.doResetCommentAttribute(component);
    },

    fnApprovalLine : function(component, event, helper) {
        var objName = component.get("v.sObjectName");
        console.log(objName +' / '+ component.get("v.recordId")  );

        $A.createComponent(
            "c:ApprovalLines",
            {
                'sRecordId'              : component.get("v.recordId") ,
                'sObjectName'      : objName,
                'bHistory'         : true,
                'userId'           : component.get("v.userId"),
                'sHistoryRecordId' : component.get("v.recordId")
            }, 

            function(cApprovalLines, status, errorMessage) {
                if(status === "SUCCESS") {
                    component.set("v.ApprovalLines", cApprovalLines),
                    document.body.style.overflow = "hidden";
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error : " + errorMessage);
                }
            }
        );
    },


})