/**
 * Created by gyubin on 2022/04/18.
 */

({
    init: function (component, event) {
        let isEnglish = event.getParam('isEnglish')
        isEnglish ? component.set('v.isEnglish', isEnglish) :
            component.set('v.isEnglish', false)
    },
});