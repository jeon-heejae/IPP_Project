({
    
    onInit: function(component,event,helper) {
        var action = component.get("c.checkId");
        action.setParams({
            recordId: component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var flag = response.getReturnValue();
                console.log('DEBUG: flag value = ' + flag); 
                
                component.set("v.isLookSig",flag);
                if (flag) {
                    console.log('helper start');
                    
                    var action2 = component.get("c.getSignaturePicture");
                    action2.setParams({
                        parentId: component.get("v.recordId")
                    });

                    action2.setCallback(this, function(response) {
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
                    $A.enqueueAction(action2);
                }
                else{
                    console.log('서명 권한 없음');

                }
            } else {
                console.error("Error:", response.getError());
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