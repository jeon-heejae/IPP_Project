({
    handleError: function(response) {
        var errors = response.getError();
        var message = "알 수 없는 오류가 발생했습니다.";
        if (errors && errors[0] && errors[0].message) {
            message = errors[0].message;
        }
        console.log('Error: ' + message);
    },
    
    //모든 신입의 데이터 가져오기
    getData : function(component) {
        console.log('getData start');
        //남아있는 프로그램 가져오기
        var actionRemain = component.get("c.getAllEmployeeRemain");
        actionRemain.setCallback(this, function(response) {
            var state = response.getState();
            console.log('getData state: '+state);
            if (state === "SUCCESS") {
                var listProgramData = response.getReturnValue();
                
               // 데이터 변환 -> 직원 이름을 쉼표로 연결하여 하나의 문자열로 변환
              
               const dataTableData = listProgramData.map(function(program) {
                return {
                    id: program.id,
                    programName: program.programName,
                    category: program.category,
                    employeeNames: program.employeeNames.join(", ")
                };
            });


            

            console.log('dataTableData: '+JSON.stringify(dataTableData));
                //컴럼 정의
                const columns = [
                    { label: '관련분야', fieldName: 'category', type: 'text', initialWidth:90, sortable: true },
                    { label: '프로그램 명', fieldName: 'programName', type: 'text', sortable: true },
                    { label: '사원 명', fieldName: 'employeeNames', type: 'text', sortable: true}
                ];
                
                component.set("v.columns", columns);
                component.set("v.data", dataTableData);

                console.log("Data Table Data:", dataTableData); // 확인용 콘솔 로그
            } else {
                helper.handleError(response);
            }
        });

        // 진행 중 프로그램 데이터 가져오기
        var actionInprogress = component.get("c.getAllEmployeeInProgress");
        actionInprogress.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var listProgramData2 = response.getReturnValue();
                
                // 데이터 변환 -> 직원 이름을 쉼표로 연결하여 하나의 문자열로 변환
               var dataTableData2 = listProgramData2.map(function(program) {
                return {
                    id: program.programName,
                    programName: program.programName,
                    category: program.category,
                    employeeNames: program.employeeNames.join(", ")
                };
            });
                //컴럼 정의
                var columns2 = [
                    { label: '관련분야', fieldName: 'category', type: 'text', initialWidth:90, sortable: true },
                    { label: '프로그램 명', fieldName: 'programName', type: 'text', sortable: true },
                    { label: '사원 명', fieldName: 'employeeNames', type: 'text', sortable: true}
                ];
                
                component.set("v.columns2", columns2);
                component.set("v.data2", dataTableData2);
            }else{
                helper.handleError(response);
            }
        });
        
        $A.enqueueAction(actionInprogress);
        $A.enqueueAction(actionRemain);
    },
    //로그인한 유저의 데이터 가져오기
    loadEducation: function(component){
        console.log('helper start');

        var actionGetName=component.get("c.getName");
        actionGetName.setCallback(this,function(response){
            var state = response.getState();
            console.log('state: '+state);
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                console.log('result: '+result);
                component.set("v.objName",result);
            } else {
                helper.handleError(response);
            }
        });
        //남아있는 프로그램 가져오기
        var actionRemain=component.get("c.getRemainEducation");
        actionRemain.setCallback(this,function(response){
            var state = response.getState();
            console.log('state: '+state);
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                console.log('result: '+JSON.stringify(result));

                //컬럼 정의
                var columns=[
                    { label: '관련분야', fieldName: 'Category', type: 'text', initialWidth:90, sortable: true },
                    { label: '프로그램 명', fieldName: 'Name', type: 'text', sortable: true }
                ];
                component.set("v.objColumns",columns);
                component.set("v.objData",result);

            } else {
                helper.handleError(response);
            }
        });
        //진행 중 프로그램 가져오기
        var actionProgress=component.get("c.getInProgressEducation");
        actionProgress.setCallback(this,function(response){
            var state = response.getState();
            console.log('state: '+state);
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                console.log('result: '+result);

               //컬럼 정의
               var columns2=[
                { label: '관련분야', fieldName: 'Category', type: 'text', initialWidth:90, sortable: true },
                { label: '프로그램 명', fieldName: 'Name', type: 'text', sortable: true }
            ];
            component.set("v.objColumns2",columns2);
            component.set("v.objData2",result);
            } else {
                helper.handleError(response);
            }
        });
        
        $A.enqueueAction(actionGetName);
        $A.enqueueAction(actionRemain);
        $A.enqueueAction(actionProgress);
    },
    //멘티들의 데이터 가져오기
    loadMentee: function(component){
        console.log('loadMentee start');
        //남아있는 프로그램 데이터 가져오기
        var actionMenteeRemain = component.get("c.getAllMenteeRemain");
        actionMenteeRemain.setCallback(this, function(response) {
            var state = response.getState();
            console.log('loadMentee state: '+state);
            if (state === "SUCCESS") {
                var listMenteeData = response.getReturnValue();
                
               // 데이터 변환 -> 직원 이름을 쉼표로 연결하여 하나의 문자열로 변환
               var dataTableData = listMenteeData.map(function(program) {
                return {
                    id: program.programName,
                    programName: program.programName,
                    category: program.category,
                    employeeNames: program.employeeNames.join(", ")
                };
            });
                //컴럼 정의
                var columns = [
                    { label: '관련분야', fieldName: 'category', type: 'text', initialWidth:90, sortable: true },
                    { label: '프로그램 명', fieldName: 'programName', type: 'text', sortable: true },
                    { label: '사원 명', fieldName: 'employeeNames', type: 'text', sortable: true }
                ];
                
                component.set("v.MenteeColumns", columns);
                component.set("v.MenteeData", dataTableData);

                console.log("Data Table Data:", dataTableData); // 확인용 콘솔 로그
            } else {
                helper.handleError(response);
            }
        });

        // 진행 중 프로그램 데이터 가져오기
        var actionMenteeInprogress = component.get("c.getAllMenteeInProgress");
        actionMenteeInprogress.setCallback(this, function(response) {
            var state = response.getState();
            console.log('loadMentee state: '+state);
            if (state === "SUCCESS") {
                var listMenteeData = response.getReturnValue();
                
               // 데이터 변환 -> 직원 이름을 쉼표로 연결하여 하나의 문자열로 변환
               var dataTableData2 = listMenteeData.map(function(program) {
                return {
                    id: program.programName,
                    programName: program.programName,
                    category: program.category,
                    employeeNames: program.employeeNames.join(", ")
                };
            });
                //컴럼 정의
                var columns2 = [
                    { label: '관련분야', fieldName: 'category', type: 'text', initialWidth:90, sortable: true },
                    { label: '프로그램 명', fieldName: 'programName', type: 'text', sortable: true },
                    { label: '사원 명', fieldName: 'employeeNames', type: 'text', sortable: true }
                ];
                
                component.set("v.MenteeColumns2", columns2);
                component.set("v.MenteeData2", dataTableData2);

                console.log("Data Table Data:", dataTableData2); // 확인용 콘솔 로그
            } else {
                helper.handleError(response);
            }
        });

        $A.enqueueAction(actionMenteeRemain);
        $A.enqueueAction(actionMenteeInprogress);
    },

    dataSort: function(component, event, helper) {
        console.log('Helper:');
    
        //조건 추가
        
        // 데이터 가져오기
        const cloneData = component.get("v.data");
        const cloneData2 = component.get("v.data2");


        //console.log('data: '+JSON.stringify(data));

        //이벤트 가져오기
        console.log('event.getParams: '+JSON.stringify(event.getParams()));
        const sortedBy=event.getParam('fieldName');
        const sortDirection=event.getParam('sortDirection');
        console.log('sortedBy: '+sortedBy+', sortDirection: '+sortDirection);
        
        
        //정렬
        cloneData.sort(this.sortBy(sortedBy,sortDirection =='asc'? 1: -1));
        cloneData2.sort(this.sortBy(sortedBy,sortDirection =='asc'? 1: -1));

        
        
        //console.log('정렬: '+JSON.stringify(data));
        component.set('v.data', cloneData);
        component.set('v.data2', cloneData2); 
        component.set('v.sortDirection',sortDirection); 
        component.set('v.sortedBy', sortedBy);
        
        
    },
    
    //정렬 함수
    sortBy: function (field, reverse) {
        return (a,b) =>{
            var valueA=a[field] ? a[field]: '';
            var valueB=b[field] ? b[field]: '';
            
            if(valueA>valueB){
                return reverse;
            }else if(valueA<valueB){
                return -reverse;
            }
            return 0;
        };
    }
})