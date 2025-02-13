/**
 * Created by yeonlim on 2023-12-15.
 */

({
    doApproval : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.doApproval");
        var textarea = document.getElementById('comment');
        var comment = textarea.value;

        action.setParams({
            "recordId" : component.get('v.recordId'),
            "comment" : comment
        });

        action.setCallback(this, function(response) {
            this.hideSpinner(component);
            var state = response.getState();

            if (state === "SUCCESS") {
                var returnVal = response.getReturnValue();
                if (returnVal.strStatus == 'SUCCESS') {
                    this.showToast(returnVal.strStatus, returnVal.strMessage);
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                } else {
                    this.showToast(returnVal.strStatus, returnVal.strMessage);
                }

            } else {
                this.showToast('ERROR', returnVal.strMessage);
            }

        });

        $A.enqueueAction(action);
    },

    showSpinner: function (component) {
        component.set('v.isShowSpinner', true);
    },

    hideSpinner: function (component) {
        component.set('v.isShowSpinner', false);
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
});