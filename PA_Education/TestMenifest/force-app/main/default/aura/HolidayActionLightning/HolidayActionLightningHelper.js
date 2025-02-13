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
        var modal = component.find('divModal');
        $A.util.removeClass(modal, 'slds-show');
        $A.util.addClass(modal, 'slds-hide');
        component.find('first').set('v.value',null);
        component.set('v.firstApproverId',null);
        component.find('second').set('v.value',null);
        component.set('v.secondApproverId',null);
        component.set('v.holidayModalView', false);

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
    getApproverId : function (component, event, helper){
        var action = component.get('c.getApproverId');
        action.setCallback(this, function(response) {
            var result = response.getReturnValue(); // return 값
            console.log('getApproverId', result);
            component.set("v.firstApproverId", result[2] != null ? result[2] : null);
            component.set("v.HIF.FirstHolidayRequest__c", result[2] != null ? result[2] : null);
            component.set("v.secondApproverId", result[3] != null ? result[3] : null);
            component.set("v.HIF.SecondApproverRequest__c", result[3] != null ? result[3] : null);
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
            var state = response.getState();
            console.log("state : ", state);
            if(state != "SUCCESS") {
                console.log(response.getError());
            }

            var result = response.getReturnValue(); // return 값
            console.log("result : ", result);
            if(result != null || result != undefined) {
                component.set("v.department", result[0].Department__c);
                component.set("v.HIF.Department__c", result[0].Department__c);
                console.log("EmployeePerformProject", result[0].EmployeePerformPjt__r);
                if(result[0].EmployeePerformPjt__r != null || result[0].EmployeePerformPjt__r != undefined) {
                    component.set("v.isProject", true);
                    component.set("v.projectId", result[0].EmployeePerformPjt__r[0].Project__c);
                    component.set("v.HIF.Project__c", result[0].EmployeePerformPjt__r[0].Project__c);
                    if(result[0].EmployeePerformPjt__r[0].IsPM__c == true || result[0].EmployeePerformPjt__r[0].IsPM__c == 'true') {
                        component.set("v.position", "프로젝트 PM");
                        component.set("v.HIF.Position__c", "프로젝트 PM");
                    } else {
                        component.set("v.position", "프로젝트 팀원");
                        component.set("v.HIF.Position__c", "프로젝트 팀원");
                    }
                } else {
                    component.set("v.position", "본사근무");
                    component.set("v.HIF.Position__c", "본사근무");
                }
                if(result[0].fm_Position__c == "임원") {
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

    doSave : function(component, event, helper,saveList) {
        component.set("v.showSpinner", true);
        console.log('[dosave] saveList', saveList);
        console.log(component.get('v.thisRecordId'));

        var isCheck = true;
        var action  = component.get("c.doHolidayAction"); 
        action.setParams({
            "saveList": saveList,
            "currentUserId" : component.get('v.thisRecordId')
        });

        action.setCallback(this, function(response) {
            var result = response.getReturnValue(); 
            var state = response.getState(); 
            var errors = response.getError();
            var naviDetail = $A.get("e.force:navigateToComponent");
            console.log('result : ' + result);
            console.log('state : ' + state);
            console.log('errors : ' + errors);

            if (errors) {
                if (errors[0] && errors[0].message) {
                    console.log("Error message: " + errors[0].message);
                }
            } else {
                console.log("Unknown error");
            }

            if(state == 'SUCCESS') {
                console.log('SUCCESS: :' + state);
                if(result != '') {
                    isCheck = false;
                }
                if(isCheck){
                    if(result.includes('Already applied a Women Holiday this month')) {
                        this.showSuccessToast(component, 'Error!', 'Error',result);
                        return null;
                    }
                    component.set("v.showSpinner", false);
                    this.showSuccessToast(component, 'Success!', 'Success' ,'Your holiday application has submitted : 휴가 신청이 완료 되었습니다. 승인 프로세스를 진행 해주세요');
                    helper.closeModal(component, helper);

                    var recordId = component.get('v.thisRecordId');
                        if(recordId){
                            var rtnUrl = window.location.href;
                            var url = "/lightning/r/" + recordId+ "/view";
                            window.parent.location = url;
                        } else{
                            var rtnUrl = window.location.href;
                            var url = "/lightning/o/" + "User" + "/list?filterName=Recent";
                            window.parent.location = url;
                        }
                    
                    console.log('SUCCESS: :' + state);
                    //     naviDetail.setParams({
                    //       componentDef: "c:HolidayInfoDetailLightning",
                    //     //   componentAttribute: {
                    //     //         "thisRecordId" : component.get('v.thisRecordId')
                    //     // }
                    // });
                    // naviDetail.fire();
                } else {
                    component.set("v.showSpinner", false);
                    if(result.includes('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY')){
                        this.showSuccessToast(component, 'Error!', 'Error', 'Please check whether approver is you, or contact to system admin : 본인 신청 금지.');
                        return null;
                    }else{
                        this.showSuccessToast(component, 'Error!', 'Error',result);
                        return null;
                    }
                }
            }
        }); 
        $A.enqueueAction(action);
    },


    showSuccessToast : function(component, title, type, message) {
        var toastEvent = $A.get( "e.force:showToast" );
        toastEvent.setParams( {
            "title" : title
            , "type" : type
            , "message" : message
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

    dateChange : function(component,event,helper){
        var countDate = event.getSource().get("v.value");   
        console.log('countDate  :'+countDate);
             if(countDate =="1"){            
                 component.set("v.HIF.HolidayAction_Date2__c",null);
                 component.set("v.HIF.HolidayAction_Date3__c",null);
                 component.set("v.HIF.HolidayAction_Date4__c",null);
                 component.set("v.HIF.HolidayAction_Date5__c",null);
             }if(countDate  =="2"){
                 component.set("v.HIF.HolidayAction_Date3__c",null);
                 component.set("v.HIF.HolidayAction_Date4__c",null);
                 component.set("v.HIF.HolidayAction_Date5__c",null);
             }if(countDate =="3"){
                 component.set("v.HIF.HolidayAction_Date4__c",null);
                 component.set("v.HIF.HolidayAction_Date5__c",null);
                  
             }if(countDate =="4"){
                 component.set("v.HIF.HolidayAction_Date5__c",null);
             }if(countDate =="5"){
         
       }
    },

    fnHalfday : function(component,event,helper){
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

    fnWomen : function(component,event,helper){
        var typeValue = component.find("type").get("v.value");
            component.set("v.HIF.HolidayAction_Days__c",1);
            //date 필드에 입력된 값 초기화
            component.set("v.HIF.HolidayAction_Date2__c",null);
            component.set("v.HIF.HolidayAction_Date3__c",null);
            component.set("v.HIF.HolidayAction_Date4__c",null);
            component.set("v.HIF.HolidayAction_Date5__c",null);
            component.set("v.listDate",1);
        
 
    },


    checkRequiredCol : function(component, event, helper){
        //debugger;
        var errorCount  = 0;
        var returnValue = false;
        // var halfcheck = component.find('half').get('v.value');
        var typecheck = component.find('type').get('v.value');
        /*
         * 1. aura:id를 모두 같게 코딩한 경우
         * 2. aura:id를 하나만 코딩한 경우        
         */
        if(component.find('inputField') != undefined){

            var requierdList = component.find('inputField');
            var errorMessage = component.find('errorMessage');

            console.log('requiredList Length-------------////'+requierdList.length);
            if(requierdList.length > 0){

                if($A.util.isArray(requierdList)) {
                    for(var index = 0; index < requierdList.length; index++) {
                        if(requierdList[index].get('v.class') != null && requierdList[index].get('v.class') != ''){
                            if( requierdList[index].get('v.class') == 'customRequired none' && 
                                (requierdList[index].get('v.value') == '' || requierdList[index].get('v.value') == null) ){
                                errorCount++;
                                $A.util.addClass(requierdList[index],'slds-has-error');
                                $A.util.removeClass(errorMessage[index],'slds-hide');

                            }else if(requierdList[index].get('v.class') == 'customRequired none' && 
                                    (requierdList[index].get('v.value') != '' && requierdList[index].get('v.value') != null)){

                                if($A.util.hasClass(requierdList[index],'slds-has-error')){
                                    $A.util.removeClass(requierdList[index],'slds-has-error')
                                }
                                if(!$A.util.hasClass(errorMessage[index],'slds-hide')){
                                    $A.util.addClass(errorMessage[index],'slds-hide');
                                }
                            }
                        }
                    }
                }
                /*jQuery.each(requierdList, function(index,values) {

                    if(requierdList[index].get('v.class') != null && requierdList[index].get('v.class') != ''){
                        if( requierdList[index].get('v.class') == 'customRequired none' && 
                            (requierdList[index].get('v.value') == '' || requierdList[index].get('v.value') == null) ){
                            errorCount++;
                            $A.util.addClass(requierdList[index],'slds-has-error');
                            $A.util.removeClass(errorMessage[index],'slds-hide');

                        }else if(requierdList[index].get('v.class') == 'customRequired none' && 
                                (requierdList[index].get('v.value') != '' && requierdList[index].get('v.value') != null)){

                            if($A.util.hasClass(requierdList[index],'slds-has-error')){
                                $A.util.removeClass(requierdList[index],'slds-has-error')
                            }
                            if(!$A.util.hasClass(errorMessage[index],'slds-hide')){
                                $A.util.addClass(errorMessage[index],'slds-hide');
                            }
                        }
                    }
                });*/
            }else{
                if(requierdList.get('v.value') == '' || requierdList.get('v.value') == null){
                    // if(!halfcheck == '' && typecheck=='Half-day Leave'){
                    //     $A.util.hasClass(requierdList,'slds-has-error');
                    //     $A.util.addClass(errorMessage,'slds-hide');
                    // }else{

                    errorCount++;
                    $A.util.addClass(requierdList,'slds-has-error');
                    $A.util.removeClass(errorMessage,'slds-hide');


                }else{
                    if($A.util.hasClass(requierdList,'slds-has-error')){
                        $A.util.removeClass(requierdList,'slds-has-error')
                    }
                    if(!$A.util.hasClass(errorMessage,'slds-hide')){
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


        if(halfNullCheck =='Half-day Leave' && !indexhalf){
            console.log('-----half push 하는 if문');
            requiredColList.push('half');
        }else if(halfNullCheck !='Half-day Leave' && indexhalf){
            console.log('-----half pop 하는 if문');            
            requiredColList.splice(indexhalf,1);
        }


    
        console.log('requiredColList : : : '+requiredColList);
        if(requiredColList.length > 0){

            if($A.util.isArray(requiredColList)) {
                for(var index = 0; index < requiredColList.length; index++) {
                    var columnName = component.find(requiredColList[index]);
                    var columnErrorMessage = component.find(requiredColList[index] + 'ErrorMessage');
                    console.log('360 : columnName : '+ columnName);

                    if($A.util.isArray(columnName)) {
                        for(var columnNameIndex in columnName) {
                                console.log('280 : columnNameIndex ljk : '+ columnNameIndex);
                            
                            if(columnName[columnNameIndex].get('v.value') == '' || columnName[columnNameIndex].get('v.value') == null){
                                $A.util.addClass(columnName[columnNameIndex],'slds-has-error');
                                $A.util.removeClass(columnErrorMessage[columnNameIndex],'slds-hide');
                                errorCount++;

                            }else{
                                if($A.util.hasClass(columnName[columnNameIndex],'slds-has-error')){
                                    $A.util.removeClass(columnName[columnNameIndex],'slds-has-error')
                                }
                                if(!$A.util.hasClass(columnErrorMessage[columnNameIndex],'slds-hide')){
                                    $A.util.addClass(columnErrorMessage[columnNameIndex],'slds-hide');
                                
                                }
                            }
                        }
                    } else {
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
                    }


                    


                }
                /*반차 휴가 선택할 경우 Required field 표시 해제 ljk*/
                console.log('320 : ljk typecheck : ' + typecheck);
                if(typecheck == '' && typecheck!='Half-day Leave'){
                    if(!errorCount==0) errorCount--;
                    var halfclass = component.find('half');
                    $A.util.removeClass(halfclass,'slds-has-error');
                    var halferrormessage = component.find('halfErrorMessage');
                    $A.util.addClass(halferrormessage,'slds-hide');
                }

            }
            /*jQuery.each(requiredColList, function(index,values) {
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
            });*/
        }

        if(errorCount > 0){
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

})