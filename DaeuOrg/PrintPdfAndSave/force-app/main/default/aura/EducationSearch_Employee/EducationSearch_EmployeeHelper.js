({
    loadEducation: function(component){
        console.log('helper start');

        var actionGetName=component.get("c.getName");
        actionGetName.setParams({ recordId: component.get("v.recordId") })
        actionGetName.setCallback(this,function(response){
            var state = response.getState();
            console.log('state: '+state);
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                console.log('result: '+result);
                component.set("v.objName",result);
            } else {
                let errors = response.getError();
                let message = "알 수 없는 오류가 발생했습니다.";
                if (errors && errors[0] && errors[0].message) {
                    message = errors[0].message;
                }
                console.log('error: '+message);
            }
        });
        var actionRemain=component.get("c.getRemainEducation");
        //actionRemain.setParams({recordId: component.get("v.recordId")});
        
        actionRemain.setCallback(this,function(response){
            var state = response.getState();
            console.log('state: '+state);
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                console.log('result: '+result);
                component.set("v.objRemainEdu",result);
                console.log('v.objRemainEdu: '+JSON.stringify(component.get("v.objRemainEdu")));
            } else {
                let errors = response.getError();
                let message = "알 수 없는 오류가 발생했습니다.";
                if (errors && errors[0] && errors[0].message) {
                    message = errors[0].message;
                }
                console.log('error: '+message);
            }
        });

        var actionProgress=component.get("c.getInProgressEducation");
        //actionProgress.setParams({recordId: component.get("v.recordId")});

        actionProgress.setCallback(this,function(response){
            var state = response.getState();
            console.log('state: '+state);
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                console.log('result: '+result);
                component.set("v.objEdu",result);
                console.log('v.objEdu: '+JSON.stringify(component.get("v.objEdu")));
            } else {
                let errors = response.getError();
                let message = "알 수 없는 오류가 발생했습니다.";
                if (errors && errors[0] && errors[0].message) {
                    message = errors[0].message;
                }
                console.log('error: '+message);
            }
        });
        
        $A.enqueueAction(actionGetName);
        $A.enqueueAction(actionRemain);
        $A.enqueueAction(actionProgress);
    }
,
    isCheck:function(component){
        var actionIsCheck=component.get("c.isCheck");
        actionIsCheck.setParams({ recordId: component.get("v.recordId") });
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
                    var errors = response.getError();
                    var message = "알 수 없는 오류가 발생했습니다.";
                    if (errors && errors[0] && errors[0].message) {
                        message = errors[0].message;
                    }
                    console.log('error: '+message);
                }
            });
            $A.enqueueAction(actionIsCheck);
    }
})