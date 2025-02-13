/**
 * Created by Kwanwoo.Jeon on 2023-12-07.
 */

public without sharing class HolidayWorkApprovalController {

    @AuraEnabled
    public static dataWrapper doInit(String recordId) {
        System.debug('doInit - recordId : ' + recordId);
        dataWrapper dw = new dataWrapper();
        list<DetailWrapper> listDetail = new List<DetailWrapper>();

        for (HolidayWorkDetail__c obj : [   SELECT Id, Name, WorkUser__r.Name, PlanningTime__c, WorkingTime__c, WorkDetail__c
                                            from HolidayWorkDetail__c
                                            WHERE HolidayWork__c =: recordId]){
            listDetail.add(new DetailWrapper(obj));
        }
        System.debug('listDetail :: ' + listDetail);

        dw.timePicklist = DN_Util.getPickListValues('HolidayWorkDetail__c', 'WorkingTime__c', true);
        dw.listDetailWrapper = listDetail;

        return dw;
    }

    @AuraEnabled
    public static dataWrapper doSave(list<Map<String,String>> listDetail, String strComments, String recordId) {
        dataWrapper dw = new dataWrapper();
        dw.status = 'SUCCESS';
        list<HolidayWorkDetail__c> listHWD = new List<HolidayWorkDetail__c>();

        System.debug('listDetail :: ' + listDetail);
        for(Map<String,String> obj: listDetail){
            listHWD.add(new HolidayWorkDetail__c(Id = obj.get('Id'),WorkingTime__c = obj.get('WorkingTime')));
        }

        if (!listHWD.isEmpty()) {
            Savepoint sp = Database.setSavepoint();
            try{
                list<database.SaveResult> listSR = database.update(listHWD, true);
                system.debug(listSR);

                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments(strComments);
                req1.setObjectId(recordId);
                Approval.ProcessResult result = Approval.process(req1);
                dw.message = '근무 승인 요청 되었습니다.';

            }catch(Exception e){
                System.debug('Error ::' + e.getMessage() + ' : ' + e.getLineNumber());
                Database.rollback(sp);
                dw.status = 'Error';
                dw.message = e.getMessage();
            }
        }
        return dw;
    }

    public class dataWrapper{
        @AuraEnabled
        public list<Map<String, String>> timePicklist {get;set;}
        @AuraEnabled
        public list<DetailWrapper> listDetailWrapper {get;set;}
        @AuraEnabled
        public String status {get;set;}
        @AuraEnabled
        public String message {get;set;}
    }


    public class DetailWrapper {
        @AuraEnabled
        public Boolean checked {get;set;}
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String WorkUserName {get;set;}
        @AuraEnabled
        public String PlanningTime {get;set;}
        @AuraEnabled
        public String WorkingTime {get;set;}
        @AuraEnabled
        public String WorkDetail {get;set;}

        DetailWrapper(HolidayWorkDetail__c obj){
            this.checked = false;
            this.Id = obj.id;
            this.Name = obj.Name;
            this.WorkUserName = obj.WorkUser__r.Name;
            this.PlanningTime = obj.PlanningTime__c;
            this.WorkingTime = obj.WorkingTime__c;
            this.WorkDetail = obj.WorkDetail__c;
        }

    }
}