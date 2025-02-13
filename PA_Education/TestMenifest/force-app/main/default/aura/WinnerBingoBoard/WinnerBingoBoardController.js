/**
 * Created by jihwa on 2023-11-23.
 */

({
    fnInit : function(cmp, event, helper) {
       var bingoWinner = cmp.get("v.bingoWinnerName");
       helper.getInitData(cmp,bingoWinner);
    },
    closeBingoModal: function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        cmp.set("v.bingoModalVisible", false);
    }
});