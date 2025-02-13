/**
 * Created by smyan on 2021-01-29.
 */

({
    fnInit : function(component, event, helper){
        document.addEventListener('contextmenu', event => event.preventDefault());
        helper.getInitData(component);
    },

    fnLocChange : function(component, event, handler){
        component.destroy();
    }
});