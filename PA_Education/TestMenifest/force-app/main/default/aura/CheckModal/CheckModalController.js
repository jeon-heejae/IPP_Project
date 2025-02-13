/**
 * Created by Kwanwoo.Jeon on 2024-01-08.
 */

({
    /**
     * @description 모달 닫기
     */
    fnClose : function(component, event, helper){
        component.set('v.isConfirm', "2");
        component.set("v.showModal", false);
    },

    /**
     * @description 확인 눌렸을 시 동작
     */
    fnSave: function(component, event, helper){
        component.set('v.isConfirm', "1");
        component.set("v.showModal", false);
    },

    /**
     * @description 모달 영역 내를 눌렀을 때 화면이 닫히지 않게 설정
     */
    stopPropagation: function (component, event, helper) {
        event.stopPropagation();
    },
});