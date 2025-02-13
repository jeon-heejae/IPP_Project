({
    ExpFieldLabel : function(component, event, helper){
        var action = component.get("c.getObjectFieldLabel");

        action.setParams({
            "sObjectName" : "Expense__c"
          });
            action.setCallback(this, function(response) {
            var result = response.getReturnValue(); // return 값 
            component.set("v.ExpLabel", result);
        }); 
        $A.enqueueAction(action);
    },

    ExpDetailFieldLabel : function(component, event, helper){
        var action = component.get("c.getObjectFieldLabel");

        action.setParams({
            "sObjectName" : "ExpenseDetail__c"
          });
            action.setCallback(this, function(response) {
            var result = response.getReturnValue(); // return 값 
            component.set("v.ExpDetailLabel", result);
        }); 
        $A.enqueueAction(action);
    },

    InitData : function(component, event, helper){
        var action = component.get("c.getInitData");
        action.setParams({
            "expId" : component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue(); // return 값 
            var state = response.getState();
            console.log('state :: Init ::' + state);
            if(state==="SUCCESS"){ 
                console.log("result['ExpenseDetail'] : " + result['ExpenseDetail']);
                console.log('아래 result 확인');
                console.log(result); 
                component.set("v.objExp", result['Expense']);
                component.set("v.listExpDetail", result['ExpenseDetail']);
                component.set("v.category1", result['PicklistCategory1']);
                component.set("v.category2", result['PicklistCategory2']);
                component.set("v.paymentType", result['PicklistPayment']);
                component.set("v.year", result['PicklistYear']);
                component.set("v.month", result['PicklistMonth']);
                helper.fnInitLookupSet(component, event, helper);
                // helper.fnAccordionActive(component, event, helper);  
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }

            // Date 값 없을 시 오늘로 설정            
            var month = component.get('v.objExp.UseMonth__c');        
            var year = component.get('v.objExp.UseYear__c');        
                if(!year || !month){
                    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                    // var today = "2019-01-02";
                    year = today.split('-')[0];
                    month = today.split('-')[1];                    

                    if(month == '01'){
                        year = parseInt(year);
                        year = year-1;
                        year = year.toString();                        
                        component.set('v.objExp.UseYear__c',year);
                        month = '12';
                        component.set('v.objExp.UseMonth__c',month);

                    }else if('01' < month  < '10'){
                        month = parseInt(month.substring(1));
                        month = month-1;
                        month = month.toString();
                        component.set('v.objExp.UseYear__c',year);
                        component.set('v.objExp.UseMonth__c',month);
                    }else if(month >= '10'){
                        component.set('v.objExp.UseYear__c',year);
                        component.set('v.objExp.UseMonth__c',month);
                    }
             }

            component.set('v.toggleSpinner',false);
            // helper.fnInitRowSet(component,event,helper);
        }); 
    

        $A.enqueueAction(action);

    },    

    fnDoSave : function(component,event,helper) {
        var action = component.get('c.doSave');
        action.setParams({
            'objExp' : component.get('v.objExp'),
            'listExpDetail' : component.get('v.listExpDetail'),
            'listDel' : component.get('v.listDel'),
            // ExpndseNewHelper 역기서 파리메터 보내주면 19.08.05

        });
        action.setCallback(this, function(response) {
            var state = response.getState();
    
            if(state === 'SUCCESS') {
                var sReturnValue  = response.getReturnValue();                
                var resultArray = [];
                resultArray = sReturnValue.split('/');
                //Error Message 를 해당 String 으로 대체
                if(resultArray[2].includes('REQUIRED_FIELD_MISSING')){
                    resultArray[2] = '  모든 필드를 작성해 주세요';
                }

                if(resultArray[0] != 'ERROR'){
                    var rtnUrl = window.location.href;
                    var url = "/lightning/r/" + resultArray[2] + "/view";
                    window.parent.location = url;
                    this.showToast(resultArray[0], resultArray[1]);
                }else{
                    this.showToast(resultArray[0], resultArray[1] + resultArray[2]);
                }


            }else if(state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +errors[0].message);
                        helper.showToast("ERROR"+errors[0].message);
                        return null;
                    }

                } else {
                    helper.showToast("ERROR"+errors[0].message);
                    return null;
                    console.log("Unknown error");

                }

            }
            component.set('v.toggleSpinner',false);
        });
        
        $A.enqueueAction(action);
    },

    //Init 시 보여줄 Lookup 된 Object의 Value
    //사용시 컴포넌트에서 {!v.customLookupUser1st} 으로 선언
    fnInitLookupSet : function (component, event, helper){
        var user  = component.get('v.objExp.FirstExpenseRequest__c');
        $A.createComponent(
                 "c:CommonLookup",
                 {
                     "aura:id" : "user1" ,
                     "sId":  component.get('v.objExp.FirstExpenseRequest__c'),
                     "sNm" : component.get('v.objExp.FirstExpenseRequest__r.Name'),
                     "sLabel" : "1차승인자" ,
                     "sObj" : "User" ,
                     "sIconName" : "standard:user" ,
                     "bShowSearchIcon" : false ,
                     "bRequired" : true 


                 },function(newCmp){
                    component.set("v.customLookupUser1st", newCmp);
                    
                 }
             );

    },

    // fnInitRowSet : function(component, event, helper){
    //     var listExpDetail = component.get('v.listExpDetail');
    //     console.log('listExpDetail :'+listExpDetail);
    //     if(listExpDetail[0] == null){        
    //         var listExpDetailTemp = {
    //                 Id: null ,
    //                 Name: null ,                
    //                 Date__c:  $A.localizationService.formatDate(new Date(), "YYYY-MM-DD") ,
    //                 Category1__c: '본사행정',         
    //                 Category2__c: '식비',
    //                 Project_Name__c:  null ,

    //                 Project_Name__r:  { Name : '' } ,
                    
    //                 Opportunity_Name__c: null ,
    //                 Opportunity_Name__r: { Name : '' } ,

    //                 Payment_Type__c: '개인카드' ,
    //                 Amount__c:  0 ,
    //                 Description__c: ''
    //         }
    //         listExpDetail.push(listExpDetailTemp);

    //         component.set('v.listExpDetail[0]',listExpDetail);
    //     }

    // },

    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");

        evt.setParams({
            duration : 4000,
            key      : "info_alt",            
            type     : type,
            message  : message
        });

        evt.fire();
    },

})