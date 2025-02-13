/*
* Component Name                : HolidayActionLightning.cmp
* Component Controller          : HolidayActionLightningController.js
* Component Helper              : HolidayActionLightningHelper.js
* Component Contorlller Class   : HolidayActionLightningExtension.cls
* Test Class                    : HolidayActionLightningExtension_Test.cls
* Description                   : 휴일관리 라이트닝 신청 폼
* Modification Log
* ===============================================================
* Ver     Date          Author           Modification
* ===============================================================
  1.0   2018.08.27      JK.lee              Create
  2.0   2019.01.09      JK.lee              Modified
*/

({
    closeModal : function(component, helper) {
        const navEvent = $A.get("e.force:navigateToList");
        navEvent.setParams({
            "listViewName": 'Recent',
            "scope": "HolidayAction__c"
        });
        navEvent.fire();
    },

    // userList : function(component){
    //     var action = component.get('c.getPicklistValue');
    //     action.setParams({
    //         "objectAPIName" : "User",
    //         "fieldName" : "Name",
    //         "userId" : component.get('v.thisRecordId')
    //     });
    //     action.setCallback(this, function(response){
    //         var result = response.getReturnValue();
    //         console.log('-------유저 리스트-------');
    //         console.log(result);
    //         component.set('v.userList',result['User']);

    //     });
    //     $A.enqueueAction(action);

    // },

    selfApproverVal : function(component, helper){
        var action = component.get('c.selfApproverCheck');

        action.setCallback(this, function(response) {
        var result = response.getReturnValue(); // return 값
            component.set("v.firstApproverId", result);

        });
        $A.enqueueAction(action);
    },

    /**
     *  @author            : cj.sohn@daeunextier.com
     *  @description       : 승인자 지정 필드 기본값 설정
     *                       2차 승인자 추가 및 기본값 설정
     *  @last modified on  : 2021-09-23
     **/
    getApproverId : function (component, event, helper) {
        var action = component.get('c.getApproverId');
        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state == "SUCCESS") {
                console.log("response.getReturnValue()", response.getReturnValue());

                var result = response.getReturnValue(); // return 값
                console.log('getApproverId', result);
                component.set("v.firstApproverId", result[2] != null ? result[2] : null);
                component.set("v.HIF.FirstHolidayRequest__c", result[2] != null ? result[2] : null);
                component.set("v.secondApproverId", result[3] != null ? result[3] : null);
                component.set("v.HIF.SecondApproverRequest__c", result[3] != null ? result[3] : null);
            } else {
                console.log("response.getError()", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    /**
     *  @author            : cj.sohn@daeunextier.com
     *  @description       : 사용자의 사원 정보 및 프로젝트 정보를 조회
     *  @last modified on  : 2021-01-18
     **/
    employeeStatus : function (component, event, helper) {
        var action = component.get('c.employeeStatus');
        action.setCallback(this, function(response) {
            var result = response.getReturnValue(); // return 값
            console.log("result :: ", result);

            if(result != null && result != undefined) {
                var us = result.userStatus[0];
                component.set("v.department", us.Department__c);
                component.set("v.HIF.Department__c", us.Department__c);

                if(us.EmployeePerformPjt__r != null && us.EmployeePerformPjt__r != undefined && us.EmployeePerformPjt__r.length > 0) {
                    component.set("v.isProject", true);
                    component.set("v.projectId", us.EmployeePerformPjt__r[0].Project__c);
                    component.set("v.HIF.Project__c", us.EmployeePerformPjt__r[0].Project__c);

                    if(us.EmployeePerformPjt__r[0].IsPM__c == true || us.EmployeePerformPjt__r[0].IsPM__c == 'true') {
                        component.set("v.position", "프로젝트 PM");
                        component.set("v.HIF.Position__c", "프로젝트 PM");
                    } else {
                        component.set("v.position", "프로젝트 팀원");
                        component.set("v.HIF.Position__c", "프로젝트 팀원");

                        // PM 정보 있을 경우, 1차 승인자를 PM으로 설정
                        if(result.pmId != null && result.pmId != '') {
                            component.set("v.firstApproverId", result.pmId);
                            component.set("v.HIF.FirstHolidayRequest__c", result.pmId);
                        }
                    }
                } else {
                    component.set("v.position", "본사근무");
                    component.set("v.HIF.Position__c", "본사근무");
                }

                if(us.Position__c == "임원") {
                    component.set("v.position", "임원");
                    component.set("v.HIF.Position__c", "임원");
                }
            } else {
                component.set("v.department", null);
                component.set("v.HIF.Department__c", "");
                component.set("v.position", null);
                component.set("v.HIF.Position__c", "");
            }
        });
        $A.enqueueAction(action);
    },

    doSave : function(component, event, helper, saveList) {
        component.set("v.showSpinner", true);
        console.log('[dosave] saveList', saveList);
        console.log(component.get('v.recordId'));

        var isCheck = true;
        var action = component.get("c.doHolidayAction");
        action.setParams({
            "saveList": saveList,
            // "currentUserId" : component.get('v.recordId') // fix : 이거는 . .userinfo에서 호출한다는 전제하에 ...
        });

        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            var errors = response.getError();
            var naviDetail = $A.get("e.force:navigateToComponent");
            console.log('result : ' + result['checkMessage']);
            console.log('state : '  + state);
            console.log('errors : ' + JSON.stringify(errors));

            if (errors) {
                if (errors[0] && errors[0].message) {
                    console.log("Error message: " + errors[0].message);
                }
            } else {
                console.log("Unknown error");
            }

            if(state == 'SUCCESS') {
                console.log('SUCCESS: :' + state);
                if(result['checkMessage'] != '') {
                    isCheck = false;
                }

                if(isCheck) {
                    if(result['checkMessage'].includes('Already applied a Women Holiday this month')) {
                        this.showSuccessToast(component, 'Error!', 'Error', result['checkMessage']);
                        return null;
                    }

                    component.set("v.showSpinner", false);
                    var recordId = result['createdRecordId'];
                    console.log('%ccreatedRecordId : ' + recordId, 'background:lightgreen');

                    var navService = component.find("navService");
                    var pageReference = {};
                    if(recordId) {
                        // 레코드 아이디가 있는 경우 해당 레코드ID 페이지로 감
                        pageReference = {
                            type: 'standard__recordPage',
                            attributes: {
                                objectApiName: 'HolidayAction__c',
                                actionName: 'view',
                                recordId: recordId
                            }
                        };
                    } else {
                        // 레코드 아이디가 없는 경우 해당 리스트 페이지로 감
                        pageReference = {
                            type: 'standard__listPage',
                            attributes: {
                                objectApiName: 'HolidayAction__c',
                                actionName: 'home'
                            }
                        };
                    }

                    // 페이지 이동 후, 토스트 메시지 노출
                    navService.generateUrl(pageReference).then($A.getCallback(function(url) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title"     : 'Success!',
                            "type"      : 'Success',
                            "message"   : 'Your holiday application has submitted : 휴가 신청이 완료 되었습니다.'
                        });
                        toastEvent.fire();

                        }), $A.getCallback(function(error) { console.log(error); }
                    ));
                    navService.navigate(pageReference, true);
                } else {
                    component.set("v.showSpinner", false);
                    if(result['checkMessage'].includes('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY')) {
                        this.showSuccessToast(component, 'Error!', 'Error', 'Please check whether approver is you, or contact to system admin : 본인 신청 금지.');
                        return null;
                    } else {
                        this.showSuccessToast(component, 'Error!', 'Error', result['checkMessage']);
                        return null;
                    }
                }
            }

            return true;
        });
        $A.enqueueAction(action);
    },

    showSuccessToast : function(component, title, type, message) {
        var toastEvent = $A.get( "e.force:showToast" );
        toastEvent.setParams( {
            "title" : title
            , "type" : type
            , "message" : message
//            , "duration" : 500000
        } );
        toastEvent.fire();
    },

    selectFieldName : function(component, event, helper){
        var action = component.get("c.getSelectFieldName");
        action.setCallback(this, function(response) {
            var result = response.getReturnValue(); // return 값
            component.set("v.holidayAction", result);
        });

        $A.enqueueAction(action);
    },

    /**
     *  @author            : yj.kim@daeunextier.com
     *  @description       : 기존 연차 신청가능일수 5 -> 10 변경
     *  @last modified on  : 2023-06-28
     **/
    dateChange : function(component,event,helper){
        var countDate = event.getSource().get("v.value");
        console.log('countDate  :'+countDate);
        if(countDate =="1") {
            component.set("v.HIF.HolidayAction_Date2__c",null);
            component.set("v.HIF.HolidayAction_Date3__c",null);
            component.set("v.HIF.HolidayAction_Date4__c",null);
            component.set("v.HIF.HolidayAction_Date5__c",null);
            component.set("v.HIF.HolidayAction_Date6__c",null);
            component.set("v.HIF.HolidayAction_Date7__c",null);
            component.set("v.HIF.HolidayAction_Date8__c",null);
            component.set("v.HIF.HolidayAction_Date9__c",null);
            component.set("v.HIF.HolidayAction_Date10__c",null);
        }
        if(countDate  =="2") {
            component.set("v.HIF.HolidayAction_Date3__c",null);
            component.set("v.HIF.HolidayAction_Date4__c",null);
            component.set("v.HIF.HolidayAction_Date5__c",null);
            component.set("v.HIF.HolidayAction_Date6__c",null);
            component.set("v.HIF.HolidayAction_Date7__c",null);
            component.set("v.HIF.HolidayAction_Date8__c",null);
            component.set("v.HIF.HolidayAction_Date9__c",null);
            component.set("v.HIF.HolidayAction_Date10__c",null);
        }
        if(countDate =="3") {
           component.set("v.HIF.HolidayAction_Date4__c",null);
           component.set("v.HIF.HolidayAction_Date5__c",null);
           component.set("v.HIF.HolidayAction_Date6__c",null);
           component.set("v.HIF.HolidayAction_Date7__c",null);
           component.set("v.HIF.HolidayAction_Date8__c",null);
           component.set("v.HIF.HolidayAction_Date9__c",null);
           component.set("v.HIF.HolidayAction_Date10__c",null);
        }
        if(countDate =="4") {
           component.set("v.HIF.HolidayAction_Date5__c",null);
           component.set("v.HIF.HolidayAction_Date6__c",null);
           component.set("v.HIF.HolidayAction_Date7__c",null);
           component.set("v.HIF.HolidayAction_Date8__c",null);
           component.set("v.HIF.HolidayAction_Date9__c",null);
           component.set("v.HIF.HolidayAction_Date10__c",null);
        }
        if(countDate =="5") {
           component.set("v.HIF.HolidayAction_Date6__c",null);
           component.set("v.HIF.HolidayAction_Date7__c",null);
           component.set("v.HIF.HolidayAction_Date8__c",null);
           component.set("v.HIF.HolidayAction_Date9__c",null);
           component.set("v.HIF.HolidayAction_Date10__c",null);
        }
        if(countDate =="6") {
           component.set("v.HIF.HolidayAction_Date7__c",null);
           component.set("v.HIF.HolidayAction_Date8__c",null);
           component.set("v.HIF.HolidayAction_Date9__c",null);
           component.set("v.HIF.HolidayAction_Date10__c",null);
        }
        if(countDate =="7") {
           component.set("v.HIF.HolidayAction_Date8__c",null);
           component.set("v.HIF.HolidayAction_Date9__c",null);
           component.set("v.HIF.HolidayAction_Date10__c",null);
        }
        if(countDate =="8") {
           component.set("v.HIF.HolidayAction_Date9__c",null);
           component.set("v.HIF.HolidayAction_Date10__c",null);
        }
        if(countDate =="9") {
           component.set("v.HIF.HolidayAction_Date10__c",null);
        }
        if(countDate =="10") { }
    },

    fnHalfday : function(component,event,helper) {
        var typeValue = component.find("type").get("v.value");
        var halfValue = component.find("half").get("v.value");
        component.set("v.HIF.HolidayAction_Days__c",0.5);
        component.set("v.HIF.HolidayAction_HalfdayTime__c",halfValue);

        //date 필드에 입력된 값 초기화
        component.set("v.HIF.HolidayAction_Date2__c",null);
        component.set("v.HIF.HolidayAction_Date3__c",null);
        component.set("v.HIF.HolidayAction_Date4__c",null);
        component.set("v.HIF.HolidayAction_Date5__c",null);
        component.set("v.listDate",1);
    },

    fnWomen : function(component,event,helper) {
        var typeValue = component.find("type").get("v.value");
        component.set("v.HIF.HolidayAction_Days__c",1);

        //date 필드에 입력된 값 초기화
        component.set("v.HIF.HolidayAction_Date2__c",null);
        component.set("v.HIF.HolidayAction_Date3__c",null);
        component.set("v.HIF.HolidayAction_Date4__c",null);
        component.set("v.HIF.HolidayAction_Date5__c",null);
        component.set("v.listDate",1);
    },

    checkRequiredCol : function(component, event, helper) {
        // debugger;
        var errorCount  = 0;
        var returnValue = false;
        var typecheck = component.find('type').get('v.value');
        // var halfcheck = component.find('half').get('v.value');

        /*
         * 1. aura:id를 모두 같게 코딩한 경우
         * 2. aura:id를 하나만 코딩한 경우
         */
        if(component.find('inputField') != undefined) {
            var requierdList = component.find('inputField');
            var errorMessage = component.find('errorMessage');
            console.log('requiredList Length-------------//// ' + requierdList.length);

            if(requierdList.length > 0) {
                if($A.util.isArray(requierdList)) {
                    for(var index = 0; index < requierdList.length; index++) {
                        if(requierdList[index].get('v.class') != null && requierdList[index].get('v.class') != '') {
                            if( requierdList[index].get('v.class') == 'customRequired none' &&
                                (requierdList[index].get('v.value') == '' || requierdList[index].get('v.value') == null) ) {
                                errorCount++;
                                $A.util.addClass(requierdList[index], 'slds-has-error');
                                $A.util.removeClass(errorMessage[index], 'slds-hide');

                            } else if(requierdList[index].get('v.class') == 'customRequired none' &&
                                     (requierdList[index].get('v.value') != '' && requierdList[index].get('v.value') != null)) {
                                if($A.util.hasClass(requierdList[index],'slds-has-error')) {
                                    $A.util.removeClass(requierdList[index], 'slds-has-error');
                                }
                                if(!$A.util.hasClass(errorMessage[index], 'slds-hide')) {
                                    $A.util.addClass(errorMessage[index], 'slds-hide');
                                }
                            }
                        }
                    }
                }

                /*
                jQuery.each(requierdList, function(index,values) {
                    if(requierdList[index].get('v.class') != null && requierdList[index].get('v.class') != '') {
                        if( requierdList[index].get('v.class') == 'customRequired none' &&
                            (requierdList[index].get('v.value') == '' || requierdList[index].get('v.value') == null) ) {
                            errorCount++;
                            $A.util.addClass(requierdList[index],'slds-has-error');
                            $A.util.removeClass(errorMessage[index],'slds-hide');

                        } else if(requierdList[index].get('v.class') == 'customRequired none' &&
                                (requierdList[index].get('v.value') != '' && requierdList[index].get('v.value') != null)) {

                            if($A.util.hasClass(requierdList[index],'slds-has-error')) {
                                $A.util.removeClass(requierdList[index],'slds-has-error')
                            }
                            if(!$A.util.hasClass(errorMessage[index],'slds-hide')) {
                                $A.util.addClass(errorMessage[index],'slds-hide');
                            }
                        }
                    }
                });
                */
            } else {
                if(requierdList.get('v.value') == '' || requierdList.get('v.value') == null) {
                    // if(!halfcheck == '' && typecheck=='Half-day Leave'){
                    //     $A.util.hasClass(requierdList,'slds-has-error');
                    //     $A.util.addClass(errorMessage,'slds-hide');
                    // }else{
                    errorCount++;
                    $A.util.addClass(requierdList,'slds-has-error');
                    $A.util.removeClass(errorMessage,'slds-hide');
                } else {
                    if($A.util.hasClass(requierdList,'slds-has-error')) {
                        $A.util.removeClass(requierdList,'slds-has-error')
                    }
                    if(!$A.util.hasClass(errorMessage,'slds-hide')) {
                        $A.util.addClass(errorMessage,'slds-hide');
                    }
                }
            }
        }

        var requiredColList = component.get('v.checkRequiredColumn');
        var halfNullCheck = component.get('v.selectedType');
        var indexhalf = requiredColList.indexOf('half');
        // var a = requiredColList.push('half');
        // var b = requiredColList.pop('half');
        // console.log('halfNullCheck : : : '+halfNullCheck);
        // if(halfNullCheck == 'Half-day Leave' ? a : b){

        //     console.log('requiredColList : : : '+requiredColList);
        //     component.set('v.requiredColList');
        // }


        if((halfNullCheck == 'Half-day Leave' || halfNullCheck == 'Reward Half-Holiday') && !indexhalf) {
            console.log('-----half push 하는 if문');
            requiredColList.push('half');
        } else if((halfNullCheck != 'Half-day Leave' && halfNullCheck != 'Reward Half-Holiday') && indexhalf) {
            console.log('-----half pop 하는 if문');
            requiredColList.splice(indexhalf, 1);
        }

        console.log('requiredColList : : : '+requiredColList);
        if(requiredColList.length > 0) {
            if($A.util.isArray(requiredColList)) {
                for(var index = 0; index < requiredColList.length; index++) {
                    var columnName = component.find(requiredColList[index]);
                    var columnErrorMessage = component.find(requiredColList[index] + 'ErrorMessage');
                    console.log('360 : columnName : '+ columnName);

                    if($A.util.isArray(columnName)) {
                        for(var columnNameIndex in columnName) {
                            console.log('280 : columnNameIndex ljk : '+ columnNameIndex);

                            if(columnName[columnNameIndex].get('v.value') == '' || columnName[columnNameIndex].get('v.value') == null) {
                                $A.util.addClass(columnName[columnNameIndex],'slds-has-error');
                                $A.util.removeClass(columnErrorMessage[columnNameIndex],'slds-hide');
                                errorCount++;

                            } else {
                                if($A.util.hasClass(columnName[columnNameIndex],'slds-has-error')) {
                                    $A.util.removeClass(columnName[columnNameIndex],'slds-has-error')
                                }
                                if(!$A.util.hasClass(columnErrorMessage[columnNameIndex],'slds-hide')) {
                                    $A.util.addClass(columnErrorMessage[columnNameIndex],'slds-hide');

                                }
                            }
                        }
                    } else {
                        if(columnName.get('v.value') == '' || columnName.get('v.value') == null) {
                            $A.util.addClass(columnName,'slds-has-error');
                            $A.util.removeClass(columnErrorMessage,'slds-hide');
                            errorCount++;
                        } else {
                            if($A.util.hasClass(columnName,'slds-has-error')) {
                                $A.util.removeClass(columnName,'slds-has-error')
                            }
                            if(!$A.util.hasClass(columnErrorMessage,'slds-hide')) {
                                $A.util.addClass(columnErrorMessage,'slds-hide');
                            }
                        }
                    }
                }

                /* 반차 휴가 선택할 경우 Required field 표시 해제 ljk */
                console.log('320 : ljk typecheck : ' + typecheck);
                if(typecheck == '' && (typecheck != 'Half-day Leave' && typecheck != 'Reward Half-Holiday')) {
                    if(!errorCount == 0) errorCount--;
                    var halfclass = component.find('half');
                    $A.util.removeClass(halfclass,'slds-has-error');
                    var halferrormessage = component.find('halfErrorMessage');
                    $A.util.addClass(halferrormessage,'slds-hide');
                }
            }

            /*
            jQuery.each(requiredColList, function(index,values) {
                var columnName = component.find(values);
                var columnErrorMessage = component.find(values + 'ErrorMessage');

                if(columnName.get('v.value') == '' || columnName.get('v.value') == null){
                    $A.util.addClass(columnName,'slds-has-error');
                    $A.util.removeClass(columnErrorMessage,'slds-hide');
                    errorCount++;
                }else{
                    if($A.util.hasClass(columnName,'slds-has-error')){
                        $A.util.removeClass(columnName,'slds-has-error')
                    }
                    if(!$A.util.hasClass(columnErrorMessage,'slds-hide')){
                        $A.util.addClass(columnErrorMessage,'slds-hide');
                    }
                }
            });
            */
        }

        if(errorCount > 0) {
            returnValue = true;
        }

        return returnValue;
    },

    initRequiredSet : function(component, event, helper){
        console.log("initRequiredSet init");
        /*inputField
         * 1. aura:id를 모두 같게 코딩한 경우
         * 2. aura:id를 하나만 코딩한 경우
         */
        //debugger;
        if(component.find('inputField') != undefined){

            var requierdList = component.find('inputField');

            if(requierdList.length > 0){

                if($A.util.isArray(requierdList)) {
                    for(var index = 0; index < requierdList.length; index++) {
                        if(requierdList[index].get('v.class') != null && requierdList[index].get('v.class') != ''){
                            if(requierdList[index].get('v.class') == 'customRequired none'){
                                $A.util.removeClass(requierdList[index], "none");
                            }
                        }
                    }
                }
                /*jQuery.each(requierdList, function(index,values) {

                    if(requierdList[index].get('v.class') != null && requierdList[index].get('v.class') != ''){
                        if(requierdList[index].get('v.class') == 'customRequired none'){
                            $A.util.removeClass(requierdList[index], "none");
                        }
                    }
                });*/
            }else{
                if(requierdList.get('v.class') != null && requierdList.get('v.class') != ''){
                    if(requierdList.get('v.class') == 'customRequired none'){
                        $A.util.removeClass(requierdList, "none");


                    }
                }
            }
        }

        var requiredColList = component.get('v.checkRequiredColumn');
        console.log(requiredColList);
        /***********************************************************/
        /************* aura:id를 모두 다르게 했을경우 ****************/
        /***********************************************************/
        /*
         * Field에 Required Field 표시 없애고 싶을경우 아래 css적용
         */
        /*$A.util.removeClass(component.find("type"), "customRequired none");*/
        /*
         * Field에 Required Field 표시하고 싶을 경우 아래 css적용
         */

        if(requiredColList.length > 0){
            if($A.util.isArray(requiredColList)) {
                for(var index = 0; index < requiredColList.length; index++) {
                    var elem = component.find(requiredColList[index]);
                    if($A.util.isArray(elem)) {
                        for(var elemIndex in elem) {
                            if($A.util.hasClass(elem[elemIndex],'none')) {
                                $A.util.removeClass(elem[elemIndex], "none");
                            }
                        }
                    } else {
                        if($A.util.hasClass(elem,'none')) {
                            $A.util.removeClass(elem, "none");
                        }
                    }
                }
            }

            /*jQuery.each(requiredColList, function(index,values) {
                var columnName = component.find(values);
                $A.util.removeClass(columnName, "none");
            });*/
        }
    },

    projectChange : function(component, projectId) {
        var action = component.get('c.getProjectPmId');
        action.setParams({
            "projectId": projectId
        });

        action.setCallback(this, function(response) {
            var result = response.getReturnValue(); // return 값
            console.log("result_projectChange :: ", result);

            if(result != null && result != undefined) {
                if(result.pmId != null && result.pmId != '') {
                    console.log('result.pmId', result.pmId);
                    component.set("v.firstApproverId", result.pmId);
                    component.set("v.HIF.FirstHolidayRequest__c", result.pmId);
                    console.log('v.HIF.FirstHolidayRequest__c :: ', JSON.stringify(component.get("v.HIF.FirstHolidayRequest__c")));
                } else {
                    component.set("v.firstApproverId", "");
                    component.set("v.HIF.FirstHolidayRequest__c", "");
                    this.showSuccessToast(component, 'Error!', 'Error', '프로젝트 관리자가 등록 되어있지 않습니다.');
                }
            }
        });
        $A.enqueueAction(action);
    },

    /**
     *  @author            : yj.kim@daeunextier.com
     *  @description       : 사용자의 잔여 휴가일수 조회
     *  @last modified on  : 2023-06-28
     **/
    getHolidayRemain : function(component, event, helper){
        var action = component.get('c.getHolidayRemain');
        action.setCallback(this, function(response) {
            var result = response.getReturnValue(); // return 값
            console.log("result :: ", result);

            if(result != null && result != undefined){
                component.set('v.totalRemain', result.totalRemain);
                component.set('v.rewardRemain', result.rewardRemain);
            }
            console.log(component.get('v.rewardRemain'));
            if(component.get('v.rewardRemain') > 0 ){
                this.showSuccessToast(component, null, 'warning', '앗, 대체휴가가 남아 있어요!\n대체휴가 먼저 사용해주실래요?');
            }
        });
        $A.enqueueAction(action);
    }
})