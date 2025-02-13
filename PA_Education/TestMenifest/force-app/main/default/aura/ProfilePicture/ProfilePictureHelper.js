({
    readFile: function(component, helper, file) {
        if (!file) return;
        if (!file.type.match(/(image.*)/)) {
  			return alert('Image file not supported');
		}
        var reader = new FileReader();
        reader.onloadend = function() {
            var dataURL = reader.result;
            console.log(dataURL);
            component.set("v.pictureSrc", dataURL);
            helper.upload(component, file, dataURL.match(/,(.*)$/)[1]);
        };
        reader.readAsDataURL(file);
	},
    
    MAX_FILE_SIZE: 750000, // 1 000 000 * 3/4 to account for base64 
	
	save : function(component) {
        var fileInput = component.find("file").getElement();
    	var file = fileInput.files[0];
   
        if (file.size > this.MAX_FILE_SIZE) {
            alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
    	          'Selected file size: ' + file.size);
    	    return;
        }
    
        var fr = new FileReader();
        
        var self = this;
       	fr.onload = $A.getCallback(function() {
            var fileContents = fr.result;
    	    var base64Mark = 'base64,';
            console.log(fileContents);
            component.set("v.pictureSrc", fileContents);
            console.log(fileContents);
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
 
            fileContents = fileContents.substring(dataStart);
    	    self.upload(component, file, fileContents);
        });
 
        fr.readAsDataURL(file);
    },
    
    upload: function(component, file, base64Data) {
        var action = component.get("c.saveAttachment"); 
        
        action.setParams({
            parentId: component.get("v.recordId"),
            fileName: file.name,
            base64Data: base64Data, 
            contentType: file.type
        });
        action.setCallback(this, function(a) {
            component.set("v.message", "Image uploaded");
        });
        component.set("v.message", "Uploading...");
        $A.enqueueAction(action);
      //  document.location.reload(true);
    }
    
})