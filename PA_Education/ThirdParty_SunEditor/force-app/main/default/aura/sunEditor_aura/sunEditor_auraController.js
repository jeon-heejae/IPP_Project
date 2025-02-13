({
    doInit: function(component, event, helper) {
        component.set('v.recordId', component.get('v.recordId'));
    
        //SunEditor__c 필드에 저장된 값 가져오기기
        helper.handleGetSunEditor(component, event);

        // VF Origin 가져오기, 동기로 작성: 호스트네임을 가져온 후 뒤 코드를 진행해야 함함
        helper.getDomainHostName(component, event)
            .then((vfOrigin) => {
                console.log("return vfOrigin:", vfOrigin);
                component.set("v.vfOrigin", vfOrigin);

                // 메시지 리스너 등록 (한 번만 등록해야 함)
                window.addEventListener("message", $A.getCallback(function(event) {
                    if (event.origin !== vfOrigin) {
                        console.warn("Origin mismatch: ", event.origin);
                        return;
                    }

                    const message = event.data;
                    if (message.type === "sunEditorContent") {
                        console.log("Received content: ", message.payload);
                        
                        // Aura 변수에 데이터 설정
                        component.set("v.message", message.payload);

                        // 데이터를 서버에 저장
                        helper.saveSunEditor(component, event);

                        //window.location.reload();

                    }
                }), false);
            })
            .catch((error) => {
                console.error("Error fetching VF origin:", error);
            });
    },

    handleEdit: function(component,event,helper){
        component.set("v.isEditMode",true);
    },

    sendVF:function(component,event,helper){
        var message = component.get("v.message");
        console.log('edit message:'+ message);
        var vfOrigin = component.get("v.vfOrigin");
        console.log('vfOrigin: '+vfOrigin);

        var vfFrame=component.find("vfFrame");
        console.log("VF Frame:", vfFrame);

        
        console.log("iframe src:", vfFrame.getElement().src);

        if (vfFrame) {
            var element = vfFrame.getElement();
            console.log("Iframe Element:", element);
    
            if (element && element.contentWindow) {
                var vfWindow = element.contentWindow;
                console.log("VF Window:", vfWindow);
            } else {
                console.error("ContentWindow is missing.");
            }
        } else {
            console.error("VF Frame not found.");
        }
            
        vfWindow.postMessage(message, vfOrigin);
    },
 
    handleSave:function(component,event,helper){
        console.log('save button start');
        
        var message = "save";
        
        console.log('save message:'+ message);
        var vfOrigin = component.get("v.vfOrigin");
        console.log('vfOrigin: '+vfOrigin);
        var vfFrame = component.find("vfFrame");
        console.log("VF Frame:", vfFrame);
        console.log("iframe src:", vfFrame.getElement().src);

        // var recordId=component.get('v.recordId');
        
        // var iframe_src=vfOrigin + '/apex/vfSunEditor?recordId=' + recordId;
        // console.log('iframe_src: '+iframe_src);

        if (vfFrame) {
            var element = vfFrame.getElement();
            console.log("Iframe Element:", element);

            if (element && element.contentWindow) {
                var vfWindow = element.contentWindow;
                console.log("VF Window:", vfWindow);
                vfWindow.postMessage(message, vfOrigin);
                console.log('save start');
            } else {
                console.error("ContentWindow is missing.");
            }
        } else {
            console.error("VF Frame not found.");
        }
                

        component.set("v.isEditMode", false);
    },
 
    handleCancel:function(component,event,helper){

        console.log('cancel button start');
        
        var message = component.get("v.message");
        message="cancel";
        console.log('cancel message:'+ message);
        var vfOrigin = component.get("v.vfOrigin");
        console.log('vfOrigin: '+vfOrigin);
        var vfFrame = component.find("vfFrame");
        console.log("VF Frame:", vfFrame);

        if (vfFrame) {
            var element = vfFrame.getElement();
            console.log("Iframe Element:", element);

            if (element && element.contentWindow) {
                var vfWindow = element.contentWindow;
                console.log("VF Window:", vfWindow);
            } else {
                console.error("ContentWindow is missing.");
            }
        } else {
            console.error("VF Frame not found.");
        }
        vfWindow.postMessage(message, vfOrigin);

        component.set("v.isEditMode",false);
    }
})
