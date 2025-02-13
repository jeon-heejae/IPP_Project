({
    init: function (component, event, helper) {
        let isEnglish = event.getParam('isEnglish')
        isEnglish ? component.set('v.isEnglish', isEnglish) :
            component.set('v.isEnglish', false)
        helper.getPositions(component);
    },
    renderTitle: function (component, event) {
        const originalTitle = event.target.innerHTML
        const head = originalTitle.slice(0, 4)
        const cutPosition_2 = originalTitle.indexOf('W/')
        const body = originalTitle.slice(5, cutPosition_2)
        const tail = originalTitle.slice(cutPosition_2)
        event.target.innerHTML = `${head}<br/>${body}<br />${tail}`
    },
    loadMore: function (component, event, helper) {
        helper.getLoadMore(component);
    },
    showModal: function (component, event, helper) {
        event.stopPropagation();

        component.set("v.contentsModalOpen", false);
        var JobPositionRecord = event.getSource().get("v.value");
        console.log('Target Obj', JobPositionRecord);
        component.set("v.JobPositionObj", JobPositionRecord);
        component.set("v.isOpen", true);
        $A.util.addClass(component.find("modal"), "active");
    },
    hideModal: function (component, event) {
        if (event.target == event.currentTarget) {
            $A.util.removeClass(component.find("modal"), "active");
            component.set("v.isOpen", false);
        }
    },
    fnSave: function (component, event, helper) {
        helper.doSaveApplyTo(component);
    },
    fnFileUpload: function (component, event, helper) {
        var fileInput = component.find("fileInput").getElement();
        var file = fileInput.files[0];

        var fileReader = new FileReader();
        fileReader.readAsDataURL(file);
        fileReader.onload = function () {
            var fileContents = fileReader.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            fileContents = fileContents.substring(dataStart);
            var base64Data = encodeURIComponent(fileContents);
            if(base64Data.length > 4000000) {
                helper.showToast('error', '자기소개서 파일은 4MB 이하로 반영해주세요.');
                component.find("fileInput").getElement().value = "";
                return;
            }else{
                console.log('fileName >> ' + file.name);
                console.log('base64Data >> ' + base64Data);
                console.log('contentType >> ' + file.type);

                component.set('v.fileName', file.name);
                /*component.set('v.title',file.name); */
                component.set('v.base64Data', encodeURIComponent(fileContents));
                component.set('v.contentType', file.type);
            }
        }

    },
    showContentsModal: function (component, event, helper) {
        var positionId = event.target.querySelector('.positionId').value;
        var positionSubject = event.target.querySelector('.positionSubject').value;
        var positionCategory = event.target.querySelector('.positionCategory').value;
        var positionWorkType = event.target.querySelector('.positionWorkType').value;
        var positionCareer = event.target.querySelector('.positionCareer').value;
        var positionName = event.target.querySelector('.positionName').value;
        var positionEducation = event.target.querySelector('.positionEducation').value;
        var positionBusiness = event.target.querySelector('.positionBusiness').value;
        var positionQualifications = event.target.querySelector('.positionQualifications').value;
        var positionPreferentialTreatment = event.target.querySelector('.positionPreferentialTreatment').value;
        var positionLocation = event.target.querySelector('.positionLocation').value;
        var status = event.target.querySelector('.status').value;
        var data = {
            'Id': positionId,
            'fm_subject__c': positionSubject,
            'RecruitmentCategory__c': positionCategory,
            'WorkType__c': positionWorkType,
            'Career__c': positionCareer,
            'Position__c': positionName,
            'Education__c': positionEducation,
            'MainBusiness__c': positionBusiness,
            'Qualifications__c': positionQualifications,
            'preferentialTreatment__c': positionPreferentialTreatment,
            'WorkingPlace__c': positionLocation,
            'Status__c': status
        };

        component.set("v.contentsItem", data);
        component.set("v.contentsModalOpen", true);

    },
    hideContentsModal: function (component, event, helper) {
        component.set("v.contentsModalOpen", false);
    },
    termsChanged: function (component, event, helper) {
        component.set("v.checkTerms", document.getElementById("terms").checked);
    },
    phoneMasking: function (component, event, helper) {
        component.set("v.Mobile", event.getParam("value").replace(/^(\d{3})(\d{4})(\d{4})$/, `$1-$2-$3`));
    },
    onChangeEmail: function (component, event, helper) {
        var email = component.get("v.Email");

        if (email) {
            var provider = email.split('@')[1];

            if (provider) {
                component.set("v.Email", event.target.value + '@' + provider);
            } else {
                component.set("v.Email", event.target.value + '@naver.com');
            }
        } else {
            component.set("v.Email", event.target.value + '@naver.com');
        }
    },
    onChangeEmailProvider: function (component, event, helper) {
        if (event.target.value === 'self') {
            component.set("v.emailSelf", true);
            return;
        }

        var provider = event.target.value;
        var email = component.get("v.Email");

        if (email) {
            component.set("v.Email", email.split("@")[0] + "@" + provider);
        } else {
            component.set("v.Email", "@" + provider);
        }
    },
    termsOpen: function (component) {
        component.set("v.termsOpen", true);
    },
    termsClose: function (component) {
        component.set("v.termsOpen", false);
    }
})