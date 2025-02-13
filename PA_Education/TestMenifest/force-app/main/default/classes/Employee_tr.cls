/************************************************************************************
* File Name   	    : Employee_tr
* Author	  		: Yeonlim
* Date				: 2023-12-14
* Modification Log
* ===================================================================================
* Ver      Date            Author          Modification
* ===================================================================================
* 1.0      2023-12-14      Yeonlim         사번 채번
* 1.1      2023-01-24      Yeonlim         직급(Position__c) 필드가 변경될 때 User의 직급(Position__c), Title 필드 값 업데이트
************************************************************************************/
public without sharing class Employee_tr extends TriggerHandler {
    private static List<Employee__c> listNew {get; set;}
    private static List<Employee__c> listOld {get; set;}
    private static Map<Id, Employee__c> mapNew {get; set;}
    private static Map<Id, Employee__c> mapOld {get; set;}

    public Employee_tr() {
        listNew = (List<Employee__c>) Trigger.new;
        listOld = (List<Employee__c>) Trigger.old;
        mapNew  = (Map<Id, Employee__c>) Trigger.newMap;
        mapOld  = (Map<Id, Employee__c>) Trigger.oldMap;
    }

    public override void beforeInsert() {
        createEmployeeNo();
    }

    public override void afterInsert() {
        updateUserEmployeeNumber();
    }

    public override void afterUpdate() {
        updateUserPosition();
    }

    /**
    * Event : before insert
    * Author : Yeonlim
    * Description : 사번 채번 [정주형 대리님 요청 : 기존 사번 formula 식에 문제가 있어 트리거 채번 방식으로 변경]
    */
    public void createEmployeeNo() {
        Map<String, List<Employee__c>> mapTypeToListEmployee = new Map<String, List<Employee__c>>();

        for (Employee__c obj : listNew) {
            if (obj.Type__c != null && (obj.Type__c == '내부직원' || obj.Type__c == '외부직원') && obj.JoinDate__c != null) {
                String type = (obj.Type__c == '내부직원' ? 'DU': 'OS') + String.valueOf(obj.JoinDate__c).substring(2, 4);
                if (mapTypeToListEmployee.get(type) == null) {
                    mapTypeToListEmployee.put(type, new List<Employee__c>());
                }
                mapTypeToListEmployee.get(type).add(obj);
            }
        }

        for (String key : mapTypeToListEmployee.keySet()) {
            setEmployeeNo(key, mapTypeToListEmployee);
        }
    }

    private static void setEmployeeNo(String type, Map<String, List<Employee__c>> mapTypeToListEmployee) {
        List<Employee__c> listEmployee = [
                SELECT EmployeeNo__c
                FROM Employee__c
                WHERE EmployeeNo__c LIKE :type + '%'
                ORDER BY EmployeeNo__c DESC
                LIMIT 1
        ];

        List<Employee__c> listEmployees = new List<Employee__c>();
        if (!mapTypeToListEmployee.get(type).isEmpty()) {
            Integer lastEmpNo = listEmployee.isEmpty() ? 0 : Integer.valueOf(listEmployee[0].EmployeeNo__c.right(3));
            for (Employee__c obj : mapTypeToListEmployee.get(type)) {
                Employee__c objEmp = obj;
                objEmp.EmployeeNo__c = type + String.valueOf(++lastEmpNo).leftPad(3, '0');
                listEmployees.add(objEmp);
            }
        }
    }

    public void updateUserEmployeeNumber() {

        Map<String, String> mapUserEmployeeNumber = new Map<String, String>();

        for (Employee__c obj : listNew) {
            mapUserEmployeeNumber.put(obj.User__c, obj.EmployeeNo__c);
        }

        if (!mapUserEmployeeNumber.isEmpty()) {

            List<User> listUpdateUser = new List<User>();
            for (User obj : [
                    SELECT Id, EmployeeNumber
                    FROM User
                    WHERE Id = :mapUserEmployeeNumber.keySet()
            ]) {

                obj.EmployeeNumber = mapUserEmployeeNumber.get(obj.Id);
                listUpdateUser.add(obj);
            }

            if (!listUpdateUser.isEmpty()) {
                update listUpdateUser;
            }
        }

    }

    /**
    * Event : after update
    * Author : Yeonlim
    * Description : 직급(Position__c) 필드가 변경될 때 User의 직급(Position__c), Title 필드 값 업데이트
    */
    public void updateUserPosition(){
        Map<String, String> mapUserIdToPosition = new Map<String, String>();
        for (Employee__c obj : listNew) {
            if (obj.Position__c != mapOld.get(obj.Id).Position__c) {
                mapUserIdToPosition.put(obj.User__c, obj.Position__c);
            }
        }

        if (!mapUserIdToPosition.isEmpty()) {
            // User의 Position__c 필드 label값 가져오기
            Schema.SObjectType sobject_type = Schema.getGlobalDescribe().get('User');
            Schema.DescribeSObjectResult sobjectDescribe = sobject_type.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();

            List<Schema.PicklistEntry> pickListValues = fieldMap.get('Position__c').getDescribe().getPicklistValues();

            Map<String, String> mapValueToLabel = new Map<String, String>();
            for (Schema.PicklistEntry pe : pickListValues) {
                mapValueToLabel.put(pe.getValue(), pe.getLabel());
            }

            List<User> listUpdateUser = new List<User>();
            for (User obj : [
                    SELECT Id
                    FROM User
                    WHERE Id IN: mapUserIdToPosition.keySet()
                    AND IsActive = TRUE
            ]) {
                String position = mapUserIdToPosition.get(obj.Id);
                User objUser = new User(
                        Id          = obj.Id,
                        Position__c = position,
                        Title       = mapValueToLabel.get(position)
                );

                listUpdateUser.add(objUser);
            }

            System.debug('listUpdateUser : ' + listUpdateUser);
            if (!listUpdateUser.isEmpty()) {
                update listUpdateUser;
            }
        }
    }
}