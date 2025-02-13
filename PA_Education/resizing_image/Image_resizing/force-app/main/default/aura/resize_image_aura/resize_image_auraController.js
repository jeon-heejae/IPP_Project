({
    doInit:function(component, event, helper){
        let recordId=component.get('v.recordId');
        console.log('recordId: '+recordId);
    },

    handleFilesChange:function(component, event, helper){
        let SIZE_1MB = 1048576 // 1024*1024*1
        let SIZE_250KB = 256000; // 1024*250
        let fileBlob  = event.getSource().get("v.files")[0];

        if ( fileBlob.size > SIZE_1MB){
            console.log('Resizing ::')
            helper.resizeImage(component, event, helper, fileBlob, SIZE_250KB, 0.0, 0.5, 1.0);
        } else {
            console.log('No Resizing ::')
            helper.doUploadImage(component, event, helper, fileBlob, fileBlob);
        }
    }
})