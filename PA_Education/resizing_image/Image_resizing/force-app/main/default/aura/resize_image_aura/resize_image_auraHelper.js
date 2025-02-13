({
    /**
     * @description resize image
     */
    resizeImage : function(component, event, helper, fileBlob, maxDeviation, low, middle, high) {
        console.log('Is Inputed resizeImage?');

        let SIZE_1MB = 1048576 // 1024*1024*2 
        let SIZE_250KB = 256000; // 1024*250
        let fileBlobNew;
        
        let reader  = new FileReader();
        reader.addEventListener("load", function () {
            img.src = reader.result;
        }, false);
        reader.readAsDataURL(fileBlob);

        let parent = this;
        let img = new Image;
        img.onload = function() {
            const canvas = document.createElement('canvas');
            const context = canvas.getContext("2d");
            let width = img.width ;
            let height = img.height;
        
            canvas.width = Math.round(img.width * middle);
            canvas.height = Math.round(img.height * middle);
            console.log('Ratio  :: ' + middle);   
            console.log('Before :: ' + img.width +'x'+img.height);          
            console.log('After  :: ' + canvas.width +'x'+canvas.height);    

            context.scale(canvas.width / width, canvas.height / height);
            context.drawImage(img, 0, 0);
            var dataUrl = canvas.toDataURL();
            var byteString = atob(dataUrl.split(',')[1]);
            var mimeString = dataUrl.split(',')[0].split(':')[1].split(';')[0];
            var ab = new ArrayBuffer(byteString.length);
            var ia = new Uint8Array(ab);
            for (var i = 0; i < byteString.length; i++) {
            ia[i] = byteString.charCodeAt(i);
            }
            //리사이징된 file 객체
            fileBlobNew = new Blob([ab], {type: mimeString});      
            let fileSize = fileBlobNew.size;

            if ( Math.abs(fileSize - SIZE_1MB) > maxDeviation){        

                if (fileSize < (SIZE_1MB - maxDeviation)) {
                    low = middle;
                } else if (fileSize > SIZE_1MB) {
                    high = middle;
                }
                middle = (low + high) / 2;
                parent.resizeImage(component, event, helper, fileBlob, SIZE_250KB, low, middle, high);
            } else {
                parent.doUploadImage(component, event, helper, fileBlob, fileBlobNew);
            }
        }    
    },

    /**
     * @description uplaod Image 
     */
    doUploadImage : function(component, event, helper, fileBlob, fileBlobNew) {
        let reader  = new FileReader();
        let parent=this;
        reader.addEventListener("load", function () {
            let fileContents = reader.result;
            let base64 = 'base64,';
            let dataStart = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(dataStart);
            let objPhoto = component.get('v.objPhoto');
            objPhoto.fileTitle = fileBlob.name;
            
            objPhoto.fileContents = fileContents;
            objPhoto.tempUrl = URL.createObjectURL(fileBlobNew);
            component.set('v.objPhoto', objPhoto);
            console.log(objPhoto);
            component.set('v.isResizeComplete', true);

            parent.saveImageToServer(component,event,helper);
        }, false);
        reader.readAsDataURL(fileBlobNew);

        
    },

    saveImageToServer: function(component, event, helper) {
        let image = component.get('v.objPhoto');
        let recordId = component.get('v.recordId');
    
        // 데이터 검증
        if (!image || !recordId) {
            console.error('Missing objPhoto or recordId.');
            return;
        }
    
        if (!image.fileTitle || !image.fileContents) {
            console.error('Image data is missing.');
            return;
        }
    
        // 서버 호출
        var action = component.get("c.saveImage");
        action.setParams({
            "parentId": recordId,
            "fileName": image.fileTitle,
            "base64Data": image.fileContents
        });
    
        action.setCallback(this, (response) => {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result: ' + result);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.error("Error message: " + errors[0].message);
                } else {
                    console.error("Unknown error");
                }
            } else {
                console.error("Action failed: " + state);
            }
        });
    
        $A.enqueueAction(action);
    }
    

})