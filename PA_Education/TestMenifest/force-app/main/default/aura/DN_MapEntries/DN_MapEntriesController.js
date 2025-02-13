/**
 * @description       :
 * @author            : cj.sohn@daeunextier.com
 * @group             : DaeuNextier
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   2021-12-28   cj.sohn@daeunextier.com   Initial Version
 **/


({
    fnInit : function(component, event, helper) {
        var key = component.get("v.key");
        var map = component.get("v.map");
        /*
        console.log("map" , map);
        console.log("key" , key);
        console.log("value" , map[key]);
        */
        component.set("v.value" , map[key]);
    },
});