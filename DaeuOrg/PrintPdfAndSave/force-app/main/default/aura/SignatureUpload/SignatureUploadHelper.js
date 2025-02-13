({
    
    readFile: function(component, helper, file) {
        if (!file) return;
        if (!file.type.match(/(image.*)/)) {
            return alert("Image file not supported");
        }
        var reader = new FileReader();
        reader.onloadend = function () {
            var dataURL = reader.result;
            console.log(dataURL);
            component.set("v.pictureSrc", dataURL);
            helper.upload(component, file, dataURL.match(/,(.*)$/)[1]);
        };
        reader.readAsDataURL(file);
    },

    upload: function(component, file, base64Data) {
        var action = component.get("c.saveSignaturePicture");
        action.setParams({
            parentId: component.get("v.recordId"),
            fileName: file.name,
            base64Data: base64Data
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var contentDocumentId = response.getReturnValue();
                component.set(
                    "v.pictureSrc",
                    "/sfc/servlet.shepherd/document/download/" + contentDocumentId
                );
                component.set("v.message", "Image uploaded successfully");
            } else if (state === "ERROR") {
                component.set("v.message", "Upload failed");
                console.error("Error uploading image:", response.getError());
            }
        });
        component.set("v.message", "Uploading...");
        $A.enqueueAction(action);
    }
});
