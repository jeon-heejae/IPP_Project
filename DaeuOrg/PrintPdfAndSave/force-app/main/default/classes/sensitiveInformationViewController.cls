public with sharing class sensitiveInformationViewController {
    @AuraEnabled
    public static Employee__c getEmpInfo(Id recordId) {
 
        // Id currentUserId = UserInfo.getUserId();
        //Id currentUserId='0052v00000fjMgvAAE';
 
        Employee__c employee = [SELECT Id, Gender__c, CurrentAddress__c, Birthday__c, EnglishName__c,
                                       IdNumber__c, AddressNumber__c, WeddingAnniversary__c,
                                       JoinArmyDate__c, DischargeDate__c, MilitaryServiceDiv__c,
                                       MilitaryType__c, Class__c, MilitaryTypeDescription__c,
                                       Dependents__c, UpdateDate__c, DismissalDate__c, Reason__c,
                                       Clear__c, OwnerId, User__c
                                FROM Employee__c
                                WHERE Id = :recordId //0052v00000fjMgvAAE(User__c) == 0052v00000fjMgvAAE
                                LIMIT 1];
 
        if (employee == null) {
            return null;
        }
 
        return employee;
    }
 
    @AuraEnabled
    public static Boolean isCheck(Id recordId) {
        Id userId = UserInfo.getUserId(); // 현재 로그인한 사용자 ID
        // Id userId = '0052v00000jUvMzAAK'; // 현재 로그인한 사용자 ID
   
        Boolean flag = false;
   
        // Employee__c 레코드에서 해당 기록의 User__c 필드 값 가져오기
        List<Employee__c> listUserName = [
            SELECT User__c
            FROM Employee__c
            WHERE Id = :recordId
            // WHERE Id = : ('a2O0k000004DqJ4EAK')
        ];
   
        // 사용자의 역할이 'CEO' 또는 '관리부'인지 확인
        List<User> listUser = [
            SELECT Id, UserRole.Name
            FROM User
            WHERE UserRole.Name IN ('CEO', '관리부') AND Id = :userId
        ];
   
        // 사용자가 'ViewPersonalInfoPermission' 권한을 갖고 있는지 확인
        List<PermissionSetAssignment> listUserPer = [
            SELECT PermissionSet.Id, PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE Assignee.Id = :userId
            AND PermissionSet.Name = 'ViewPersonalInfoPermission'
            LIMIT 1
        ];
   
        // 사용자 이름이 일치하거나, 역할이 맞거나, 권한이 맞으면 flag를 true로 설정
        Boolean isUser = !listUserName.isEmpty() && listUserName[0].User__c == userId;
        Boolean isRoleValid = !listUser.isEmpty();
        Boolean isPermiValid = !listUserPer.isEmpty();
        System.debug(isUser);
        System.debug(isRoleValid);
        System.debug(isPermiValid);
        // 조건을 만족하면 flag를 true로 설정
        if (isUser || isRoleValid || isPermiValid) {
            flag = true;
        }
        System.debug(flag);
       
        return flag;  // flag를 반환
    }
   
   
 
    @AuraEnabled
    public static Boolean updateEmpInfo(Employee__c employee){
        try {
            update employee;
            return true;
        } catch (Exception e) {
            return false;
        }
    }
   
    @AuraEnabled
    public static Boolean hasPermissionSet() {
        Id userId = UserInfo.getUserId();
        // Id userId = '0052v00000jUvMzAAK';
 
        try {
            // 사용자에게 할당된 PermissionSet을 쿼리
            PermissionSetAssignment psa = [
                SELECT PermissionSet.Id, PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE Assignee.Id = :userId
                AND PermissionSet.Name = 'ViewPersonalInfoPermission'
                LIMIT 1
            ];
           
            // 만약 권한 세트가 존재하면 true 반환
            if (psa != null) {
                return true;
            } else {
                return false;
            }
        } catch (QueryException e) {
            // 쿼리에서 예외가 발생하면 false를 반환
            System.debug('Error occurred while querying PermissionSetAssignment: ' + e.getMessage());
            return false;
        }
    }
 
    @AuraEnabled
    public static Map<String, List<String>> getPicklistValues() {
        Map<String, List<String>> picklistMap = new Map<String, List<String>>();
 
        List<String> picklistFields = new List<String>{ 'Gender__c', 'MilitaryServiceDiv__c', 'MilitaryType__c' };
 
        for (String fieldName : picklistFields) {
            List<String> options = new List<String>();
            Schema.DescribeFieldResult fieldResult = Schema.SObjectType.employee__c.fields.getMap().get(fieldName).getDescribe();
            List<Schema.PicklistEntry> picklist = fieldResult.getPicklistValues();
           
            for (Schema.PicklistEntry entry : picklist) {
                options.add(entry.getLabel() + ':' + entry.getValue()); // Label:Value 형식으로 저장
            }
           
            picklistMap.put(fieldName, options); // 필드 이름을 키로 사용
        }
        System.debug('picklistMap : '+picklistMap);
 
        return picklistMap;
    }
}