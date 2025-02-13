({
	init : function(component, event, helper) {
        let isEnglish = event.getParam('isEnglish')
        isEnglish ? component.set('v.isEnglish', isEnglish) :
            component.set('v.isEnglish', false)
        helper.getClassInformation(component);
    },
    loadMore: function (component, event, helper) {
        helper.getLoadMore(component);
    },
    showModal: function (component, event, helper) {
        var classId = event.getSource().get("v.value");

        component.set("v.ClassObj" , classId);
        component.set("v.isOpen", true);
        $A.util.addClass(component.find("modal"), "active");
    },
    hideModal: function (component, event) {
        if (event.target == event.currentTarget) {
            $A.util.removeClass(component.find("modal"), "active");
            component.set("v.isOpen", false);
        }
    },
    fnSave: function(component, event, helper) {
        helper.doSaveApplyTo(component);
    },
    fnFileUpload : function(component){
        var fileInput = component.find("fileInput").getElement();
        var file = fileInput.files[0];
        var fileReader = new FileReader();
        fileReader.readAsDataURL(file);
        fileReader.onload = function(){
            var fileContents = fileReader.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            fileContents = fileContents.substring(dataStart);

            console.log('fileName >> ' + file.name);
            console.log('base64Data >> ' + encodeURIComponent(fileContents));
            console.log('contentType >> ' + file.type);

            component.set('v.fileName',file.name);
            /*component.set('v.title',file.name); */
            component.set('v.base64Data',encodeURIComponent(fileContents));
            component.set('v.contentType',file.type);

        }
    },
    termsChanged: function (component, event, helper) {
        component.set("v.checkTerms", document.getElementById("terms").checked);
    },
    phoneMasking: function (component, event, helper) {
        component.set("v.Mobile", event.getParam("value").replace(/^(\d{3})(\d{4})(\d{4})$/, `$1-$2-$3`));
    },
    termsOpen: function (component) {
        component.set("v.termsOpen", true);
    },
    termsClose: function (component) {
        component.set("v.termsOpen", false);
    }
})