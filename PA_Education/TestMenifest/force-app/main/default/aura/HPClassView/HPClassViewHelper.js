/**
 * Created by sjhyk on 2021-12-06.
 */

({
    doSearchClasses: function(component) {
        var action = component.get("c.doSearchClasses");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try{
                    var returnValue = response.getReturnValue();
                    if(returnValue) {
                        console.log("Return Value", JSON.stringify(returnValue));
                        let listClasses = returnValue;
                        var countPerPage = component.get("v.countPerPage");
                        component.set("v.maxPage", Math.floor((listClasses.length + (countPerPage - 1)) / countPerPage));
                        var pageNumber = component.get("v.pageNumber");
                        var pageRecords = listClasses.slice((pageNumber - 1) * countPerPage, pageNumber * countPerPage);
                        component.set("v.pageRecords", pageRecords);
                    }
                }catch(e){
                    component.set("v.isReady", true);
                    console.log('error : ' + e.message);
                }
            } else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        this.showToast("error", errors[0].message);
                    }
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    getRecordById: function (component, id) {
        var action = component.get("c.getRecordById");
        action.setParams({ recordId: id });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                try {
                    var returnValue = response.getReturnValue();
                    console.log('classItem', returnValue);
                    if (returnValue) {
                        component.set("v.classItem", returnValue);
                    }
                } catch (e) {
                    console.log('error: ' + e.message);
                }
            }
        });

        $A.enqueueAction(action);
    },

    doSaveApplyTo : function (component) {
        let strRegister = component.get("v.strRegister");
        let strMobile = component.get("v.strMobile");
        let dBirthDate = component.get("v.dBirthDate");
        if(strRegister == undefined || strRegister == null || strMobile == undefined || strMobile == null || dBirthDate || undefined || dBirthDate == null){
            this.showToast('error', '수장자, 연락처, 생년월일를 입력하셔야 지원하실 수 있습니다.');
        }else{
            var classId = component.get("v.strClassId");
            var paramMap = {
                "Register" : component.get("v.strRegister"),
                "Mobile"   : component.get("v.strMobile"),
                "BirthDate": component.get("v.dBirthDate"),
                "ClassId"  : classId
            };
            var action = component.get("c.doSaveApplyTo");

            if (component.get("v.checkTerms") != true) {
                this.showToast('error', '개인정보 제공 동의를 하셔야 지원하실 수 있습니다.');
                return;
            }

            action.setParams({
                paramMap : paramMap,
            });

            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('init state > ' + state);
                if (state === "SUCCESS") {
                    try{
                        var returnValue = response.getReturnValue();

                        if(returnValue) {
                            /*component.set("v.listJobPosition", returnValue);
                            component.set("v.myVal" , returnValue[0].RichTextTest__c);*/
                            this.showToast('success', '신청되었습니다.');
                            component.set("v.isOpen", false);
                            $A.get('e.force:refreshView').fire();
                        }
                    }catch(e){
                        component.set("v.isReady", true);
                        console.log('error : ' + e.message);
                    }
                } else if(state === "ERROR") {
                    var errors = response.getError();
                    if(errors) {
                        if(errors[0] && errors[0].message) {
                            this.showToast('error', errors[0].message);
                        }
                    } else {
                        this.showToast("error", "Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },

    /**
     * 페이징 처리
     * @param {*} component
     */
    doRenderPage : function(component) {
        var pageNumber = component.get("v.pageNumber");
        var countPerPage = component.get("v.countPerPage");
        var listWrapIncentiveRate = component.get("v.listWrapIncentiveRate");

        var pageRecords = listWrapIncentiveRate.slice((pageNumber - 1) * countPerPage, pageNumber * countPerPage);

        component.set("v.pageRecords", pageRecords);
        component.set("v.showSpinner", false);
    },

    /**
     * @description 토스트 메세지 출력 이벤트 발생
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
    },
});