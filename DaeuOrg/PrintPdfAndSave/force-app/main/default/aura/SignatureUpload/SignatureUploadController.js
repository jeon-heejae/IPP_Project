({
    
    onInit: function(component) {
        var action = component.get("c.getSignaturePicture");
        action.setParams({
            parentId: component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var contentDocument = response.getReturnValue();
                if (contentDocument) {
                    
                    console.log('Id: '+contentDocument.Id);
                    component.set(
                        "v.pictureSrc",
                        "/sfc/servlet.shepherd/version/download/" + contentDocument.Id
                    );
                }
            } else {
                console.error("Error fetching file:", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    handleDragOver: function(component, event) {
        event.preventDefault();
    },

    handleDrop: function(component, event, helper) {
        event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = "copy";
        var files = event.dataTransfer.files;
        if (files.length > 1) {
            return alert("You can only upload one signature picture");
        }
        helper.readFile(component, helper, files[0]);
    },

    handleFileSelect: function(component, event, helper) {
        var fileInput = document.createElement("input");
        fileInput.type = "file";
        fileInput.accept = "image/*";
        fileInput.onchange = function () {
            if (fileInput.files.length > 0) {
                helper.readFile(component, helper, fileInput.files[0]);
            }
        };
        fileInput.click();
    }
});
