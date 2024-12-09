({
    fnInit: function(component,event,helper){
        console.log('helper init');

        //role 체크
        var actionIsCheck=component.get("c.isMainRole");
        actionIsCheck.setCallback(this,function(response){
            var state = response.getState();
            console.log('state: '+state);
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                console.log('result: '+result);
                component.set("v.isRole",result);
                if(result==true) {
                    //모든 신입들것을 볼수 있도록
                    helper.loadAllEmployee(component);
                    return;
                }
            } else {
                let errors = response.getError();
                let message = "알 수 없는 오류가 발생했습니다.";
                if (errors && errors[0] && errors[0].message) {
                    message = errors[0].message;
                }
                console.log('error: '+message);
            }
        });
        $A.enqueueAction(actionIsCheck);


        var actionIsCheck=component.get("c.isCheck");
        actionIsCheck.setCallback(this,function(response){
            var state = response.getState();
            console.log('state: '+state);
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                console.log('result: '+result);
                component.set("v.isCheck",result);
                if(result==true) {
                    helper.loadEducation(component);
                }
            } else {
                let errors = response.getError();
                let message = "알 수 없는 오류가 발생했습니다.";
                if (errors && errors[0] && errors[0].message) {
                    message = errors[0].message;
                }
                console.log('error: '+message);
            }
        });
        $A.enqueueAction(actionIsCheck);
    },
  
    sortTable: function(component, event, helper) {
        const field = event.target.getAttribute('data-field');
        const currentDirection = component.get("v.sortDirection");
        const newDirection = currentDirection === 'asc' ? 'desc' : 'asc';
        
        component.set("v.sortField", field);
        component.set("v.sortDirection", newDirection);

        const objRemainEdu = component.get("v.objRemainEdu");
        const sortedRemainEdu = helper.sortData(objRemainEdu, field, newDirection);
        component.set("v.objRemainEdu", sortedRemainEdu);

        const objEdu = component.get("v.objEdu");
        const sortedEdu = helper.sortData(objEdu, field, newDirection);
        component.set("v.objEdu", sortedEdu);
    
    }
    
    
})