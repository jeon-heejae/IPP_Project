/**
 * Created by Kwanwoo.Jeon on 2024-01-15.
 */

({
    /**
     * @description doInit
     */
    fnInit: function(component, event, helper){
        console.log('fnInit');
        helper.gfnInit(component, event, helper);
    },

    /**
     * @description 아코디언 열기/닫기
     */
    clickStatus : function(component, event, helper) {
        var x = document.getElementById("myDIV");
        if (x.style.display === "none") {
            x.style.display = "block";
            component.set('v.clickType', true);
        } else {
            x.style.display = "none";
            component.set('v.clickType', false);
        }
    },
});