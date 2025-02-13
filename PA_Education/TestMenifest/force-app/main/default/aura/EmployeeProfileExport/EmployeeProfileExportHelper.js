({
    getInitData : function(component) {
    	var action = component.get("c.getInitData");

        action.setParams({
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
            	var returnValue 	= response.getReturnValue();
            	var iTotalCnt 		= returnValue["iTotalCnt"];
            	var listChildObject = returnValue["listChildObject"];
                console.log("iTotalCnt : " + iTotalCnt);

                if(iTotalCnt <= 2000) component.set("v.iTotalRows", iTotalCnt);
                else component.set("v.iTotalRows", 2000);

                component.set("v.listChildObject", listChildObject);

                this.getListEmployee(component);
            }
        });

        $A.enqueueAction(action);	
    },

    getListEmployee : function(component) {
        console.log("offset : " + component.get("v.iRowNumberOffset") + ", limit : " + component.get("v.iInitRows"));

        var action = component.get("c.getListEmployee");

        action.setParams({
            "limits"     : component.get("v.iInitRows"),
            "offsets"    : component.get("v.iRowNumberOffset")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                component.set("v.listEmployee", response.getReturnValue());
                component.set("v.iCurrentCnt", component.get("v.iInitRows"));
            }
        });

        $A.enqueueAction(action);
    },

    doFetchData : function(component, rows) {
        return new Promise($A.getCallback(function(resolve, reject) {
            console.log("*** doFetchData ***");
            console.log("offset : " + component.get("v.iCurrentCnt") + ", limit : " + component.get("v.iInitRows"));

            var action = component.get("c.getListEmployee");

            action.setParams({
                "limits"     : component.get("v.iInitRows"),
                "offsets"    : component.get("v.iCurrentCnt")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();

                if(state === "SUCCESS") {
                    resolve(response.getReturnValue());

                    component.set("v.iCurrentCnt", component.get("v.iCurrentCnt") + component.get("v.iInitRows"));
                    console.log("iCurrentCnt : " + component.get("v.iCurrentCnt"));
                }
            });

            $A.enqueueAction(action);
        }));    
    },

    doSorting : function(component, sFieldName, sSortDirection) {
        var listEmployee   = component.get("v.listEmployee");
        var reverse         = sSortDirection !== "asc";

        if(sFieldName == 'AgreementUrl') listEmployee.sort(this.doSortBy("Name", reverse));
        else if(sFieldName == 'ServiceAccountUrl') listEmployee.sort(this.doSortBy("ServiceAccount", reverse));
        else listEmployee.sort(this.doSortBy(sFieldName, reverse));

        component.set("v.listEmployee", listEmployee);
    },

    doSortBy : function(sFieldName, reverse, primer) {
        var key = primer ? function(x) {return primer(x[sFieldName])} : function(x) {return x[sFieldName]};
        reverse = !reverse ? 1 : -1;

        return function(a, b) {
            return a = key(a) ? key(a) : '', b = key(b) ? key(b) : '', reverse * ((a > b) - (b > a));
        }
    },

    doCreateApproval : function(component, listIdRecords) {
        var action = component.get("c.doCreateApproval");

        action.setParams({
            "listIdRecords" : listIdRecords
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var sReturnValue    = response.getReturnValue();
                var listReturnValue = sReturnValue.split("/");

                // Hide Spinner
                component.set("v.bIsShowSpinner", false);

                // Toast message
                this.showToast(listReturnValue[0], listReturnValue[1]);

                if(listReturnValue[0] === "success") {
                    component.find("datatable").set("v.selectedRows", []);

                    var navigateEvent = $A.get("e.force:navigateToSObject");

                    navigateEvent.setParams({ 
                        "recordId": listReturnValue[2]
                    });

                    navigateEvent.fire();                    
                }
            }
        });

        $A.enqueueAction(action);
    },    

    doCreateExcelUpload : function(component) {
        $A.createComponent(
            "c:AgreementExcelUpload",
            {},
            function(cAgreementExcelUpload, status, errorMessage) {
                if(status === "SUCCESS") {
                    // callback action
                    component.set("v.AgreementExcelUpload", cAgreementExcelUpload);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }   
        );
    },

    getInfoServiceReport : function(component) {
        var sDevName = "InforService_Agreement"; // 레포트 명
        var action = component.get("c.getInfoServiceReport");

        action.setParams({
            "sDevName" : sDevName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var sReturnValue    = response.getReturnValue();
                var listReturnValue = sReturnValue.split("/");

                if(listReturnValue[0] === "success") {
                    var navigateEvent = $A.get("e.force:navigateToSObject");
                    navigateEvent.setParams({ 
                        "recordId": listReturnValue[1]
                    });
                    navigateEvent.fire();                    
                } else {
                    // Toast message
                    this.showToast(listReturnValue[0], listReturnValue[1]);   
                }
            }
        });

        $A.enqueueAction(action);    
    },

    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");

        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });

        evt.fire();
    },
})