({
    fnInit: function(component, event, helper){
        var strId = component.get("v.sId");
        var strNm = component.get("v.sNm");
        if(strId != undefined && strId != null && strId != '' ){
        // console.log("lookup init : " + sId + "^" + sNm);
            var data = {
                 'sobjectType' : "Object",
                 "strId" : strId,
                 "strName" : strNm
            };
            component.set("v.selectedRecord" , data);
            var forclose = component.find("lookup-pill");
            $A.util.addClass(forclose, 'slds-show');
            $A.util.removeClass(forclose, 'slds-hide');
      
        
            var forcloseres = component.find("searchRes");
            $A.util.addClass(forcloseres, 'slds-is-close');
            $A.util.removeClass(forcloseres, 'slds-is-open');
        
            var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');  
        }
    },

    /*keyPressController : function(component, event, helper) {
        var sObj = component.get("v.sObj");
        var clearTimer = component.get( "v.timer" );
        clearTimeout( clearTimer );
        var timer = setTimeout( $A.getCallback( function() { 
            component.set("v.listOfSearchRecords", null);
            var lookUpMsgTarget = component.find("lookupErrorMsg");
            $A.util.addClass(lookUpMsgTarget, 'slds-hide');
            $A.util.removeClass(lookUpMsgTarget, 'slds-show');

            var lookUpBoxTarget = component.find("lookupErrorBox");
            $A.util.removeClass(lookUpBoxTarget, 'slds-has-error');

          // get the search Input keyword   
            var getInputkeyWord = component.get("v.sSearchKeyWord");
            console.log("getInputkeyWord : " + getInputkeyWord);
          // check if getInputKeyWord size id more then 0 then open the lookup result List and 
          // call the helper 
          // else close the lookup result List part.   
            if( getInputkeyWord.length > 0 ){
                var forOpen = component.find("searchRes");
                $A.util.addClass(forOpen, 'slds-is-open');
                $A.util.removeClass(forOpen, 'slds-is-close');
                if(sObj == "Eval__c"){
                    helper.searchListWithAcct(component,event,getInputkeyWord);
                }else{
                    helper.searchList(component,event,getInputkeyWord);    
                }
                
            }
            else{  
                component.set("v.listOfSearchRecords", null ); 
                var forclose = component.find("searchRes");
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');
            }
        } ) , 500 );
        component.set( "v.timer", timer );
    },*/

    keyPressController : function(component, event, helper) {
        var sObj = component.get("v.sObj");
        // var clearTimer = component.get( "v.timer" );
        // clearTimeout( clearTimer );
        // var timer = setTimeout( $A.getCallback( function() { 
        // var isEnterKey = event.keyCode === 13;
        // if(isEnterKey) {
        component.set("v.listOfSearchRecords", null);
        var lookUpMsgTarget = component.find("lookupErrorMsg");
        $A.util.addClass(lookUpMsgTarget, 'slds-hide');
        $A.util.removeClass(lookUpMsgTarget, 'slds-show');

        var lookUpBoxTarget = component.find("lookupErrorBox");
        $A.util.removeClass(lookUpBoxTarget, 'slds-has-error');

      // get the search Input keyword   
        var getInputkeyWord = component.get("v.sSearchKeyWord");
        console.log("getInputkeyWord : " + getInputkeyWord);
          // check if getInputKeyWord size id more then 0 then open the lookup result List and 
          // call the helper 
          // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            if(sObj == "Eval__c"){
                helper.searchListWithAcct(component,event,getInputkeyWord);
            }else{
                helper.searchList(component,event,getInputkeyWord);    
            }
            
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
        // } ) , 500 );
        // }
        // component.set( "v.timer", timer );
    },
  
  // function for clear the Record Selaction 
    clear :function(component,event,heplper){
        component.set("v.bShowSearchIcon", true);
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
      
        component.set("v.sSearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );

        // 선택했다가 지우면 값이 남아있는 현상 때문에 추가
        component.set("v.selectedRecord", {});
        component.set("v.sId", null);
    },
    parentSet:function(component, event, helper){
        var params = event.getParam('arguments');
        if(params){
            component.set("v.selectedRecord" , params.param); 
        }
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
      
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');  
    },
  // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        component.set("v.bShowSearchIcon", false);
        console.log("select~~~~");
        // get the selected Account record from the COMPONETN event      
        var selectRecord = event.getParam("recordByEvent");
        console.log(JSON.parse(JSON.stringify(selectRecord)));
        component.set("v.selectedRecord" , selectRecord); 

        console.log("commonlookup : " + selectRecord.strId + " // " + selectRecord.strName);
        component.set("v.sId", selectRecord.strId);
        component.set("v.sNm", selectRecord.strName);
       
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
      
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');  
      
    },
/*  // automatically call when the component is done waiting for a response to a server request.  
    hideSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : false });
        evt.fire();    
    },
 // automatically call when the component is waiting for a response to a server request.
    showSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();    
    },*/
    
    getSelectItem : function(component, event){
        var wrapper = component.get("v.selectedRecord");
        var params = event.getParam('arguments');
        if(params){
            if(params.fieldNm == "sId"){
                return wrapper.strId;
            }else if(params.fieldNm == "sName"){
                return wrapper.strName;
            }else if(params.fieldNm == "sObj"){
                var obj = {
                    "sId" : wrapper.strId,
                    "sName" : wrapper.strName,
                    "sParentId" : component.get("v.sParentId"),
                    "sParentField" : component.get("v.sParentField")
                };
                return obj;
            }
        }else{
            return "";
        }
    },
    doErrorMsg : function(component, event){
        var params = event.getParam('arguments');
        console.log(params.errorMsg);
        if(params){
            component.set("v.errorMessage" , params.errorMsg); 
        }
        console.log(component.get("v.errorMessage"));

        var lookUpMsgTarget = component.find("lookupErrorMsg");
        $A.util.addClass(lookUpMsgTarget, 'slds-show');
        $A.util.removeClass(lookUpMsgTarget, 'slds-hide');

        var lookUpBoxTarget = component.find("lookupErrorBox");
        $A.util.addClass(lookUpBoxTarget, 'slds-has-error');
        
    },
    doRequiredMark : function(component,event){
        var requiredMarks = component.find("requiredMark");
        $A.util.addClass(requiredMarks, 'slds-hide');
    }
})