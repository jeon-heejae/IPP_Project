({
    fnInit: function(component,event,helper){
        console.log('helper init');

         //role 체크
         var actionIsRole=component.get("c.isMainRole");
         actionIsRole.setCallback(this,function(response){
             var state = response.getState();
             console.log('state: '+state);
             if (state === "SUCCESS") {
                 var result=response.getReturnValue();
                 console.log('result: '+result);
                 component.set("v.isRole",result);
                 if(result==true) {
                    helper.loadEducation(component);
                     return;
                 }
                 else{
                    
                }
             } else {
                 let errors = response.getError();
                 let message = "알 수 없는 오류가 발생했습니다.";
                 if (errors && errors[0] && errors[0].message) {
                     message = errors[0].message;
                 }
                 console.log('error: '+message);
             }
         });
         $A.enqueueAction(actionIsRole);
        
    }
    
    
})