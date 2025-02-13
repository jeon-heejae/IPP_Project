({
    fnInit : function(component, event, helper) {
        component.set("v.listColumns", [
            {label: "사원명", fieldName: "Name", type: "text", sortable: true},
            {label: "주역할", fieldName: "MainRole__c", type: "text", sortable: true},
            {label: "직급", fieldName: "Position__c", type: "text", sortable: true},
            {label: "사번", fieldName: "EmployeeNo__c", type: "text", sortable: true}
        ]);

        helper.getInitData(component);
    },

    fnColumnSorting : function(component, event, helper) {
        var sFieldName      = event.getParam("fieldName");
        var sSortDirection  = event.getParam("sortDirection");

        component.set("v.sSortBy"       , sFieldName);
        component.set("v.sSortDirection", sSortDirection);

        helper.doSorting(component, sFieldName, sSortDirection);
    },

    fnLoadMore : function(component, event, helper) {
        console.log("*** onLoadMore Init ***");
        event.getSource().set("v.isLoading", true);
        component.set("v.sLoadMoreStatus", "데이터를 불러오는 중입니다. 잠시만 기다려주세요.");

        helper.doFetchData(component, component.get("v.iLoadCnt")).then($A.getCallback(function(data) {
            console.log("iTotalRows : " + component.get("v.iTotalRows"));
            console.log("listEmployee length : " + component.get("v.listEmployee").length);
            if(component.get("v.listEmployee").length >= component.get("v.iTotalRows")) {
                component.set("v.bEnableLoading", false);
                component.set("v.sLoadMoreStatus", "더이상 불러 올 데이터가 없습니다.");
            } 
            else {
                var currentData = component.get("v.listEmployee");
                var newData = currentData.concat(data);
                
                component.set("v.listEmployee", newData);
            }
            
            event.getSource().set("v.isLoading", false);
            component.set("v.sLoadMoreStatus", "");
        }));
        console.log("*** onLoadMore Finish ***");
    },

    fnCreateApproval : function(component, event, helper) {
        var listSelectedRows = component.find("datatable").getSelectedRows();

        if(!listSelectedRows || listSelectedRows.length <= 0) {
            helper.showToast("error", "레코드를 하나 이상 선택하고 다시 시도하십시오.");
        } 
        else {
            // Show Spinner
            component.set("v.bIsShowSpinner", true);

            var listIdRecords = [];
            for(var i in listSelectedRows) {
                var obj = listSelectedRows[i];
                listIdRecords.push(obj.Id);
            }    
            console.log(listIdRecords);

            helper.doCreateApproval(component, listIdRecords);
        }
    },

    /*
     * 	프로그레스 바 스텝 핸들링 펑션
     */
    fnStep1Validation : function(component, event, helper) {
    	var listSelectedRows = component.find("datatable").getSelectedRows();
    	console.log("listSelectedRows : " + listSelectedRows);

    	// 체크 된 사원이 있는 경우 다음 스텝으로 넘어갈 수 있음
    	if(listSelectedRows.length > 0) {
    		component.find("progress").set("v.currentStep", "step3");
    		component.find("childObjects").set("v.disabled", false);
    		component.find("exportBtn").set("v.disabled", false);
    	} 
    	// 선택 된 사원이 없으면 다음 스텝으로 넘어갈 수 없음
    	// 다음 스텝으로 넘어간 상태에서 체크를 해제하는 경우, 다시 스텝1로 돌아감
    	else {
    		component.find("progress").set("v.currentStep", "step1");
    		component.find("childObjects").set("v.disabled", true);
    		component.find("exportBtn").set("v.disabled", true);
    	}
    },

    fnExport : function(component, event, helper) {
    	// 선택 된 사원 아이디 배열
    	var listIdRecords = [];
    	var listSelectedRows = component.find("datatable").getSelectedRows();

		for(var i in listSelectedRows) {
			var obj = listSelectedRows[i];
			listIdRecords.push(obj.Id);
		}    
		console.table(listIdRecords);

		// 선택 된 하위 오브젝트 배열
		var listChildSelected = component.get("v.listChildSelected");
		var listRequired = component.get("v.requiredOptions");

    	window.location.href = "/apex/ResourceProfile_doc?ids=" + JSON.stringify(listIdRecords) + "&child=" + JSON.stringify(listChildSelected);
    },
})