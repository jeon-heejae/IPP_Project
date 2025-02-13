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
*/  


({
    doInit :  function(component, event, helper) {
        helper.selectFieldName(component, event, helper);
        // helper.selfApproverVal(component, event, helper);
        helper.getApproverId(component, event, helper);
        helper.employeeStatus(component, event, helper);
        // helper.userList(component);
        var dayNullcheck = component.get('v.HIF.HolidayAction_Days__c');
        if(dayNullcheck==''){
            component.set('v.HIF.HolidayAction_Days__c',1);
        }
        console.log('v.HIF.FirstHolidayRequest__c', component.get('v.HIF.FirstHolidayRequest__c'));
        console.log('v.HIF.HolidayAction_Days__c', component.get('v.HIF.HolidayAction_Days__c'));
    },

    closeDialog : function(component, event, helper) {
        component.set('v.errormessage', false);

    },

    
    closeDialog2 : function(component, event, helper) {
        component.set('v.errormessage2', false);
    },

    clickCreate: function(component, event, helper) {
       
        var saveList = component.get('v.HIF');
        
        var returnValue = helper.checkRequiredCol(component, event, helper);

        if(returnValue){
            return;
        }else{
            helper.doSave(component, event, helper ,saveList);
        }
    },

    /*fnDoneRendering : function(component, event, helper){
         console.log("fnDoneRendering init");
         helper.initRequiredSet(component, event, helper);-0
    },*/

    showRequiredFields : function(component, event, helper){
        //console.log("showRequiredFields");
        helper.initRequiredSet(component, event, helper);
    },
    
    close : function(component, event, helper) {
        helper.closeModal(component, helper);
    },

    fnCheckIsProject : function(component, event, helper) {
        let position = component.get("v.position");
        component.set("v.HIF.Position__c", position);
        let havingProject = position.indexOf("프로젝트") < 0;
        if(!havingProject){
            component.set("v.isProject", true);
        }else{
            component.set("v.isProject", false);
            component.set("v.projectId", '');
            component.set("v.HIF.projectId", '');
        }
    },

    typeRlatedDate : function(component,event,helper){
        var fieldName = event.getSource().get("v.fieldName");
        var fieldValue = event.getSource().get("v.value");
        var fieldNameList = component.get("v.holidayAction");
        var value = event.getParam('value');
        var typeValue = component.find("type").get("v.value");

        component.set('v.selectedType',typeValue);
        console.log('selectedType : : '+component.get('v.selectedType'));

        if(fieldName != null && fieldName != ''){
            if($A.util.isArray(fieldNameList)) {
                for(var index = 0; index < fieldNameList.length; index++) {
                    if(fieldNameList[index] == fieldName){
                        if(fieldName == 'FirstHolidayRequest__c' || fieldName == 'SecondApproverRequest__c' || fieldName == 'Project__c'){
                            component.set("v.HIF."+fieldNameList[index], fieldValue[0]);
                            if(fieldName == 'SecondApproverRequest__c' && (fieldValue[0] == undefined || fieldValue[0] == null || fieldValue[0] == '')){
                                component.set("v.HIF.SecondApproverSelection__c", false);
                                console.log("v.HIF.SecondApproverSelection__c", component.get("v.HIF.SecondApproverSelection__c"));
                            }else if(fieldName == 'SecondApproverRequest__c' && fieldValue[0] != ''){
                                component.set("v.HIF.SecondApproverSelection__c", true);
                                console.log("v.HIF.SecondApproverSelection__c", component.get("v.HIF.SecondApproverSelection__c"));
                            }
                        }else{
                            component.set("v.HIF."+fieldNameList[index], fieldValue);
                        }
                        console.log("v.HIF."+fieldNameList[index], component.get("v.HIF."+fieldNameList[index]));
                    }
                }
            }
        }

        // helper.dateChange(component,event,helper);

           
        // if(typeValue == 'Half-day Leave'){
        //     component.set('v.selectedType',typeValue);
        //     helper.fnHalfday(component,event,helper);
        // }else if(typeValue == 'Women Holiday'){
        //     helper.fnWomen(component,event,helper);
        // } 
            // component.set('v.HIF.HolidayAction_Days__c', 1);
            // component.set("v.HIF.HolidayAction_Date2__c",'');
            // component.set("v.HIF.HolidayAction_Date3__c",'');
            // component.set("v.HIF.HolidayAction_Date4__c",'');
            // component.set("v.HIF.HolidayAction_Date5__c",'');
            // component.set("v.HIF.HolidayAction_HalfdayTime__c",'');
            // component.set("v.listDate",1);
        


        // var approverId = component.get('v.approverId');
        // var validitycheck = component.find("first");
        // var selfId = component.find("first").get("v.value");
        // if(selfId==approverId){
        //     alert('** ERROR ** : YOU CAN NOT APPOINT YOURSELF AS A APPROVER / 본인으로 승인자 지정 불가');
        //     return null;
        // }


    },
    fnTypeChange : function (component, event, helper) {
        var fieldName = event.getSource().get("v.fieldName");
        var fieldValue = event.getSource().get("v.value");
        var fieldNameList = component.get("v.holidayAction");
        var value = event.getParam('value');
        var typeValue = component.find("type").get("v.value");
        component.set('v.selectedType',typeValue);

        if(typeValue == 'Half-day Leave'){
            component.set('v.selectedType',typeValue);
            helper.fnHalfday(component,event,helper);
        }else if(typeValue == 'Women Holiday'){
            helper.fnWomen(component,event,helper);
        }else {
            component.set('v.HIF.HolidayAction_Days__c', 1);
            component.set("v.HIF.HolidayAction_Date2__c",null);
            component.set("v.HIF.HolidayAction_Date3__c",null);
            component.set("v.HIF.HolidayAction_Date4__c",null);
            component.set("v.HIF.HolidayAction_Date5__c",null);
            component.set("v.HIF.HolidayAction_HalfdayTime__c",null);
            component.set("v.listDate",1);
        }

        if(fieldName != null && fieldName != ''){

            if($A.util.isArray(fieldNameList)) {
                for(var index = 0; index < fieldNameList.length; index++) {

                    if(fieldNameList[index] == fieldName){
                        component.set("v.HIF."+fieldNameList[index], fieldValue);
                    }
                }
            }
        }

        // Class 변경
        //helper.initRequiredSet(component, event, helper);
    },

    fnDateChange : function (component, event, helper) {
        //debugger;
        var fieldNameList = component.get("v.holidayAction");
        var fieldName = event.getSource().get("v.fieldName");
        var fieldValue = event.getSource().get("v.value");
        var dateArray = [];
        for(var i = 1; i <= fieldValue; i++){
            dateArray.push(i);
        }
        console.log('fieldName : '+ fieldName);
        console.log('fieldValue : '+ fieldValue);
        component.set('v.listDate',dateArray);

        helper.dateChange(component,event,helper);
        // helper.fnHalfday(component,event,helper);

        if(fieldName != null && fieldName != ''){

            if($A.util.isArray(fieldNameList)) {
                for(var index = 0; index < fieldNameList.length; index++) {

                    if(fieldNameList[index] == fieldName){
                        component.set("v.HIF."+fieldNameList[index], fieldValue);
                    }
                }
            }
        }

        // Class 변경
        //helper.initRequiredSet(component, event, helper);
    },

    fnDateSave : function (component, event, helper) { 
        var fieldNameList = component.get("v.holidayAction");
        var fieldName = event.getSource().get("v.fieldName");
        var fieldValue = event.getSource().get("v.value");
        console.log('fieldName : '+ fieldName);
        console.log('fieldValue : '+ fieldValue);

        if(fieldName != null && fieldName != ''){

            if($A.util.isArray(fieldNameList)) {
                for(var index = 0; index < fieldNameList.length; index++) {


                    if(fieldNameList[index] == fieldName){
            
                        component.set("v.HIF."+fieldNameList[index], fieldValue);
                    }
                }
            }
        }

        console.log('DATE1 : '+component.get('v.HIF.HolidayAction_Date1__c'));
    },




})