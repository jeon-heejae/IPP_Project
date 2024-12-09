({
    fnInit: function(component, event, helper) {
        console.log('helper init');

        //로그인 유저 체크
        var action = component.get("c.getUserRoles");
        action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            var result = response.getReturnValue();
            component.set("v.isRole", result.isMainRole);
            component.set("v.isCheck", result.isCheck);
            component.set("v.isMentor", result.isMentor);

            if (result.isMainRole) { //CEO 또는 Business ManageMent인 경우
                helper.getData(component);
            } else if (result.isCheck) { //신입인 경우
                helper.loadEducation(component);
            } else if (result.isMentor) { //멘토인 경우
                helper.loadMentee(component);
            }
        } else {
            console.log("Error: ", response.getError());
        }
    });
    $A.enqueueAction(action);
    },
    
    handleSort1: function(component, event, helper) {

        console.log('currentSortedBy: '+component.get("v.sortedBy"));
        console.log('currentSortDirection: '+component.get("v.sortDirection"));
         
        
        // 두 개의 테이블 데이터를 함께 정렬
        helper.dataSort(component, event, helper);
    }
})
