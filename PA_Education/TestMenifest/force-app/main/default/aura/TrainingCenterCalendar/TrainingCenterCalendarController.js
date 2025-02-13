/**
 * Created by Kwanwoo.Jeon on 2024-02-16.
 */

({
    /**
     * @description doInit
     */
    scriptsLoaded : function(component, event, helper) {
        helper.getEvents(component, event);
    },
    /**
     * @description Get data when clicking the search button
     */
    fnSearch : function(component, event, helper){
        component.set('v.sObjectName','ApplicationTrainingCenter__c');
        helper.getEvents(component, event);
    },

    /**
     * @description create applicationTrainingCenter data when clicking the 수련원신청 button
     */
    fnCreate : function(component, event, helper){
        if(component.get('v.isCreateActive')){
            component.set('v.showModal', true);
        }else{
            helper.showToast('ERROR', '수련원 신청 기간이 아닙니다');
        }

    },

    fnChangeShowModal: function(component, event, helper){
        if(!component.get('v.showModal')){
            component.set('v.sObjectName','ApplicationTrainingCenter__c');
            helper.getEvents(component, event);
        }
    }
})