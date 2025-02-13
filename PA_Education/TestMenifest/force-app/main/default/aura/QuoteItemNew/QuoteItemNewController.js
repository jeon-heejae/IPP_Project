({
	fnInit : function(component, event, helper) {
		helper.getInitData(component);		
	},

	fnNext : function(component, event, helper) {
		var idEmployee = "";
		var sRecordType = component.get("v.sRecordType");
		var bIsAutomatic = component.get("v.bIsAutomatic");

		var bIsAuto = (sRecordType === "Consulting" && bIsAutomatic ? true : false);
		var bIsValid = true;

		// 자동 입력인 경우 유효성 검사 필요
		if(bIsAuto) {
			var employeeLookup = component.find("employeeLookup");

			if(employeeLookup.selectItem("sId")) {
				idEmployee = employeeLookup.selectItem("sId");
			}
			else {
				bIsValid = false;
				employeeLookup.errorCheck('Complete this field');
				return;
			}
		}

		// 유효성 검사 통과 후 생성 화면 출력
		if(bIsValid) {
			var mapRecordTypeId = component.get("v.mapRecordTypeId");
			var params = {
				"sRecordType" : sRecordType,
				"idRecordType" : mapRecordTypeId[sRecordType],
				"bIsAutomatic" : component.get("v.bIsAutomatic"),
				"idEmployee" : idEmployee
			};	

			if(bIsAuto) {
				helper.doCreateRecordAuto(component, params);	
			}
			else {
				helper.doCreateRecord(component, params);	
			}
		}
	},

	fnCancel : function(component, event, helper) {
		helper.doClose(component);
	},
})