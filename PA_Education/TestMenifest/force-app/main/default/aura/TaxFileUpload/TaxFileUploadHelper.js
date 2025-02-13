/**
 * Created by user on 2024-08-09.
 */

({

    fnInit: function (component) {

    },

    getBillingList: function (component, event, helper) {

        var selectedYear = component.find("Year").get("v.value");
        var selectedMonth = component.find("selectMonth").get("v.value");
        component.set("v.selectedMonth", selectedMonth);
        console.log("Year,Month: " + selectedYear + "." + selectedMonth);
        var data = component.get("v.data");

        var action = component.get("c.getBillingList");

        action.setParams({
            Year: selectedYear,
            Month: selectedMonth
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("getBillingListWorking")

                var billingList = response.getReturnValue();
                console.log('billingList: ', JSON.stringify(billingList));
                
                component.set("v.data2", billingList);
                component.set("v.billingList", billingList);


            }else {
                console.log("step2 callback 실패");
            }
        });
        $A.enqueueAction(action);



    },
    showBillingList : function(component, event) {
        // 클릭된 행의 값 가져오기 (요청건수 숫자)
        var action = event.getParam('action');
        var row = event.getParam('row');

        // 요청건수 버튼이 클릭된 경우 처리
        if (action.name === 'requestCount') {
            var strN = row['사업자번호'];
            console.log('선택된 사업자번호:', strN);

            if (strN !== '해당없음'){
                var selectedYear = component.get("v.currentYear");
                    var selectedMonth = component.get("v.selectedMonth");

                    var billingList = component.get("v.data2");

                    // 문자열에서 숫자만 남기는 함수
                    function stripNonNumericChars(value) {
                        return value.replace(/\D/g, ''); // 숫자 제외 모든 문자 제거
                    }

                    // strN을 처리하여 숫자만 남기기
                    var processedStrN = stripNonNumericChars(strN);

                    // data2를 필터링하여 StoreBusinessNumber__c와 일치하는 항목만 남기기
                    var linkData3 = billingList.filter(function(record) {
                        var processedStoreNumber = stripNonNumericChars(record.StoreBusinessNumber__c);
                        return processedStoreNumber === processedStrN;
                    });
                    // 필터링된 데이터를 LinkData3 속성에 설정
                    component.set("v.LinkData3", linkData3);
            }else{
                var notIncluded = component.get("v.notIncluded");
                component.set("v.LinkData3", notIncluded);

            }




        }


    },

    UpdateList : function(component){
        var billingList = component.get("v.billingList");
        console.log("billinglist: " + billingList);
        var excelData = component.get("v.excelBody");

        var action = component.get("c.updateBillingList");

        action.setParams({
            billingList: billingList,
            data: excelData
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("actionworks?");

                var formattedMap = [];
                var mapResults = response.getReturnValue();
                console.log('mapResults:' + mapResults);
                component.set("v.mapResults", mapResults);
                console.log('mapResults.size:' + mapResults.size);

                // Map 데이터를 배열 형식으로 변환
                for (var key in mapResults) {
                    if (mapResults.hasOwnProperty(key)) {
                        formattedMap.push({ key: key, value: mapResults[key] });
                    }
                }
                console.log("log here");
                console.log('formattedMap1:' + formattedMap[0]);
                component.set("v.mapResults", formattedMap);


            }else {
                console.log("helper.updateList 실패;");
            }
        });
        $A.enqueueAction(action);

    },
    navProduct: function(component) {

        var navService = component.find("navService");

        var pageReference = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'CorporateCardBilling__c',
                actionName: 'list'
            },
        };
        navService.navigate(pageReference);
    },

    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key : "info_alt"
            , type : type
            , message : message
        });
        evt.fire();
    },



});