({
    doInit: function(component, event, helper) {
        var listSelectId = component.get("v.listSelectId");
        console.log("doInit listSelectId: " + listSelectId);
        
         // 대괄호와 따옴표 제거: split과 join 사용
         if (listSelectId) {
            listSelectId = listSelectId.split('[').join('').split(']').join('').split('"').join('');
        }
        
        console.log("doInit listSelectId (Processed): " + listSelectId);
        //helper.getData(listSelectId);

        // URL 생성
        var vfPageUrl = "/apex/printTestPdf?recordId=" + encodeURIComponent(listSelectId);
        console.log('VF Page URL: ' + vfPageUrl);

        // URL 설정
        component.set("v.vfPageUrl", vfPageUrl);
    },
    fnCancel: function (component, event, helper) {
        window.history.back(); // 브라우저 히스토리에서 이전 페이지로 이동
        //component.set("v.isModalOpen", false);
    },

    fnSave: function (component, event, helper) {
        console.log("저장 버튼 눌림");
        //저장버튼 누를 시, 액션
        helper.saveAction(component, event, helper);
    }
})