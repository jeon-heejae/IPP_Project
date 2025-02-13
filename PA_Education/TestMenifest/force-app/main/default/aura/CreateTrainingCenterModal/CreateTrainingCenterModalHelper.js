/**
 * Created by Kwanwoo.Jeon on 2024-02-20.
 */

({
    gfnSave: function(component, event){
        var action = component.get("c.modalSave");
        action.setParams({
           mapTrainingCenter : component.get("v.mapTrainingCenter")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var returnVal = response.getReturnValue();
                if(returnVal.status == "SUCCESS") {
                    this.gfnShowToast('SUCCESS', '수련원 신청을 완료하였습니다.');
                    component.set('v.showModal', false);
                }else{
                    this.gfnShowToast('ERROR', returnVal.msg);
                }
            }else{
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.gfnShowToast('ERROR', errors[0].message);
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    this.gfnShowToast('ERROR', "Unknown error");
                    console.log("Unknown error");
                }
            }
            component.set('v.showSpinner', false);

        });
        $A.enqueueAction(action);
    },
    gfnShowToast  : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });

        evt.fire();
    },
});