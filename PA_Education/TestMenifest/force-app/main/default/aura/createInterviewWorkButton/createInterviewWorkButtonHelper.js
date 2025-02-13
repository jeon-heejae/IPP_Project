({
    // checkInterviewButtonStatus: function(component, event, helper) {
    //     var action = component.get("c.isInterviewNotesDisabled");  // APEX 메서드 호출
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         console.log('Apex response state: ' + state);  // Apex 응답 상태 확인

    //         if (state === "SUCCESS") {
    //             var isDisabled = response.getReturnValue();
    //             console.log('Apex response: ' + isDisabled);  // Apex에서 반환된 값 확인
    //             component.set("v.isInterviewDisabled", isDisabled);
    //         } else if (state === "ERROR") {
    //             var errors = response.getError();
    //             console.error("Error details: ", errors);
    //             if (errors && errors.length > 0) {
    //                 console.error("Error message: " + errors[0].message);
    //             } else {
    //                 console.error("Unknown error occurred.");
    //             }
    //         }
    //     });

    //     $A.enqueueAction(action);  // Apex 메서드 호출
    // }
})