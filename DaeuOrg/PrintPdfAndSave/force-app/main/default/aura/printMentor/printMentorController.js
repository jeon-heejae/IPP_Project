({
    fnInit : function(component, event, helper){

        console.log('Init function started');  // 초기 진입점 확인
       
       try {
           var listSelectId = component.get("v.listSelectId");
           console.log('listSelectId: ', listSelectId);

           
           var vfPageUrl = "/apex/printInterviewList?recordId=" + listSelectId;
           console.log('VF Page URL: ' + vfPageUrl);
           
           component.set("v.vfPageUrl", vfPageUrl);
           console.log('URL set completed');

       } catch(error) {
           console.error('Error in init: ', error);
       }
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