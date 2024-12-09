({
    getData : function(component) {
        var action = component.get("c.getEmployeeSecret");
        
        // action.setParams({
        //     "recordId": component.get("v.recordId")
        // });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                console.log('result: '+result);
                component.set("v.objEmployee",result);
            } else {
                let errors = response.getError();
                let message = "알 수 없는 오류가 발생했습니다.";
                if (errors && errors[0] && errors[0].message) {
                    message = errors[0].message;
                }
                console.log('error: '+message);
            }
        });

        $A.enqueueAction(action);
    },
    updateRecordData: function(component) {
        var action = component.get("c.updateEmpInfo"); // 저장을 처리할 Apex 메서드
        action.setParams({ employee: component.get("v.objEmployee") });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isUpdate=response.getReturnValue();
                if(isUpdate){
                    // 저장 후 objEmpOriginal을 objEmpNew로 갱신하고 편집 모드를 종료
                    component.set("v.objEmpOriginal", JSON.parse(JSON.stringify(component.get("v.objEmpNew"))));
                    component.set("v.isEditMode", false);
                }
                else{
                    this.showToast(component,"error","update 실패")
                }
            } else {
                this.showToast(component, "error", "데이터 저장을 실패했습니다.");
            }
        });

        $A.enqueueAction(action);
    }
})