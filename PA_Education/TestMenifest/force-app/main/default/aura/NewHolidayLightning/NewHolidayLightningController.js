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

        if ( $A.get("$Browser.formFactor") == 'DESKTOP') {
            component.set('v.device', 'DeskTop');
        }  else {
            component.set('v.device', 'Mobile');
        }

        helper.selectFieldName(component, event, helper);
        // helper.selfApproverVal(component, event, helper);
        helper.getApproverId(component, event, helper);
        helper.employeeStatus(component, event, helper);
        // helper.userList(component);
        helper.getHolidayRemain(component, event, helper);

        var dayNullcheck = component.get('v.HIF.HolidayAction_Days__c');
        if(dayNullcheck=='') {
            component.set('v.HIF.HolidayAction_Days__c',1);
        }
    },

    closeDialog : function(component, event, helper) {
        component.set('v.errormessage', false);
    },

    closeDialog2 : function(component, event, helper) {
        component.set('v.errormessage2', false);
    },

    clickCreate: function(component, event, helper) {
        var saveList = component.get('v.HIF');
        var params = event.getParams();
        var returnValue = helper.checkRequiredCol(component, event, helper);
        console.log('clickCreate ::', JSON.stringify(saveList), params, returnValue);

        if(returnValue) {
            return;
        } else {
            helper.doSave(component, event, helper, saveList);
        }
    },

    /*
    fnDoneRendering : function(component, event, helper){
         console.log("fnDoneRendering init");
         helper.initRequiredSet(component, event, helper);-0
    },
    */

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
        if(!havingProject) {
            component.set("v.isProject", true);
        } else {
            component.set("v.isProject", false);
            component.set("v.projectId", '');
            component.set("v.HIF.projectId", '');
            component.set("v.HIF.Project__c", '');
        }
    },

    typeRlatedDate : function(component,event,helper) {
        var fieldName = event.getSource().get("v.fieldName");
        var fieldValue = event.getSource().get("v.value");
        var fieldNameList = component.get("v.holidayAction");
        var value = event.getParam('value');
        var typeValue = component.find("type").get("v.value");
        var EmployeePerformProject = component.get("v.EmployeePerformProject");

        console.log('typeRlatedDate :::', {
            fieldName : fieldName,
            fieldValue : fieldValue,
            fieldNameList : fieldNameList,
            value : value,
            typeValue : typeValue,
            EmployeePerformProject : EmployeePerformProject,
            position : component.get("v.position")
        });

        component.set('v.selectedType', typeValue);
        console.log('selectedType : : '+component.get('v.selectedType'));

        if(fieldName != null && fieldName != '') {
            if($A.util.isArray(fieldNameList)) {
                for(var index = 0; index < fieldNameList.length; index++) {
                    if(fieldNameList[index] == fieldName) {
                        if(fieldName == 'FirstHolidayRequest__c' || fieldName == 'SecondApproverRequest__c' || fieldName == 'Project__c') {

                            component.set("v.HIF." + fieldNameList[index], fieldValue[0]);
                            if(fieldName == 'SecondApproverRequest__c' && (fieldValue[0] == undefined || fieldValue[0] == null || fieldValue[0] == '')) {
                                component.set("v.HIF.SecondApproverSelection__c", false);
                                console.log("v.HIF.SecondApproverSelection__c", component.get("v.HIF.SecondApproverSelection__c"));
                            } else if(fieldName == 'SecondApproverRequest__c' && fieldValue[0] != '') {
                                component.set("v.HIF.SecondApproverSelection__c", true);
                                console.log("v.HIF.SecondApproverSelection__c", component.get("v.HIF.SecondApproverSelection__c"));
                            } else if(fieldName == 'Project__c' && fieldValue[0] != null && fieldValue[0] != '' && component.get("v.position") == '프로젝트 팀원') { // 프로젝트 변경 시, 1차 승인자를 PM으로 설정
                                helper.projectChange(component, fieldValue[0]);
                            }
                        } else {
                            component.set("v.HIF."+fieldNameList[index], fieldValue);
                        }
                        console.log("v.HIF."+fieldNameList[index], component.get("v.HIF."+fieldNameList[index]));
                    }
                }
            }
        }

        /*
        helper.dateChange(component, event, helper);

        if(typeValue == 'Half-day Leave') {
            component.set('v.selectedType',typeValue);
            helper.fnHalfday(component,event,helper);
        } else if(typeValue == 'Women Holiday') {
            helper.fnWomen(component,event,helper);
        }
        component.set('v.HIF.HolidayAction_Days__c', 1);
        component.set("v.HIF.HolidayAction_Date2__c",'');
        component.set("v.HIF.HolidayAction_Date3__c",'');
        component.set("v.HIF.HolidayAction_Date4__c",'');
        component.set("v.HIF.HolidayAction_Date5__c",'');
        component.set("v.HIF.HolidayAction_HalfdayTime__c",'');
        component.set("v.listDate",1);

        var approverId = component.get('v.approverId');
        var validitycheck = component.find("first");
        var selfId = component.find("first").get("v.value");
        if(selfId==approverId) {
            alert('** ERROR ** : YOU CAN NOT APPOINT YOURSELF AS A APPROVER / 본인으로 승인자 지정 불가');
            return null;
        }
        */
    },

    fnTypeChange : function (component, event, helper) {
        var fieldName = event.getSource().get("v.fieldName");
        var fieldValue = event.getSource().get("v.value");
        var fieldNameList = component.get("v.holidayAction");
        var value = event.getParam('value');
        var typeValue = component.find("type").get("v.value");
        component.set('v.selectedType',typeValue);

        if(typeValue == 'Half-day Leave' || typeValue == 'Reward Half-Holiday') {
            helper.fnHalfday(component, event, helper);
        } else if(typeValue == 'Women Holiday') {
            helper.fnWomen(component, event, helper);
        } else {
            component.set('v.HIF.HolidayAction_Days__c', 1); // note : 단위 일수
            component.set("v.HIF.HolidayAction_Date2__c", null);
            component.set("v.HIF.HolidayAction_Date3__c", null);
            component.set("v.HIF.HolidayAction_Date4__c", null);
            component.set("v.HIF.HolidayAction_Date5__c", null);
            component.set("v.HIF.HolidayAction_HalfdayTime__c", null);
            component.set("v.listDate", 1);
            // console.log('%c'+component.get("v.listDate"),'background:lightgreen');
        }

        if(fieldName != null && fieldName != '') {
            if($A.util.isArray(fieldNameList)) {
                for(var index = 0; index < fieldNameList.length; index++) {
                    if(fieldNameList[index] == fieldName) {
                        component.set("v.HIF."+fieldNameList[index], fieldValue);
                    }
                }
            }
        }

        // Class 변경
        // helper.initRequiredSet(component, event, helper);
    },

    fnDateChange : function (component, event, helper) {
        var fieldValue = event.getSource().get("v.value");
        var dateArray = [];
        for(var i = 1; i <= fieldValue; i++){
            dateArray.push(i);
        }
        console.log('fieldValue : '+ fieldValue);
        component.set('v.listDate',dateArray);

        helper.dateChange(component,event,helper);
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


// fix : 없애야할듯?
    handleSuccess: function(component, event, helper) {
        console.log('%chandleSuccess]==start===============','background:lightgreen');
        var params = event.getParams();
        component.find("navService").navigate({
            "type": "standard__recordPage",
            "attributes": {
                "recordId": params.response.id,
                "objectApiName": "holidayAction__c",
                "actionName": "view"
            }
        });
//        component.set("v.isModalOpen", false);
        console.log('%chandleSuccess]==end===============','background:lightgreen');
    }
})