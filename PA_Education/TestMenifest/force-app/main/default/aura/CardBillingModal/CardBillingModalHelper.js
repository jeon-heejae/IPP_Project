/**
 * Created by Kwanwoo.Jeon on 2024-01-03.
 */

({
    /**
     * @description 청구내역 조회 및 변수 설정
     */
    getData : function(component, event, helper){
        var action       = component.get("c.getData");
        var BudgetType   =  component.get("v.BudgetType")
        var selectedItem = component.get('v.listExpDetail').map(obj => obj.CorporateCardBilling);

        console.log( 'component.get("v.UseYear__c") :: ' + component.get("v.UseYear__c"));
        console.log( 'component.get("v.UseMonth__c") :: ' + component.get("v.UseMonth__c"));
        action.setParams({
           intYear : component.get("v.UseYear__c"),
           intMonth : component.get("v.UseMonth__c"),
           budgetType : BudgetType,
           listSelected : selectedItem
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state == "SUCCESS") {
                var returnVal = response.getReturnValue();
                var listCardNickName = component.get('v.listCardNickName');

                if(component.get('v.listExpDetail').length > 0 ){
                    returnVal.forEach(function(obj){
                        console.log('obj : ' + obj);
                        obj.checked = selectedItem.includes(obj.Id)? true : false;
                        if(!listCardNickName.includes(obj.CorporateCardNickName)){
                            listCardNickName.push(obj.CorporateCardNickName);
                        }
                    });
                }else{
                    returnVal.forEach(function(obj){
                        obj.checked = false;
                        if(!listCardNickName.includes(obj.CorporateCardNickName)){
                            listCardNickName.push(obj.CorporateCardNickName);
                        }
                    });
                }
                if(BudgetType == "프로젝트"){
                    var inputDate    = new Date(component.get("v.inputDate"));
                    var withDrawDate = new Date(component.get("v.withdrawDate"));
                    if (inputDate != null && withDrawDate != null){
                        withDrawDate.setDate(withDrawDate.getDate()+1);
                        console.log('objDate :::', withDrawDate);

                        returnVal.forEach(function(obj){
                           var objDate      = new Date(obj.BillingDate);
                           console.log('objDate :::', objDate);
                           if (inputDate <= objDate && withDrawDate >= objDate){
                               obj.checked = true;
                           }
                        });
                    }

                }
                console.log('returnVal', returnVal);
                component.set('v.Data', returnVal);

                component.set('v.selectedCardData', returnVal);

                if(listCardNickName.length > 0){
                    component.set('v.listCardNickName', listCardNickName);
                }

                if(returnVal.filter(obj => obj.checked == false).length <= 0){
                    component.set('v.checked', true);
                }
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },

    gfnChangeCard :function(component, event, helper){
        var selectedCard = component.get('v.selectedCard');
        var Data = component.get('v.Data');
        var selectedCardData;

        if(selectedCard != 'All'){
            selectedCardData = component.get('v.Data').filter(obj => obj.CorporateCardNickName == selectedCard);
        }else{
            selectedCardData = component.get('v.Data')
        }
        component.set('v.selectedCardData', selectedCardData);
        if(selectedCardData.filter(obj => obj.checked == false).length <= 0){
            component.set('v.checked', true);
        }else{
            component.set('v.checked', false);
        }

    }
});