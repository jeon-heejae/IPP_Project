({
    handleKeyUp: function(component, event, helper) {
        var keyCode = event.keyCode;
        var searchKeyword = component.get("v.searchKeyword");
        console.log(event.keyCode);
        
        // Enter 키를 눌렀을 때 검색 실행
        if (keyCode == 13) {
            helper.searchAddress(component);
        } 
    },
    
    selectAddress: function(component, event, helper) {
        var selectedItem = event.currentTarget;
        console.log(selectedItem);
        console.log('dataset: '+ selectedItem.dataset);
        var roadAddress = selectedItem.dataset.address;
        var zipCode = selectedItem.dataset.zipcode;
        console.log(roadAddress);
        console.log(zipCode);
        
        var selectedAddress = {
            PostalCode__c: zipCode,
            RoadAddress__c: roadAddress,
            DetailAddress__c: ""
        };

        component.set("v.selectedAddress", selectedAddress);
        console.log(selectedAddress);
        component.set("v.searchResults", []); // 검색 결과 목록 초기화

        component.set("v.showSearchAddress", false);  
        component.set("v.showSelectedAddress",true);
    },
    

    saveAddress: function(component, event, helper) {
        var selectedItem=component.get("v.selectedAddress");
        component.set("v.objAddress",selectedItem);
        console.log("objAddress: " + component.get("v.objAddress.DetailAddress__c")
    +component.get("v.objAddress.PostalCode__c")+component.get("v.objAddress.RoadAddress__c"));
        console.log("selectedAddress: "+ component.get("v.selectedAddress.DetailAddress__c"));
        
        // 로딩 상태 설정
        component.set("v.isLoading", true);
        
        helper.saveAddressToContact(component);
    },


    backToSearch: function(component, event, helper) {
        
        component.set("v.showSelectedAddress", false);
        component.set("v.showSearchAddress", true);
        
        component.set("v.selectedAddress", { PostalCode__c: '', RoadAddress__c: '', DetailAddress__c: '' });
        component.set("v.searchResults", []); // 검색 결과 목록 초기화
        component.set("v.searchKeyword",""); //검색키워드 초기화
    },

    handleCancel: function(component, event, helper) {
         // 모든 관련 속성 초기화
         component.set("v.selectedAddress", { PostalCode__c: '', RoadAddress__c: '', DetailAddress__c: '' });
         component.set("v.searchResults", []);
         component.set("v.searchKeyword", "");
         component.set("v.showSelectedAddress", false);
         component.set("v.showSearchAddress", true);
         component.set("v.isLoading", false);
        
        

        // 모달 닫기 이벤트 발생
        var closeModalEvent = component.getEvent("closeModal");
        closeModalEvent.fire();
    },

    closeModal : function(component, event, helper) {
        var closeModalEvent = component.getEvent("closeModal");
        closeModalEvent.fire();
    }
})