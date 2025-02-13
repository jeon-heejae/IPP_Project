({
    getPositions: function (component) {
        var action = component.get("c.getPositions");
        action.setParams({ isEnglish: component.get('v.isEnglish') })
        console.log('english : '+JSON.stringify(component.get('v.isEnglish')));
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                try {
                    var returnValue = response.getReturnValue();

                    if (returnValue) {
                        component.set("v.positions", returnValue);
                    }

                    if (returnValue.length >= 9) {
                        component.set("v.hasMore", true);
                    }
                } catch (e) {
                    component.set("v.isReady", true);
                    console.log('error : ' + e.message);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
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
        var action = component.get("c.loadMorePositions");
        action.setParams({ isEnglish: component.get('v.isEnglish') })

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                try {
                    var returnValue = response.getReturnValue();

                    if (returnValue) {
                        component.set("v.positions", returnValue);
                    }

                    component.set("v.hasMore", false);
                } catch (e) {
                    component.set("v.isReady", true);
                    console.log('error : ' + e.message);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("error", errors[0].message);
                    }
                } else {
                    console.log("error", "Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },
    doSaveApplyTo: function (component) {
        console.log('doSaveApplyTo start ::::');
        if (component.get("v.checkTerms") != true) {
            this.showToast('error', '개인정보 제공 동의를 하셔야 지원하실 수 있습니다.');
            return;
        }
        if (!component.get("v.fileName")) {
            this.showToast('error', "자기소개서 파일이 등록되지 않았습니다.");
            return;
        }
        if (!component.get("v.Applicant")) {
            this.showToast('error', "지원자 이름이 입력되지 않았습니다.");
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
        if (!component.get("v.BirthDate")) {
            this.showToast('error', "생년월일이 입력되지 않았습니다.");
            return;
        }
        var JobPositionId = component.get("v.JobPositionObj").Id;
        var paramMap = {
            "Applicant": component.get("v.Applicant"),
            "Mobile": component.get("v.Mobile"),
            "Email": component.get("v.Email"),
            "JobPositionId": JobPositionId,
            "BirthDate": component.get("v.BirthDate")
        };
        console.log('paramMap', paramMap);

        var action = component.get("c.doSaveApplyTo");
        action.setParams({
            paramMap: paramMap,
            fileName: component.get("v.fileName"),
            base64Data: component.get("v.base64Data"),
            contentType: component.get("v.contentType")
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            console.log(response.getError());

            console.log('init state > ' + state);
            if (state === "SUCCESS") {
                try {
                    var returnValue = response.getReturnValue();

                    if (returnValue) {
                        /*component.set("v.listJobPosition", returnValue);
                        component.set("v.myVal" , returnValue[0].RichTextTest__c);*/

                        this.showToast('success', component.get("v.Applicant") + '님 지원에 감사드립니다.');
                        component.set("v.isOpen", false);
                        $A.get('e.force:refreshView').fire();
                    }
                } catch (e) {
                    component.set("v.isReady", true);
                    console.log('error : ' + e.message);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
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
    showToast: function (type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key: "info_alt",
            type: type,
            message: message
        });
        evt.fire();
    }
});