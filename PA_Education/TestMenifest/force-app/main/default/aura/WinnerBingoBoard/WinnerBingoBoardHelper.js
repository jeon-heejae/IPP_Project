/**
 * Created by jihwa on 2023-11-23.
 */

({
    getInitData : function(cmp,bingoWinner) {
        var action = cmp.get("c.getInitData");
        action.setParams({
            bingoWinner: bingoWinner
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                var bingoCellParticipant = cmp.get("v.bingoCellParticipant");
                var bingoCellParticipantName = cmp.get("v.bingoCellParticipantName");
                for (var i = 0; i < returnValue.length; i++) {
                    bingoCellParticipant[i] = returnValue[i].BingoMember__c;
                    bingoCellParticipantName[i] = returnValue[i].BingoMember__r.Name;
                    if(returnValue[i].IsChecked__c) {
                        $A.util.addClass(cmp.find("block"+i), 'isChecked');
                    }
                    else {
                        $A.util.removeClass(cmp.find("block"+i), 'isChecked');
                    }
                    cmp.set("v.bingoCellParticipant", bingoCellParticipant);
                    cmp.set("v.bingoCellParticipantName", bingoCellParticipantName);
                    console.log('bingoCellParticipant :: '+bingoCellParticipant);
                    console.log('bingoCellParticipantName :: '+bingoCellParticipantName);
                }

            } else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    this.showToast("error", "임직원 정보 조회 실패");
                } else {}
            }
        });
        $A.enqueueAction(action);
    }

});