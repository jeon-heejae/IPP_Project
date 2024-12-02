({
    initColumns: function(component) {
        component.set('v.columns', [
            {label: 'Contact Id', type: 'button', initialWidth: 135, 
                typeAttributes: { label: 'View Details', name: 'view_details', title: 'Click to View Details'}},
            {label: 'Last Name', fieldName: 'LastName', type: 'text'},
            {label: 'Account Name', fieldName: 'AccountName', type: 'text'},
            {label: 'Email', fieldName: 'Email', type: 'email'} 
        ]);
    },
    
    searchContacts: function(component) {
        var action = component.get("c.searchContacts");
        action.setParams({
            "searchLastName": component.get("v.searchLastName"),
            "searchAccountName": component.get("v.searchAccountName"),
            "searchEmail": component.get("v.searchEmail")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var results = response.getReturnValue();
                console.log('결과: '+ JSON.stringify(results));

                if (results.length === 0) {
                    this.showToast("Info", "검색된 내역이 없습니다.");
                }

                var processedContacts = results.map(function(contact) {
                    return {
                        Id: contact.Id,
                        LastName: contact.LastName,
                        AccountName: contact.Account ? contact.Account.Name : '',
                        Email: contact.Email
                    };
                });
                console.log(processedContacts);
                console.log(processedContacts.length);
                component.set("v.contacts", processedContacts);
                component.set("v.totalCount", processedContacts.length);
                
                console.log("저장된 개수: "+ component.get("v.totalCount"));
                
                var totalCount=component.get("v.totalCount");
                
                var totalPages=Math.ceil(totalCount / 10);
                component.set("v.totalPages",totalPages);
                component.set("v.currentPage",1);


                var listContacts=component.get("v.contacts");
                var listcurrent=component.get("v.currentContacts");
                console.log('listContacts: '+ listContacts);
                console.log('listcurrent:'+listcurrent);
                var index;
                for(index=0;index<10;index++){
                    listcurrent[index]=listContacts[index];
                }
                console.log(listcurrent);
                component.set("v.currentContacts",listcurrent);
                console.log('Processed v.currentContacts (stringify):', JSON.stringify(component.get("v.currentContacts")));
                
                
            } else {
                this.showToast("Error", "Error occurred while searching contacts.");
            }
        });
        
        $A.enqueueAction(action);
    },

    nextContacts: function(component,nextPage){
        var currentContacts=[];
        var contacts=component.get("v.contacts");
        var index;
        var i=0;
        for(index=nextPage*10-10;index<nextPage*10;index++){
            if(index>=contacts.length)
                break;
            currentContacts[i]=contacts[index];
            i++;
        }
        component.set("v.currentContacts",currentContacts);
    },

    prevContacts: function(component,prevPage){
        var currentContacts=[];
        var contacts=component.get("v.contacts");
        var index;
        var i=0;
        for(index=prevPage*10-10;index<prevPage*10;index++){
            if(index>=contacts.length)
                break;
            currentContacts[i]=contacts[index];
            i++;
        }
        component.set("v.currentContacts",currentContacts);
    },

    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key : "info_alt"
            , type : type
            , message : message
        });
        evt.fire();
    }
})