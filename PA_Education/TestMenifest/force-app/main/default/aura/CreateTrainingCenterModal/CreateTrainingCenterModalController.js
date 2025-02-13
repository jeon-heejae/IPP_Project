/**
 * Created by Kwanwoo.Jeon on 2024-02-20.
 */

({
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
        var mapTrainingCenter = component.get('v.mapTrainingCenter');
        //필수값 체크
        if($A.util.isEmpty(mapTrainingCenter.UseType__c)){
            helper.gfnShowToast("error", "사용유형을 입력하시기 바랍니다.");
            return;
        }
        if($A.util.isEmpty(mapTrainingCenter.RoomType__c)){
            helper.gfnShowToast("error", "객실유형을 입력하시기 바랍니다.");
            return;
        }
        if($A.util.isEmpty(mapTrainingCenter.Date1__c)){
            helper.gfnShowToast("error", "사용일1을 입력하시기 바랍니다.");
            return;
        }
        if(mapTrainingCenter.UseType__c === '2박' && $A.util.isEmpty(mapTrainingCenter.Date2__c)){
            helper.gfnShowToast("error", "사용일2를 입력하시기 바랍니다.");
            return;
        }



        helper.gfnSave(component, event)
        component.set("v.showSpinner", true);
    },

    fnCheck: function(component, event, helper){
        console.log('fnCheck');
        console.log(JSON.stringify(component.get('v.mapTrainingCenter')));
    },


});