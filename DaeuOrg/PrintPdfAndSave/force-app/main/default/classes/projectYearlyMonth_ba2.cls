public with sharing class projectYearlyMonth_ba2 implements Database.Batchable<SObject>, Database.Stateful {
   
    private Map<String, YearlyAmount__c> mapYearlyAmount = new Map<String, YearlyAmount__c>();
    private String query;
 
    public projectYearlyMonth_ba2() {

        //기존 YearlyAmount조회
        List<YearlyAmount__c> listYearly = [
            SELECT Id, Project__c, Type__c, Year__c, Name,
            month1__c, month2__c, month3__c, month4__c, month5__c, month6__c,
            month7__c, month8__c, month9__c, month10__c, month11__c, month12__c
            FROM YearlyAmount__c
        ];
        System.debug('[YearlyAmount 조회] 조회된 개수: ' + listYearly.size());
       
         //업데이트 위해 존재하는 YearlyAmount 레코드 전부 삭제
         if(!listYearly.isEmpty()){
            delete listYearly;
            System.debug('[YearlyAmount 삭제 완료]');
        }
        //예산이 배정된 프로젝트 전체 조회
        query = 'SELECT Id, ru_Budget__c, Name, ' +
                            'ru_Amount__c, fm_NetAmount__c ' +
                            'FROM Project__c '+
                            'WHERE ru_Budget__c != 0 ';
 
        System.debug('Query 실행됨: ' + query);
    }
 
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
   
    /*
    *** Batch Execute
    */
    public void execute(Database.BatchableContext BC, List<Project__c> listProject) {
        System.debug('[Project 조회] 조회된 프로젝트 개수: ' + listProject.size());
 
        //프로젝트가 비어있을 경우 return
        if (listProject.isEmpty()) return;
 
        //프로젝트 Id Set
        Set<Id> setProjectId = new Set<Id>();
        for (Project__c project : listProject) {
            setProjectId.add(project.Id);
            System.debug('[Project ID] ' + project.Id + ' - ' + project.Name);
        }
        
       
        // 프로젝트별 예산 상세 조회
        List<ProjectBudgetDetail__c> listDetail = [
            SELECT Amount__c, Category2__c, ProjectBudget__r.Project__c, effectiveStartDate__c, effectiveEndDate__c
            FROM ProjectBudgetDetail__c
            WHERE ProjectBudget__r.Project__c IN :setProjectId AND effectiveStartDate__c!=null AND effectiveEndDate__c!=null
        ];

        System.debug('[ProjectBudgetDetail 조회] 조회된 개수: ' + listDetail.size()); 
       
        //세부내역 타입 맵핑
        Map<Id, Map<String,List<ProjectBudgetDetail__c>>> mapListProjectDetail = new Map<Id, Map<String,List<ProjectBudgetDetail__c>>>();
        for (ProjectBudgetDetail__c objDetail : listDetail) {
            Id projectId = objDetail.ProjectBudget__r.Project__c;

            if (!mapListProjectDetail.containsKey(projectId)) {
                mapListProjectDetail.put(projectId, new Map<String,List<ProjectBudgetDetail__c>>());
            }
            Map<String,List<ProjectBudgetDetail__c>> mapListDetail = mapListProjectDetail.get(projectId);

            //같은 카테고리끼리 묶어 List에 보관
            String category = objDetail.Category2__c;
            if(!mapListDetail.containsKey(category)){
                mapListDetail.put(category,new List<ProjectBudgetDetail__c>());
            }
            List<ProjectBudgetDetail__c> listBudgetDetail=mapListDetail.get(category);
            System.debug('[Budget Detail] Project: ' + projectId + ' | Category: ' + category + ' | listDetail: ' + listBudgetDetail);
            listBudgetDetail.add(objDetail);
            mapListDetail.put(category, listBudgetDetail);

            mapListProjectDetail.put(projectId, mapListDetail);
        }
 
        //월별 예산 계산 후 맵에 담기
        mapYearlyAmount=calculateYearlyAmount(listProject, mapListProjectDetail);

        
        if (!mapYearlyAmount.isEmpty()) {
            // 리스트에 추가 후 insert 실행
            List<YearlyAmount__c> listYearlyAmount = new List<YearlyAmount__c>(mapYearlyAmount.values());
            System.debug('[YearlyAmount 생성 개수] ' + listYearlyAmount.size());
 
            insert listYearlyAmount;
            System.debug('[YearlyAmount Insert 완료]');
        }
    }
   
    /*
    ** Batch finish
    */
    public void finish(Database.BatchableContext BC) {
    }
   
   
    /*
    * 프로젝트의 연간 월별 예산을 계산하는 메서드 
    */
    private Map<String, YearlyAmount__c> calculateYearlyAmount(
        List<Project__c> listProject, 
        Map<Id, Map<String, List<ProjectBudgetDetail__c>>> mapListProjectDetail
    ) {
        Map<String, YearlyAmount__c> mapYearlyAmount = new Map<String, YearlyAmount__c>();
    
        for (Project__c project : listProject) {
            if (!mapListProjectDetail.containsKey(project.Id)) {
                System.debug('프로젝트에 대한 예산 상세 정보 없음: ' + project.Name);
                continue;
            }
            
            Map<String, List<ProjectBudgetDetail__c>> mapListDetail = mapListProjectDetail.get(project.Id);
            
            for (String mapKey : mapListDetail.keySet()) {
                Map<String, YearlyAmount__c> mapYearlyDetailAmount = new Map<String, YearlyAmount__c>();
                List<ProjectBudgetDetail__c> listDetails = mapListDetail.get(mapKey);
                
                if (listDetails.isEmpty()) {
                    System.debug('listDetails is Empty');
                    continue;
                }
                
                for (ProjectBudgetDetail__c objDetail : listDetails) {
                    // 세부 예산의 기간 및 금액 정보 설정
                    Date startDate = objDetail.effectiveStartDate__c;
                    Date endDate = objDetail.effectiveEndDate__c;
                    Integer startYear = startDate.year();
                    Integer endYear = endDate.year();
                    Integer startMonth = startDate.month();
                    Integer endMonth = endDate.month();
                    Integer startDay = startDate.day();
                    Integer endDay = endDate.day();
                    Integer dayDiff = startDate.daysBetween(endDate) + 1;
    
                    Decimal decProject = (Decimal) objDetail.Amount__c; //세부예산
                    Decimal dayByProject=0; //월별일할 예산

                    if (decProject == 0) { //세부 예산이 0인 경우 프로젝트 기간이 변동되었다고 판단 후 해당 로직 실행
                        //유효시작일 이후 배정되었던 월별 일할 예산들의 총합을 계산하는 메서드
                        decProject = redistributeExistingBudget(project, mapKey, mapYearlyDetailAmount, startYear, endYear, startMonth, endMonth);

                        dayByProject = decProject / Decimal.valueOf(dayDiff);
                        //변동된 프로젝트 기간만큼 월별 일할 예산을 다시 재분배하는 메서드
                        distributeBudget(project, mapKey, mapYearlyDetailAmount, startYear, endYear, startMonth, endMonth, startDay, endDay, dayByProject);
                    }
                    else{
                        dayByProject=decProject / Decimal.valueOf(dayDiff);
                        //월별 일할 예산을 계산하는 메서드
                        CalculateBudget(project, mapKey, mapYearlyDetailAmount, startYear, endYear, startMonth, endMonth, startDay, endDay, dayByProject,decProject);
                    }
                }
                
                for (String key : mapYearlyDetailAmount.keySet()) {
                    if (!mapYearlyAmount.containsKey(key)) {
                        mapYearlyAmount.put(key, mapYearlyDetailAmount.get(key));
                    }
                }
            }
        }
        return mapYearlyAmount;
    }
    
    /*
    * 유효시작일 이후 배정되었던 월별 일할 예산들의 총합을 계산하고 해당 월의 예산을 0으로 초기화시키는 메서드
    */
    private Decimal redistributeExistingBudget(
        Project__c project, String mapKey, Map<String, YearlyAmount__c> mapYearlyDetailAmount,
        Integer startYear, Integer endYear, Integer startMonth, Integer endMonth
    ) {
        Decimal totalAmount = 0; //유효시작일 이후 배정되었던 월별 일할 예산들의 총합을 보관
        for (Integer year = startYear; year <= endYear; year++) {
            String strYearKey = project.Id + '-' + year + '-' + mapKey;

            if (mapYearlyDetailAmount.containsKey(strYearKey)) {
                YearlyAmount__c objYearlyAmount = mapYearlyDetailAmount.get(strYearKey);

                Integer firstMonth = (year == startYear) ? startMonth : 1;
                Integer lastMonth = (year == endYear) ? endMonth : 12;

                System.debug('firstMonth: ' + firstMonth +'lastMonth: '+ lastMonth);

                for (Integer month = firstMonth; month <= 12; month++) {
                    String monthFieldName = 'month' + String.valueOf(month) + '__c';
                    if (objYearlyAmount.get(monthFieldName) != null) {
                        totalAmount += (Decimal) objYearlyAmount.get(monthFieldName);
                    }

                    // 유효 종료일이 줄어든 경우 → 유효 종료일 이후 월별 예산 0으로 설정
                    if (year == endYear && month > lastMonth) {
                        if (objYearlyAmount.get(monthFieldName) != null) {
                            System.debug('유효 종료일 이후 예산 제거 (0 설정): ' + monthFieldName);
                            objYearlyAmount.put(monthFieldName, 0);
                        }
                    }

                }
            }
        }
        return totalAmount;
    }
    
    /*
    * 예산을 변동된 프로젝트 기간만큼 월별 일할 계산을 통해 다시 재분배하는 메서드 
    */
    private void distributeBudget(
        Project__c project, String mapKey, Map<String, YearlyAmount__c> mapYearlyDetailAmount,
        Integer startYear, Integer endYear, Integer startMonth, Integer endMonth,
        Integer startDay, Integer endDay, Decimal dayByProject
    ) {

        for (Integer year = startYear; year <= endYear; year++) {
            String strYearKey = project.Id + '-' + year + '-' + mapKey;

            if (!mapYearlyDetailAmount.containsKey(strYearKey)) {
                //새로운 YearlyAmount 레코드 생성 후 맵에 담기
                mapYearlyDetailAmount.put(strYearKey, createYearlyAmountRecord(project, mapKey, year)); 
            }
            
            YearlyAmount__c objYearlyAmount = mapYearlyDetailAmount.get(strYearKey);

            Integer firstMonth = (year == startYear) ? startMonth : 1;
            Integer lastMonth = (year == endYear) ? endMonth : 12;

            for (Integer month = firstMonth; month <= lastMonth; month++) {
                //해당 월의 일 수를 판단하는 메서드
                Integer day = getEffectiveDaysInMonth(year, month, startYear, endYear, startMonth, endMonth, startDay, endDay);
                Decimal monthProject = dayByProject * Decimal.valueOf(day);

                String monthFieldName = 'month' + String.valueOf(month) + '__c';
                
                objYearlyAmount.put(monthFieldName, monthProject);
                
                System.debug('monthField: '+objYearlyAmount.get(monthFieldName));

            }
        }
    }

    /*
    * 예산을 월별 일할 예산을 계산하는 메서드
    */
    private void CalculateBudget(
        Project__c project, String mapKey, Map<String, YearlyAmount__c> mapYearlyDetailAmount,
        Integer startYear, Integer endYear, Integer startMonth, Integer endMonth,
        Integer startDay, Integer endDay, Decimal dayByProject, Decimal decProject
    ) {
        Decimal decRemainAmount=0; //총예산과 일할 계산들의 차액을 보관할 변수

        for (Integer year = startYear; year <= endYear; year++) {
            String strYearKey = project.Id + '-' + year + '-' + mapKey;

            if (!mapYearlyDetailAmount.containsKey(strYearKey)) {
                //새로운 YearlyAmount 레코드 생성 후 맵에 담기
                mapYearlyDetailAmount.put(strYearKey, createYearlyAmountRecord(project, mapKey, year));
            }
            
            YearlyAmount__c objYearlyAmount = mapYearlyDetailAmount.get(strYearKey);

            Integer firstMonth = (year == startYear) ? startMonth : 1;
            Integer lastMonth = (year == endYear) ? endMonth : 12;

            for (Integer month = firstMonth; month <= lastMonth; month++) {
                Integer day = getEffectiveDaysInMonth(year, month, startYear, endYear, startMonth, endMonth, startDay, endDay);
                Decimal monthProject = Math.round(dayByProject * Decimal.valueOf(day)); //정수로 반올림

                decRemainAmount+=monthProject;

                if(year==endYear && month==endMonth){
                    //연말은 차액만큼 더해서 저장(총예산 합을 유지하기 위함)
                    monthProject+=decProject-decRemainAmount;
                }
                
                String monthFieldName = 'month' + String.valueOf(month) + '__c';
                
                if (objYearlyAmount.get(monthFieldName) == null) {
                    objYearlyAmount.put(monthFieldName, monthProject);
                } else {
                    Decimal monthAmount=(Decimal) objYearlyAmount.get(monthFieldName);
                    monthAmount+=monthProject; //예산 증액 되는 경우 계산
                    if(monthAmount<0){ //음수값 나오지 않게 하기 위함
                        monthAmount=0;
                    }
                    objYearlyAmount.put(monthFieldName, monthAmount);
                }
                
                System.debug('monthField: '+objYearlyAmount.get(monthFieldName));

            }
        }
    }
    
    /*
    * 연간 예산 레코드를 생성하는 메서드
    */
    private YearlyAmount__c createYearlyAmountRecord(Project__c project, String mapKey, Integer year) {
        YearlyAmount__c objYearlyAmounts = new YearlyAmount__c();
        objYearlyAmounts.Type__c = mapKey;
        objYearlyAmounts.Project__c = project.Id;
        objYearlyAmounts.Year__c = String.valueOf(year);
        objYearlyAmounts.Name = String.valueOf(year) + '년_' + project.Name + ' ' + mapKey + ' 월별예산';
        return objYearlyAmounts;
    }
    
    /*
    * 각 월에 대한 일수를 계산하는 메서드
    */
    private Integer getEffectiveDaysInMonth(
        Integer year, Integer month, Integer startYear, Integer endYear,
        Integer startMonth, Integer endMonth, Integer startDay, Integer endDay
    ) {
        Integer day = Date.daysInMonth(year, month);
        if (year == startYear && year == endYear && startMonth == endMonth) {
            return endDay - startDay + 1;
        } else if (year == startYear && month == startMonth) {
            return day - startDay + 1;
        } else if (year == endYear && month == endMonth) {
            return endDay;
        }
        return day;
    }
    
    
}

