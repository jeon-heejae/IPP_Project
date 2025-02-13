({
    fnInit: function(component, event, helper) {
        // 메시지 이벤트가 null인지 먼저 확인
        if (event) {
            var contents = event.getParam('contents');
            if (contents) {
                component.set("v.lightningMessage", contents);
            }
        }
    },

    publishMC: function(component, event, helper) {
        var inputValue = component.get("v.lightningMessage");
        
        var payload = { contents: inputValue };

        // LMS 메시지 채널을 통해 데이터 전송
        component.find("messageChannel").publish(payload);
    },

    unsubscribe:function(component,event,helper){
        component.set("v.isSubscribe",false);
    }
})
