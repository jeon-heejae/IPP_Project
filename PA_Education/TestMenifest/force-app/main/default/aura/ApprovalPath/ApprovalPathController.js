({
	fnInit : function(component, event, helper) {

		var listApprover = event.getParam("listApprover");
		var listAppName  = event.getParam("listAppName");
		var sPendingUser = event.getParam("sPendingUser");
		var bIsCreatePath= event.getParam("bIsCreatePath");
		var iPending ;

		if(bIsCreatePath) $A.get('e.force:refreshView').fire();

		component.set("v.listApprover", listApprover);
		component.set("v.listAppName",  listAppName );
		component.set("v.sPendingUser", sPendingUser);


		var listObj =[];
		// pending index
		for(var i in listApprover) {
			var objAppNameId = {
									"Id"   : listApprover[i],
									"Name" : listAppName[i]
			};
			// console.log(JSON.stringify(objAppNameId));
			listObj.push(objAppNameId);
			if(listApprover[i] == sPendingUser) { iPending = i;}
		}
		
		component.set("v.listObj" , listObj);
		component.set("v.iPending", parseInt(iPending));
	}
})