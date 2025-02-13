/**
 * Created by yj.kim on 2023-07-04.
 */

({

    fnInit : function(component, event, helper){
        helper.getInitData(component, event, helper);
    },

    fnSave : function(component, event, helper){
        console.log('======== fnSave ==========');
        console.log('inList : ' , component.get('v.inList'));
        console.log('exList : ' , component.get('v.exList'));

        //데이터 필수값 검증
        var validResult = helper.fnValidation(component);
        console.log('validResult', validResult);

        if(validResult == true){
            helper.doSave(component, event, helper);
        }

    }
});