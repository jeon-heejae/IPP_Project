/*
* Component Name                : HolidayActionLightning.cmp
* Component Controller          : HolidayActionLightningController.js
* Component Helper              : HolidayActionLightningHelper.js
* Component Contorlller Class   : HolidayActionLightningExtension.cls
* Test Class                    : HolidayActionLightningExtension_Test.cls
* Description                   : 휴일관리 라이트닝 신청 폼
* Modification Log 
* =============================================================== 
* Ver     Date          Author           Modification
* ===============================================================
  1.0   2018.08.27      JK.lee              Create
  1.1   2019.04.26                          Modified
  2.0   2021.01.18      CJ.Sohn             Modified(승인자 자동 할당, 사원 정보 및 프로젝트 수행팀 이력(오늘 날짜 기준) 조회)
*/  

global without sharing class HolidayActionLightningExtension {
    
    @AuraEnabled
    @RemoteAction
    public static String doHolidayAction(HolidayAction__c saveList , String currentUserId){
        system.debug('saveList :: ' + saveList);
        String checkMessage = '';

        try { 
            String userId = UserInfo.getUserId();
            //String userId = saveList.CreatedById            
            saveList.OwnerId = currentUserId;
            system.debug('userId : :'+ userId);
            system.debug('currentUserId : :'+currentUserId);

            system.debug('--holidayActionSh--');
            if(String.valueOf(saveList.HolidayAction_Parent__c) == ''){
                string parentId = [SELECT Id FROM Holiday__c WHERE Holiday_User__c = :currentUserId  limit 1].Id;
                saveList.HolidayAction_Parent__c = parentId;
                system.debug('여기걸림 ? HolidayActionParent 삽입 : ' + saveList.HolidayAction_Parent__c);
            }

            //반차 Half- PM/AM 추가 
            if(saveList.HolidayAction_Type__c =='Half-day Leave'){
                saveList.HolidayAction_Days__c= 0.5;
            }
            system.debug('saveList.HolidayAction_Parent__c :: ' + saveList.HolidayAction_Parent__c);

            if(saveList.HolidayAction_Type__c =='Women Holiday') {
               integer year = system.today().year();                
               integer mon = system.today().month();
               Date fromdt = date.newInstance(year, mon, 1);
               integer cnt = [SELECT Id FROM HolidayAction__c WHERE HolidayAction_Parent__c =:saveList.HolidayAction_Parent__c AND HolidayAction_Date1__c >= :fromdt AND HolidayAction_Type__c ='Women Holiday'].size();
               system.debug('cnt ::: '+ cnt);
               system.debug('year ::: '+ year);
               system.debug('mon ::: '+ mon);
               system.debug('fromdt :::' +fromdt);

                if(cnt > 0) {
                    checkMessage = 'Already applied a Women Holiday this month : 이미 이번달 여성 보건휴가를 신청했습니다.';
                    return checkMessage;
                }
            }
          
            insert saveList;
            System.debug('saveList: ' + saveList);

            //레코드 공유 규칙
            if(userId != currentUserId){

                HolidayAction__Share holidaySh = new HolidayAction__Share();
                holidaySh.ParentId = saveList.Id;
                holidaySh.UserOrGroupId = userId;
                holidaySh.AccessLevel = 'Edit';
                // holidaySh.UserOrGroupId = obj.FirstHolidayRequest__c;
                // holidaySh.RowCause = Schema.HolidayAction__Share.RowCause.ActionForAll__c;

                insert holidaySh;
		    }
        } catch(System.DmlException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                system.debug(' ==>'); // boolean->string 메세지가 2개이상이기 때문에 boolean값으로 받지 못한다.
                system.debug(e);
                system.debug(i);
                system.debug('e.getStackTraceString(): ' + e.getStackTraceString());
                system.debug('e.getLineNumber(): ' + e.getLineNumber());
                system.debug('e.getCause(): ' + e.getCause());
                checkMessage = String.valueof(e.getDmlMessage(i)); // string value를 integer로 받기
                System.debug('checkMessage================================='+checkMessage);

                return checkMessage;
            }
        }
        return checkMessage;
    }


    @AuraEnabled
    public static List<String> getSelectFieldName() {
        List<String> fieldName = new List<String>();
        Schema.DescribeSObjectResult objDescribe = HolidayAction__c.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        System.debug('fieldMap============='+fieldMap);
        for(String strKey : fieldMap.keySet()){
            Schema.SObjectField field = fieldMap.get(strKey);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            fieldName.add(fieldDescribe.getName());
        }

        return fieldName;
    }

    @AuraEnabled
    public static String selfApproverCheck() {
        Id userId = UserInfo.getUserId();
        String.valueOf(userId);
        return userId;
    }

    /**
     * @description       : 사용자의 ApprovalLine1 필드의 1차 승인자를 리턴
     * @author            : cj.sohn@daeunextier.com
     * @group             : DaeuNextier
    **/
    @AuraEnabled
    public static String[] getApproverId() {
        List<User> listUsers = [SELECT Id, ApprovalLine1__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        if(listUsers.size() > 0) {
            return String.valueOf(listUsers.get(0).ApprovalLine1__c).split('/');
        } else {
            return null;
        }
    }

    /**
     * @description       : 사용자의 사원 정보(부서, 직급)와 프로젝트 수행팀 정보(현재 투입되어있는지 유무)를 리턴
     * @author            : cj.sohn@daeunextier.com
     * @group             : DaeuNextier
    **/
    @AuraEnabled
    public static List<Employee__c> employeeStatus(){
        List<Employee__c> userStatus = [SELECT Id, Name, Department__c, toLabel(Position__c), (SELECT Id, Project__c, IsPM__c, fm_FromDate__c, fm_ToDate__c FROM EmployeePerformPjt__r WHERE InputDate__c <=: System.today() AND ((WithdrawDate__c != null AND WithdrawDate__c >=: System.today()) OR WithdrawDate__c = null) ORDER BY LastModifiedDate DESC) FROM Employee__c WHERE Employee__c.User__c =: UserInfo.getUserId()];
        if(userStatus.size() > 0) {
            return userStatus;
        } else {
            return null;
        }
    }
}