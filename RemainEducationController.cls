public with sharing class RemainEducationController {

    //role 체크하는 메서드
    @AuraEnabled(cacheable=true)
    public static Map<String, Boolean> getUserRoles() {
        Map<String, Boolean> mapRole = new Map<String, Boolean>();
        mapRole.put('isMainRole', isMainRole());
        mapRole.put('isCheck', isCheck());
        mapRole.put('isMentor', isMentor());
        return mapRole;
    }
    //CEO 또는 BusinessManagement인지 확인하는 메서드
    @AuraEnabled(cacheable=true)
    public static boolean isMainRole(){
        String userId=UserInfo.getUserId();
        //String userId='0052v00000fjMgvAAE';
        // 현재 사용자의 UserRoleId를 가져옴
        User currentUser = [
            SELECT UserRoleId
            FROM User
            WHERE Id = :userId
            LIMIT 1
        ];

        UserRole userRole=new UserRole();
        // UserRoleId가 존재하는 경우에만 UserRole을 조회
        if (currentUser.UserRoleId != null) {
            userRole = [
                SELECT Name
                FROM UserRole
                WHERE Id = :currentUser.UserRoleId
                LIMIT 1
            ];
        }
        String role=userRole.Name;
        System.debug('role: '+role);
        
        if(role=='CEO' || role=='Business Management'){
            return true;
        }
        return false;
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
            WHERE OwnerId =:emp.OwnerId
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
    //직원 진행 중/완료 프로그램 가져오는 메서드
    public static List<Map<String, Object>> getInProgressEducation(Employee__c emp) {
        // 업무일지에 기록된 교육 프로그램을 조회하여 진행 중인 프로그램만 반환
        List<Map<String, Object>> listInProgress = new List<Map<String, Object>>();
        AggregateResult[] listDaily = [
            SELECT Dt_EduName__c, Dt_EduName__r.Name, Dt_EduName__r.Edu_Category__c, COUNT(Id)
            FROM DailyTraining__c 
            WHERE OwnerId = :emp.OwnerId
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
    //모든 신입의 미진행 프로그램 가져오는 메서드 
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getAllEmployeeRemain(){
        //인턴, 사원, 사원(수습)들의 OwnerId,이름 가져오기
        String[] roles=new String[]{'9','13','14'};

        List<Employee__c> listEmployee=new List<Employee__c>();
        listEmployee=[
            SELECT OwnerId,Name
            FROM Employee__c
            WHERE Position__c IN :roles
        ];
        System.debug('listEmployee: '+listEmployee);

        // 각 교육 프로그램에 대한 직원 이름 리스트를 저장할 Map 생성
        Map<String, Map<String, Object>> mapRemain = new Map<String, Map<String, Object>>();
        
            for (Employee__c emp : listEmployee) {
                // 직원의 남은 교육 프로그램 가져오기
                List<Map<String, Object>> listRemainEdu = getRemainEducation(emp);
                for (Map<String, Object> mapRemainEdu : listRemainEdu) {
                    String programName = (String) mapRemainEdu.get('Name');
                    String programCategory=(String) mapRemainEdu.get('Category');
                    String Id=(String) mapRemainEdu.get('Id');
                    
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
                    listEmployeeNames.add(emp.Name);
                }
            }
            return mapRemain.values();
    }
    //모든 신입의 진행 중/완료 프로그램 가져오는 메서드
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getAllEmployeeInProgress() {
        // 진행 중인 프로그램 맵핑 로직
        String[] roles = new String[]{'9', '13', '14'};
        
        List<Employee__c> listEmployee = [
            SELECT OwnerId, Name 
            FROM Employee__c 
            WHERE Position__c IN :roles
        ];
        
        Map<String, Map<String, Object>> mapInProgress = new Map<String, Map<String, Object>>();
        
        for (Employee__c objEmp : listEmployee) {
            List<Map<String, Object>> listInProgressEdu = getInProgressEducation(objEmp);
            for (Map<String, Object> mapInProgressEdu : listInProgressEdu) {
                String programName = (String) mapInProgressEdu.get('Name');
                String programCategory=(String) mapInProgressEdu.get('Category');
                String Id=(String) mapInProgressEdu.get('Id');
                
                if (!mapInProgress.containsKey(programName)) {
                    // 새로운 프로그램이므로 카테고리 및 직원 리스트 초기화
                    Map<String, Object> mapProgram = new Map<String, Object>();
                    mapProgram.put('id', Id);
                    mapProgram.put('programName', programName);
                    mapProgram.put('category', programCategory);
                    mapProgram.put('employeeNames', new List<String>());
                    mapInProgress.put(programName, mapProgram);
                }
                
                // 직원 이름 추가
                // employeeNames를 List<String>으로 캐스팅하여 add 메서드 사용
                List<String> listEmployeeNames = (List<String>) mapInProgress.get(programName).get('employeeNames');
                listEmployeeNames.add(objEmp.Name);
            }
        }
        return mapInProgress.values();
    }
    //신입의 이름 가져오는 메서드
    @AuraEnabled(cacheable=true)
    public static string getName(){
        String userId=UserInfo.getUserId();
        //String userId='0052v00000gMeB8AAK';
        List<Employee__c> listUserName=new List<Employee__c>();
        listUserName=[
            SELECT Name
            FROM Employee__c
            WHERE OwnerId=:userId
        ];
        System.debug('listUserName: '+listUserName);
        String userName=listUserName[0].Name;
        System.debug('userName: '+userName);
        return userName;
    }
    //신입인지 확인하는 메서드
    @AuraEnabled(cacheable=true)
    public static Boolean isCheck(){
        String userId=UserInfo.getUserId();
        boolean check=false;
        //userId로 해당 직급 반환
        //Id recordId='a2O0k000004DbA4EAK';
        List<Employee__c> listPosition=new List<Employee__c>();
        listPosition=[
            SELECT Position__c
            FROM Employee__c 
            WHERE OwnerId=:userId
        ];

        String position=listPosition[0].Position__c;

        if(position=='9'||position=='13'||position=='14'){
            check=true;
        }
        System.debug(check);

        return check;
    }
    //멘토인지 확인하는 메서드
    @AuraEnabled(cacheable=true)
    public static Boolean isMentor(){
        String userId=UserInfo.getUserId();
        //String userId='0052v00000fjMgvAAE';
        Boolean flag=false;
        System.debug(userId);
        List<Employee__c> listMentor=new List<Employee__c>();
        listMentor=[
            SELECT Id,Name
            FROM Employee__c 
            WHERE MentorUser__c=:userId
        ];

        if(!listMentor.isEmpty()){
            flag=true;
        }
        System.debug(listMentor);
        System.debug(flag);

        return flag;
    }
    //멘티별 미진행 프로그램 가져오는 메서드 
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getAllMenteeRemain(){
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
            WHERE OwnerId =:userId
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
            WHERE OwnerId = :userId
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

}