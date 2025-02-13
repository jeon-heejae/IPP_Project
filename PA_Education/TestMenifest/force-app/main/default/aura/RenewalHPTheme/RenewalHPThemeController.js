({
    onMouseOver: function (component, event, helper) {
        $A.util.addClass(component.find("background"), "active");
    },
    onMouseOut: function (component, event, helper) {
        $A.util.removeClass(component.find("background"), "active");
    },
    gnbOpen: function (component, event, helper) {
        $A.util.addClass(component.find("mobileGnb"), "active");
    },
    gnbClose: function (component, event, helper) {
        $A.util.removeClass(component.find("mobileGnb"), "active");
    },
    signup: function (component, event, helper) {
        this.showToast('info', '준비 중입니다.');
    },
    getLanguageString: function (component) {
        const isEnglish = localStorage.getItem('userLangSetting') === 'true'
       isEnglish ? component.set('v.languageString', 'English') : component.set('v.languageString', 'Korean')


        const isEnglish2 = localStorage.getItem('userLangSetting') === 'true'
        isEnglish2 ? component.set('v.isEnglish', true) : component.set('v.isEnglish', false)
    },
    languageToggle: function (component, event, helper) {
        const currentLanguageSetting = localStorage.getItem('userLangSetting') === 'true'
        localStorage.setItem('userLangSetting', (!currentLanguageSetting).toString())
        $A.enqueueAction(component.get('c.getLanguageString'))
        $A.enqueueAction(component.get('c.fireLanguageEvent'))
        $A.util.toggleClass(component.find('upTriangle'), 'on');
        $A.util.toggleClass(component.find('downTriangle'), 'on');
    },
    languageToEnglish: function (component, event, helper) {
        localStorage.setItem('userLangSetting', (true).toString())
        component.set('v.isEnglish', true)
        $A.enqueueAction(component.get('c.getLanguageString'))
        $A.enqueueAction(component.get('c.fireLanguageEvent'))
    },
    languageToKorean: function (component, event, helper) {
        localStorage.setItem('userLangSetting', (false).toString())
        component.set('v.isEnglish', false)
        $A.enqueueAction(component.get('c.getLanguageString'))
        $A.enqueueAction(component.get('c.fireLanguageEvent'))
    },
    mobileLanguageToEnglish: function (component, event, helper) {
        localStorage.setItem('userLangSetting', (true).toString())
        component.set('v.isEnglish', true)
        $A.enqueueAction(component.get('c.getLanguageString'))
        $A.enqueueAction(component.get('c.fireLanguageEvent'))
        $A.util.removeClass(component.find("mobileGnb"), "active")
    },
    mobileLanguageToKorean: function (component, event, helper) {
        localStorage.setItem('userLangSetting', (false).toString())
        component.set('v.isEnglish', false)
        $A.enqueueAction(component.get('c.getLanguageString'))
        $A.enqueueAction(component.get('c.fireLanguageEvent'))
        $A.util.removeClass(component.find("mobileGnb"), "active")
    },

    initializeLanguageSetting: function (component) {

        if (localStorage.getItem('userLangSetting') == null) {
            localStorage.setItem('userLangSetting', 'false')
        }
        let isEnglish = localStorage.getItem('userLangSetting') === "true"
        $A.enqueueAction(component.get('c.fireLanguageEvent'))
    },
    fireLanguageEvent: function (component, event, helper) {
        // Get userLangSetting from localstorage. true for English, false for Korean
        const isEnglish = localStorage.getItem('userLangSetting') === "true"
        let appEvent = $A.get('e.c:i18nEvent');
        appEvent.setParam("isEnglish", isEnglish);
        appEvent.fire()
    },
    init: function (component, event, helper) {
        if (!component.get('v.isDoneRendering')) {
            component.set('v.isDoneRendering', true)
            // Queue functions
            $A.enqueueAction(component.get('c.initializeLanguageSetting'))
            $A.enqueueAction(component.get('c.getLanguageString'))
            setTimeout($A.getCallback(() => {
                $A.enqueueAction(component.get('c.fireLanguageEvent'))
            }), 800)
            if (Number(localStorage.getItem('refreshCounter')) < 1) {
                localStorage.setItem('refreshCounter', '1')
                window.location.reload()
            } else {
                localStorage.setItem('refreshCounter', '0')
            }
        }
    },

})