({
    // 나중에 클래스에서 받아올 초기 데이터가 있는 경우 주석 해제
	getInitData : function(component) {
        var recordCount = component.get("v.recordCount");
        var action = component.get("c.getInitData");

        action.setParams({
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();

                var iEmployeeCnt = returnValue["iEmployeeCnt"];
                var maxPageNumber = Math.ceil(iEmployeeCnt / recordCount);
                console.log("maxPageNumber : " + maxPageNumber);
                component.set("v.maxPageNumber", maxPageNumber);

                this.doSetInitData(component);
            }
        });

        $A.enqueueAction(action);   	
    },

    // 스크립트단에서 생성하는 기본 데이터
    doSetInitData : function(component) {
        var i;
        var dateCurrent = new Date();

        // 연 픽리스트 값
        var yearYYYY;
        var currentYear = dateCurrent.getFullYear();
        var listYear = [];
        for(i = -5; i <= 1; i++) {
            yearYYYY = currentYear + i;
            listYear.push({label: yearYYYY + "년", value: yearYYYY.toString()});
        }
        
        component.set("v.listYear", listYear);

        // 월 픽리스트 값
        var listMonth = [];
        for(i = 1; i <= 12; i++) {
            listMonth.push({label: i + "월", value: i.toString()});
        }
        
        component.set("v.listMonth", listMonth);

        // 기본값 설정
        this.doSetDefaultValue(component);
    },

    // 기본값 설정
    doSetDefaultValue : function(component) {
        var dateCurrent = new Date();

        // 현재 년도
        component.set("v.sYearDefault", dateCurrent.getFullYear().toString());

        // 현재 월
        var month = dateCurrent.getMonth() + 1;
        component.set("v.sMonthDefault", month.toString());

        // 현재 분기
        var quarter = this.getQuarterAsDate(dateCurrent.getMonth() + 1);
        component.set("v.sQuarterDefault", quarter);

        // 현재 반기
        var half = this.getHalfAsDate(dateCurrent);
        component.set("v.sHalfDefault", half);
    },

    // 조회 구분이 변경 될 때 리스트 초기화
    doClearList : function(component) {
        component.set("v.listWrapRow", []);
    },

    getQueryHRView : function(component, params) {
        var action = component.get("c.queryHRView");

        action.setParams({
            "pFromDt"           : params["dateFrom"],
            "pToDt"             : params["dateTo"],
            "pType"             : params["dateType"],
            "pIncludeHoliday"   : component.find("hasHoliday").get("v.checked"),
            "pOffset"           : params["offset"],
            "pLimit"            : params["limit"]
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();

                component.set("v.listMainHeader", returnValue["listMainHeader"]);
                component.set("v.listSubHeader", returnValue["listSubHeader"]);
                component.set("v.listWrapRow", returnValue["listWrapRow"]);

                console.log(returnValue);
            }

            $A.util.toggleClass(component.find("spinner"), "slds-hide");
        });

        $A.enqueueAction(action);      
    },

    doSetDateTerm : function(component, selectedDate) {
        var sRadioValue = component.get("v.sRadioValue");
        var maxDate = new Date(selectedDate);

        // 주단위인 경우 최대 6개월, 일단위인 경우 최대 1개월까지 선택 가능
        if(sRadioValue === "WEEKLY") {
            maxDate = new Date(maxDate.setMonth(maxDate.getMonth() + 6));
        }
        else if(sRadioValue == "DAILY") {
            maxDate = new Date(maxDate.setMonth(maxDate.getMonth() + 1));
        }

        maxDate = new Date(maxDate.setDate(maxDate.getDate() - 1));

        // 종료일의 min, max
        component.set("v.dFromDate", this.setDateFormat(selectedDate));
        component.set("v.dToDate", this.setDateFormat(maxDate));
    },


    /*
     *  조회 조건 날짜 구하기
     */
    // 날짜 형식 변경 (yyyy-mm-dd)
    setDateFormat : function(date) {
        var yyyy, mm, dd;

        yyyy = date.getFullYear();
        mm = date.getMonth() + 1;
        dd = date.getDate();

        return [yyyy, (mm > 9 ? "" : "0") + mm, (dd > 9 ? "" : "0") + dd].join("-");
    },

    // 연도로 날짜 구하기
    getDateAsYear : function(yearYYYY) {
        var dateFrom, dateTo;

        dateFrom = this.setDateFormat(new Date(yearYYYY, 0, 1));
        dateTo = this.setDateFormat(new Date(yearYYYY, 12, 0));

        var returnValue = {
            "dateFrom" : dateFrom,
            "dateTo" : dateTo
        };

        return returnValue;
    },

    // 월로 날짜 구하기
    getDateAsMonth : function(yearYYYY, monthM) {
        var dateFrom, dateTo;

        dateFrom = this.setDateFormat(new Date(yearYYYY, monthM - 1, 1));
        dateTo = this.setDateFormat(new Date(yearYYYY, monthM, 0));

        var returnValue = {
            "dateFrom" : dateFrom,
            "dateTo" : dateTo
        };

        return returnValue;
    },

    // 반기로 날짜 구하기
    getDateAsHalf : function(yearYYYY, half) {
        var dateCurrent = new Date();
        var dateFrom, dateTo;

        if(half === "A") {
            dateFrom = this.setDateFormat(new Date(yearYYYY, 0, 1));
            dateTo = this.setDateFormat(new Date(yearYYYY, 6, 0));
        }
        else {
            dateFrom = this.setDateFormat(new Date(yearYYYY, 6, 1));
            dateTo = this.setDateFormat(new Date(yearYYYY, 12, 0));
        }

        var returnValue = {
            "dateFrom" : dateFrom,
            "dateTo" : dateTo
        };

        return returnValue;
    },

    // 분기로 날짜 구하기
    getDateAsQuarter : function(yearYYYY, quarter) {
        var dateFrom, dateTo;
        
        switch(quarter) {
            case "1" : 
                dateFrom = this.setDateFormat(new Date(yearYYYY, 0, 1));
                dateTo = this.setDateFormat(new Date(yearYYYY, 3, 0));

                break;

            case "2" : 
                dateFrom = this.setDateFormat(new Date(yearYYYY, 3, 1));
                dateTo = this.setDateFormat(new Date(yearYYYY, 6, 0));

                break;

            case "3" : 
                dateFrom = this.setDateFormat(new Date(yearYYYY, 6, 1));
                dateTo = this.setDateFormat(new Date(yearYYYY, 9, 0));

                break;

            case "4" : 
                dateFrom = this.setDateFormat(new Date(yearYYYY, 9, 1));
                dateTo = this.setDateFormat(new Date(yearYYYY, 12, 0));

                break;
        }

        var returnValue = {
            "dateFrom" : dateFrom,
            "dateTo" : dateTo
        };

        return returnValue;     
    },

    // 날짜로 분기 구하기
    getQuarterAsDate : function(monthM) {
        var quarter = Math.ceil(monthM / 3).toString();
        console.log("quarter : " + quarter);

        return quarter;
    },

    // 날짜로 반기 구하기
    getHalfAsDate : function(dateCurrent) {
        var stdDate = new Date(dateCurrent.getFullYear(), 6, 1);
        
        // 7월 이전은 전반기, 이후는 후반기
        var half = dateCurrent < stdDate ? "A" : "B";

        return half;
    },
})