/**
 * Created by sjhyk on 2021-12-06.
 */

({
    init: function(component, event, helper) {
        let tableHeaders = [
            {type: "STRING", fieldName: 'IndexNumber', label: 'No.'},
            {type: "STRING", fieldName: 'ClassName', label: '강의 명'},
            {type: "STRING", fieldName: 'Subject', label: '구분'},
            {type: "STRING", fieldName: 'Target', label: '대상'},
            {type: "STRING", fieldName: 'Times', label: '회차'},
            {type: "STRING", fieldName: 'StartDate', label: '시작일자'},
            {type: "STRING", fieldName: 'EndDate', label: '종료일자'},
            /*{type: "STRING", fieldName: 'Tuition', label: 'Tuition'},*/
            {type: "STRING", fieldName: 'IsEnd', label: '신청하기'}
        ];
        component.set("v.tableHeaders", tableHeaders);
        helper.doSearchClasses(component);
    },

    fnRenderPage : function(component, event, helper) {
        component.set("v.showSpinner", true);
        console.log("showSpinner true : " + component.get("v.showSpinner"));

        setTimeout(function() {
            helper.doRenderPage(component);
        }, 1);
    },

    /**
        @Description: 강의에 대한 상세내용이 보이도록 설정
     */
    showRecordModal: function (component, event, helper) {
        helper.getRecordById(component, event.currentTarget.id);
        $A.util.addClass(component.find("recordModal"), "active");
    },

    /**
     @Description: 강의에 대한 상세내용이 보이지 않도록 설정
     */
    hideRecordModal: function (component, event) {
        if (event.target == event.currentTarget) {
            $A.util.removeClass(component.find("recordModal"), "active");
        }
    },

    /**
     @Description: 강의에 대한 신청양식이 보이도록 설정
     */
    showModal: function (component, event, helper) {
        var objClass = event.getSource().get("v.value");
        component.set("v.classItem" , objClass);
        component.set("v.isOpen", true);
        $A.util.removeClass(component.find("recordModal"), "active");
        $A.util.addClass(component.find("modal"), "active");
    },

    /**
     @Description: 강의에 대한 신청양식이 보이지 않도록 설정
     */
    hideModal: function (component, event) {
        if (event.target == event.currentTarget) {
            $A.util.removeClass(component.find("modal"), "active");
            component.set("v.isOpen", false);
        }
    },

    /**
     @Description: 강의에 대한 신청서 저장
     */
    fnSave: function(component, event, helper) {
        helper.doSaveApplyTo(component);
    },

    /**
     @Description: 강의에 대한 신청서에서 휴대폰 번호 양식 반영
     */
    phoneMasking: function (component, event, helper) {
        component.set("v.strMobile", event.getParam("value").replace(/^(\d{3})(\d{4})(\d{4})$/, `$1-$2-$3`));
    },

    /**
     @Description: 강의에 대한 신청서에서 개인정보동의서 체크에 대한 값 반영
     */
    termsChanged: function (component, event, helper) {
        component.set("v.checkTerms", document.getElementById("terms").checked);
    },

    /**
     @Description: 강의에 대한 신청서에서 개인정보동의서가 보이도록 설정
     */
    termsOpen: function (component) {
        component.set("v.termsOpen", true);
        $A.util.addClass(component.find("termsModal"), "active");
    },

    /**
     @Description: 강의에 대한 신청서에서 개인정보동의서가 보이지 않도록 설정
     */
    termsClose: function (component) {
        component.set("v.termsOpen", false);
        $A.util.addClass(component.find("termsModal"), "active");
    }
});