({
    searchAddress: function(component) {
        var searchKeyword = component.get("v.searchKeyword");
        var action = component.get("c.searchAddress");
        
        action.setParams({ keyword: searchKeyword });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var results = JSON.parse(response.getReturnValue());
                //console.log('Raw: '+ results);
                //console.log('Proceessed: '+JSON.stringify(results));
                if(results.size==0)
                    this.showToast("Error","검색결과가 없습니다.");
                component.set("v.searchResults", results);
            } else {
                console.error('Error searching address');
                this.showToast("Error", "주소 검색 중 오류가 발생했습니다.");
            }
            component.set("v.isLoading", false);
        });

        component.set("v.isLoading", true);
        $A.enqueueAction(action);
    },

    saveAddressToContact: function(component) {
        var action = component.get("c.saveAddressData");
        var objAddress = component.get("v.objAddress");
        var recordId = component.get("v.recordId");
       
        console.log("우편번호: "+  objAddress.PostalCode__c);
        console.log("도로명주소: "+ objAddress.RoadAddress__c);
        console.log("상세주소: "+ objAddress.DetailAddress__c);
        console.log(recordId);
        
        action.setParams({
            recordId: recordId,
            addressData: {
                PostalCode__c: objAddress.PostalCode__c,
                RoadAddress__c: objAddress.RoadAddress__c,
                DetailAddress__c: objAddress.DetailAddress__c
            }
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                // 주소 저장 이벤트 발생
                var addressSavedEvent = component.getEvent("addressSaved");
                addressSavedEvent.fire();
                
                // 모달 닫기
                this.closeModal(component);
            } else if (state === "ERROR") {
                var errors = response.getError();
                this.showToast('Error', errors[0].message);
            } 
            
            component.set("v.isLoading", false);
        });
        
        $A.enqueueAction(action);
    },

     //토스트 메시지를 사용할 helper에 이 함수를 꼭 추가해주세요
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