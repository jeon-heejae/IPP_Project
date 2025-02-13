/**
 * Created by user on 2024-08-09.
 */

({

    Init: function (component, event, helper) {
        var today = new Date();
        var year = today.getFullYear()
        component.set("v.currentYear", year);
        component.set("v.currentYear", year);
        var fieldNameValidation = ["가맹점사업자번호", "가맹점유형", "업태", "업종", "공제여부결정", "비고"];
        component.set("v.fieldNameValidation", fieldNameValidation);

    },
    closeModal : function(component, event, helper) {
//            component.set("v.isModalOpen", false);

            helper.navProduct(component);
    },
    lookUpBilling : function(component, event, helper) {

        var regex = /^[0-9]{4}$/;
        var year = component.get("v.currentYear");
        if (regex.test(year) && (year > 2000 && year < 2099)) {
            console.log(year + '성공');
        } else {
            helper.showToast('error', '2000 ~ 2099년만 조회 가능합니다.');
            component.set("v.currentYear", '');
            return false;
        }

        helper.getBillingList(component, event, helper);

    },
    headToStep2 : function(component, event, helper) {

        var data = component.get("v.data");

        if (data.length === 0) {
            helper.showToast("error", "양식 데이터를 먼저 변환해 주세요");
            return;
        }

        component.set("v.step1", false);
        component.set("v.step2", true);
    },
    backToStep2 : function(component, event, helper){
        component.set("v.step3", false);
        component.set("v.step2", true);
    },
    backToStep3 : function(component, event, helper){
        component.set("v.step3Link", false);
        component.set("v.step3", true);
    },


    eraseBtn: function(component, event, helper) {

        component.set("v.csv", '');
    },

    handleExcelData : function(component, event, helper) {
        var fieldRule = component.get("v.fieldNameValidation");

        var inputExcel = component.find("inputExcel").get("v.value");
        var csv = component.get("v.csv").split('\n');
        console.log(csv);

        if (csv[0].length == 0) {
            component.set("v.csv", '');
            helper.showToast("error", "데이터를 입력하세요.");
            return false;
        }

        // 필드 규칙 에러부분 찾기
        var fieldNameRuleError = '';
        var field = csv[0].split('\t');
        for (var i = 0; i < field.length; i++) {
           if (fieldRule[i] != field[i]) {
                fieldNameRuleError += fieldRule[i];
                break;
           }
        }

        //필드 개수 감지
        if (csv[0].split('\t').length != fieldRule.length) {
            component.set("v.csv", '');
            helper.showToast("error", "필드를 확인하세요.");
            return false;
        }

        // 필드 규칙 에러 alert
        if (fieldNameRuleError != '') {
            component.set("v.csv", '');
            helper.showToast("error", "필드 순서오류: " + fieldNameRuleError);
            return false;
        }

        // 마지막 줄 바꿈 제거
        function listPop() {
            if (csv[csv.length-1].length === 0) {
                csv.pop();
            } else {
                return;
            }
            return listPop();
        }
        listPop();

        if (csv.length - 1 > 1000) {
            helper.showToast("error", `현재 레코드 개수 ${csv.length}개(1000개 이하만 가능합니다.)`);
            return;
        }

        console.log("적용버튼 눌림");
        console.log("inputExcel: "+ inputExcel);
        var rows = inputExcel.trim().split('\n');
        console.log("rows: "+ rows);
        var headers = rows[0].split('\t').map(header => header.trim().toLowerCase());
        var excelBody = rows.slice(1).map(row=> row.split('\t'));
        console.log('excelBody: ' + excelBody);
        console.log('excelBody[0]: ' + excelBody[0]);
        component.set("v.excelBody", excelBody);


        var columns = [];
        columns = headers.map(header =>({
            label: header,
            fieldName: header,
            type: 'test'
        }));
        console.log("columns: " + JSON.stringify(columns[0], null, 2));

        component.set("v.columns", columns);

        var data = [];
        data = rows.slice(1).map((row, index) => {
            var rowData = row.split('\t');
            var record = {};
            headers.forEach((header, i) => {
                record[header] = rowData[i] ? rowData[i].trim() : '';
            });
            return record;
        });
        for (var i = 0; i < data.length; i++) {
            if (!data[i]['가맹점사업자번호']) {
                // '가맹점사업자번호' 필드가 비어 있는 경우
                helper.showToast("error", ` '가맹점사업자번호'필드를 모두 채워주세요 (${i}번째 행이 비었습니다) `);
                return;
            }
        }

        component.set("v.data", data);
        console.log("data: " + JSON.stringify(data[0], null, 2));

    },

    headToStep3 : function(component, event, helper) {
        var excelData = component.get("v.data");

        // '가맹점사업자번호' 열의 모든 값을 배열로 변환
        var businessNumbers = excelData.map(row => row['가맹점사업자번호']);

        console.log('Business Numbers:', businessNumbers);

        //사업자 번호 리스트 생성
        var brNumber = new Set();
        businessNumbers.forEach(businessNumber => {
            var value = businessNumber;// v.data List<List<String>> 구조, 내부 리스트[0]은 사업자 번호
            if (value) {
                var cleanedValue = value.replace(/[^\d]/g, '');
            }
            brNumber.add(cleanedValue);

        });


        //법인 카드 청구 내역 레코드 갯수 Map - 사업자 번호를 key, value를 0으로
        var brNumberCountMap = new Map();
        brNumber.forEach(value => {
            brNumberCountMap.set(value, 0);
            var aa = value;
        });
        brNumberCountMap.set('해당없음', 0);

        var data2 = component.get("v.data2");//getBillingList로부터 받은 법인 카드 청구 내역 레코드


        var notIncluded = [];   //해당없음을 추가하고 저장할 리스트
        //사업자 번호가 동일하면 value + 1
        data2.forEach(item => {
            var storeBusinessNumber = item.StoreBusinessNumber__c || '';

            if (storeBusinessNumber) {
                storeBusinessNumber = storeBusinessNumber.replace(/[^\d]/g, '');
            }
            console.log(storeBusinessNumber);
            if (brNumberCountMap.has(storeBusinessNumber)) {
                // Map의 해당 키 값에 1을 더합니다
                brNumberCountMap.set(storeBusinessNumber, brNumberCountMap.get(storeBusinessNumber) + 1);
            }else {
                brNumberCountMap.set('해당없음', brNumberCountMap.get('해당없음') + 1);
                notIncluded.push(item);
            }
        });
        component.set("v.notIncluded", notIncluded);

        //datatable에 사용하기 위해 list로 전환
        var dataTableData = Array.from(brNumberCountMap, ([key, value]) => ({
            사업자번호: key,
            요청건수: value
        }));
        component.set("v.data3", dataTableData);

        //step3 활성화
        component.set("v.step2", false);
        component.set("v.step3", true);


    },
    showBillingList : function(component,event, helper) {

        helper.showBillingList(component, event);
        component.set("v.step3", false);
        component.set("v.step3Link", true);


    },

    handleUpload : function(component, event, helper) {
        helper.UpdateList(component, event, helper);
        component.set("v.step3", false);
        component.set("v.step4", true);

    }


});