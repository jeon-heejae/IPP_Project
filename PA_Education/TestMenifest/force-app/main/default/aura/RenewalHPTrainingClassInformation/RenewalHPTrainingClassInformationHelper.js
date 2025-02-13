({
    getClassInformation : function(component) {
        var action = component.get("c.getClassInformation");
        action.setParams({
            isEnglish: component.get('v.isEnglish')
        })

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                try{
                    var returnValue = response.getReturnValue();

                    if(returnValue) {
                        returnValue = returnValue.map(function (item) {
                            return {
                                Id: item.Id,
                                ClassName__c: item.ClassName__c,
                                ClassNameEng__c: item.ClassNameEng__c,
                                Subject__c: item.Subject__c,
                                SubjectEng__c: item.SubjectEng__c,
                                Target__c: item.Target__c,
                                Times__c: item.Times__c,
                                Tuition__c: item.Tuition__c,
                                StartDate__c: $A.localizationService.formatDate(item.StartDate__c, "yyyy-MM-dd"),
                                EndDate__c: $A.localizationService.formatDate(item.EndDate__c, "yyyy-MM-dd"),
                                isEnd: new Date() > new Date(item.EndDate__c)
                            }
                        });

                        if (returnValue.length >= 9) {
                            component.set("v.hasMore", true);
                        }

                        component.set("v.nowDate", new Date());
                    	component.set("v.classInformation", returnValue);
                    }
                }catch(e){
                    component.set("v.isReady", true);
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
    getLoadMore: function (component) {
        var action = component.get("c.loadMoreClasses");
        action.setParams({
            isEnglish: component.get('v.isEnglish')
        })

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                try{
                    var returnValue = response.getReturnValue();

                    if(returnValue) {
                        returnValue = returnValue.map(function (item) {
                            return {
                                Id: item.Id,
                                ClassName__c: item.ClassName__c,
                                Subject__c: item.Subject__c,
                                Target__c: item.Target__c,
                                Times__c: item.Times__c,
                                Tuition__c: item.Tuition__c,
                                StartDate__c: $A.localizationService.formatDate(item.StartDate__c, "yyyy-MM-dd"),
                                EndDate__c: $A.localizationService.formatDate(item.EndDate__c, "yyyy-MM-dd"),
                                isEnd: new Date() > new Date(item.EndDate__c)
                            }
                        });

                        component.set("v.hasMore", false);
                        component.set("v.nowDate", new Date());
                        component.set("v.classInformation", returnValue);
                    }
                }catch(e){
                    component.set("v.isReady", true);
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
    doSaveApplyTo : function (component) {
        var classId = component.get("v.ClassObj").Id;
        var paramMap = {
            "Register"     : component.get("v.Register"),
            "Mobile"        : component.get("v.Mobile"),
            "BirthDate"         : component.get("v.BirthDate"),
            "ClassId" : classId
        };
        var action = component.get("c.doSaveApplyTo");

        if (component.get("v.checkTerms") != true) {
            this.showToast('error', '개인정보 제공 동의를 하셔야 지원하실 수 있습니다.');
            return;
        }

        if (!component.get("v.Register")) {
            this.showToast('error', '수강자 명이 입력되지 않았습니다.');
            return;
        }

        if (!component.get("v.Mobile")) {
            this.showToast('error', '휴대전화 번호가 입력되지 않았습니다.');
            return;
        }

        if (!component.get("v.BirthDate")) {
            this.showToast('error', '생년월일이 입력되지 않았습니다.');
            return;
        }

        console.log('params', {
            paramMap : paramMap,
            fileName     : component.get("v.fileName"),
            base64Data    : component.get("v.base64Data"),
            contentType   : component.get("v.contentType"),
        });

        action.setParams({
            paramMap : paramMap,
            fileName     : component.get("v.fileName"),
            base64Data    : component.get("v.base64Data"),
            contentType   : component.get("v.contentType"),
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