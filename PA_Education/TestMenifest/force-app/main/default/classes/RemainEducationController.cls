public with sharing class RemainEducationController {

    // Role checking method
    @AuraEnabled(cacheable=true)
    public static Map<String, Boolean> getUserRoles() {
        Map<String, Boolean> mapRole = new Map<String, Boolean>();
        mapRole.put('isMainRole', isMainRole());
        mapRole.put('isCheck', isCheck());
        mapRole.put('isMentor', isMentor());
        return mapRole;
    }

    // Check if the user is CEO or Business Management
    @AuraEnabled(cacheable=true)
    public static boolean isMainRole(){
        String userId = UserInfo.getUserId();

        // Fetch current user's role
        User currentUser = [
            SELECT UserRole.Name
            FROM User
            WHERE Id = :userId
            LIMIT 1
        ];

        String role = currentUser.UserRole != null ? currentUser.UserRole.Name : '';
        System.debug('role: ' + role);

        return (role == 'CEO' || role == 'Business Management'|| role == '관리부');
    }

    // Get the name of the logged-in user
    @AuraEnabled(cacheable=true)
    public static String getName(){
        String userId = UserInfo.getUserId();
        List<Employee__c> listUserName = [
            SELECT Name
            FROM Employee__c
            WHERE OwnerId = :userId
            LIMIT 1
        ];
        System.debug('listUserName: ' + listUserName);
        String userName = listUserName.size() > 0 ? listUserName[0].Name : '';
        System.debug('userName: ' + userName);
        return userName;
    }

    // Check if the user is an intern or trainee
    @AuraEnabled(cacheable=true)
    public static Boolean isCheck(){
        String userId = UserInfo.getUserId();
        Boolean flag=false;
        // String userId='00590000002IUUeAAO';
        List<Employee__c> listPosition = [
            SELECT Position__c
            FROM Employee__c 
            WHERE OwnerId = :userId
            LIMIT 1
        ];

        String position = listPosition.size() > 0 ? listPosition[0].Position__c : '';
        System.debug('position: '+position);

        if(position == '13' || position == '17' || position == '18'){
            flag=true;
        }

        //emp 레코드에 어드민아이디로 직급이 9인 필드가 만들어져 있으므로 더블체크 
        if(flag==true){
            User currentUser = [
            SELECT UserRole.Name
            FROM User
            WHERE Id = :userId
            LIMIT 1
        ];

            String role = currentUser.UserRole != null ? currentUser.UserRole.Name : '';
            System.debug('role: ' + role);

            if(role == 'CEO' || role == 'Business Management'){
                flag=false;
            }
        }
        
        System.debug('flag:'+flag);
        return flag;
    }

    // Check if the user is a mentor
    @AuraEnabled(cacheable=true)
    public static Boolean isMentor(){
        String userId = UserInfo.getUserId();
        List<Employee__c> listMentor = [
            SELECT Id
            FROM Employee__c 
            WHERE MentorUser__c = :userId
            LIMIT 1
        ];

        return !listMentor.isEmpty();
    }

    //로그인유저 미진행 프로그램 가져오는 메서드
    @AuraEnabled(cacheable=true)
    public static List<Map<String,Object>> getRemainEducation() {

        String userId=UserInfo.getUserId();
        
        System.debug('userId: '+userId);
        
        //직무 확인
        List<Employee__c> listMainRole=[
        SELECT MainRole__c
        FROM Employee__c 
        WHERE OwnerId =:userId];

        System.debug('listMainRole: '+listMainRole);
        //교육 프로그램의 관련분야 필드값에 맞게 수정
        String role='';
        switch on listMainRole[0].MainRole__c {
            when 'Developer' {
                role='Dev.';
                System.debug('role: '+role);
            }
            when 'Consultant' {
                role='Admin';
                System.debug('role: '+role);
            }
            when else {
                role='';
                System.debug('role: '+role);
            }
         }
         System.debug('role: '+role);
        //해당 직무가 들어야 하는 교육프로그램 확인
        List<EduCurriculum__c> listEdu=new List<EduCurriculum__c>();
        listEdu=[
            SELECT ID, Name,Edu_Category__c
            FROM EduCurriculum__c
            WHERE Edu_Active__c =true
            AND (Edu_Category__c =:role
            OR Edu_Category__c ='ALL')
        ];
        System.debug('listEdu: '+listEdu);

        //맵에 들어야 하는 프로그램 담기
        Map<String,Educurriculum__c> mapEdu=new Map<String,EduCurriculum__c>(listEdu);
        System.debug('mapEdu: '+mapEdu);

        //업무일지에 쓴 교육프로그램 확인
        AggregateResult[] listDaily = [
            SELECT Dt_EduName__c, Dt_EduName__r.Name, COUNT(Id)
            FROM DailyTraining__c 
            WHERE Dt_UserName__c =:userId
            AND Dt_EduName__r.Edu_Category__c!='Other'
            GROUP BY Dt_EduName__r.Name, Dt_EduName__c
        ];

        
        //들어야 하는 프로그램 중 업무일지에 쓴 프로그램은 제거
        for (AggregateResult daily : listDaily) {
            System.debug(daily);
            mapEdu.remove((String) daily.get('Dt_EduName__c'));
        }

        //남은 프로그램들 담기
        List<Map<String, Object>> listRemain = new List<Map<String, Object>>();
        for (String key : mapEdu.keySet()) {
            EduCurriculum__c edu = mapEdu.get(key);
            Map<String, Object> eduMap = new Map<String, Object>();
            eduMap.put('Id', edu.Id);
            eduMap.put('programName', edu.Name);
            eduMap.put('category',edu.Edu_Category__c);
            listRemain.add(eduMap);
        }
        
        return listRemain;
    }
    //로그인유저 진행 중/완료 프로그램 가져오는 메서드
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getInProgressEducation() {
        
        //로그인 유저 Id 담기
        String userId = UserInfo.getUserId();
        System.debug('userId: '+userId);
        
        // 업무일지에 기록된 교육 프로그램을 조회하여 진행 중인 프로그램만 반환
        List<Map<String, Object>> listInProgress = new List<Map<String, Object>>();
        AggregateResult[] listDaily = [
            SELECT Dt_EduName__c, Dt_EduName__r.Name, Dt_EduName__r.Edu_Category__c, COUNT(Id)
            FROM DailyTraining__c 
            WHERE Dt_UserName__c = :userId
            AND Dt_EduName__r.Edu_Category__c!='Other'
            GROUP BY Dt_EduName__c, Dt_EduName__r.Name, Dt_EduName__r.Edu_Category__c
        ];
        
        for (AggregateResult daily : listDaily) {
            System.debug('Daily: ' + Daily);
            Map<String, Object> inProgressMap = new Map<String, Object>();
            inProgressMap.put('Id', daily.get('Dt_EduName__c'));
            inProgressMap.put('programName', daily.get('Name'));
            inProgressMap.put('category',daily.get('Edu_Category__c'));
            listInProgress.add(inProgressMap);
        }

        return listInProgress;
    }

    //직원 진행 중/완료 프로그램 가져오는 메서드
    public static List<Map<String, Object>> getInProgressEducation(Employee__c emp) {
        // 업무일지에 기록된 교육 프로그램을 조회하여 진행 중인 프로그램만 반환
        List<Map<String, Object>> listInProgress = new List<Map<String, Object>>();
        AggregateResult[] listDaily = [
            SELECT Dt_EduName__c, Dt_EduName__r.Name, Dt_EduName__r.Edu_Category__c, COUNT(Id)
            FROM DailyTraining__c 
            WHERE Dt_UserName__c = :emp.OwnerId
            AND Dt_EduName__r.Edu_Category__c!='Other'
            GROUP BY Dt_EduName__c, Dt_EduName__r.Name,Dt_EduName__r.Edu_Category__c
        ];
        
        for (AggregateResult daily : listDaily) {
            System.debug('Daily: ' + Daily);
            Map<String, Object> inProgressMap = new Map<String, Object>();
            inProgressMap.put('Id', daily.get('Dt_EduName__c'));
            inProgressMap.put('Name', daily.get('Name'));
            inProgressMap.put('Category',daily.get('Edu_Category__c'));
            listInProgress.add(inProgressMap);
        }

        return listInProgress;
    }
     //직원 미진행 프로그램 가져오는 메서드
     public static List<Map<String,Object>> getRemainEducation(Employee__c emp) {
        //직무 확인
        List<Employee__c> listMainRole=[
        SELECT MainRole__c
        FROM Employee__c 
        WHERE OwnerId =:emp.OwnerId];

        System.debug('listMainRole: '+listMainRole);
        //교육 프로그램의 관련분야 필드값에 맞게 수정
        String role='';
        switch on listMainRole[0].MainRole__c {
            when 'Developer' {
                role='Dev.';
                System.debug('role: '+role);
            }
            when 'Consultant' {
                role='Admin';
                System.debug('role: '+role);
            }
         }
         System.debug('role: '+role);

        //해당 직무가 들어야 하는 교육프로그램 확인
        List<EduCurriculum__c> listEdu=new List<EduCurriculum__c>();
        listEdu=[
            SELECT ID, Name,Edu_Category__c
            FROM EduCurriculum__c
            WHERE Edu_Active__c =true
            AND (Edu_Category__c =:role
            OR Edu_Category__c ='ALL')
        ];
        System.debug('listEdu: '+listEdu);

        //맵에 들어야 하는 프로그램 담기
        Map<String,Educurriculum__c> mapEdu=new Map<String,EduCurriculum__c>(listEdu);
        System.debug('mapEdu: '+mapEdu);

        //업무일지에 쓴 교육프로그램 확인
        AggregateResult[] listDaily = [
            SELECT Dt_EduName__c, Dt_EduName__r.Name, COUNT(Id)
            FROM DailyTraining__c 
            WHERE Dt_UserName__c =:emp.OwnerId
            AND Dt_EduName__r.Edu_Category__c!='Other'
            GROUP BY Dt_EduName__r.Name, Dt_EduName__c
        ];

    
        
        //들어야 하는 프로그램 중 업무일지에 쓴 프로그램은 제거
        for (AggregateResult daily : listDaily) {
            System.debug(daily);
            mapEdu.remove((String) daily.get('Dt_EduName__c'));
        }

        //남은 프로그램들 담기
        List<Map<String, Object>> listRemain = new List<Map<String, Object>>();
        for (String key : mapEdu.keySet()) {
            EduCurriculum__c edu = mapEdu.get(key);
            Map<String, Object> eduMap = new Map<String, Object>();
            eduMap.put('Id', edu.Id);
            eduMap.put('Name', edu.Name);
            eduMap.put('Category',edu.Edu_Category__c);
            listRemain.add(eduMap);
        }
        
        return listRemain;
    }
    //모든 신입의 미진행 프로그램 가져오는 메서드 
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getAllEmployeeRemain() {
        // 신입, 직무 조건 쿼리
        String[] roles = new String[] { '13', '17', '18' };
        String[] mainRole = new String[] { 'Developer', 'Consultant' };

        List<Employee__c> listEmployee = [
            SELECT OwnerId, Name, MainRole__c
            FROM Employee__c
            WHERE Position__c IN :roles
            AND MainRole__c IN :mainRole
            AND Owner.isActive=true
            AND ExitDate__c = NULL 
            AND MentorUser__c!=NULL
        ];
        System.debug('listEmployee: ' + listEmployee);

        // 직원들 직무를 맵으로
        Map<Id, String> mapEmployeeRoles = new Map<Id, String>();
        for (Employee__c emp : listEmployee) {
            String role = '';
            switch on emp.MainRole__c {
                when 'Developer' {
                    role = 'Dev.';
                }
                when 'Consultant' {
                    role = 'Admin';
                }
            }
            mapEmployeeRoles.put(emp.OwnerId, role);
        }

        // Collect all roles needed for querying EduCurriculum__c
        Set<String> setRolesNeeded = new Set<String>();
        setRolesNeeded.addAll(mapEmployeeRoles.values());
        setRolesNeeded.add('ALL');

        // 직무들 들어야하는 프로그램 쿼리
        List<EduCurriculum__c> listEdu = [
            SELECT Id, Name, Edu_Category__c
            FROM EduCurriculum__c
            WHERE Edu_Active__c = true
            AND Edu_Category__c IN :setRolesNeeded
        ];
        System.debug('listEdu: ' + listEdu);

        // 카테고리별로 들어야하는 프로그램 맵으로 담기
        Map<String, List<EduCurriculum__c>> mapCategoryToEdu = new Map<String, List<EduCurriculum__c>>();
        for (EduCurriculum__c edu : listEdu) {
            if (!mapCategoryToEdu.containsKey(edu.Edu_Category__c)) {
                mapCategoryToEdu.put(edu.Edu_Category__c, new List<EduCurriculum__c>());
            }
            mapCategoryToEdu.get(edu.Edu_Category__c).add(edu);
        }

        // Collect all employee setOwnerIds
        Set<Id> setEmployeesetOwnerIds = new Set<Id>();
        for (Employee__c emp : listEmployee) {
            setEmployeesetOwnerIds.add(emp.OwnerId);
        }

        // 직원들이 쓴 업무일지 쿼리(프로그램명 중복방지 위해 group by)
        AggregateResult[] listDaily = [
            SELECT Dt_EduName__c, Dt_UserName__c
            FROM DailyTraining__c
            WHERE Dt_UserName__c IN :setEmployeesetOwnerIds
            AND Dt_EduName__r.Edu_Category__c != 'Other'
            GROUP BY Dt_EduName__c, Dt_UserName__c
        ];

        // 직원별 업무일지에 쓴 프로그램 맵에 담기
        Map<Id, Set<Id>> mapEmployeeCompletedEduIds = new Map<Id, Set<Id>>();
        for (AggregateResult ar : listDaily) {
            Id userId = (Id) ar.get('Dt_UserName__c');
            Id eduId = (Id) ar.get('Dt_EduName__c');
            if (!mapEmployeeCompletedEduIds.containsKey(userId)) {
                mapEmployeeCompletedEduIds.put(userId, new Set<Id>());
            }
            mapEmployeeCompletedEduIds.get(userId).add(eduId);
        }

        
        Map<Id, Map<String, Object>> mapProgramInfo = new Map<Id, Map<String, Object>>();

        //직원별로 하나씩 맵에 할당
        for (Employee__c emp : listEmployee) {
            String role = mapEmployeeRoles.get(emp.OwnerId);

            List<EduCurriculum__c> listRequiredEduPrograms = new List<EduCurriculum__c>();

            if (mapCategoryToEdu.containsKey(role)) {
                listRequiredEduPrograms.addAll(mapCategoryToEdu.get(role));
            }

            if (mapCategoryToEdu.containsKey('ALL')) {
                listRequiredEduPrograms.addAll(mapCategoryToEdu.get('ALL'));
            }

            Set<Id> completedEduIds = mapEmployeeCompletedEduIds.containsKey(emp.OwnerId) ? mapEmployeeCompletedEduIds.get(emp.OwnerId) : new Set<Id>();

            for (EduCurriculum__c edu : listRequiredEduPrograms) {
                if (!completedEduIds.contains(edu.Id)) {
                    
                    if (!mapProgramInfo.containsKey(edu.Id)) {
                        // 새로운 프로그램이므로 카테고리 및 직원 리스트 초기화
                        Map<String, Object> programInfo = new Map<String, Object>();
                        programInfo.put('id', edu.Id);
                        programInfo.put('programName', edu.Name);
                        programInfo.put('category', edu.Edu_Category__c);
                        programInfo.put('employeeNames', new List<String>());
                        mapProgramInfo.put(edu.Id, programInfo);
                    }

                    // 직원 이름 추가
                    // employeeNames를 List<String>으로 캐스팅하여 add 메서드 사용
                    List<String> employeeNames = (List<String>) mapProgramInfo.get(edu.Id).get('employeeNames');
                    employeeNames.add(emp.Name);
                }
            }
        }

        return mapProgramInfo.values();
    }

    //모든 신입의 진행 중/완료 프로그램 가져오는 메서드
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getAllEmployeeInProgress() {
        
        String[] roles = new String[]{'13', '17', '18'};
        String[] mainRoles = new String[]{'Developer', 'Consultant'};
        
        
        List<Employee__c> listEmployee = [
            SELECT OwnerId, Name 
            FROM Employee__c 
            WHERE Position__c IN :roles
            AND MainRole__c IN :mainRoles
            AND Owner.isActive=true
            AND ExitDate__c = NULL 
            AND MentorUser__c!=NULL
        ];
        
        System.debug('listEmployee: ' + listEmployee);

       // OwnerId를 직원 이름과 매핑
        Map<Id, String> mapOwnerIdToName = new Map<Id, String>();
        Set<Id> setOwnerIds = new Set<Id>();
        for (Employee__c emp : listEmployee) {
            mapOwnerIdToName.put(emp.OwnerId, emp.Name);
            setOwnerIds.add(emp.OwnerId);
        }

        // 모든 직원의 DailyTraining__c 레코드 일괄 조회
        List<DailyTraining__c> listDailyTraining = [
            SELECT Dt_EduName__c, Dt_EduName__r.Name, Dt_EduName__r.Edu_Category__c, Dt_UserName__c
            FROM DailyTraining__c 
            WHERE Dt_UserName__c IN :setOwnerIds
            AND Dt_EduName__r.Edu_Category__c != 'Other'
        ];

        System.debug('listDailyTraining: ' + listDailyTraining);

        // 프로그램 정보를 담을 맵 생성
        Map<Id, Map<String, Object>> mapProgramInfo = new Map<Id, Map<String, Object>>();

        // 프로그램별로 직원 이름을 저장하기 위한 맵 생성 (중복 제거를 위해 Set 사용)
        Map<Id, Set<String>> mapProgramToEmployeeNames = new Map<Id, Set<String>>();

        // 직원별로 업무일지에 쓴 프로그램들을 맵핑
        for (DailyTraining__c dt : listDailyTraining) {
            Id eduId = dt.Dt_EduName__c;
            String programName = dt.Dt_EduName__r.Name;
            String programCategory = dt.Dt_EduName__r.Edu_Category__c;
            Id userId = dt.Dt_UserName__c;
            String employeeName = mapOwnerIdToName.get(userId);

            if (!mapProgramInfo.containsKey(eduId)) {
                // 새로운 프로그램이므로 프로그램 정보 초기화
                Map<String, Object> programInfo = new Map<String, Object>();
                programInfo.put('id', eduId);
                programInfo.put('programName', programName);
                programInfo.put('category', programCategory);
                programInfo.put('employeeNames', new List<String>());
                mapProgramInfo.put(eduId, programInfo);

                // 직원 이름을 저장할 Set 초기화
                mapProgramToEmployeeNames.put(eduId, new Set<String>());
            }

            // 직원 이름 Set에 추가 (중복 자동 제거)
            mapProgramToEmployeeNames.get(eduId).add(employeeName);
        }

        // Set에 저장된 직원 이름들을 List로 변환하여 mapProgramInfo에 설정
        for (Id eduId : mapProgramInfo.keySet()) {
            Set<String> employeeNameSet = mapProgramToEmployeeNames.get(eduId);
            List<String> employeeNameList = new List<String>(employeeNameSet);
            mapProgramInfo.get(eduId).put('employeeNames', employeeNameList);
        }

        return mapProgramInfo.values();
    }


    //멘티별 미진행 프로그램 가져오는 메서드 
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getAllMenteeRemain(){
        //멘토 UserId를 통해 멘티들의 UserId,이름 가져오기
        String userId=UserInfo.getUserId();

        List<Employee__c> listMentee=new List<Employee__c>();
        listMentee=[
            SELECT OwnerId,Name,Id
            FROM Employee__c
            WHERE MentorUser__c=:userId
        ];
        System.debug('listEmployee: '+listMentee);

        // 각 교육 프로그램에 대한 직원 이름 리스트를 저장할 Map 생성
        Map<String, Map<String, Object>> mapRemain = new Map<String, Map<String, Object>>();

        //멘티들의 Id를 통해 남아있는 프로그램들 조회
        for(Employee__c objMentee:listMentee){
            // 직원의 남은 교육 프로그램 가져오기
            List<Map<String,Object>> listRemainEdu=getRemainEducation(objMentee);
            for(Map<String,Object> mapRemainEdu:listRemainEdu){
                String programName=(String)mapRemainEdu.get('Name');
                String programCategory=(String)mapRemainEdu.get('Category');
                String Id=(String)mapRemainEdu.get('Id');

                if (!mapRemain.containsKey(programName)) {
                    // 새로운 프로그램이므로 카테고리 및 직원 리스트 초기화
                    Map<String, Object> mapProgram = new Map<String, Object>();
                    mapProgram.put('id', Id);
                    mapProgram.put('programName', programName);
                    mapProgram.put('category', programCategory);
                    mapProgram.put('employeeNames', new List<String>());
                    mapRemain.put(programName, mapProgram);
                }

            // 직원 이름 추가
            // employeeNames를 List<String>으로 캐스팅하여 add 메서드 사용
            List<String> listEmployeeNames = (List<String>) mapRemain.get(programName).get('employeeNames');
            listEmployeeNames.add(objMentee.Name);
            }
        }
        return mapRemain.values();
    }

    //멘티별 진행 중/완료 프로그램 가져오는 메서드
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getAllMenteeInProgress() {
        //멘토 UserId를 통해 멘티들의 UserId,이름 가져오기
        String userId=UserInfo.getUserId();

        List<Employee__c> listMentee=new List<Employee__c>();
        listMentee=[
            SELECT OwnerId,Name
            FROM Employee__c
            WHERE MentorUser__c=:userId
        ];
        System.debug('listEmployee: '+listMentee);
        
        // 각 교육 프로그램에 대한 직원 이름 리스트를 저장할 Map 생성
        Map<String, Map<String, Object>> mapInprogress = new Map<String, Map<String, Object>>();
        
        for (Employee__c objMentee : listMentee) {
            List<Map<String, Object>> listInProgressEdu = getInProgressEducation(objMentee);
            for (Map<String, Object> mapInProgressEdu : listInProgressEdu) {
                String programName = (String) mapInProgressEdu.get('Name');
                String programCategory=(String) mapInProgressEdu.get('Category');
                String Id=(String) mapInProgressEdu.get('Id');
                
                if (!mapInprogress.containsKey(programName)) {
                    // 새로운 프로그램이므로 카테고리 및 직원 리스트 초기화
                    Map<String, Object> mapProgram = new Map<String, Object>();
                    mapProgram.put('id',Id);
                    mapProgram.put('programName', programName);
                    mapProgram.put('category', programCategory);
                    mapProgram.put('employeeNames', new List<String>());
                    mapInprogress.put(programName, mapProgram);
                }
                
                // 직원 이름 추가
                // employeeNames를 List<String>으로 캐스팅하여 add 메서드 사용
                List<String> listEmployeeNames = (List<String>) mapInprogress.get(programName).get('employeeNames');
                listEmployeeNames.add(objMentee.Name);
            }
        }
        return mapInprogress.values();
    }

}