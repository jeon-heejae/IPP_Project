/*
* Component Name                : MyHolidayInfoLightning.cmp
* Component Controller          : MyHolidayInfoLightningController.js
* Component Helper              : MyHolidayInfoLightningHelper.js
* Component Contorlller Class   : HolidayController.cls
* Test Class                    : HolidayController_Test.cls
* Description                   : 휴가정보 Detail
* Modification Log 
* =============================================================== 
* Ver     Date          Author           Modification
* ===============================================================
  1.0   2018.08.27      MH.Kwak             Create
  2.0   2018.12.27		JK.lee				Modified
*/

({
	doInit : function(component, event, helper) {	
		helper.getPermCheck(component,event,helper);
        helper.getHolidayLabel(component);
        helper.getActionLabel(component);
	},

    gotoURL : function(component, event, helper) {
        helper.goDetail(component, event, helper);
    },

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
    
    clickStatus2 : function(component, event, helper) {
	var y = document.getElementById("myDIV2");
		if (y.style.display === "none") {
		    y.style.display = "block";
		    component.set('v.clickType2', true);
		} else {
		    y.style.display = "none";
		    component.set('v.clickType2', false);
		}
	},

	clickStatus21 : function(component, event, helper) {
    var y = document.getElementById("myDIV21");
    	if (y.style.display === "none") {
    	    y.style.display = "block";
    	    component.set('v.clickType21', true);
    	} else {
    	    y.style.display = "none";
    	    component.set('v.clickType21', false);
    	}
    },

    clickStatus22 : function(component, event, helper) {
        var y = document.getElementById("myDIV22");
    	if (y.style.display === "none") {
    	    y.style.display = "block";
    	    component.set('v.clickType22', true);
    	} else {
    	    y.style.display = "none";
    	    component.set('v.clickType22', false);
    	}
    },

    clickStatus23 : function(component, event, helper) {
        var y = document.getElementById("myDIV23");
    	if (y.style.display === "none") {
    	    y.style.display = "block";
    	    component.set('v.clickType23', true);
    	} else {
    	    y.style.display = "none";
    	    component.set('v.clickType23', false);
    	}
    },
    clickStatus24 : function(component, event, helper) {
        var y = document.getElementById("myDIV24");
    	if (y.style.display === "none") {
    	    y.style.display = "block";
    	    component.set('v.clickType24', true);
    	} else {
    	    y.style.display = "none";
    	    component.set('v.clickType24', false);
    	}
    },

	clickStatus3 : function(component, event, helper) {
	var y = document.getElementById("myDIV3");
		if (y.style.display === "none") {
		    y.style.display = "block";
		    component.set('v.clickType3', true);
		} else {
		    y.style.display = "none";
		    component.set('v.clickType3', false);
		}
	},

	clickStatus4 : function(component, event, helper) {
	var y = document.getElementById("myDIV4");
		if (y.style.display === "none") {
		    y.style.display = "block";
		    component.set('v.clickType4', true);
		} else {
		    y.style.display = "none";
		    component.set('v.clickType4', false);
		}
	}
});