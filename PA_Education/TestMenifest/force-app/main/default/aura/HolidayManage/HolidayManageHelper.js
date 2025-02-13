({
	getData : function(component) {
    	var action = component.get("c.getData");
    	var showGDC = component.get('v.showGDC');
        action.setParams({
            "pIsChecked" : component.get("v.showRetired"),
        }); 
        /*클래스를 호출해서 메소드 실행*/
        action.setCallback(this, function(response) {        	
        	/* 메소드를 실행한 상태를 반환하는 걸 변수에 담음 */
            var state = response.getState();
            /* 성공 상태이면..값을 리턴할것 */
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();

                let filterValue = []; 
                for (let item of returnValue) { 
                    // 필수 제외 조건
                    if (item.UserName == '경영지원부' || item.UserName == '테스트' || item.UserName == '디지털스퀘어'){
                        continue;
                    // 필수 포함 조건
                    } else if (item.UserName == '하형석'){
                        filterValue.push(item);
                    } else if (item.Department != 'GDC'){
                        filterValue.push(item);
                    } else if (showGDC){
                        filterValue.push(item);
                    }
                }

                // component.set("v.hldChkLst", showGDC? returnValue : returnValue.filter(obj => (obj.Department != 'GDC' )));

                component.set("v.hldChkLst", filterValue);
                console.log("v.hldChkLst2 : ", component.get("v.hldChkLst"));
            }
            component.set('v.toggleSpinner',false);
        });
        $A.enqueueAction(action);		
	},

    doSave : function(component) {
        var action = component.get('c.doSave');
        
        var hldChkLst = component.get('v.hldChkLst');
        console.log('[doSave] hldChkLst : ' + JSON.stringify(hldChkLst));

        var hldLst = [];
        hldChkLst.forEach(function(obj) {
            hldLst.add({'Id' : obj.Id, 'Holiday_JoinDate__c' : obj.JoinDate});
        });

        action.setParams({
            'hldLst' : hldLst
        });
        action.setCallback(this, function(response) {
            var state = response.getState();    
            if(state === 'SUCCESS') {
                var sReturnValue    = response.getReturnValue();
                this.showToast('SUCCESS', sReturnValue);
        		component.set("v.isChanged", false);
                this.getData(component);
            }
            component.set('v.toggleSpinner',false);
        });        
        $A.enqueueAction(action);
    },

    doCreate : function(component) {
        var action = component.get('c.doCreate');
        action.setCallback(this, function(response) {
            var state = response.getState();    
            if(state === 'SUCCESS') {
                var sReturnValue    = response.getReturnValue();
                this.showToast('SUCCESS', sReturnValue);
        		component.set("v.isChanged", false);
                this.getData(component);
            }
            component.set('v.toggleSpinner',false);
        });        
        $A.enqueueAction(action);
    },

    doUpdate : function(component) {
        var action = component.get('c.doUpdate');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var sReturnValue    = response.getReturnValue();
                this.showToast('SUCCESS', sReturnValue);
        		component.set("v.isChanged", false);
                this.getData(component);
            }
            component.set('v.toggleSpinner',false);
        });
        $A.enqueueAction(action);
    },

    doReset : function(component, type) {
        var action = component.get('c.doReset');
        var hldChkLst = this.getCheckedList(component);
        action.setParams({
            'hldLst' : hldChkLst,
            'type' : type
        });
        action.setCallback(this, function(response) {
            var state = response.getState();    
            if(state === 'SUCCESS') {
                var sReturnValue    = response.getReturnValue();
                this.showToast('SUCCESS', sReturnValue);
        		component.set("v.isChanged", false);
                this.getData(component);
        		component.set("v.checked", false);
            }
            component.set('v.toggleSpinner',false);
        });        
        $A.enqueueAction(action);
    },

    doModify : function(component) {
        var action = component.get('c.doModify');
        var modifyDays = component.get("v.modifyDays");
        var reason = component.get("v.reason");
        var hldChkLst = this.getCheckedList(component);
        console.log('hldChkLst : ' ,hldChkLst);
        action.setParams({
            'hldLst' : hldChkLst,
            'addDays' : modifyDays,
            'addDesc' : reason
        });
        action.setCallback(this, function(response) {
            var state = response.getState();    
            if(state === 'SUCCESS') {
                var sReturnValue    = response.getReturnValue();
                        console.log('sReturnValue : '+sReturnValue);

                this.showToast('SUCCESS', sReturnValue);
        		component.set("v.isChanged", false);
                this.getData(component);
            	component.set('v.modifyDays',null);
            	component.set('v.reason',null);
        		component.set("v.checked", false);
            }
            component.set('v.toggleSpinner',false);
        });        
        $A.enqueueAction(action);
    },

    doSend : function(component) {
        var action = component.get('c.doSend');
        var hldChkLst = this.getCheckedList(component);
        action.setParams({
            'hldLst' : hldChkLst
        });
        action.setCallback(this, function(response) {
            var state = response.getState();    
            if(state === 'SUCCESS') {
                var sReturnValue    = response.getReturnValue();
                this.showToast('SUCCESS', sReturnValue);
        		component.set("v.isChanged", false);
        		component.set("v.checked", false);
                this.getData(component);
            }
            component.set('v.toggleSpinner',false);
        });        
        $A.enqueueAction(action);
    },

    getCheckedList : function(component){    
        var listData = component.get("v.hldChkLst");
        for(var i = listData.length-1; i>=0; i--) {
            var obj = listData[i];
            if(!obj.isChecked) {
                listData.splice(i, 1);
            }
        }
        return listData;
    },

    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });

        evt.fire();
    }
})