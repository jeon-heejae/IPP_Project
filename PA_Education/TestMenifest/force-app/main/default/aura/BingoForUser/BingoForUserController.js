({
    fnInit : function(cmp, event, helper) {
       helper.getInitData(cmp);
    },
    saveBtnClick : function (cmp, event, helper) {
        var inputBingo = [];
        var inputBingoSet = new Set();
        for(var i=0;i<5;i++) {
            for(var j=0;j<5;j++) {
                var value = cmp.find("bingoCellParticipant"+j+i).get("v.value");
                //공백 에러
                if(value == "" || value == null) {
                    helper.showToast("error", "모든 빈칸을 채워주세요.");
                    return;
                }
                inputBingo[i*5+j] = value;
                inputBingoSet.add(cmp.find("bingoCellParticipant"+j+i).get("v.value"));
                console.log('bingoCellParticipant : '+inputBingo[i*5+j]);
            }
        }
        //중복 에러
        if(inputBingoSet.size != inputBingo.length) {
            helper.showToast("error", "중복된 빙고가 존재합니다.");
            return;
        }

        helper.saveData(cmp, inputBingo);
    },
    randomBtnClick : function (cmp, event, helper) {
        helper.randomData(cmp);
    },

    //Drag & Drop
    handleDrag: function (component, event, helper) {
        var memberIndex = event.target.dataset.member;

        var daeuMembers = component.get("v.daeuMembers");
        var draggedMemberId = daeuMembers[memberIndex].Id;
        component.set("v.draggedMemberId", draggedMemberId);
    },
    allowDrop: function (component, event, helper) {
        event.preventDefault();
    },
    handleDrop: function (component, event, helper) {
        event.preventDefault();
        var draggedMemberId = component.get("v.draggedMemberId");
        console.log('get :: '+component.get("v.draggedMemberId"));
        var targetIndex = event.currentTarget.getAttribute("id");
        console.log('targetIndex ::' +targetIndex);
        var targetField = component.find("bingoCellParticipant"+targetIndex);
        if (targetField) {
            targetField.set("v.value", draggedMemberId);
        } else {
            console.error("Target field is undefined.");
        }
    },
    //@@@@@배포시 삭제@@@@@
    allBtnClick : function (cmp, event, helper) {
        helper.randomData2(cmp);
    },
})