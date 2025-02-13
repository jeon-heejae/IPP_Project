({
	init : function(component, event, helper) {
        console.log('COME HERE DATA');
        var recordId = component.get("v.recordId");
        console.log('recordId:::::' + recordId);
        //var action = component.get("c.doInit");
        //action.setParams({ recordId : component.get("v.recordId") });
        var action = component.get("c.doInit");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("state:"+state);
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log("getReturnValue:"+JSON.stringify(returnValue));
                const jsonValue = JSON.stringify(returnValue);
                const withStrings = JSON.parse(jsonValue, (key, val) => (
                    typeof val !== 'object' && val !== null ? String(val) : val
                ));
             // 데이터 테이블에서 아이콘 보여주기(현재 체크박스)추가 19.07.31
                console.log('wwithStrings');
                console.log(withStrings);


             // 체크박스 종료
                component.set("v.listWrapObject", withStrings);
            }
            // 07.12 오후 추가
            else if(state === "ERROR") {
                let errors = response.getError();
                let message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                console.error(message);
            }
        });
        $A.enqueueAction(action);
    }

})