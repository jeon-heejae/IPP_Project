/**
 * Created by smyan on 2021-01-29.
 */

({
    getPdfData:function(component, contentDocumentId){
        component.set("v.status", "NONE");
        var action = component.get('c.getPdfData');
        action.setParams({ "contentDocumentId" : contentDocumentId});
        var self = this;
        action.setCallback(this, function(actionResult) {
            var r = actionResult.getReturnValue();
            console.log(r);
            $A.createComponent(
                "c:PdfViewer",
                {
                    "pdfData": r
                },
                function(pdfViewer, status, errorMessage){
                    component.set("v.status", status);
                    if (status === "SUCCESS") {
                        var pdfContainer = component.get("v.pdfContainer");
                        pdfContainer.push(pdfViewer);
                        component.set("v.pdfContainer", pdfContainer);
                        component.set("v.toggleSpinner", false);
                    }
                    else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                    }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }
                    //self.resizeView();
                }
            );
        });
        $A.enqueueAction(action);
    },


    resizeView : function(){
        var winHeight = jQuery(window).height();
        console.log('winHeight : ' +winHeight  );

        jQuery('#drawPdf').height("76vh");
    }
});