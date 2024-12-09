({
   fnInit : function(component, event, helper) {

    // var actionIsCheck=component.get("c.isCheck");
    // actionIsCheck.setParams({
    //     "recordId": component.get("v.recordId")
    // });
    // actionIsCheck.setCallback(this,function(response){
    //     var state = response.getState();
    //     console.log('state: '+state);
    //     if (state === "SUCCESS") {
    //         var result=response.getReturnValue();
    //         console.log('result: '+result);
    //         component.set("v.isCheck",result);
    //         if(result==true) {
    //             helper.getData(component);
    //         }
    //     } else {
    //         let errors = response.getError();
    //         let message = "알 수 없는 오류가 발생했습니다.";
    //         if (errors && errors[0] && errors[0].message) {
    //             message = errors[0].message;
    //         }
    //         console.log('error: '+message);
    //     }
    // });
    // $A.enqueueAction(actionIsCheck);
    var action = component.get("c.getPicklistValues");
        action.setParams({
            objectName: "Employee__c",
            fieldName: "Gender__c"
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.genderOptions", response.getReturnValue());
            } else {
                console.error("Failed to load picklist values:", response.getError());
            }
        });

        $A.enqueueAction(action);

    helper.getData(component);

    },

    handleSave:function(component,event,helper){
        helper.updateRecordData(component);
        //component.set("v.isEditMode",false);
    }
})