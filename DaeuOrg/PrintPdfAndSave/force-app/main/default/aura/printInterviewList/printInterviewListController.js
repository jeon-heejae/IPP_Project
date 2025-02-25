({
    fnInit: function(component, event, helper) {
        var listSelectId = component.get("v.listSelectId");
        console.log("doInit listSelectId: " + listSelectId);

        // 대괄호와 따옴표 제거: split과 join 사용
        if (listSelectId.length > 2) { //아무것도 선택하지 않았을 때 길이:2
            listSelectId = listSelectId.split('[').join('').split(']').join('').split('"').join('');
            console.log("doInit listSelectId (Processed): " + listSelectId);

            helper.checkRecordType(component, listSelectId);
        }
        else{
            helper.showToast('error','면담일지를 선택해주세요');
            window.history.back(); // 브라우저 히스토리에서 이전 페이지로 이동
        } 
    },

    fnCancel: function (component, event, helper) {
         window.history.back(); // 브라우저 히스토리에서 이전 페이지로 이동
    },

    fnSave: function (component, event, helper) {
        console.log("Save 버튼 눌림");
        // Save 버튼 클릭 시 PDF 다운로드를 위한 Action 호출
         helper.saveAction(component, event, helper);
    }
})