public with sharing class projectYearlyMonth_ba2 implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String ProjectId = 'a2TF7000002N7dQMAS';
        String query = 'SELECT Id, ru_Budget__c, Name, '+
                        'StartDate__c, EndDate__c, ru_Amount__c, fm_NetAmount__c ' +
                       'FROM Project__c WHERE ru_Budget__c != 0 and id=: ProjectId';

        System.debug('start() 실행됨. Query: ' + query);

        List<Project__c> listProject = Database.query(query);
        System.debug('📊 [start] 조회된 레코드 개수: ' + listProject.size());

        if(!listProject.isEmpty()){
            for(Project__c project: listProject){
                Date startDate=project.StartDate__c;
                Date endDate=project.EndDate__c;

                //프로젝트 시작년도와 종료년도 가져오기
                Integer startYear = startDate.year();
                System.debug('startYear: '+startYear);
                Integer endYear = endDate.year();
                System.debug('endYear: '+endYear);
                //프로젝트 시작월과 종료월 가져오기
                Integer startMonth=startDate.month();
                System.debug('startMonth: '+startMonth);
                Integer endMonth=endDate.month();
                System.debug('endMonth: '+endMonth);
                //프로젝트 시작일과 종료일일 가져오기
                Integer startDay=startDate.day();
                System.debug('startDay: '+startDay);
                Integer endDay=endDate.day();
                System.debug('endDay: '+endDay);
                //두 날짜간의 일차이 가져오기
                Integer dayDiff=startDate.daysBetween(endDate);
                System.debug('dayDiff: '+dayDiff);
                //프로젝트에 할당 된 예산 가져오기
                Decimal decproject=project.ru_Budget__c;
                System.debug('decproject: '+decproject);
                
                Decimal dayByproject=decproject/Decimal.valueOf(dayDiff); //일별 예산
                System.debug('dayByproject: '+dayByproject);

                //필드를 몇개 만들어야 할지 비교 후 생성(예산)
                List<YearlyAmount__c> listYearlyAmount=new List<YearlyAmount__c>();
                for(Integer year=startYear;year<=endYear;year++){
                    yearlyAmount__c objYearlyAmount=new yearlyAmount__c();
                    //objYearlyAmount.project__c=project.id; //예산
                    //System.debug('1. : '+objYearlyAmount.project__c);
                    objYearlyAmount.Type__c='예산';//타입: 예산
                    System.debug('2. : '+objYearlyAmount.Type__c);
                    objYearlyAmount.Project__c=project.id; //프로젝트
                    System.debug('3. : '+objYearlyAmount.Project__c);
                    objYearlyAmount.Year__c=String.valueOf(year); //년도
                    System.debug('4. : '+objYearlyAmount.Year__c);
                    objYearlyAmount.Name=String.valueOf(year)+'년_'+ project.Name + ' 월별예산';
                    
                    Integer firstMonth=(year==startYear)? startMonth : 1;
                    Integer lastMonth=(year==endYear)? endMonth: 12;

                    for(Integer month=firstMonth;month<=lastMonth;month++){
                        Integer day=Date.daysInMonth(year, month); //해당 년도 달의 일 수 반환
                        if(year==startYear&& month==startMonth){
                            day=day-startDay+1;
                        }
                        else if(year==endYear && month==endMonth){
                            day=endDay;
                        }
                        
                        System.debug('day: '+day);
                        //예산 계산
                        
                        Decimal monthproject = dayByproject * Decimal.valueOf(day);
                        System.debug('monthproject: '+monthproject);
                        String monthFieldName='month'+ String.valueOf(month) +'__c';
                        System.debug('monthFieldName: '+monthFieldName);
                        
                        objYearlyAmount.put(monthFieldName,monthproject);
                    }
                    System.debug('objYearlyAmount: '+objYearlyAmount);
                    listYearlyAmount.add(objYearlyAmount);
                }

                System.debug('listYearlyAmount: '+listYearlyAmount);
                insert listYearlyAmount;
            }  
        }
        else{
            System.debug('listProject is Empty');
        }
        
        

        

        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<project__c> scope) {
        System.debug('execute() 실행됨. scope size: ' + scope.size());
        
        for (project__c b : scope) {
            System.debug('Processing project__c record: ' + b);
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('finish() 실행됨. 배치 완료');
    }
}