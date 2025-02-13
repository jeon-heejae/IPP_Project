({
	fnInit : function(component, event, helper) {
		helper.getInitData(component);
		// helper.doSetInitData(component);
	},

	fnChangeDivision : function(component, event, helper) {
		var name = event.getSource().get("v.name");
		var value = event.getSource().get("v.value");
		console.log("name : " + name + ", value : " + value);

		component.set("v.s" + name + "Value", value);

		// 구분이 지정인 경우, 기본값 및 맥스 데이트 설정
		if(value === "POINT") {
			helper.doSetDateTerm(component, new Date());
		}
	},

	fnChangeRadio : function(component, event, helper) {
		var value = event.getSource().get("v.value");
		
		component.set("v.sRadioValue", value);

		// 조회 구분이 변경 될 때 리스트 초기화
		helper.doClearList(component);
	},

	fnChangeDate : function(component, event, helper) {
		var dateValue = event.getSource().get("v.value");
		console.log("dateValue : " + dateValue);

		// 시작일이 변경되면 종료일의 min, max 자동 설정
		helper.doSetDateTerm(component, new Date(dateValue));
	},

	fnSearch : function(component, event, helper) {
		$A.util.toggleClass(component.find("spinner"), "slds-hide");

		var params;
		var sRadioValue = component.get("v.sRadioValue");
		var yearYYYY = component.find("year") ? component.find("year").get("v.value") : null;

		if(sRadioValue === "MONTHLY") {
			params = helper.getDateAsYear(yearYYYY);
		}
		else if(sRadioValue === "WEEKLY" || sRadioValue === "DAILY") {
			var division = component.get("v.s" + (sRadioValue === "WEEKLY" ? "Weekly" : "Daily") + "Value");

			switch(division) {
				case "HALF" :
					var half = component.find("half").get("v.value");
					params = helper.getDateAsHalf(yearYYYY, half);

				break;

				case "QUARTER" :
					var quarter = component.find("quarter").get("v.value");
					params = helper.getDateAsQuarter(yearYYYY, quarter);

				break;

				case "MONTHLY" : 
					var month = component.find("month").get("v.value");
					params = helper.getDateAsMonth(yearYYYY, month);

					break;

				case "POINT" :
					var fromDate = component.find("fromDate").get("v.value");
					var toDate = component.find("toDate").get("v.value");

					params = {
						"dateFrom" : fromDate,
        				"dateTo" : toDate
					};
				break;					
			}
		}

		params["dateType"] = sRadioValue;

		// paging offset, limit
		var currentPage = component.get("v.currentPageNumber");
		var recordCount = component.get("v.recordCount");

		params["offset"] = (currentPage - 1) * recordCount;
		params["limit"] = recordCount;

		// parameter date
		component.set("v.pFromDt", params["dateFrom"]);
		component.set("v.pToDt", params["dateTo"]);

		console.log(params);
		helper.getQueryHRView(component, params);
	},

	fnClickName : function(component, event, helper) {
		var idEmployee = event.currentTarget.dataset.employee;
		var pFromDt = component.get("v.pFromDt");
		var pToDt   = component.get("v.pToDt");

		console.log("idEmployee : " + idEmployee + ", pFromDt : " + pFromDt + ", pToDt : " + pToDt);
		
        $A.createComponent(
            "c:ViewHRInfo",
            {   
                "idEmployee"    : idEmployee,
                "pFromDt"       : pFromDt,
                "pToDt"         : pToDt
            },
            function(cViewHRInfo, status, errorMessage) {
            	console.log("status : " + status);

                if(status === "SUCCESS") {
                    // callback action
                    component.set("v.ViewHRInfoCmp", cViewHRInfo),
                    /* scroll 방지*/
                    document.body.style.overflow = "hidden";
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }   
            
        ); 
	},


})