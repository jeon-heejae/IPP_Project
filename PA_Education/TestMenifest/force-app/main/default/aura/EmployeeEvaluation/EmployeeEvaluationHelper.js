/**
 * Created by yj.kim on 2023-07-05.
 */

({
    getInitData : function(component, event, helper){
        this.showSpinner(component);
        console.log('recordId : ' + component.get('v.recordId'));
        var action = component.get("c.doInit");
        action.setParams({
            "recordId" : component.get('v.recordId')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state :: ' + state);
            if(state == "SUCCESS"){
                var returnVal = response.getReturnValue();
                console.log('returnVal : ', returnVal)
                component.set('v.projectName', returnVal.projectName);
                component.set('v.firstEvaluation', returnVal.firstEvaluation);
                if($A.util.isEmpty(returnVal.InternalWrapper) && $A.util.isEmpty(returnVal.externalWrapper)){
                    this.showToast('ERROR', '프로젝트 수행팀에 불러올 데이터가 없습니다.');
                }
                if(!$A.util.isEmpty(returnVal.InternalWrapper)){
                    component.set('v.inList', returnVal.InternalWrapper);
                    component.set('v.isIn', true);
                }
                if(!$A.util.isEmpty(returnVal.externalWrapper)){
                    component.set('v.exList', returnVal.externalWrapper);
                    component.set('v.isEx', true);
                }

                console.log('projectName : ' + component.get('v.projectName'));
                console.log('firstEvaluation : ' + component.get('v.firstEvaluation'));
                console.log('isIn : ' + component.get('v.isIn'));
                console.log('isEx : ' + component.get('v.isEx'));

            }else{
                this.showToast('ERROR', '데이터를 불러오는 중에 ERROR 발생');
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },

    doSave : function(component, event, helper){
        this.showSpinner(component);
        var action = component.get("c.doSave");
        action.setParams({
            "inList" : component.get('v.inList'),
            "exList" : component.get('v.exList'),
            "firstEvaluation" : component.get('v.firstEvaluation')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state :: ' + state);
            if(state == "SUCCESS"){
                var returnVal = response.getReturnValue();
                if(returnVal.status == 'SUCCESS'){
                    this.showToast(returnVal.status, returnVal.message);
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                            "recordId": component.get('v.recordId')
                        });
                    navEvt.fire();
                }else{
                    this.showToast(returnVal.status, returnVal.message);
                }
            }else{
                this.showToast('ERROR', '저장 시 오류발생');
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },

    fnValidation : function(component){
        if(component.get("v.isIn") == true){
            for(var i=0; i<component.get("v.inList").length; i++){
                if($A.util.isEmpty(component.get("v.inList")[i]["competency"])){
                    this.showToast('ERROR', 'Competency(프로젝트 수행능력) 를 입력해주세요.');
                    return false;
                }
                if($A.util.isEmpty(component.get("v.inList")[i]["communication"])){
                    this.showToast('ERROR', 'Communication(소통능력) 를 입력해주세요.');
                    return false;
                }
                if($A.util.isEmpty(component.get("v.inList")[i]["cooperation"])){
                    this.showToast('ERROR', 'cooperation(협업) 를 입력해주세요.');
                    return false;
                }
                if($A.util.isEmpty(component.get("v.inList")[i]["passion"])){
                    this.showToast('ERROR', 'passion(열정,적극성) 를 입력해주세요.');
                    return false;
                }
                if($A.util.isEmpty(component.get("v.inList")[i]["attitude"])){
                    this.showToast('ERROR', 'attitude(업무수행 태도,자세) 를 입력해주세요.');
                    return false;
                }
                if($A.util.isEmpty(component.get("v.inList")[i]["addComment"])){
                    this.showToast('ERROR', '평가자의견 을 구체적으로 입력해주세요.');
                    return false;
                }
            }
        }

        if(component.get("v.isEx") == true){
             for(var i=0; i<component.get("v.exList").length; i++){
                if($A.util.isEmpty(component.get("v.exList")[i]["competency"])){
                    this.showToast('ERROR', 'Competency(프로젝트 수행능력) 를 입력해주세요.');
                    return false;
                }
                if($A.util.isEmpty(component.get("v.exList")[i]["communication"])){
                    this.showToast('ERROR', 'Communication(소통능력) 를 입력해주세요.');
                    return false;
                }
                if($A.util.isEmpty(component.get("v.exList")[i]["cooperation"])){
                    this.showToast('ERROR', 'cooperation(협업) 를 입력해주세요.');
                    return false;
                }
                if($A.util.isEmpty(component.get("v.exList")[i]["passion"])){
                    this.showToast('ERROR', 'passion(열정,적극성) 를 입력해주세요.');
                    return false;
                }
                if($A.util.isEmpty(component.get("v.exList")[i]["attitude"])){
                    this.showToast('ERROR', 'attitude(업무수행 태도,자세) 를 입력해주세요.');
                    return false;
                }
                if($A.util.isEmpty(component.get("v.exList")[i]["addComment"])){
                    this.showToast('ERROR', '평가자의견 을 구체적으로 입력해주세요.');
                    return false;
                }
             }
        }
        return true;
    },

    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });
        evt.fire();
    },

    showSpinner: function(component) {
        component.set('v.isShowSpinner', true);
    },

    hideSpinner: function(component) {
        component.set('v.isShowSpinner', false);
    }

});