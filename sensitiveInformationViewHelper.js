({
    getRecordData: function(component) { //초기에 정보들 불러오기
        var action = component.get("c.getEmpInfo");
        action.setParams({ recordId: component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var employeeData = response.getReturnValue();
 
                if (employeeData) {
                    component.set("v.objEmpOriginal", employeeData);
                    component.set("v.objEmpNew", JSON.parse(JSON.stringify(employeeData))); // objEmpNew에 값 복사
                    console.log('gender: '+ component.get("v.objEmpOriginal.Gender__c"));
                } else {
                    this.showToast(component, "error", "데이터를 가져오는 데 실패했습니다.");
                }
            }
        });
 
        $A.enqueueAction(action);
    },
    getPicklistOptions: function(component, event, helper) { //picklist 값들 불러오기
        var action = component.get("c.getPicklistValues");
 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var picklistMap = response.getReturnValue();
 
                var genderOptions = picklistMap['Gender__c'];
                var militaryServiceDivOptions = picklistMap['MilitaryServiceDiv__c'];
                var militaryTypeOptions = picklistMap['MilitaryType__c'];
 
                var genderOptionsParsed = genderOptions.map(function(option) {
                    var parts = option.split(':');
                    console.log('parts :: ' + parts);
                    return { label: parts[0], value: parts[1] };
                });
 
                var militaryServiceDivOptionsParsed = militaryServiceDivOptions.map(function(option) {
                    var parts = option.split(':');
                    console.log('parts :: ' + parts);
                    return { label: parts[0], value: parts[1] };
                });
 
                var militaryTypeOptionsParsed = militaryTypeOptions.map(function(option) {
                    var parts = option.split(':');
                    console.log('parts :: ' + parts);
                    return { label: parts[0], value: parts[1] };
                });
 
                component.set("v.genderOptions", genderOptionsParsed);
                component.set("v.militaryServiceDivOptions", militaryServiceDivOptionsParsed);
                component.set("v.militaryTypeOptions", militaryTypeOptionsParsed);
               
                // 할당 및 로그로 디버깅
                component.set("v.genderOptions", genderOptionsParsed);
                console.log('Parsed Gender Options:', genderOptionsParsed);
                console.log('Current Gender Value:', component.get("v.objEmpNew.Gender__c"));
 
                // 비교 검증
                if (!genderOptionsParsed.find(opt => opt.value === component.get("v.objEmpNew.Gender__c"))) {
                    console.error("Current Gender Value does not match any option in genderOptionsParsed.");
                }
   
                   
 
            } else {
                console.log('Picklist 로드 오류' + response.getError());
            }
        });
 
        $A.enqueueAction(action);
   
    },
 
    updateRecordData: function(component) { //정보 데이터베이스에 저장
        var action = component.get("c.updateEmpInfo"); // 저장을 처리할 Apex 메서드
       
        action.setParams({ employee: component.get("v.objEmpNew") });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isUpdate = response.getReturnValue();
                if (isUpdate) {
                    // 저장 후 objEmpOriginal을 objEmpNew로 갱신하고 편집 모드를 종료
                    component.set("v.objEmpOriginal", JSON.parse(JSON.stringify(component.get("v.objEmpNew"))));
                    component.set("v.isEditMode", false);
                    console.log('gender: ' + component.get("v.objEmpOriginal.Gender__c"));
                } else {
                    this.showToast(component, "error", "데이터 저장에 실패했습니다1.");
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors.length > 0) {
                    var errorMessage = errors[0].message || '알 수 없는 오류가 발생했습니다.';
                    this.showToast(component, "error", errorMessage);
                } else {
                    this.showToast(component, "error", "데이터 저장에 실패했습니다2.");
                }
            }
        });
       
        $A.enqueueAction(action);
    },
   
    cancelEdit: function (component) {
        // 편집 내용을 취소하고 objEmpNew 초기화 및 편집 모드를 종료
        component.set("v.objEmpNew", JSON.parse(JSON.stringify(component.get("v.objEmpOriginal")))); // objEmpNew 초기화
        component.set("v.isEditMode", false); // 편집 모드 종료
    },
 
    showToast: function(component, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: message
        });
        toastEvent.fire();
    }
})