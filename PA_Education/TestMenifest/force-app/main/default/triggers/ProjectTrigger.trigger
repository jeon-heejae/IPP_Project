/**
 * @description       : 프로젝트 레코드가 Insert 되거나 Update 되는 경우, 프로젝트 관리자 이메일 필드 값 변경
 * @author            : jinwoo.jang@daeunextier.com
 * @group             : DaeuNextier
 *
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2023-02-14   jinwoo.jang@daeunextier.com   Init
 * 1.1   2023-07-07   yj.kim                        Modify
**/

trigger ProjectTrigger on Project__c (before insert, before update, before delete, after insert, after update, after delete) {
    new Project_tr().run();
}

//trigger ProjectTrigger on Project__c (before insert, before update) {

//    if(Trigger.isBefore) {
//
//        if(Trigger.isInsert) {
//            Set<Id> setPmUserId = new Set<Id>();
//            for (Project__c objProject : Trigger.new) {
//                setPmUserId.add(objProject.PM__c);
//            }
//
//            Map<Id, User> mapPmUser = new Map<Id, User>([SELECT Id, email FROM User WHERE Id IN :setPmUserId]);
//            for (Project__c objProject : Trigger.new) {
//                String email = objProject.PM__c == null || mapPmUser.get(objProject.PM__c) == null ? null : mapPmUser.get(objProject.PM__c).Email;
//                objProject.PMEmail__c = email;
//            }
//        }

//        if(Trigger.isUpdate){
//            System.debug('isUpdate !!');
//            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
//            List<String> setEmail = new List<String>();
//            String projectId = '';
//
//            Set<Id> setPmUserId = new Set<Id>();
//            for (Project__c objProject : Trigger.new) {
//                if(objProject.Completed__c = true){
//                    setEmail.add(objProject.PMEmail__c);
//                    projectId = objProject.Id;
//                }
//                setPmUserId.add(objProject.PM__c);
//            }
//
//            Map<Id, User> mapPmUser = new Map<Id, User>([SELECT Id, email FROM User WHERE Id IN :setPmUserId]);
//            for (Project__c objProject : Trigger.new) {
//                String PMEmail = objProject.PM__c == null || mapPmUser.get(objProject.PM__c) == null ? null : mapPmUser.get(objProject.PM__c).Email;
//                objProject.PMEmail__c = PMEmail;
//            }
//
//            System.debug('isUpdate2222 !!');
////            if(!setEmail.isEmpty()){
////                email.setToAddresses(setEmail);
////                email.setSubject('[' + '한국콜마' + '] 프로젝트 인력평가 안내');
//////                String body = 'https://daeunextier--dev.sandbox.lightning.force.com/lightning/r/Project__c/';
////                String body = 'test';
////                email.setHtmlBody(body);
////
////                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'admin@daeunextier.com'];
////                System.debug('owea : ' + owea);
////                if ( owea.size() > 0 ) {
////                    email.setOrgWideEmailAddressId(owea.get(0).Id);
////                }
////
////                try{
////                    if(!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
////                }catch(Exception e){
////                    System.debug('error');
////                }
////            }
//
//        }

        /**
         * Created by yj.kim on 2023-07-07.
         * 프로젝트 완료여부 = 'true' 일때, PM 이메일로 투입인력 평가서 url 전송
         */
//        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
//        List<String> setEmail = new List<String>();
//        String projectId = '';


//        for(Project__c obj : Trigger.new){
//            if(obj.Completed__c = true){
//                setEmail.add(obj.PMEmail__c);
//                projectId = obj.Id;
//            }
//        }
//
//        if(!setEmail.isEmpty()){
//            email.setToAddresses(setEmail);
//            email.setSubject('[' + '한국콜마' + '] 프로젝트 인력평가 안내');
////                String body = 'https://daeunextier--dev.sandbox.lightning.force.com/lightning/r/Project__c/';
//            String body = 'test';
//            email.setHtmlBody(body);
//
//            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'admin@daeunextier.com'];
//            System.debug('owea : ' + owea);
//            if ( owea.size() > 0 ) {
//                email.setOrgWideEmailAddressId(owea.get(0).Id);
//            }
//
//            try{
//                if(!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
//            }catch(Exception e){
//                System.debug('error');
//            }
//        }


//    }
//
//}