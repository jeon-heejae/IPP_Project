({
    checkRecordType:function(component,listSelectId){
        var action=component.get("c.checkRecordType");
        action.setParams({"listSelectId":listSelectId});
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var isCheck=response.getReturnValue();
                console.log('ischeck: ' + isCheck);
                if(!isCheck){
                    this.showToast('error','ipp만 선택할 수 있습니다');
                    window.history.back(); // 브라우저 히스토리에서 이전 페이지로 이동
                }
                else{
                    this.checkMonth(component,listSelectId);
                    // this.setVfPageUrl(component,listSelectId);
                }
            }
            else {
                console.error("Action failed: " + state);
            }
        });

        $A.enqueueAction(action); 
    },

    checkMonth:function(component, listSelectId){
        var action=component.get("c.checkMonth");
        action.setParams({"listSelectId":listSelectId});
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var isMonth=response.getReturnValue();
                console.log('isMonth: ' + isMonth);
                if(!isMonth){
                    this.showToast('error','같은 월끼리만 선택할 수 있습니다');
                    window.history.back(); // 브라우저 히스토리에서 이전 페이지로 이동
                }
                else{
                    this.setVfPageUrl(component, listSelectId);
                }
            }
            else {
                console.error("Action failed: " + state);
            }
        });

        $A.enqueueAction(action); 
    },

    setVfPageUrl: function(component,listSelectId) {
        // URL 생성
        var vfPageUrl = "/apex/printTestPdf?recordId=" + encodeURIComponent(listSelectId);
        console.log('VF Page URL: ' + vfPageUrl);

        // URL 설정
        component.set("v.vfPageUrl", vfPageUrl);
    },

    saveAction : function(component) {
        console.log('Action start');
        
    	let action = component.get("c.generatePDF");
        let vfPageUrl=component.get("v.vfPageUrl");

        action.setParams({ 'vfPageUrl': vfPageUrl });

        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let pdfBase64 = response.getReturnValue();

                // Base64 데이터를 Blob으로 변환
                let pdfBlob = new Blob([new Uint8Array(atob(pdfBase64).split("").map(char => char.charCodeAt(0)))], { type: 'application/pdf' });

                 // 사용자에게 파일 이름 입력 받기
                 let fileName = prompt("저장할 파일 이름을 입력하세요:", "Interview_Report.pdf");
                 if (!fileName.endsWith(".pdf")) {
                     fileName += ".pdf"; // 확장자 추가
                 }
                 
                // Blob을 URL로 변환하여 다운로드
                let downloadUrl = URL.createObjectURL(pdfBlob);
                let downloadLink = document.createElement("a");
                downloadLink.href = downloadUrl;
                downloadLink.download = fileName;
                downloadLink.click();
                URL.revokeObjectURL(downloadUrl); // URL 해제
            } else {
                console.error("PDF 다운로드 실패: ", response.getError());
            }
        });

        $A.enqueueAction(action); 
    },

    showToast: function (type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: message
        });
        toastEvent.fire();
    }
})