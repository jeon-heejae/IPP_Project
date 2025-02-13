/**
 * Created by Kwanwoo.Jeon on 2024-01-04.
 */

({
    ExpFieldLabel : function(component, event, helper){
        var action = component.get("c.getObjectFieldLabel");

        action.setParams({
            "sObjectName" : "Expense__c"
        });

        action.setCallback(this, function(response) {
            var result = response.getReturnValue(); // return 값
            component.set("v.ExpLabel", result);
            //console.log( ' result :: ' + JSON.stringify(result));
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
            if(state==="SUCCESS"){
                if(result['PicklistBudgetType'] == ''){
                    this.showToast('ERROR', '사용 가능한 예산 배정 타입이 없습니다. 관리팀에 문의해주세요');
                    component.set('v.toggleSpinner',false);
                    setTimeout(function() {
                        helper.doCancel(component, event, helper);
                    }, 1500);
                    return;
                }
                component.set("v.objExp", result['Expense']);
                var ExpenseDetail = result['ExpenseDetail'];
//                ExpenseDetail.forEach(function(obj){
//                    obj.CardNickname__c = obj.CorporateCardBilling__r.fm_CardNickname__c
//                    obj.Date__c = obj.BillingDate__c = $A.localizationService.formatDateTime(obj.Date__c);
//                })
                component.set("v.listExpDetail", ExpenseDetail);

                component.set("v.BudgetTypeList",   result['PicklistBudgetType']);
                component.set("v.SalesTypeList",    result['PicklistSalesType']);
                component.set("v.category1",        result['PicklistCategory1']);
                component.set("v.category2",        result['PicklistCategory2']);
                component.set("v.paymentType",      result['PicklistPayment']);
                component.set("v.year",             result['PicklistYear']);
                component.set("v.month",            result['PicklistMonth']);
                helper.fnInitLookupSet(component, event, helper);
                this.fnInitDate(component, event, helper);
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
                year = today.split('-')[0];
                month = today.split('-')[1];

                if(month == '01'){
                    year = parseInt(year);
                    year = year-1;
                    year = year.toString();
                    component.set('v.objExp.UseYear__c',year);
                    month = '12';
                    component.set('v.objExp.UseMonth__c',month);
                } else {
                    month = parseInt(month);
                    month = month-1;
                    month = month.toString();
                    component.set('v.objExp.UseYear__c',year);
                    component.set('v.objExp.UseMonth__c',month);
                }
            }

            //budgetType 없을 때 초기화
            if(!component.get('v.objExp.BudgetType__c')){
                /** kc
                *24.11.01 추가 - 사용자가 전 월에 진행한 프로젝트가 있는경우 -  default : 프로젝트로 설정
                */
                //v.BudgetTypeList 에 프로젝트 항목이 없는 사람 체크
                var projectCheck = false;
                let BudgetTypeList = component.get("v.BudgetTypeList");
                for ( let a in BudgetTypeList){
                    if ( BudgetTypeList[a].value =='프로젝트'){
                         projectCheck = true;
                         break;
                    }
                }
                if(result['PerformProject'].length > 0 && projectCheck){

                    component.set("v.objExp.BudgetType__c", '프로젝트');
                    component.set('v.BudgetType', '프로젝트');
                    for ( let i in BudgetTypeList){
                        if ( BudgetTypeList[i].value =='프로젝트'){
                             BudgetTypeList[i].selected = true;
                        } else {
                             BudgetTypeList[i].selected = false;
                        }
                    }
                    component.set('v.BudgetTypeList', BudgetTypeList);
                    //console.log("objExpForPerformP::", JSON.stringify(component.get("v.objExp")));
//                    if (result['PerformProject'].length < 2){
                        component.set("v.objExp.Project__c",    result['PerformProject'][0].Project__r.Id);
                        component.set("v.ProjectName",          result['PerformProject'][0].Project__r.Name);
//                    }
                } else if ( BudgetTypeList[0].value =='프로젝트'){      //0번째 index가 프로젝트이고 저번달 진행 프로젝트가 없을 때 index1번째 항목을 default
                    if (BudgetTypeList.length <= 1){
                        component.set('v.objExp.BudgetType__c', component.get("v.BudgetTypeList")[0].value);
                        component.set('v.BudgetType', component.get("v.BudgetTypeList")[0].value);
                    }else{
                        component.set('v.objExp.BudgetType__c', component.get("v.BudgetTypeList")[1].value);
                        component.set('v.BudgetType', component.get("v.BudgetTypeList")[1].value);
                            for (let i = 0; i < BudgetTypeList.length; i++) {
                                if (i === 1) {
                                    BudgetTypeList[i].selected = true;
                                } else {
                                    BudgetTypeList[i].selected = false;
                                }
                            }
                    }

                }else {
                    component.set('v.objExp.BudgetType__c', component.get("v.BudgetTypeList")[0].value);
                }
            }
            component.set('v.toggleSpinner',false);
        });
        $A.enqueueAction(action);
    },

    fnDoSave : function(component,event,helper) {
        var action = component.get('c.doSave');

        action.setParams({
            'objExp'        : component.get('v.objExp'),
            'listExpDetail' : component.get('v.listExpDetail'),
            'listDel'       : component.get('v.listDel'),
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
                        this.showToast("error", "ERROR: "+errors[0].message);
                    }
                } else {
                    this.showToast("error", "ERROR"+errors[0].message);
                    console.log("Unknown error");
                }
            }
            component.set('v.toggleSpinner',false);
        });

        $A.enqueueAction(action);
    },

    // Init 시 보여줄 Lookup 된 Object의 Value
    // 사용시 컴포넌트에서 {!v.customLookupUser1st} 으로 선언
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
                "bRequired" : true ,
            },function(newCmp){
//                component.set("v.customLookupUser1st", newCmp);
            }
        );

    },

    fnInitDate: function(component, event, helper){
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        // var today = "2019-01-02";
        var year = today.split('-')[0];
        var month = today.split('-')[1];

        if(month == '01'){
            year = parseInt(year);
            year = year-1;
            year = year.toString();
            month = '12';
        } else {
            month = parseInt(month);
            month = month-1;
            month = month.toString();
        }


        console.log('year: ', year);
        console.log('month: ', month);

        component.set('v.selectedYear',year);
        component.set('v.selectedMonth',month);
    },

    fnGetTerm : function(component, event, helper) {

        var projectId = component.get("v.objExp.Project__c");
        var action = component.get("c.getTerm");
        action.setParams({
            "projectId" : projectId
        });

        action.setCallback(this, function(response) {
            var result = response.getReturnValue(); // return 값
            if (result != null){
                component.set("v.inputDate",        result['inputDate']);
                component.set("v.withdrawDate",     result['withdrawDate']);
                console.log('dateinput&withdra ::',result['inputDate'] );
                console.log('dateinput&withdra ::',result['withdrawDate'] );
            }

            //console.log( ' result :: ' + JSON.stringify(result));
        });
        $A.enqueueAction(action);

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

    doCancel : function(component, event, helper){
        var recordId = component.get('v.recordId');
        if(recordId){
            var rtnUrl = window.location.href;
            var url = "/lightning/r/" + recordId+ "/view";
            window.parent.location = url;
        } else{
            var rtnUrl = window.location.href;
            var url = "/lightning/o/" + "Expense__c" + "/list?filterName=Recent";
            window.parent.location = url;
        }
    },

})