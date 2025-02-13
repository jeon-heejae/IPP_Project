/**
 * Created by Kwanwoo.Jeon on 2024-01-04.
 */

({
    /**
     * @description 모달 닫기
     */
    fnCloseModal : function(component, event) {
        component.set('v.mouseOver', false);
    },

    /**
     * @description 모달 영역을 눌렀을 시 창이 닫히지 않게 설정
     */
    stopPropagation: function (component, event, helper) {
        event.stopPropagation();
    },

});