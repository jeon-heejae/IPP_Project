({
    fnInit : function(component, event, helper) {
       //reocord Id log로 확인해보기
       console.log("recordId :: ", component.get("v.recordId"));
       //helper로 이동
       helper.getInitData(component);
    }
});