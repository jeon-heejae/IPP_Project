({
    fnInit: function(component, event, helper) {
        component.set('v.toggleSpinner',true);
        component.set("v.isChanged", false);

        helper.getData(component);
    },

    fnGoRecord : function(component, event , helper){
        var target = event.target;
		var detailId = target.getAttribute("data-Index");

		var url = '/lightning/r/User/' + detailId + '/view';
	    if (detailId.startsWith('a')) {
	        url = '/lightning/r/Holiday__c/' + detailId + '/view';
        }

        window.open(url, '_blank');
    },

    fnDoSave : function(component, event , helper){
        component.set('v.toggleSpinner',true);
        helper.doSave(component);
    },

    fnDoCreate : function(component, event , helper){
        component.set('v.toggleSpinner',true);
        helper.doCreate(component);
    },

    fnDoUpdate : function(component, event , helper){
        component.set('v.toggleSpinner',true);
        helper.doUpdate(component);
    },

    fnDoResetUnPaid : function(component, event , helper){
        component.set('v.toggleSpinner',true);    
        helper.doReset(component,'unpaid');
    },

    fnDoResetUncountable: function(component, event , helper){
        component.set('v.toggleSpinner',true);    
        helper.doReset(component,'uncountable');
    },

    fnDoModify: function(component, event , helper){
        var modifyDays = component.get("v.modifyDays");
        if(modifyDays == 0 || modifyDays == null){
            helper.showToast('Error', 'Check Days.');
            return;
        }
        component.set('v.toggleSpinner',true);    
        helper.doModify(component);
    },

    fnDoSend: function(component, event , helper){
        component.set('v.toggleSpinner',true);    
        helper.doSend(component);
    },

    fnCheckAll : function(component, event , helper){
        var ischecked = event.getSource().get("v.checked");
        var listData = component.get("v.hldChkLst");
        if(listData != undefined){
            for(var i = 0; i<listData.length; i++){
                listData[i].isChecked = ischecked;
            }
            component.set("v.hldChkLst", listData);
        }
    },

    fnValueChange : function(component, event , helper){
        component.set("v.isChanged", true);
    },
})