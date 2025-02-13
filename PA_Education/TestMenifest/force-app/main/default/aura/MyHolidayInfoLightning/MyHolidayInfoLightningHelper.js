/*
* Component Name                : MyHolidayInfoLightning.cmp
* Component Controller          : MyHolidayInfoLightningController.js
* Component Helper              : MyHolidayInfoLightningHelper.js
* Component Contorlller Class   : HolidayController.cls
* Test Class                    : HolidayController_Test.cls
* Description                   : 휴가정보 Detail
* Modification Log 
* =============================================================== 
* Ver     Date          Author           Modification
* ===============================================================
  1.0   2018.08.27      MH.Kwak             Create
  1.0   2018.12.27      JK.Lee              Modified
*/

({
    getActionLabel: function (component, event, helper) {
        var action = component.get('c.getObjectFieldLabel');
        action.setParams({
            "sObjectName": "HolidayAction__c"
        });
        action.setCallback(this, function (reponse) {
            var state = reponse.getState();
            var result = reponse.getReturnValue();
            component.set('v.holidayActionMapLabel', result);
        });
        $A.enqueueAction(action);
    },

    getHolidayLabel: function (component, event, helper) {
        var action = component.get('c.getObjectFieldLabel');
        action.setParams({
            "sObjectName": "Holiday__c"
        });
        action.setCallback(this, function (reponse) {
            var state = reponse.getState();
            var result = reponse.getReturnValue();
            component.set('v.holidayMapLabel', result);
        });

        $A.enqueueAction(action);
    },

    getHoliday: function (component, event, helper) {
        var action = component.get('c.getHoliday');

        action.setParams({
            "userId": component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            var state = response.getState();
            var error = response.getError();

            if (state == 'SUCCESS') {
                console.log('getHoliday', result);
                component.set('v.holiday', result);
                helper.getHolidayHistory(component, event, helper);
            } else {
                console.log('error', error);
            }
            component.set('v.togglespinner', false);
        });

        $A.enqueueAction(action);
    },

    getPermCheck: function (component, event, helper) {
        component.set('v.togglespinner', true);
        var action = component.get('c.getPermissionCheck');
        action.setParams({
            "userId": component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            var state = response.getState();

            if (state == 'SUCCESS') {
                console.log('getPermCheck', result);
                component.set('v.holidayPerm', result);
                if (result) {
                    helper.getHoliday(component, event, helper);
                    helper.getHolidayActionList(component, event, helper);
                } else {
                    helper.getHolidayActionList(component, event, helper);
                }
            }

            component.set('v.toggleSpinner', false);
        });
        $A.enqueueAction(action);
    },

    // getHolidayActionList : function(component, holidayPerm, helper){
    //  console.log('HoldiayActionList 들어옴');
    //  var action = component.get('c.getHolidayAction');
    //  action.setParams({
    //      "userId" : component.get('v.recordId'),
    //      "holidayPerm" : holidayPerm
    //  });
    //  action.setCallback(this,function(response){
    //    var result =response.getReturnValue();
    //    var state = response.getState();
    //    console.log("state : " + state);
    //    if(state =='SUCCESS'){
    //      component.set('v.holidayAction',result);

    //    }
    //    component.set('v.toggleSpinner',false);
    //  });
    //   $A.enqueueAction(action);
    // },

    getHolidayActionList: function (component, event, helper) {
        var perm = component.get('v.holidayPerm');
        var action = component.get('c.getHolidayAction');
        action.setParams({
            "userId": component.get('v.recordId'),
            "holidayPerm": perm
        });
        action.setCallback(this, function (reponse) {
            var result = reponse.getReturnValue();
            var state = reponse.getState();

            if (state == 'SUCCESS') {
                console.log('getHolidayActionList', result);
                component.set('v.holidayAction', result);
            }

            component.set('v.toggleSpinner', false);
        });
        $A.enqueueAction(action);
    },

    getHolidayHistory: function (component, event, helper) {
        var action = component.get('c.getHolidayHistory');
        action.setParams({
            "userId": component.get('v.recordId')
        });
        action.setCallback(this, function (reponse) {
            var result = reponse.getReturnValue();
            var state = reponse.getState();

            if (state == 'SUCCESS') {
                console.log('getHolidayHistory', result);
                component.set('v.holidayHistory', result);
            }

            component.set('v.toggleSpinner', false);
        });
        $A.enqueueAction(action);
    },

    /*
    getUserId : function(component,helper) {
        var action = component.get('c.userIdCheck');
        var currentId = component.get('v.recordId');

        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            component.set('v.currentId',result);
            if(currentId==result) {
                component.set('v.holidayOwnerCheck',true);
            } else {
                component.set('v.holidayOwnerCheck',false);
            }
        });
        $A.enqueueAction(action);
    },
    */
    
    goDetail: function (component, event, helper) {
        $A.createComponent(
            "c:NewHolidayLightning",
            {
                'userName': '',
                'approverId': '',
                'thisRecordId': component.get('v.recordId')
            },
            function (newCmp) {
                component.set('v.body', newCmp);
            }
        );
    }
});