({
    doSave : function(component) {
        var action = component.get('c.doSave');
        
        var prjBgt = component.get('v.prjBgt');
        var prjBgtDtlLst = component.get('v.prjBgtDtlLst');
        var recordId =  component.get('v.recordId');

        action.setParams({
            'prjBgt' : prjBgt,
            'prjBgtDtlLst' : prjBgtDtlLst,
            'recordId' : recordId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();    
            if(state === 'SUCCESS') {
                var sReturnValue    = response.getReturnValue();
                this.showToast('SUCCESS', sReturnValue);
                this.doClose(component);
            }
            component.set('v.toggleSpinner',false);
        });        
        $A.enqueueAction(action);
    },
	getInitData : function(component) {
    	var action = component.get("c.getInitData"); 

        action.setParams({
            "recordId" : component.get("v.recordId"),
            "parentId" : component.get("v.parentId")
        });

        /*클래스를 호출해서 메소드 실행*/
        action.setCallback(this, function(response) {
        	
        	/*메소드를 실행한 상태를 반환하는 걸 변수에 담음*/
            var state = response.getState();

            /*성공 상태이면..값을 리턴할것*/
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set("v.prjBgt", returnValue["prjBgt"]);
                component.set("v.prjBgtDtlLst", returnValue["prjBgtDtlLst"]);
                component.set("v.category2Lst",  returnValue["typePckLst"]);
                component.set("v.bizMngHlpTxt",  returnValue["bizMngHlpTxt"]);
                component.set("v.user" , returnValue["user"]);

				var bgt = component.get("v.prjBgt");
                component.set("v.totAmt", bgt.ru_TotalAmount__c);
            }
        });

        $A.enqueueAction(action);
    },
    
	doClose : function(component) {
        this.getInitData(component);
		var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({ 
            "recordId": component.get("v.parentId")
        });
        navigateEvent.fire();
	},
	dosesese : function(component) {
                this.getInitData(component);
		var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({ 
            "recordId": component.get("v.parentId")
        });
        navigateEvent.fire();	
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