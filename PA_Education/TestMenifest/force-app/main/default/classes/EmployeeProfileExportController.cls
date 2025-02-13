/************************************************************************************
 * File Name   : EmployeeProfileExportController.cls
 * Author      : Soyoung.Jung 
 * Date        : 2019.01.09
 * Tester      : EmployeeProfileExportController_test.cls
 * Description : 사원 프로필 문서 생성 및 로컬 다운로드 컴포넌트 컨트롤러
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2019.01.09      Soyoung.Jung        Create
*************************************************************************************/

public without sharing class EmployeeProfileExportController {

	/************************************************************************************
    *   초기 데이터 셋팅
    * 	사원 오브젝트의 레코드 전체 갯수, 하위 오브젝트 리스트(픽리스트)
    *************************************************************************************/
	@AuraEnabled
	public static Map<String, Object> getInitData() {
		// 사원 오브젝트의 레코드 전체 갯수
		String sQuery = '';

		sQuery += 'SELECT 	COUNT(Id) iTotalCnt';
		sQuery += '  FROM 	Employee__c';

		if(!hasPermission) {
			sQuery += ' WHERE User__c = :idCurrentUser';
		}

		AggregateResult result = Database.query(sQuery);

        Integer iTotalCnt = (Integer) result.get('iTotalCnt');

        // 사원 오브젝트의 하위 연관 오브젝트 리스트
        List<Map<String, String>> listChildObject = new List<Map<String, String>>();

		Schema.DescribeSObjectResult describeSObj = Employee__c.SObjectType.getDescribe();
		for(Schema.ChildRelationship child : describeSObj.getChildRelationships()) {
			if(child.getRelationshipName() != null) {
				String sValue = String.valueOf(child.getRelationshipName());                          
				String sLabel = String.valueOf(child.getChildSObject());

				Schema.DescribeSObjectResult describe = Schema.getGlobalDescribe().get(sLabel).getDescribe();

				if(describe.isCustom()) {
					sLabel = String.valueOf(describe.getLabel());
					if(sLabel == '증명서'){continue;}
					listChildObject.add(new Map<String, String>{'value' => sValue, 'label' => sLabel});	
				}
			}
		}

		// 결과 맵 생성 및 리턴
		Map<String, Object> mapReturnValue = new Map<String, Object>{
			'iTotalCnt' 		=> iTotalCnt,
			'listChildObject' 	=> listChildObject
		};

		return mapReturnValue;
	}

	/************************************************************************************
    * 	사원 오브젝트 리스트
    *************************************************************************************/
    @AuraEnabled
    public static List<Employee__c> getListEmployee(Integer limits, Integer offsets) {
    	System.debug('limits : ' + limits + ', offsets : ' + offsets);

        limits  = Integer.valueOf(limits);
        offsets = Integer.valueOf(offsets);

        String sQuery = '';

        sQuery += 'SELECT 	Id, Name, MainRole__c, toLabel(Position__c) Position__c, EmployeeNo__c, User__c';
        sQuery += '  FROM 	Employee__c';
        sQuery += ' WHERE 	Status__c = true';

        if(!hasPermission) {
        	sQuery += ' AND User__c = :idCurrentUser';
        }

        sQuery += ' ORDER BY MainRole__c, Position__c, EmployeeNo__c';
        sQuery += ' LIMIT ' + limits;
        sQuery += ' OFFSET ' + offsets;

        List<Employee__c> listEmployee = Database.query(sQuery);

        System.debug('listEmployee : ' + listEmployee);

        return listEmployee;
    }

    /************************************************************************************
    * 	사원 리스트 권한 체크
    * 	접속한 유저가 HRGroup에 속한 경우 사원 목록 전체를 출력하고, 그렇지 않은 경우 본인만 출력
    *************************************************************************************/
    private static Boolean hasPermission {
    	get {
    		if(hasPermission == null) {
    			hasPermission = setIdHRGroupMember.contains(idCurrentUser);
    		}

    		return hasPermission;
    	}
    	set;
    }

    private static Set<Id> setIdHRGroupMember {
    	get {
    		if(setIdHRGroupMember == null) {
    			List<GroupMember> listGroupMember = [SELECT Id, UserOrGroupId
    												 FROM 	GroupMember
    												 WHERE 	Group.DeveloperName = 'HRGroup'];

				setIdHRGroupMember = new Set<Id>();    			
    			for(GroupMember objGroupMember : listGroupMember) {
    				setIdHRGroupMember.add(objGroupMember.UserOrGroupId);
    			}
    		}

    		return setIdHRGroupMember;
    	}
    	set;
    }

    private static Id idCurrentUser {
    	get {
    		if(idCurrentUser == null) {
    			idCurrentUser = UserInfo.getUserId();
    		}

    		return idCurrentUser;
    	}
    	set;
    }

}