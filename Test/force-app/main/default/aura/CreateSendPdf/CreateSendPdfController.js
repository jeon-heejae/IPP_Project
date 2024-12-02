({
    fnInit : function(component, event, helper){
        component.set("v.vfPageUrl" , "/apex/PdfTemplet?recordId=" + component.get("v.recordId"));
    },

    fnCancel : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    
    fnSaveAndSend: function(component, event, helper) {
        console.log("Call Save and Send");
        
        // PDF 저장
        helper.saveAction(component, event)
            .then(() => {
                console.log("PDF saved successfully");
                // 이메일 정보 가져오기
                return helper.getResult(component);
            })
            .then(() => {
                console.log("Email information retrieved successfully");
                // 이메일 전송
                return helper.sendEmailWithAttachment(component);
            })
            .then(() => {
                console.log("Email sent successfully");
                helper.showToast("success", "PDF가 저장되고 이메일이 성공적으로 전송되었습니다.");
            })
            .catch((error) => {
                console.error("Error occurred: ", error);
                helper.showToast("error", "처리 중 오류가 발생했습니다: " + error);
            });
    }
});