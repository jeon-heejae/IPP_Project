({
    getResult: function(component) {
        return new Promise((resolve, reject) => {
            var recordId = component.get("v.recordId");
            console.log('recordId: ', recordId);
            var action = component.get("c.getObject");
            action.setParams({
                OfflineClassId: recordId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var mapResult = response.getReturnValue();
                    console.log('mapResult: ', mapResult);
    
                    // Email 리스트 설정
                    component.set("v.listParentEmail", mapResult.Email);
                    console.log('v.listParentEmail: ', component.get('v.listParentEmail'));
    
                    // Name (학생 정보) 리스트 설정
                    component.set("v.listStudentName", mapResult.Name);
                    console.log('v.listStudentName: ', component.get('v.listStudentName'));
    
                    // Change (레벨 변경 정보) 리스트 설정
                    component.set("v.listLevelChanges", mapResult.Change);
                    console.log('v.listLevelChanges: ', component.get('v.listLevelChanges'));
    
                    resolve();
                } else {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.error("Error message: " + errors[0].message);
                        }
                    } else {
                        console.error("Unknown error");
                    }
                    this.showToast("error", "Failed to call getParentEmail");
                    reject("Failed to get email");
                }
            });
            $A.enqueueAction(action);
        });
    },

    sendEmailWithAttachment: function(component) {
        return new Promise((resolve, reject) => {
            var action = component.get("c.sendEmailWithAttachment");
            action.setParams({
                recordId: component.get("v.recordId"),
                toAddress: component.get("v.listParentEmail"),
                students: component.get("v.listStudentName"),
                levelChanges: component.get("v.listLevelChanges")
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    this.showToast("success", "이메일이 성공적으로 전송되었습니다.");
                    resolve();
                } else {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.error("Error message: " + errors[0].message);
                        this.showToast("error", "이메일 전송 실패: " + errors[0].message);
                    } else {
                        console.error("Unknown error");
                        this.showToast("error", "이메일 전송 중 알 수 없는 오류가 발생했습니다.");
                    }
                    reject("Failed to send emails");
                }
            });
            
            $A.enqueueAction(action);
        });
    },


    saveAction: function(component, event) {
        return new Promise((resolve, reject) => {
            var action = component.get('c.doSavePdf');
            action.setParams({
                'strRecordId': component.get('v.recordId')
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('State success');
                    resolve();
                } else {
                    console.log('state error');
                    reject("Failed to save PDF");
                }
            });
            $A.enqueueAction(action);
        });
    },
    
    //토스트 메시지를 사용할 helper에 이 함수를 꼭 추가해주세요
    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key : "info_alt"
            , type : type
            , message : message
        });
        evt.fire();
    }
})
