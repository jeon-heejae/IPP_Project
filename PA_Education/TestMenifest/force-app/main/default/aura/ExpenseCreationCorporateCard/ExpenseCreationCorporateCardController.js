/**
 * Created by Kwanwoo.Jeon on 2024-01-04.
 */

({
    /**
     * @description doInit
     */
	fnInit : function(component, event, helper) {
        component.set('v.toggleSpinner',true);
        if(component.get("v.recordId")){
            component.set("v.showModal", false);
        }

		helper.InitData(component,event,helper);
		helper.ExpFieldLabel(component);
		helper.ExpDetailFieldLabel(component);
	},

    /**
     * @description 경비신청 아코디언 열기/닫기
     */
    fnChangeState1 : function (component){
	   component.set('v.isExp',!component.get('v.isExp'));
	 },

    /**
     * @description 경비신청상세 아코디언 열기/닫기
     */
    fnChangeState2 : function (component){
	   component.set('v.isExpDetail', !component.get('v.isExpDetail'));
	 },

    /**
     * @description 경비규정 팁 모달 열기
     */
	fnMouseOver : function(component, event, helper){
		component.set('v.mouseOver', true);
	},

    /**
     * @description 경비규정 팁 모달 닫기
     */
	fnCloseModal : function(component, event) {
        var modal = component.find("divModal");
        $A.util.removeClass(modal, "slds-show");
        $A.util.addClass(modal, "slds-hide");
        component.set('v.mouseOver', false);
    },

    /**
     * @description 뒤로가기 버튼
     */
    fnCancel : function(component, event, helper){
        helper.doCancel(component, event, helper);
    },

    //To caculate width of Table Column
    calculateWidth : function(component, event, helper) {
            var childObj = event.target
            var parObj = childObj.parentNode;
            var count = 1;
            //parent element traversing to get the TH
            while(parObj.tagName != 'TH') {
                parObj = parObj.parentNode;
                count++;
            }
            //to get the position from the left for storing the position from where user started to drag
            var mouseStart=event.clientX;
            component.set("v.mouseStart",mouseStart);
            component.set("v.oldWidth",parObj.offsetWidth);
    },
    //New Definition of width
    setNewWidth : function(component, event, helper) {
            var childObj = event.target
            var parObj = childObj.parentNode;
            var count = 1;
            //parent element traversing to get the TH
            while(parObj.tagName != 'TH') {
                parObj = parObj.parentNode;
                count++;
            }
            var mouseStart = component.get("v.mouseStart");
            var oldWidth = component.get("v.oldWidth");
            //To calculate the new width of the column
            var newWidth = event.clientX- parseFloat(mouseStart)+parseFloat(oldWidth);
            parObj.style.width = newWidth+'px';//assign new width to column
    },

    //A selected index Row Remove
    fnDeleteSelectedRow : function(component, event, helper){
        var idx = event.getSource().get('v.name');
        var listExpDetail = component.get('v.listExpDetail');
        var listDel = component.get('v.listDel');

        if(listExpDetail[idx]){
            var obj = listExpDetail[idx];
            var deletedId = obj.Id;

            if(deletedId != null){
                listDel.push(deletedId);
                component.set('v.listDel',listDel);
            }
            listExpDetail.splice(idx,1);
            component.set('v.listExpDetail',listExpDetail);
        }
    },

    /**
     * @description 저장 버튼
     */
    fnSave  : function (component, event, helper){
        component.set('v.toggleSpinner',true);
        var listExpDetail = component.get('v.listExpDetail');
        var BudgetType = component.get('v.objExp.BudgetType__c');
        var sumAmount = 0;
        var errorMsg;

        //필수값 체크 및 에러메세지
        if(BudgetType == '프로젝트' && !component.get('v.objExp.Project__c')){
            helper.showToast('error', '경비신청 프로젝트를 선택하세요.');
            component.set('v.toggleSpinner',false);;
            return;
        }

        listExpDetail.forEach(function(obj){
             if(Number(obj.Amount) > Number(obj.BillingAmount) ){
                errorMsg = '경비신청 금액이 청구금액보다 큽니다.';
                return;
            }else if(BudgetType == '영업' && obj.SalesType == '잠재고객' && !obj.Lead){
                errorMsg = '잠재고객을 선택하세요.';
                return;
            }else if(BudgetType == '영업' && obj.SalesType == '프로젝트' && !obj.ProjectNameId){
                errorMsg = '프로젝트를 선택하세요.';
                return;
            }else if(BudgetType == '영업' && obj.SalesType == '영업기회' && !obj.OpportunityNameId){
                errorMsg = '영업기회를 선택하세요.';
                return;
            }else if(!['자격증', '영업', '임원 및 감사님','본사행정', '마케팅'].includes(BudgetType) && Number(obj.Amount) >= 300000 && !obj.PriorExpenseApplication){
                errorMsg = '경비신청 금액이 30만원 이상일 경우 경비사전승인을 선택해주세요';
                return;
            }
            sumAmount += Number(obj.Amount);
        });


        if(errorMsg){
            helper.showToast('error', errorMsg);
            component.set('v.toggleSpinner',false);
            return;
        }else{
            component.set('v.objExp.TotalAmount__c', sumAmount)
        }

        helper.fnDoSave(component, event, helper);
    },

    /**
     * @description 모달을 눌렀을 때 창이 안 닫히게 설정
     */
    stopPropagation: function (component, event, helper) {
        event.stopPropagation();
    },

    /**
     * @description 청구내역 조회 모달 열기
     */
    fnShowModal: function (component, event, helper) {
        var check = component.get("v.objExp.BudgetType__c");
        console.log("check budgettype::::", component.get("v.BudgetType"));
        if (check === '프로젝트' && !component.get("v.objExp.Project__c") && !component.get("v.ProjectName")){
            helper.showToast("error", '프로젝트를 선택해 주세요.');
            return
        }else if (check === '프로젝트'){
            helper.fnGetTerm(component, event, helper);
        }
        component.set("v.showModal", true);
    },

    /**
     * @description 사용목적 변경 시 값 변경
     */
    fnChangeBudgetType: function (component, event, helper) {
        var budgetType      = component.get('v.BudgetType');
        var listExpDetail   = component.get('v.listExpDetail');
        var newValue        = event.getSource().get("v.value");
        if(budgetType === '영업'){
            component.set('v.tableWidth', '120%');
        }else{
            component.set('v.tableWidth', '100%');
        }

        if((budgetType === '자격증' || newValue === '자격증') && budgetType != newValue && listExpDetail.length > 0){
            component.set('v.showCheckModal', true);
            component.set('v.strMessage', budgetType === '자격증'? '사용목적을 자격증에서 다른 값으로 변경 시 기존 선택된 청구내역이 제거됩니다' : '사용목적을 자격증으로 변경 시 기존 선택된 청구내역이 제거됩니다');
        }else{
            component.set('v.BudgetType', newValue);
            helper.fnInitDate(component, event, helper);
            console.log('1 ', component.get('v.objExp.Project__c'));
        }


        let BudgetTypeList = component.get("v.BudgetTypeList");

        for ( let i in BudgetTypeList){
            if ( BudgetTypeList[i].value == newValue){
                 BudgetTypeList[i].selected = true;
            } else {
                 BudgetTypeList[i].selected = false;
            }
        }
                console.log('BudgetTypeList :: ' + JSON.stringify(component.get("v.BudgetTypeList")) );
    },

    /**
     * @description 컴펌 모달에서 확인/취소 버튼 클릭 시 동작
     */
    fnChangeTypeConfirm:  function (component, event, helper) {
        var flag            = component.get('v.typeChangeConfirm')
        var expBudgetType   = component.get('v.objExp.BudgetType__c');
        var BudgetType      = component.get('v.BudgetType');

        console.log('2 ', component.get('v.objExp.Project__c'));

        if(flag === '1'){
            //확인시
            component.set('v.listExpDetail'     , []);
            component.set('v.BudgetType'        , expBudgetType);
            component.set('v.typeChangeConfirm' , "0");
            console.log('3 ', component.get('v.objExp.Project__c'));

            helper.fnInitDate(component, event, helper);
        }else if(flag === '2'){
            //취소시
            component.set('v.objExp.BudgetType__c'        , BudgetType);
            component.set('v.typeChangeConfirm' , "0");
            console.log('4 ', component.get('v.objExp.Project__c'));
        }
    }
})