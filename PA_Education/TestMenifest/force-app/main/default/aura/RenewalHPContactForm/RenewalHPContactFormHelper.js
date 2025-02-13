/**
 * @description       :
 * @author            : CJSohn
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   2022-01-29   CJSohn        Initial Version
 **/
({
    getPicklist : function(component) {
        var action = component.get("c.getPickListValues");
        action.setParams({
            objectType : 'Lead__c',
            selectedField : 'Type__c',
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                try{
                    var returnValue = response.getReturnValue();
                    console.log('return', returnValue);
                    if(returnValue) {
                        component.set("v.listLeadTypes", returnValue);
                    }
                }catch(e){
                    console.log('error : ' + e.message);
                }
            } else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        console.log("error", errors[0].message);
                    }
                } else {
                    console.log("error", "Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    doSave : function (component) {
        if (component.get("v.PersonalInformationUseAgreement") != true) {
            this.showToast('error', '개인정보 제공 동의를 하셔야 문의를 등록하실 수 있습니다.');
            return;
        }
        if (!component.get("v.LeadName")) {
            this.showToast('error', "이름이 등록되지 않았습니다.");
            return;
        }
        if (!component.get("v.Company")) {
            this.showToast('error', "회사 정보가 입력되지 않았습니다.");
            return;
        }
        if (!component.get("v.Mobile")) {
            this.showToast('error', "휴대폰 번호가 입력되지 않았습니다.");
            return;
        }
        if (!component.get("v.Email")) {
            this.showToast('error', "이메일 주소가 입력되지 않았습니다.");
            return;
        }

        if (!component.get("v.LeadType")) {
            this.showToast('error', "문의 유형이 입력되지 않았습니다.");
            return;
        }

        if (!component.get("v.Subject")) {
            this.showToast('error', "문의 주제가 입력되지 않았습니다.");
            return;
        }

        if (!component.get("v.Description")) {
            this.showToast('error', "상세내용이 입력되지 않았습니다.");
            return;
        }

        component.set("v.showSpinner", true);
        var paramMap = {
            "Name"          : component.get("v.LeadName"),
            "Company"       : component.get("v.Company"),
            "Mobile"        : component.get("v.Mobile"),
            "Email"         : component.get("v.Email"),
            "LeadType"      : component.get("v.LeadType"),
            "Subject"       : component.get("v.Subject"),
            "Description"   : component.get("v.Description"),

        };
        console.log('paramMap', paramMap);

        var action = component.get("c.doSave");
        action.setParams({
            paramMap : paramMap,
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                try{
                    var returnValue = response.getReturnValue();
                    console.log('return', returnValue);
                    if(returnValue) {
                        this.showToast('success', component.get("v.LeadName") + '님 지원에 감사드립니다.');
                        location.reload();
                    }
                }catch(e){
                    console.log('error : ' + e.message);
                }
            } else if(state === "ERROR") {
                var errors = response.getError();
                console.log('errors', errors);
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        this.showToast('error', errors[0].message);
                    }
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
            component.set("v.showSpinner", false);
        });

        $A.enqueueAction(action);
    },


    /**
     * 토스트 메세지 출력 이벤트 발생
     * @param {string} type 메세지 유형 (success, error, info, warning, other)
     * @param {string} message 토스트에 보여질 메세지
     */
    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });
        evt.fire();
    }
});