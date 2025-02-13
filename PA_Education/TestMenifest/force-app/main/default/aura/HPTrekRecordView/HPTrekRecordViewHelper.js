/**
 * ==================================================================================
 * File Name         : HPTrekRecordViewHelper.js
 * Author            : Changjoo.Sohn
 * Group             : Daeu Nextier
 * Description       :
 * Modification Logs
 * ==================================================================================
 *   Ver     Date          Author          Modification
 * ==================================================================================
 *   1.0   2022-01-18     Changjoo.Sohn   Initial Version
 **/
({
    doSearchTrekRecords: function(component) {
        var action = component.get("c.doSearchTrekRecords");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try{
                    var returnValue = response.getReturnValue();
                    if(returnValue) {
                        console.log("Return Value", JSON.stringify(returnValue));
                        let listTrekRecords = returnValue;
                        var countPerPage = component.get("v.countPerPage");
                        component.set("v.maxPage", Math.floor((listTrekRecords.length + (countPerPage - 1)) / countPerPage));
                        var pageNumber = component.get("v.pageNumber");
                        var pageRecords = listTrekRecords.slice((pageNumber - 1) * countPerPage, pageNumber * countPerPage);
                        component.set("v.pageRecords", pageRecords);
                    }
                }catch(e){
                    component.set("v.isReady", true);
                    console.log('error : ' + e.message);
                }
            } else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        this.showToast("error", errors[0].message);
                    }
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    getRecordById: function (component, id) {
        var action = component.get("c.getRecordById");
        action.setParams({ recordId: id });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                try {
                    var returnValue = response.getReturnValue();
                    console.log('trekRecordItem', returnValue);
                    if (returnValue) {
                        component.set("v.trekRecordItem", returnValue);
                    }
                } catch (e) {
                    console.log('error: ' + e.message);
                }
            }
        });

        $A.enqueueAction(action);
    },

    /**
     * 페이징 처리
     * @param {*} component
     */
    doRenderPage : function(component) {
        var pageNumber = component.get("v.pageNumber");
        var countPerPage = component.get("v.countPerPage");
        var listWrapIncentiveRate = component.get("v.listWrapIncentiveRate");

        var pageRecords = listWrapIncentiveRate.slice((pageNumber - 1) * countPerPage, pageNumber * countPerPage);

        component.set("v.pageRecords", pageRecords);
        component.set("v.showSpinner", false);
    },

    /**
     * @description 토스트 메세지 출력 이벤트 발생
     * @param {string} type 메세지 유형 (success, error, info, warning, other)
     * @param {string} message 토스트에 보여질 메세지
     */
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