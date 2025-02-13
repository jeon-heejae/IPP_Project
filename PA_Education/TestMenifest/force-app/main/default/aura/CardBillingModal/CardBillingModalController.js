/**
 * Created by Kwanwoo.Jeon on 2024-01-03.
 */

({
    /**
     * @description doInit
     */
    fnInit : function(component, event, helper){
        component.set('v.showSpinner', true);
        component.set('v.Columns', ['사용일자', '카드별칭', '카드사', '가맹점명', '업종', '주소', '청구금액']);
        helper.getData(component,event, helper);
    },

    /**
     * @description 모달 닫기
     */
    fnClose : function(component, event, helper){
        component.set("v.showModal", false);
    },

    /**
     * @description 모달창 내부를 눌렀을때는 창이 안닫기게 설정
     */
    stopPropagation: function (component, event, helper) {
        event.stopPropagation();
    },

    /**
     * @description 저장 버튼 클릭 시 listExpDetail 데이터 변경
     */
    fnSave: function(component, event, helper){
        var budgetType      = component.get('v.BudgetType');
        var selectedRow     = component.get('v.Data').filter(obj=>obj.checked == true);
        var unSelectedRowId = component.get('v.Data').filter(obj=>obj.checked == false).map(obj=> obj.Id);
        var listExpDetail   = component.get('v.listExpDetail');

        for(var i = 0; i < listExpDetail.length; i++){
            console.log('listExpDetail[i] : ',listExpDetail[i]);
            if (unSelectedRowId.includes(listExpDetail[i].CorporateCardBilling)) {
                listExpDetail.splice(i, 1);
                i--;
            }
        }

        var listExpDetailBillingId = listExpDetail.map(obj => obj.CorporateCardBilling);
        var category2 = component.get('v.BudgetType') ==  '자격증'? '교육/훈련' : '식비';
        selectedRow.forEach(function(obj) {
            if(!listExpDetailBillingId.includes(obj.Id)){
                listExpDetail.push({
                    CorporateCardBilling  : obj.Id,
                    Dt                    : obj.BillingDate,
                    CardCompany           : obj.CardCompany,
                    StoreName             : obj.StoreName,
                    BusinessType          : obj.BusinessType,
                    StoreAddress          : obj.StoreAddress,
                    BillingAmount         : obj.BillingAmount,
                    Amount                : obj.BillingAmount,
                    CurrencyIsoCode       : obj.CurrencyIsoCode,
                    Category2             : category2,
                    CorporateCardNickName : obj.CorporateCardNickName
                });
            }
        });

        //정렬 순서 : 카드순, 날짜 순
        listExpDetail.sort(function(a, b)  {
            return a.CorporateCardNickName.localeCompare(b.CorporateCardNickName) || new Date(a.Dt).getTime() - new Date(b.Dt).getTime();
        });
        component.set('v.listExpDetail', listExpDetail);
        component.set("v.showModal", false);
    },

    /**
     * @description 체크박스 선택 시 동작
     */
    fnSelectRow: function(component, event, helper){
        var name = event.getSource().get("v.name");
        var data = component.get('v.selectedCardData');

        //전체 선택 체크박스 설정 및 계획과 같음 버튼 활성화
        if(name === 'selectAll'){
            if(event.getSource().get("v.checked")){
                component.set('v.checked', true);
                data.forEach((obj)=> obj.checked = true)
            }else{
                component.set('v.checked', false);
                data.forEach((obj)=> obj.checked = false)
            }
            component.set('v.selectedCardData', data);
        }else if(data.filter(obj => obj.checked == false).length <= 0){
            component.set('v.checked', true);
        }else{
            component.set('v.checked', false);
        }
    },

    fnChangeCard: function(component, event, helper){
        helper.gfnChangeCard(component, event, helper);
    }
});