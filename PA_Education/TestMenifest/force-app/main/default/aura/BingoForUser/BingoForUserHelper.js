({
    getInitData : function(cmp) {
        var actionInitData = cmp.get("c.getInitData");
        var actionInitMemberData = cmp.get("c.getInitMemberData");
        var actionInitImgData = cmp.get("c.getInitImgData");
        actionInitData.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
            console.log('returnValue ::'+ returnValue);
            var returnValue = response.getReturnValue();
            //BingoMember Id값
            var bingoCellParticipant = cmp.get("v.bingoCellParticipant");
            //BingoMember Name값
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
            }
            cmp.set("v.bingoCellParticipant", bingoCellParticipant);
            cmp.set("v.bingoCellParticipantName", bingoCellParticipantName);
            console.log("bingoCellParticipantName ::"+bingoCellParticipantName);

            //actionInitImgData
            actionInitImgData.setParams({
                bingoCellData: bingoCellParticipant
            });
            $A.enqueueAction(actionInitImgData);

            } else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    this.showToast("error", "빙고 정보 조회 실패");
                } else {}
            }
        });
        actionInitMemberData.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                cmp.set("v.daeuMembers", returnValue);

            } else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    this.showToast("error", "임직원 정보 조회 실패");
                } else {}
            }
        });
        actionInitImgData.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                var bingoCellParticipantImg = cmp.get("v.bingoCellParticipantImg");
                var bingoCellParticipant = cmp.get("v.bingoCellParticipant");
                console.log('returnValue :: ');
                console.log(returnValue);
                for (var key in returnValue) {
                    if (returnValue.hasOwnProperty(key)) {
                        console.log('키:', key, ', 값:', returnValue[key]);
                    }
                }

                for (var i = 0; i < bingoCellParticipantImg.length; i++) {
                    var key = bingoCellParticipant[i];
                    if (returnValue[key]) {
                        bingoCellParticipantImg[i] = returnValue[key];
                        console.log('bingoCellParticipant[' + i + ']에 대한 처리:', bingoCellParticipantImg[i]);
                    } else {
                        console.log('bingoCellParticipant[' + i + ']에 대한 값이 없습니다.');
                        bingoCellParticipantImg[i] = "";
                    }
                }
                cmp.set("v.bingoCellParticipantImg", bingoCellParticipantImg);
            } else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    this.showToast("error", "이미지 정보 로드 실패");
                } else {}
            }
        });
        $A.enqueueAction(actionInitData);
        $A.enqueueAction(actionInitMemberData);
    },

	saveData : function(cmp,inputBingo) {
        var action = cmp.get("c.saveData");
        action.setParams({
            bingoCellData: inputBingo
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if(returnValue) {
                    this.showToast("success", "빙고 저장 완료.");
                }
                else {
                    this.showToast("error", "빙고 저장 실패");
                }
            } else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    this.showToast("error", "빙고 저장 실패");
                } else {}
            }
        });
        console.log('inputBingo'+inputBingo);
        $A.enqueueAction(action);
	},
    randomData : function(cmp) {
        var action = cmp.get("c.randomData");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                var bingoCellParticipant = cmp.get("v.bingoCellParticipant");

                for(var i=0;i<25;i++) {
                    console.log('returnValue'+i+'::'+returnValue[i].Id);
                    bingoCellParticipant[i] = returnValue[i].Id;
                }
                this.showToast("success", "빙고 랜덤 완료");
                cmp.set("v.bingoCellParticipant", bingoCellParticipant);
            } else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    this.showToast("error", "빙고 랜덤 실패");
                } else {}
            }
        });
        $A.enqueueAction(action);
	},
	//@@@@@배포시 삭제@@@@@
    randomData2 : function(cmp) {
        var action = cmp.get("c.randomData2");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();

                this.showToast("success", returnValue+"번");
            } else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    this.showToast("error", "실패");
                } else {}
            }
        });
        $A.enqueueAction(action);
	},

    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key : "info_alt"
            , type : type
            , message : message
        });
        evt.fire();
    },
})