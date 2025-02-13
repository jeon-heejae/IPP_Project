/**
 * Created by gyubin on 2022/04/20.
 */

({
    init: function (component, event, helper) {
        let isEnglish = event.getParam('isEnglish')
        isEnglish ? component.set('v.isEnglish', isEnglish) :
            component.set('v.isEnglish', false)
    },
});