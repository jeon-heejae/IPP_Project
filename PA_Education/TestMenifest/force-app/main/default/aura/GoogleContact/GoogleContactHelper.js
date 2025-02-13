({	
	doGetInitialData : function(component, helper){
		var action = component.get("c.getInitialData");
        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.clientId"  , result.objConfig.ClientId__c);
                component.set("v.apiKey"    , result.objConfig.ApiKey__c);
                component.set("v.userEmail" , result.userEmail);
                if(result.objConfig.AccessToken__c !== null && result.objConfig.AccessToken__c !== undefined){
                    component.set("v.accessToken", result.objConfig.AccessToken__c);
                    helper.fnGetRememberFolderId(component, helper);
                } 
                else {
                    this.googleConnect(component, helper);
                } 
            }
        });

        $A.enqueueAction(action);
    },
    
    fnGetRememberFolderId : function(component, helper){
        $.get("https://www.google.com/m8/feeds/groups/"+component.get("v.userEmail")+"/full?alt=json&access_token=" + component.get("v.accessToken") + "&max-results=500&v=3.0",
            function(response){
                console.log("url : "+"https://www.google.com/m8/feeds/groups/"+component.get("v.userEmail")+"/full?alt=json&access_token=" + component.get("v.accessToken") + "&max-results=500&v=3.0");
                var entry = response.feed.entry;
                for(var i=0; i < entry.length; i++){
                    if(entry[i].title.$t === "Remember"){
                        component.set("v.rememberFolderId", entry[i].id.$t);
                        helper.doGetContactData(component);
                        break;
                    }
                }
                //helper.getData(component);
                component.set("v.bSpinner", false);
            }
        ).fail(function(jqXHR) {
            var msg = jqXHR.responseJSON.error.message;
            var title = jqXHR.responseJSON.error.status;
            console.log(jqXHR.responseJSON.error.message);
            console.log(jqXHR.responseJSON.error.status);
            alert(title + '\n' + '\n'+ msg);
        });
    },

	googleConnect : function(component, helper){
        console.log('googleConnect access');
		var gapi = component.get("v.gapi");
		gapi.client.setApiKey(component.get("v.apiKey"));
		var handleAuthorization = function(authorizationResult){
			if (authorizationResult && !authorizationResult.error) {
                
                component.set("v.accessToken", authorizationResult.access_token);
                helper.fnUpdateAccessToken(component, helper);
                helper.fnGetRememberFolderId(component, helper);
				
            }else{
                //alert(authorizationResult.error);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": authorizationResult.error
                });
                toastEvent.fire();
                component.set("v.bSpinner", false);
            }
		};
		gapi.auth2.authorize({client_id: component.get("v.clientId"), scope: component.get("v.scopes"), immediate: false, access_type : "offline", response_type: "code token"}, handleAuthorization);
    },
    
    fnUpdateAccessToken : function(component, helper){
        var action = component.get("c.doUpdateAuthentication");
        
        action.setParams({
            "accessToken" : component.get("v.accessToken")
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                helper.fnGetRememberFolderId(component, helper);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": response.getError()
                });
                toastEvent.fire();
                component.set("v.bSpinner", false);
            }
        });
        $A.enqueueAction(action);
    }, 

	getData : function(component){
		var self = this;
		var callApi = {
            url : "https://www.google.com/m8/feeds/contacts/"+component.get("v.userEmail")+"/full",
            type : 'GET',
            data: "alt=json&access_token=" + component.get("v.accessToken") + "&max-results=500&v=3.0&updated-min="+component.get("v.searchDate")+"T00:00:00",
            crossDomain : true,
            success : function(result){
            	var listData = [];
                if(result.feed.entry){
                    var entry = result.feed.entry;
                    for(var i=0; i < entry.length; i++){
                        if(entry[i].gContact$groupMembershipInfo){
                            var folders = entry[i].gContact$groupMembershipInfo;
                            for(var j=0; j < folders.length; j++){
                                if(folders[j].href === component.get("v.rememberFolderId")){
                                    var obj = {
                                        email : entry[i].gd$email[0].address,
                                        name : entry[i].gd$name.gd$fullName.$t,
                                        companyName : entry[i].gd$organization[0].gd$orgName.$t,
                                        position : entry[i].gd$organization[0].gd$orgTitle.$t,
                                        phone : entry[i].gd$phoneNumber[0].$t,
                                        companyPhone : null,
                                        companyFax : null,
                                        stateDistrict : entry[i].gd$structuredPostalAddress[0].gd$formattedAddress != undefined ? entry[i].gd$structuredPostalAddress[0].gd$formattedAddress.$t : null,
                                        billingAddress_city	: entry[i].gd$structuredPostalAddress[0].gd$neighborhood != undefined ? entry[i].gd$structuredPostalAddress[0].gd$neighborhood.$t : null,
                                        billingAddress_country : entry[i].gd$structuredPostalAddress[0].gd$country != undefined ? entry[i].gd$structuredPostalAddress[0].gd$country.$t : null,
                                        billingAddress_state : entry[i].gd$structuredPostalAddress[0].gd$city != undefined ? entry[i].gd$structuredPostalAddress[0].gd$city.$t : null,
                                        billingAddress_street : entry[i].gd$structuredPostalAddress[0].gd$street != undefined ? entry[i].gd$structuredPostalAddress[0].gd$street.$t : null,
                                        googleId : entry[i].id.$t
                                    };

                                    if(entry[i].gd$phoneNumber.length > 1){
                                         for(var k = 1; k < entry[i].gd$phoneNumber.length; k++){
                                            var phoneNumber =  entry[i].gd$phoneNumber[k].rel;
                                            if(phoneNumber.endsWith('work')) obj.companyPhone = entry[i].gd$phoneNumber[k].$t; 
                                            if(phoneNumber.endsWith('work_fax')) obj.companyFax = entry[i].gd$phoneNumber[k].$t;
                                         }
                                    }
                                    listData.push(obj);
                                    break;
                                }
                            }
                        }
                    }
                    component.set("v.listData", listData);
                    self.initdataTableIcon(component);
                }else{
                    component.set("v.listData", []);
                    component.set("v.bSpinner", false);
                }
                
            },
            error : function(result){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "데이터 조회에 실패했습니다."
                });
                toastEvent.fire();
            }
        };
        $.ajax(callApi);
	},
    
    doGetContactData : function(component){
        var self = this;
        var action = component.get("c.getContact");
        action.setParams({
            "fSearchDate" : component.get("v.searchDate")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.listContactData", result);
                self.getData(component);
            }
        });
        $A.enqueueAction(action);
    },

    doCreateContact : function(component, row){
        var self = this;
        var action = component.get("c.createContact");

        action.setParams({
            datas : JSON.stringify(row)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                self.dataTableChangeIcon(component, row, result);
                window.open("/lightning/r/Contact/"+result+"/view");
            }
        });

        $A.enqueueAction(action);
        
        /*
        var lexOrigin = "https://wonsuk-dev-ed.lightning.force.com";
        parent.postMessage(JSON.stringify(row), lexOrigin);
        */
    },

    dataTableChangeIcon : function (component, row, result) {
	    var data = component.get('v.listData');
        data = data.map(function(rowData) {
	        if (rowData.googleId === row.googleId) {
	            rowData.iconName = 'utility:check';
                rowData.GoogleContactId__c = row.googleId;
	            rowData.disabledValue = true;
            }else if(rowData.GoogleContactId__c && rowData.GoogleContactId__c != ''){
                rowData.iconName = 'utility:check';
	            rowData.disabledValue = true;
        	}else{
	        	rowData.iconName = 'utility:add';
	            rowData.disabledValue = false;
	        }
	        return rowData;
	    });
	    component.set("v.listData", data);
	},

	initdataTableIcon : function (component) {
        var data = component.get('v.listData');
        var result = component.get('v.listContactData');
        
        if(result.length > 0){
            data = data.map(function(rowData) {
                rowData.iconName = 'utility:add';
                rowData.disabledValue = false;
                
                for(var i=0; i < result.length; i++){
                    if (result[i].GoogleContactId__c === rowData.googleId) {
                        rowData.iconName = 'utility:check';
                        rowData.disabledValue = true;
                        rowData.GoogleContactId__c = result[i].GoogleContactId__c;
                        break;
                    }
                }
                return rowData;
            });
            component.set("v.listData", data);
        }else{
            data = data.map(function(rowData) {
                rowData.iconName = 'utility:add';
                rowData.disabledValue = false;
                return rowData;
            });
            component.set("v.listData", data);
        }
        component.set("v.bSpinner", false);
	    
	},

	doSorting : function(component, sFieldName, sSortDirection) {
        var listData   = component.get("v.listData");
        var reverse    = sSortDirection !== "asc";

        listData.sort(this.doSortBy(sFieldName, reverse));

        component.set("v.listData", listData);
    },


    // javascript list (compareFunction) 활용한 sorting
    doSortBy : function(sFieldName, reverse, primer) {
        var key = primer ? function(x) {return primer(x[sFieldName])} : function(x) {return x[sFieldName]};
        reverse = !reverse ? 1 : -1;

        return function(a, b) {
            return a = key(a) ? key(a) : '', b = key(b) ? key(b) : '', reverse * ((a > b) - (b > a));
        }
    },
})