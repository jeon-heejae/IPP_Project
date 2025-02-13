({  
    // 검색어 하이라이트 기능
    // 2018-08-01 Soyoung.Jung 추가
    fnInit : function(component, event, helper) {
        var searchKeyword = component.get("v.searchKeyword");
        var recordInfo = component.get("v.recordInfo");
        var strName = "";
        if(recordInfo) strName = recordInfo.strName;

        if(searchKeyword) {
            var strName = "";
            var strSubName = "";
            if(recordInfo) {
                strName = recordInfo.strName;
                strSubName = recordInfo.strSubName;
            }

            // 검색어 특수문자 제거
            var pattern = /[^가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]/gi;
            searchKeyword = searchKeyword.replace(pattern, "");

            var reg = new RegExp(searchKeyword, "gi");
            var matchArray;
            var outputText = "<div>";

            var first = 0, last = 0;
            while((matchArray = reg.exec(strName)) !== null) {
                last = matchArray.index;
                outputText += strName.substring(first, last);
                outputText += "<b>" + matchArray[0] + "</b>";
                first = reg.lastIndex; 
            }
            outputText += strName.substring(first, strName.length).replace(/\./g, "<span style='color:rgb(22, 50, 92);'>.</span>");
            if(strSubName) outputText += "<span style='float: right;'>" + strSubName + "</span>";
            outputText += "</div>";

            component.set("v.outputText", outputText);
        } else {
            component.set("v.outputText", strName);
        }
    },

    doSelectItem : function(component, event, helper){      
        // get the selected Account from list  
        var getSelectRecord = component.get("v.recordInfo");
        // call the event   
        var compEvent = component.getEvent("selectedLookupEvent");
        // set the Selected Account to the event attribute.  
        compEvent.setParams({
            "recordByEvent" : getSelectRecord ,
            "sParentId" : component.get("v.sParentId") ,
            "sParentField" : component.get("v.sParentField") 
        });  
        // fire the event
        console.log(compEvent);  
        compEvent.fire();
    },
})