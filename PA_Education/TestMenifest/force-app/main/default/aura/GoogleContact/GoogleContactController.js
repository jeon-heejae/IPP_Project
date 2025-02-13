({
    
    doInit : function(compoenent) {
    	console.log("component access");    
    }, 
    
    fnInit : function(component, event, helper) {
        
        console.log("test component");
    	component.set("v.listColumns", 
    		[
	            {label: '이름', fieldName: 'name', type: 'text', sortable:true},
	            {label: '회사', fieldName: 'companyName', type: 'text', sortable:true},
                {label: '직책', fieldName: 'position', type: 'text', sortable:true},
	            {label: '연락처', fieldName: 'phone', type: 'text', sortable:true},
                {label: 'E-Mail', fieldName: 'email', type: 'text', sortable:true},
                {type: 'button-icon', initialWidth:30, typeAttributes: {name: 'addWorker', iconName: {fieldName: 'iconName'}, disabled: {fieldName: 'disabledValue'}}}
        	]
    	);
		var today = new Date();
        var monthDigit = today.getMonth() + 1;
	    if (monthDigit <= 9) {
	        monthDigit = "0" + monthDigit;
	    }
	    var dayDigit = today.getDate();
	    if (dayDigit <= 9 ) {
	    	dayDigit = "0" + dayDigit;
	    }
        component.set("v.searchDate", today.getFullYear() + "-" + monthDigit + "-" + dayDigit);
        component.set("v.bSpinner", true);
    	helper.doGetInitialData(component, helper);
    	//helper.getUserData(component, helper);
    },

    //조회 버튼 클릭 시
    fnHandleSearch : function(component, event, helper) {
        component.set("v.bSpinner", true);
        helper.doGetContactData(component);
    },

    //header 클릭 시 sort 처리
    fnColumnSorting : function(component, event, helper) {
        var sFieldName      = event.getParam("fieldName");
        var sSortDirection  = event.getParam("sortDirection");

        component.set("v.sSortBy"       , sFieldName);
        component.set("v.sSortDirection", sSortDirection);
        helper.doSorting(component, sFieldName, sSortDirection);
    },

    //row 클릭 시 이벤트
    fnHandleRowAction : function(component, event, helper) {
        var action = event.getParam('action');
        var row    = event.getParam('row');

        // standard record page 로 이동 record action 이 여러개 일때 typeAttributes 로 구분해서 이벤트 처리가 가능
        switch (action.name) {
            case 'addWorker':
                console.log(row.name);
                helper.doCreateContact(component, row);
                break;
            default:
                break;
        }
    },

    handlerKeyPress : function(component, event, helper){
        if(event.keyCode==13){
            component.set("v.bSpinner", true);
            var searchDate = component.find('searchDate');
            if(!$A.util.isEmpty(searchDate)){
                helper.doGetContactData(component);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "조회일자를 입력해 주세요."
                });
                toastEvent.fire();
                component.set("v.bSpinner", false);
            }
        }
        
    }

})