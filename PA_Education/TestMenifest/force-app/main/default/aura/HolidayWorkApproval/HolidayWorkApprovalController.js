/**
 * Created by Kwanwoo.Jeon on 2023-12-07.
 */

({
    /**
     * @description doInit
     */
    fnInit : function(component, event, helper){
        console.log('fnViewControll');
        helper.doInit(component,event, helper);
    },

    /**
     * @description 근무시간 변경 시 근무시간이 모두 설정되었을 경우 제출 버튼 활성화
     */
    changeTime : function(component, event, helper){
        console.log('changeTime');
        helper.doChangeTime(component,event);
    },

    /**
     * @description 체크박스 선택 시 '계획과 같음' 버튼 활성화
     */
    fnSelectRow: function(component, event, helper){
        console.log('fnSelectRow');
        var name = event.getSource().get("v.name");
        var listDetail = component.get('v.listDetail');
        console.log('name', name);
        console.log('value', event.getSource().get("v.checked"))

        //전체 선택 체크박스 설정 및 계획과 같음 버튼 활성화
        if(name === 'selectAll'){
            if(event.getSource().get("v.checked")){
                component.set('v.checked', true);
                listDetail.forEach((obj)=> obj.checked = true)
            }else{
                component.set('v.checked', false);
                listDetail.forEach((obj)=> obj.checked = false)
            }
            component.set('v.listDetail', listDetail);
        }else if(listDetail.filter(obj => obj.checked == true).length > 0){
            component.set('v.checked', true);
        }else{
            component.set('v.checked', false);
        }
    },

    /**
     * @description '계획과 같음' 버튼 클릭시 근무시간을 계획시간으로 값 할당
     */
    fnSameBtn : function(component, event, helper){
        console.log('fnSameBtn');
        var listDetail = component.get('v.listDetail');
        listDetail.forEach((obj)=> obj.WorkingTime = obj.checked == true? obj.PlanningTime : obj.WorkingTime);
        console.log('listDetail', listDetail);
        component.set('v.listDetail', listDetail);
        helper.doChangeTime(component,event);
    },

    /**
     * @description 'Submit' 버튼 클릭시 휴일근무 상세 업데이트 및 Approval 실행
     */
    fnSave : function(component, event, helper){
        console.log('fnSave');
        helper.doSave(component,event,helper);
    },
    /**
     * @description 'Cancel' 버튼 클릭시 닫기
     */
    fnClose : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },



});