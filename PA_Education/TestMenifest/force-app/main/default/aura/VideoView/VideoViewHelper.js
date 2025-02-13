/**
 * Created by smyan on 2021-01-29.
 */

({
    getInitData : function(component){
        var action = component.get("c.doGetInitData");
        action.setParams({
            "strRecordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                //console.log(result);
                /*var video = document.getElementById('videoCmp');
                var source = document.createElement('source');
                source.setAttribute('src', result);
                video.appendChild(source);*/

                var extension = result["extension"];

                if(extension == "pdf"){
                    component.set("v.videoYn", false);
                    $A.createComponent(
                        "c:PdfViewerContainer",
                        {
                            "contentDocumentId" : result["strResult"]
                        },
                        function(newCmp){
                            if (component.isValid()) {
                                component.set("v.pdfBody", newCmp);
                            }
                        }
                    );
                }else{
                    component.set("v.videoYn", true);
                    var ele = '<video aura:id="videoRenderer" width="1230" autoplay="autoplay" height="700" controls="Play,Pause" controlsList="nodownload"> <source src="'+result["strResult"]+'" type="video/mp4"> </source>Browser dont support Videos.</video> ';
                    component.set("v.videoVal" , ele);
                }

            }
        });
        $A.enqueueAction(action);
    }
});