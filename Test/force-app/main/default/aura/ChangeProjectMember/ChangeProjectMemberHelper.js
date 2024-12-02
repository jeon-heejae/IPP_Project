({
    checkProjectStatus : function(component) {
        var action = component.get("c.isProjectActive");
        action.setParams({
            projectId: component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isActive = response.getReturnValue();
                if (!isActive) {
                    this.showToast('Error', '종료된 프로젝트의 멤버는 변경할 수 없습니다.');
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    console.log("진입");
                    this.GetProjectMembers(component);
                }
            } else {
                console.error('Error checking project status');
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        
        $A.enqueueAction(action);
    },
    GetProjectMembers : function(component) {
        var action = component.get("c.GetProjectMembers"); 
        console.log(component.get("v.recordId"));
        action.setParams({
            projectId: component.get("v.recordId") //recordId값 넘기기
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var members = response.getReturnValue();
                console.log(members);
                var mapMembers = members.map(function(member) { //(이름,id)가지는 map으로
                    return { label: member.Employee__r.EmployeeName__c, value: member.Id };
                });
                console.log(mapMembers);
                component.set("v.ListMember", mapMembers);
            } else {
                console.error('프로젝트 멤버 불러오기 에러');
            }
        });
        
        $A.enqueueAction(action);
    },
    
    checkMemberPosition : function(component, memberId) {
        var action = component.get("c.GetMemberPosition");
        action.setParams({
            MemberId: memberId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var position = response.getReturnValue();
                if (position === 'PM') {
                    this.showToast('Error', 'PM은 교체될 수 없습니다.');
                    component.set("v.ChangedMember", ""); 
                    component.set("v.ShowEmployeeOption", false);
                } else {
                    
                    this.GetAvailableEmployees(component);
                }
            } else {
                console.error('포지션 체크 에러');
            }
        });
        
        $A.enqueueAction(action);
    },
    
    GetAvailableEmployees : function(component) {
        var action = component.get("c.GetAvailableEmployees");
        action.setParams({
            projectId: component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var employees = response.getReturnValue();
                var mapEmployee = employees.map(function(employees) {
                    return { label: employees.EmployeeName__c, value: employees.Id };
                });
                component.set("v.ListEmployee", mapEmployee);
                component.set("v.ShowEmployeeOption", true); //pm아니므로 true로
            } else {
                console.error('교체 가능 멤버 체크 에러');
            }
        });
        
        $A.enqueueAction(action);
    },
    
    ReplaceProjectMember : function(component) {
        
        var action = component.get("c.ReplaceProjectMember");
        action.setParams({
            projectMemberId: component.get("v.ChangedMember"),
            newEmployeeId: component.get("v.SelectedEmployee")
        });
        
       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.showToast('Success', '프로젝트 멤버가 교체되었습니다.');
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            } else {
                this.showToast('Error', '프로젝트 멤버 교체에 실패했습니다.');
            }
        });
        
        $A.enqueueAction(action);
    },
    
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