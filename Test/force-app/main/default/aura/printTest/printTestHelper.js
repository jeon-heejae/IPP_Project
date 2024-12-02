({
    saveAction: function (component) {
        console.log("저장 버튼 눌림");

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
                downloadLink.download = "Interview_Report.pdf";
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