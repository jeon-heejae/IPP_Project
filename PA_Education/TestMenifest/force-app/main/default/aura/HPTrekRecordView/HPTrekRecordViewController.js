/**
 * ==================================================================================
 * File Name         : HPTrekRecordViewController.js
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
    init: function(component, event, helper) {
        let tableHeaders = [
            {type: "STRING", fieldName: 'IndexNumber', label: 'No.'},
            {type: "STRING", fieldName: 'AccountName', label: 'Client'},
            {type: "STRING", fieldName: 'ProjectName', label: 'Project'},
            {type: "STRING", fieldName: 'StartYear', label: 'Year'},
            {type: "STRING", fieldName: 'ApproachSolution', label: 'Approach Solution'},
            {type: "STRING", fieldName: 'Challenge', label: 'Challenge'},
            {type: "STRING", fieldName: 'OurApproach', label: 'Our Approach'}
        ];
        component.set("v.tableHeaders", tableHeaders);
        helper.doSearchTrekRecords(component);
    },

    fnRenderPage : function(component, event, helper) {
        component.set("v.showSpinner", true);
        console.log("showSpinner true : " + component.get("v.showSpinner"));

        setTimeout(function() {
            helper.doRenderPage(component);
        }, 1);
    },

    showRecordModal: function (component, event, helper) {
        helper.getRecordById(component, event.currentTarget.id);
        $A.util.addClass(component.find("modal"), "active");
    },

    hideRecordModal: function (component, event) {
        if (event.target == event.currentTarget) {
            $A.util.removeClass(component.find("modal"), "active");
        }
    }
});