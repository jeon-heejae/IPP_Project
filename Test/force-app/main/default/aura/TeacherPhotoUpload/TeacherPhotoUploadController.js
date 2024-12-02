({
    doInit : function(component, event, helper) {
        console.log('doInit called');
        var action = component.get("c.getProfilePicture"); 
        action.setParams({
            recordId: component.get("v.recordId"),
        });
        action.setCallback(this, function(a) {
            var attachment = a.getReturnValue();
            console.log(attachment);
            if (attachment && attachment.Id) {
	            component.set('v.pictureSrc', '/servlet/servlet.FileDownload?file=' 
                                                  + attachment.Id);
            }
        });
        $A.enqueueAction(action); 
        helper.loadTeacherInfo(component);
    },

    handleDragOver: function (component, event) {
        //이벤트 흐름의 어떤 단계에서라도 preventDefault()를 호출하면 이벤트를 취소합니다. 
        //즉, 이벤트에 대한 구현체의 기본 동작을 실행하지 않습니다.
        event.preventDefault();
    },

    handleDrop: function (component, event, helper) {
        event.stopPropagation();
        event.preventDefault();
        //DateTransfer 객체는 드래그 앤 드롭 작업 중에 드래그되고 있는 데이터를 보관하기 위해 사용됩니다. 
        //각각의 데이터 타입들에 해당하는 하나 이상의 데이터 항목을 포함할 수 있습니다
        event.dataTransfer.dropEffect = 'copy'; //원본 항목의 사본이 새 위치에 만들어짐
        var files = event.dataTransfer.files;
        if (files.length > 1) {
            return alert("You can only upload one profile picture");
        }
        helper.readFile(component, files[0]);
    },
    handleFileSelect: function(component, event, helper) {
        var fileInput = document.createElement('input');
        fileInput.type = 'file';
        fileInput.accept = 'image/*';
        fileInput.onchange = function() {
            if (fileInput.files.length > 0) {
                helper.readFile(component, fileInput.files[0]);
            }
        };
        fileInput.click();
    }
})