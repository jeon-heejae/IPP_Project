/**
 * Created by smyan on 2021-01-29.
 */

({
    fnInit : function(cmp, event, helper) {
        //console.log(">>>>" + cmp.get("v.contentDocumentId"));
        helper.getPdfData(cmp, cmp.get("v.contentDocumentId"));
    },
});