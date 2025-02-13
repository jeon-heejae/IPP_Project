/**
 * Created by Kwanwoo.Jeon on 2024-01-31.
 */

({
    fnInit : function(component, event, helper) {
        helper.getApprovalLines(component);
    },

    fnClickNew : function(component, event, helper) {
        var newData = {
            fieldName : '',
            label: '',
            userDatas:[]
        };
        component.set('v.listLabelClicked', newData);
        component.set('v.isSubmit', true);
    },

    fnEdit : function(component, event, helper) {
        component.set('v.isSubmit', true);
        var temp = event.getSource().get("v.value");
        var list = component.get("v.listLabel");
        var listData = list[temp];

        component.set('v.listLabelClicked',listData);
    },

    fnClose : function(component, event, helper) {
        var isSubmit = component.get('v.isSubmit');
        if(isSubmit){
            component.set('v.isSubmit', false);
        }else{
            $A.get("e.force:closeQuickAction").fire();
        }



    },

    fnSave: function(component, event, helper) {
        var bValidation = true;
        var listUser 	= component.get("v.listLabelClicked").userDatas;
        var bHistory 	= component.get("v.bHistory");
        var listLabel   = component.get("v.listLabelClicked").label;

        // 중복 및 null 검사
        if(listUser == '' || listUser == null){
            bValidation = false;
            helper.showToast('error', $A.get('$Label.c.ApproverSelectError'));
            return;
        }

        for(var i in listUser){
            i = parseInt(i);

            if(listUser[i].Id == null) {
                bValidation = false;
                helper.showToast('error', $A.get('$Label.c.ApproverSelectError'));
                return;
            }
            for(var j = i + 1; j <= listUser.length - 1; j++) {
                if(i == listUser.length-1) break;
                if(listUser[i].Id === listUser[j].Id){
                    bValidation = false;
                    helper.showToast('error', $A.get('$Label.c.ApproverDupError'));
                    return;
                }
            }
        }
        if(bValidation == true){
            helper.doSubmit(component,event, helper);
        }


    },

    fnDeleteRow : function(component, event, helper) {
        var listLabel = component.get("v.listLabelClicked");
        var listUser    = listLabel.userDatas;
        var idx 		= event.getSource().get("v.name"); //idx  0

        for(var i=listUser.length-1; i>=0; i--){
            var obj = listUser[i];
            if(idx == i){
                listUser.splice(i, 1);
            }
        }

        component.set("v.listLabelClicked", listLabel);
    },

    fnAddRow : function(component, event, helper) {
        var listLabel 	   = component.get("v.listLabelClicked");
        var iApproverLimit = component.get("v.iApproverLimit");
        var userobj = {  Id  : null, Name: null };

        console.log('listLabel', listLabel);
        if(listLabel.userDatas.length == iApproverLimit){
            return alert("Up to "+ iApproverLimit +" people available for selection.");
        }
        listLabel.userDatas.push(userobj);
        component.set("v.listLabelClicked", listLabel);
    },
})