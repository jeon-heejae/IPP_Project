/**
 * Created by kimmyeonghwan on 2022/04/18.
 */

({
    init : function(component, event, helper) {
        let isEnglish = event.getParam('isEnglish')
        isEnglish ? component.set('v.isEnglish', isEnglish) :
            component.set('v.isEnglish', false)
        }
        // let isEnglish = event.getParam('isEnglish')
        // typeof isEnglish !== 'undefined'  ? component.set('v.isEnglish', isEnglish) :
    
});