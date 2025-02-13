({
	/*초기데이터 받아오기*/
    getInitData : function(component) {
    					/*컴포넌트가 아닌 클래스 getInitData임*/
    	var action = component.get("c.getInitData"); 

        action.setParams({
        	//클래스로 Employee__c에 있는 id값 넘길거(a2~~~는 임의로 넣어놨음).
        	"idEmployee" : component.get("v.idEmployee"),
        	"pFromDt"    : component.get("v.pFromDt"),
        	"pToDt"	  	 : component.get("v.pToDt")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            /*성공 상태이면..*/
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
        		/*컴포넌트에 어트리뷰트로 선언되어있음/ 선언된 저 변수에 pjList, haList를 키로 한 리스트들을 삽입*/
        	    /*클래스에서 리턴할 key 이름 설정한거 받아서 셋팅*/
                component.set("v.listProject", returnValue["pjList"]);
                component.set("v.listHoliday", returnValue["haList"]);
                component.set("v.emUser", 	   returnValue["emUser"]);
        		/*console.log(returnValue);*/
            }
        });

        $A.enqueueAction(action);
    },

    closeModal : function(component, helper) {
        var modal = component.find('divModal');      /* aura:id 'divModal'찾기*/
        $A.util.removeClass(modal, 'slds-show');	
        $A.util.addClass(modal, 'slds-hide');		
        component.set('v.holidayModalView', false);
        /*scroll 방지 해제*/
		document.body.style.overflow="auto";
    },

})