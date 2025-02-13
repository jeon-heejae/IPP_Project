({
    /**
     * @description navigate to the clicked record
     */
    doNavigateRecordPage :function(component, calEvent) {
        var strRecordId  = calEvent['id'];
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": strRecordId,
          "slideDevName": "detail"
        });
        navEvt.fire();
    }
})