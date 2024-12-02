({
    fnInit : function(component, event, helper){
        component.set("v.vfPageUrl" , "/apex/PrintExpense?recordId="+component.get("v.recordId"));
    },

    fnCancel : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },

    fnSave : function(component, event, helper){
        console.log("call Save");
        //저장버튼 누를 시, 액션
        helper.saveAction(component);
        
    }
});