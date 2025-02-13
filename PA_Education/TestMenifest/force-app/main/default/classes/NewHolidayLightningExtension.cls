/**
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
global without sharing class NewHolidayLightningExtension {

    @AuraEnabled
    @RemoteAction
    public static Map<String, String> doHolidayAction(HolidayAction__c saveList) {
        String checkMessage = '';
        String createdRecordId = '';
        System.debug('saveList :: ' + saveList);

        try {
            String userId = UserInfo.getUserId();
            saveList.OwnerId = userId;

            Holiday__c objHoliday = [SELECT Id, Holiday_Total_Remain__c, fm_Holiday_rewardRemainDays__c FROM Holiday__c WHERE Holiday_User__c = :userId LIMIT 1];
            if(String.valueOf(saveList.HolidayAction_Parent__c) == '') {
                saveList.HolidayAction_Parent__c = objHoliday.Id;
                System.debug('HolidayActionParent 삽입 : ' + saveList.HolidayAction_Parent__c);
            }
            System.debug('saveList.HolidayAction_Parent__c :: ' + saveList.HolidayAction_Parent__c);

            // 반차 Half 및 대체휴가(반차) 일 경우, 사용일수를 0.5로 설정
            if(saveList.HolidayAction_Type__c == 'Half-day Leave' || saveList.HolidayAction_Type__c == 'Reward Half-Holiday') {
                saveList.HolidayAction_Days__c = 0.5;
            }

            // 휴가 타입 별, 유효성 체크 (생리휴가)
            if(saveList.HolidayAction_Type__c == 'Women Holiday') {
                Integer year = System.today().year();
                Integer mon  = System.today().month();
                Date fromdt  = Date.newInstance(year, mon, 1);
                Integer cnt  = [SELECT Id FROM HolidayAction__c WHERE HolidayAction_Parent__c = :saveList.HolidayAction_Parent__c AND HolidayAction_Date1__c >= :fromdt AND HolidayAction_Type__c = 'Women Holiday'].size();
                System.debug('cnt ::: ' + cnt);
                System.debug('year ::: ' + year);
                System.debug('mon ::: ' + mon);
                System.debug('fromdt :::' + fromdt);

                if(cnt > 0) {
                    checkMessage = 'Already applied a Women Holiday this month : 이미 이번달 여성 보건휴가를 신청했습니다.';
                    return new Map<String, String> {
                            'checkMessage' => checkMessage
                    };
                }
            }

            // 휴가 타입 별, 유효성 체크 (연차 및 반차)
            else if(saveList.HolidayAction_Type__c == 'Annual Holiday' || saveList.HolidayAction_Type__c == 'Half-day Leave') {
                System.debug(String.format('휴가 신청일 수 : {0}, 연월차 잔여일수 : {1}', new List<Object>{ saveList.HolidayAction_Days__c, objHoliday.Holiday_Total_Remain__c }));
                if(saveList.HolidayAction_Days__c > objHoliday.Holiday_Total_Remain__c) {
                    checkMessage = String.format('{0} :: 휴가 신청일 수 : {1}, 연월차 잔여일수 : {2}', new List<Object>{ Label.Cannot_Apply_Holiday, saveList.HolidayAction_Days__c, objHoliday.Holiday_Total_Remain__c });
                    return new Map<String, String> {
                            'checkMessage' => checkMessage
                    };
                }
            }

            // 휴가 타입 별, 유효성 체크 (대체휴가 및 대체휴가(반차))
            else if(saveList.HolidayAction_Type__c == 'Reward Holiday' || saveList.HolidayAction_Type__c == 'Reward Half-Holiday') {
                System.debug(String.format('휴가 신청일 수 : {0}, 대체휴가 잔여일수 : {1}', new List<Object>{ saveList.HolidayAction_Days__c, objHoliday.fm_Holiday_rewardRemainDays__c }));
                if(saveList.HolidayAction_Days__c > objHoliday.fm_Holiday_rewardRemainDays__c) {
                    checkMessage = String.format('{0} :: 휴가 신청일 수 : {1}, 대체휴가 잔여일수 : {2}', new List<Object>{ Label.Cannot_Apply_Reward_Holiday, saveList.HolidayAction_Days__c, objHoliday.fm_Holiday_rewardRemainDays__c });
                    return new Map<String, String> {
                            'checkMessage' => checkMessage
                    };
                }
            }

            // insert saveList 대신 saveresult를 통해 결과값 return 받기
            Database.SaveResult saveResult = Database.insert(saveList, true);
            createdRecordId = saveResult.getId();
            System.debug('saveList: ' + saveList);
            System.debug('created recordId:: ' + saveResult.getId());

            //레코드 공유 규칙
            /*
            if(userId != userId){ // NOTE : 이걸 내가 아닌 다른 사용자가 호출할 수 도 있는건가??
                HolidayAction__Share holidaySh = new HolidayAction__Share();
                holidaySh.ParentId = saveList.Id;
                holidaySh.UserOrGroupId = userId;
                //holidaySh.UserOrGroupId = obj.FirstHolidayRequest__c;
                holidaySh.AccessLevel = 'Edit';
                // holidaySh.RowCause = Schema.HolidayAction__Share.RowCause.ActionForAll__c;

                insert holidaySh;
            }
            */
        } catch (System.DmlException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                System.debug(' ==>'); // Boolean -> String 메세지가 2개이상이기 때문에 boolean값으로 받지 못한다.
                System.debug(e);
                System.debug(i);
                System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
                System.debug('e.getLineNumber(): ' + e.getLineNumber());
                System.debug('e.getCause(): ' + e.getCause());
                checkMessage = String.valueOf(e.getDmlMessage(i)); // String value를 Integer로 받기
                System.debug('checkMessage=================================' + checkMessage);

                return new Map<String, String> {
                        'checkMessage' => checkMessage
                };
            }
        }

        System.debug('checkMessage :: ' + checkMessage);
        System.debug('createdRecordId :: ' + createdRecordId);

        return new Map<String, String> {
                'checkMessage' => checkMessage,
                'createdRecordId' => createdRecordId
        };
    }

    @AuraEnabled
    public static List<String> getSelectFieldName() {
        List<String> fieldName = new List<String>();
        Schema.DescribeSObjectResult objDescribe = HolidayAction__c.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        System.debug('fieldMap=============' + fieldMap);
        for (String strKey : fieldMap.keySet()) {
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
    */
    @AuraEnabled
    public static String[] getApproverId() {
        System.debug('getApproverId Apex====================');
        List<User> listUsers = [SELECT Id, ApprovalLine1__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.debug('listUsers :: ' + listUsers);
        System.debug('UserInfo.getUserId() :: ' + UserInfo.getUserId());
        if (listUsers.size() > 0) {
            return String.valueOf(listUsers.get(0).ApprovalLine1__c).split('/');
        } else {
            List<String> strings = new List<String>();
            strings.add(UserInfo.getUserId());
            return strings;
        }
    }

    /**
     * @description       : 사용자의 사원 정보(부서, 직급)와 프로젝트 수행팀 정보(현재 투입되어있는지 유무)를 리턴
     * @author            : cj.sohn@daeunextier.com
     * @group             : DaeuNextier
    */
    @AuraEnabled
    public static Map<String, Object> employeeStatus() {
        Map<String, Object> mapResult = new Map<String, Object>();

        List<Employee__c> userStatus = [
                SELECT Id, Name, Department__c, toLabel(Position__c), (
                        SELECT Id, Project__c, IsPM__c, fm_FromDate__c, fm_ToDate__c
                        FROM EmployeePerformPjt__r
                        WHERE InputDate__c <= :System.today()
                        AND ((WithdrawDate__c != NULL AND WithdrawDate__c >= :System.today())
                        OR WithdrawDate__c = NULL)
                        ORDER BY LastModifiedDate DESC
                )
                FROM Employee__c
                WHERE Employee__c.User__c = :UserInfo.getUserId()
        ];

        if (userStatus.size() > 0) {
            mapResult.put('userStatus', userStatus);

            if(!userStatus.get(0).EmployeePerformPjt__r.isEmpty()) {
//                PerformProject__c objPerformProject = [SELECT Id, Employee__r.User__c FROM PerformProject__c WHERE Project__c = :userStatus.get(0).EmployeePerformPjt__r.get(0).Project__c AND IsPM__c = true LIMIT 1];
                Project__c objProject = [SELECT Id, PM__c FROM Project__c WHERE Id = :userStatus.get(0).EmployeePerformPjt__r.get(0).Project__c  LIMIT 1];
                mapResult.put('pmId', objProject != null && objProject.PM__c != null ? objProject.PM__c : '');
            }

            return mapResult;
        } else {
            return null;
        }
    }

    /**
     * @description       : Position이 "프로젝트 팀원" 일 경우, 프로젝트 변경 시 프로젝트 관리자의 ID값 응답
     * @author            : jinwoo.jang@daeunextier.com
     * @group             : DaeuNextier
    */
    @AuraEnabled
    public static Map<String, Object> getProjectPmId(Id projectId) {
        Map<String, Object> mapResult = new Map<String, Object>();

//        List<PerformProject__c> objPerformProject = [SELECT Id, Employee__r.User__c FROM PerformProject__c WHERE Project__c = :projectId AND IsPM__c = true LIMIT 1];
        List<Project__c> objProject = [SELECT Id, PM__c FROM Project__c WHERE Id = :projectId  LIMIT 1];
        if (objProject != null && objProject.size() > 0) {
            mapResult.put('pmId', objProject.get(0).PM__c);
        }

        return mapResult;
    }

    /**
     * @description       : 사용자의 잔여 휴가일수, 잔여 대체휴가일수 조회
     * @author            : yj.kim@daeunextier.com
     * @group             : DaeuNextier
    */
    @AuraEnabled
    public static Map<String, Object> getHolidayRemain() {

        List<Holiday__c> listHoliday = [
                SELECT Holiday_Total_Remain__c, fm_Holiday_rewardRemainDays__c
                FROM Holiday__c
                WHERE Holiday_User__c =: UserInfo.getUserId()
        ];

        Map<String, Object> mapReturnValue = new Map<String, Object> {
                'totalRemain' => !listHoliday.isEmpty() && listHoliday.get(0).Holiday_Total_Remain__c != null       ?  listHoliday.get(0).Holiday_Total_Remain__c : 0 ,
                'rewardRemain' => !listHoliday.isEmpty() && listHoliday.get(0).fm_Holiday_rewardRemainDays__c != null  ?  listHoliday.get(0).fm_Holiday_rewardRemainDays__c : 0
        };

        return mapReturnValue;
    }


}