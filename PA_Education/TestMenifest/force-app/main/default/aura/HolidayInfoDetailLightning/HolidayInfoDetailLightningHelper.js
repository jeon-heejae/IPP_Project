({
    getActionLabel : function(component, event, helper){
      var action = component.get('c.getObjectFieldLabel');
      action.setParams({
        "sObjectName" : "HolidayAction__c"
      });
      action.setCallback(this,function(reponse){
        var state = reponse.getState();
        var result = reponse.getReturnValue();
        console.log('-----result------/ '+result);      
        component.set('v.holidayActionMapLabel',result);      

       });
      $A.enqueueAction(action);
    },


    getHoilday : function(component, event, helper) {
        var action = component.get('c.getHoliday');
        
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();       
            var state =  response.getState();
            
            if(state == 'SUCCESS' ) {              
                component.set('v.holiday', result);                
                helper.getHolidayList(component, event, helper);
                helper.getHolidayHistory(component, event, helper);      // Hoilday 값을 가져오는 것이 성공을 하면 
            }
        });
        
       $A.enqueueAction(action);
    },


     getHolidayList :function(component, event, helper){
      var action2 = component.get('c.getHolidayList');
      action2.setCallback(this,function(response){
        var result =response.getReturnValue();
        var state = response.getState();

        if(state =='SUCCESS'){          
          component.set('v.holidayAction',result);
        
        }
      });
       $A.enqueueAction(action2);
     },


    getHolidayHistory : function(component, event, helper){
      var action4 = component.get('c.getHolidayHistory');
      action4.setCallback(this,function(reponse){
        var result= reponse.getReturnValue();
        var state = reponse.getState();

        if(state== 'SUCCESS'){
           component.set('v.holidayHistory',result); 
         }
      });
      $A.enqueueAction(action4);
    },

});