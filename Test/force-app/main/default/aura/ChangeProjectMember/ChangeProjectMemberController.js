({
    fnInit : function(component, event, helper) {
        helper.checkProjectStatus(component);
    },
    
    handleMemberChange : function(component, event, helper) {
        var selectedMemberId = event.getParam("value");
        if (selectedMemberId) {
            helper.checkMemberPosition(component, selectedMemberId);
        } else {
            component.set("v.ShowEmployeeOption", false);
        }
    },
    
    handleEmployeeChange : function(component, event, helper) {
        var selectedEmployeeId = event.getParam("value");
        component.set("v.SelectedEmployee", selectedEmployeeId);
    },
    
    fnChange : function(component, event, helper) {
        if(component.get("v.ChangedMember")==""){
            helper.showToast('Error','프로젝트 멤버를 선택하세요.');
        }
        else if (component.get("v.SelectedEmployee")=="") {
           helper.showToast('Error','교체하고 싶은 직원을 선택하세요.');
            
        }
        else{
            if(confirm('정말로 프로젝트 멤버를 교체 하시겠습니까?')){
                helper.ReplaceProjectMember(component);
            }
        }
    },
    
    fnCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})