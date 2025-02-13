/**
 * Created by Kwanwoo.Jeon on 2023-12-07.
 */

({
    /**
     * @description 휴일근무상세 관련 테이블 Column 및 데이터 설정
     */
    doInit : function(component, event, helper){
        component.set("v.listDetailColumn", [
                '휴일근무 상세 코드', '휴일근무자', '작업내용', '계획시간', '근무시간'
            ]);
        console.log('column : ',component.get("v.listDetailColumn"));
        var action = component.get("c.doInit");
        var recordId = component.get("v.recordId");
        action.setParams({
            'recordId'      : recordId
        });

        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rv = response.getReturnValue();
                if(rv.listDetailWrapper.length > 0) {
                    component.set('v.listDetail', rv.listDetailWrapper);
                    component.set('v.timePicklist', rv.timePicklist);
                    console.log('listDetail : ',component.get('v.listDetail'));
                }else{
                    this.showToast("info", "Detail이 없습니다.");
                }
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * @description 휴일근무 상세 업데이트 및 Approval 실행
     */
    doSave: function(component,event,helper){
        var action = component.get("c.doSave");
        var listDetail = component.get('v.listDetail');
        var strComments  = component.find("comments").get("v.value");
        var recordId = component.get("v.recordId");
        action.setParams({
            'listDetail'      : listDetail,
            'strComments'    	: strComments,
            'recordId'      : recordId
        });

        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rv = response.getReturnValue();
                if(rv.status === 'SUCCESS'){
                    this.showToast("SUCCESS", rv.message);
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                }else{
                    this.showToast("Error", rv.message);
                }

            }else{
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * @description 근무시간이 모두 설정되었을 경우 제출 버튼 활성화
     */
    doChangeTime : function(component, event){
        console.log('doChangeTime');
        console.log('v.listDetail',component.get('v.listDetail'));
        console.log('lengt: ', component.get('v.listDetail').filter(obj => obj.WorkingTime == "none").length);

        if(component.get('v.listDetail').filter(obj => obj.WorkingTime === 'none').length == 0){
            component.set('v.timeSettingDone', true);
        }else{
            component.set('v.timeSettingDone', false);
        }
    },

    /**
     * @description 토스트 메세지
     */
    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key : "info_alt"
            , type : type
            , message : message
        });
        evt.fire();
    },
});