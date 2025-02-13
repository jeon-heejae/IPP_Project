/**
 * ==================================================================================
 * File Name         : User_tr
 * Author            : yeonlim.jeong
 * Group             : Daeu Nextier
 * Description       :
 * Modification Logs
 * ==================================================================================
 *   Ver     Date          Author           Modification
 * ==================================================================================
 *   1.0   2023-12-19     yeonlim.jeong     User 생성 시 사원 오브젝트 레코드 생성
 *   1.1   2023-01-24     yeonlim.jeong     직책(Position__c)의 Label값을 Title에 Update
**/
public with sharing class User_tr extends TriggerHandler{
    private static List<User> listNew {get; set;}
    private static List<User> listOld {get; set;}
    private static Map<Id, User> mapNew {get; set;}
    private static Map<Id, User> mapOld {get; set;}

    public User_tr() {
        listNew = (List<User>) Trigger.new;
        listOld = (List<User>) Trigger.old;
        mapNew  = (Map<Id, User>) Trigger.newMap;
        mapOld  = (Map<Id, User>) Trigger.oldMap;
    }

    public override void beforeInsert() {
        doSetTitle();
    }

    public override void afterInsert() {
        checkUserId();
    }

    public void checkUserId() {
        Set<Id> setId = new Set<Id>();
        for (User obj : listNew) {
            setId.add(obj.Id);
        }

        if (!setId.isEmpty()) {
            createEmployeeRecord(setId);
        }
    }

    /**
    * Event : after insert
    * Author : Yeonlim
    * Description : User 생성 시 사원 오브젝트 레코드 생성
    */
    @Future
    public static void createEmployeeRecord(Set<Id> setId) {
        List<User> listUser = new List<User>([
                SELECT Id, Type__c, ProfileId, User_PersonalNo__c, Title, PostalCode, User_Address__c, Department, CreatedDate,
                        Email, User_JoinDate__c, MobilePhone, Alias, Position__c, toLabel(Position__c) labelPosition
                FROM User
                WHERE Id IN: setId
        ]);

        Set<String> setProfileId = new Set<String>();
        List<Employee__c> listEmployee = new List<Employee__c>();
        Map<Id, String> mapProfileIdToName = new Map<Id, String>();

        for (User obj : listUser) {
            if (obj.Type__c != null && (obj.Type__c == '내부직원' || obj.Type__c == '외부직원')) {
                setProfileId.add(obj.ProfileId);
            }
        }

        if (!setProfileId.isEmpty()) {
            for (Profile obj : [
                    SELECT Id, Name
                    FROM Profile
                    WHERE Id IN: setProfileId
            ]) {
                mapProfileIdToName.put(obj.Id, obj.Name);
            }

            if (!mapProfileIdToName.isEmpty()) {
                for (User obj : listUser) {
                    String profileName = mapProfileIdToName.get(obj.ProfileId);
                    if (profileName == 'Daeu Nextier Employee' || profileName == 'Daeu Nextier Financial' || profileName.contains('System Admin')) {
                        String gender = '';
                        if (String.isNotBlank(obj.User_PersonalNo__c) && obj.User_PersonalNo__c.length() >= 8) {
                            if (obj.User_PersonalNo__c.substring(7, 8) == '2' || obj.User_PersonalNo__c.substring(7, 8) == '4') {
                                gender = '여성';
                            } else if (obj.User_PersonalNo__c.substring(7, 8) == '1' || obj.User_PersonalNo__c.substring(7, 8) == '3') {
                                gender = '남성';
                            }
                        }

                        Employee__c objEmployee = new Employee__c(
                                AddressNumber__c     = obj.PostalCode,
                                CurrentAddress__c    = obj.User_Address__c,
                                Department__c        = obj.Department,
                                Email__c             = obj.Email,
                                Emergency_Contact__c = '010-',
                                Gender__c            = gender,
                                IdNumber__c          = obj.User_PersonalNo__c,
                                JoinDate__c          = obj.User_JoinDate__c != null && String.valueOf(obj.User_JoinDate__c) != '1900-01-01' ? obj.User_JoinDate__c : Date.valueOf(obj.CreatedDate),
                                MobilePhone__c       = obj.MobilePhone,
                                Name                 = obj.Alias,
                                Position__c          = obj.Position__c,
                                User__c              = obj.Id,
                                Type__c              = obj.Type__c,
                                OwnerId              = obj.Id
                        );
                        listEmployee.add(objEmployee);
                    }
                }

                System.debug('listEmployee : ' + listEmployee);

                if (!listEmployee.isEmpty()) {
                    insert listEmployee;
                }
            }
        }
    }

    /**
    * Event : before insert
    * Author : Yeonlim
    * Description : 직책(Position__c)의 Label값을 Title에 Update
    */
    public void doSetTitle() {
        Schema.SObjectType sobject_type = Schema.getGlobalDescribe().get('User');
        Schema.DescribeSObjectResult sobjectDescribe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();

        List<Schema.PicklistEntry> pickListValues = fieldMap.get('Position__c').getDescribe().getPicklistValues();

        Map<String, String> mapValueToLabel = new Map<String, String>();
        for (Schema.PicklistEntry pe : pickListValues) {
            mapValueToLabel.put(pe.getValue(), pe.getLabel());
        }

        for (User obj : listNew) {
            obj.Title = mapValueToLabel.get(obj.Position__c);
        }
    }

}