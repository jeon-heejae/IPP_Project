/**
 * Created by Kwanwoo.Jeon on 2024-01-31.
 */

({
    getApprovalLines : function(component) {
        var action   = component.get("c.getApprovalLines");
        var recordId = component.get("v.recordId");
        console.log('recordId', component.get("v.recordId"));

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set("v.mapReturnValue", returnValue);
                component.set("v.listLabel", 	  returnValue["listLabel"]);
                component.set("v.objUser",  	  returnValue["objUser"]);
//                component.set("v.iLineLimit",     returnValue["iLineLimit"]);
//                component.set("v.iLineLimit",     4);
//                component.set("v.iApproverLimit", returnValue["iApproverLimit"]);
//                component.set('v.iApproverLimit', 4);
                component.set("v.isNew",          returnValue["listLabel"].length < 4 ? true : false);
            }
        });

        $A.enqueueAction(action);
    },

    doSubmit : function(component,event, helper) {
        var sComments = component.find("comments").get("v.value");
        var listLabel = component.get("v.listLabelClicked");
        var recordId = component.get("v.recordId");
        var action    = component.get("c.doSubmit");
        console.log(recordId);


        action.setParams({
            'sObjectName' 		: component.get("v.sObjectName"),
            'sComments'    		: sComments,
            'sHistoryRecordId'  : recordId,
            'objListUser'   	: listLabel.userDatas
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                var values = returnValue.split('/');

                $A.get('e.force:refreshView').fire();
                this.showToast(values[0], values[1]);

                if(values[0] == "success"){
                    this.doNavigateSObject(values[2]);
                }
            }
        });

        $A.enqueueAction(action);
        /*scroll 방지 해제*/
        document.body.style.overflow="auto";
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

    doNavigateSObject : function(recordId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            recordId : recordId
        });
        navEvt.fire();
    },
})