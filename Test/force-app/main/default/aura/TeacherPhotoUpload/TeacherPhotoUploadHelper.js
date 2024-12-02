({
    loadTeacherInfo: function(component) {
        var action = component.get("c.getTeacherInfo");
        action.setParams({
            teacherId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.teacher", response.getReturnValue());
               
            } else if (state === "ERROR") {
                console.error('Error loading teacher info:', response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    readFile: function(component, file) {
        if (!file) return;
        if (!file.type.match(/(image.*)/)) {
            return alert('Image file not supported');
        }
        var reader = new FileReader();
        reader.onloadend = function() {
            var dataURL = reader.result;
            component.set("v.pictureSrc", dataURL);
            this.uploadProfilePicture(component, file, dataURL.match(/,(.*)$/)[1]);
        }.bind(this);
        reader.readAsDataURL(file);
    },

    uploadProfilePicture: function(component, file, base64Data) {
        var action = component.get("c.saveAttachment");
        action.setParams({
            parentId: component.get("v.recordId"),
            fileName: file.name,
            base64Data: base64Data,
            contentType: file.type
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.message", "Image uploaded successfully");
            } else if (state === "ERROR") {
                component.set("v.message", "Upload failed");
                console.error('Error uploading image:', response.getError());
            }
        });
        component.set("v.message", "Uploading...");
        $A.enqueueAction(action);
    }
})