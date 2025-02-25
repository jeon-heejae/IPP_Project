({
    fnInit : function(component, event, helper) {
        var listSelectId = component.get("v.listSelectId");
        console.log("doInit listSelectId: " + listSelectId);
        console.log(typeof listSelectId);  //"String"
        console.log(listSelectId.length); 

        helper.refreshBudget(component,event,helper,listSelectId);
        // 대괄호와 따옴표 제거: split과 join 사용
        // if (listSelectId.length > 2) { //아무것도 선택하지 않았을 때 길이:2
        //     listSelectId = listSelectId.split('[').join('').split(']').join('').split('"').join('');
        //     console.log("doInit listSelectId (Processed): " + listSelectId);

        //     helper.refreshBudget(component,event,helper,listSelectId);
        // }
        // else{
        //     helper.showToast('Error','프로젝트를 하나 이상 선택해주세요','Error');
        //     window.history.back(); // 브라우저 히스토리에서 이전 페이지로 이동
        // }
    }
})