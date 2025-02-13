public with sharing class InterviewName_tr extends TriggerHandler {
    private List<Interview__c> listNew {get; set;}  // 새로 생성된 면담일지 리스트
    private List<Interview__c> listOld {get; set;}  // 기존 면담일지 리스트 (업데이트 시 사용)
    private Map<Id, Interview__c> mapNew {get; set;}  // 새로 생성된 면담일지 맵
    private Map<Id, Interview__c> mapOld {get; set;}  // 기존 면담일지 맵 (업데이트 시 사용)

    public InterviewName_tr() {
        listNew = (List<Interview__c>) Trigger.new;
        listOld = (List<Interview__c>) Trigger.old;
        mapNew = (Map<Id, Interview__c>) Trigger.newMap;
        mapOld = (Map<Id, Interview__c>) Trigger.oldMap;
    }

    // 면담일지 생성 시 이름 설정 (before insert)
    public override void beforeInsert() {
        System.debug('beforeInsert');
        setInterviewNames(listNew);  
    }
    
    // 면담일지가 새로 생성된 후 이름 갱신 (after insert)
    public override void afterInsert() {
        System.debug('afterInsert');
        updateInterviewNames(listNew); 
    }

    // 면담일지가 업데이트된 후 이름 갱신 (after update)
    public override void afterUpdate() {
        System.debug('afterUpdate');
        updateInterviewNames(listNew); 
    }

    public override void afterDelete(){
        System.debug('afterDelete');
        updateInterviewNames(listOld); 
    }

    // 면담일지 이름을 설정하는 로직
    public void setInterviewNames(List<Interview__c> interviews) {
        Set<Id> menteeIds = new Set<Id>();  
        Map<String, Integer> interviewCounts = new Map<String, Integer>();  // Key: menteeId + year + month, Value: count

        // 면담일지 정보 수집
        for (Interview__c obj : interviews) {
            if (obj.Intv_Date__c != null && obj.Intv_Mentee__c != null) {
                menteeIds.add(obj.Intv_Mentee__c);  // 멘티 ID 추가
            }   
            System.debug('menteeIds ::' + menteeIds);
        }

        // 면담일지의 연/월별 개수 쿼리
        List<AggregateResult> listResult = [
            SELECT Intv_Mentee__c, CALENDAR_YEAR(Intv_Date__c) year, CALENDAR_MONTH(Intv_Date__c) month, COUNT(Id) total
            FROM Interview__c
            WHERE Intv_Mentee__c IN :menteeIds
            GROUP BY Intv_Mentee__c, CALENDAR_YEAR(Intv_Date__c), CALENDAR_MONTH(Intv_Date__c)
        ];
        System.debug('listResult ::' + listResult);
        for (AggregateResult ar : listResult) {
            String key = (String) ar.get('Intv_Mentee__c') + '-' + (Integer) ar.get('year') + '-' + (Integer) ar.get('month');
            interviewCounts.put(key, (Integer) ar.get('total'));
            System.debug('String key ::' + key);
            System.debug('interviewCounts ::' + interviewCounts);
        }

        for (Interview__c obj : interviews) {
            if (obj.Intv_Date__c != null && obj.Intv_Mentee__c != null) {
                Integer year = obj.Intv_Date__c.year();
                Integer month = obj.Intv_Date__c.month();
                String key = obj.Intv_Mentee__c + '-' + year + '-' + month;

                Integer interviewCount = interviewCounts.get(key) == null ? 0 : interviewCounts.get(key);
                Integer currentIndex = interviewCount + 1;
                System.debug('interviewCount ::' + interviewCount);
                System.debug('currentIndex ::' + currentIndex);

                obj.Intv_Name__c = 'No.' + year + '-' + (month < 10 ? '0' + String.valueOf(month) : String.valueOf(month)) +
                           '-' + currentIndex + '/' + currentIndex;
            } else {
                obj.Intv_Name__c = 'No.0000-00-0/0'; 
            }
        }
    }


    public void updateInterviewNames(List<Interview__c> interviews) {
        Set<Id> menteeIds = new Set<Id>();
        Set<Id> recordTypeIds = new Set<Id>();
    
        // `Intv_Mentee__c`와 `Intv_Date__c`가 null이 아닌 경우만 처리
        System.debug('Starting to process interviews...');
        for (Interview__c obj : interviews) {
            if (obj.Intv_Date__c != null && obj.Intv_Mentee__c != null) {
                menteeIds.add(obj.Intv_Mentee__c);  
            }
        
            if (obj.RecordTypeId != null) {
                recordTypeIds.add(obj.RecordTypeId);
            }
            System.debug('Interview Object: ' + obj);
            System.debug('Intv_Mentee__c: ' + obj.Intv_Mentee__c + ', Intv_Date__c: ' + obj.Intv_Date__c);
        }
    
        // `Intv_Mentee__c`에 해당하는 면담 리스트 가져오기
        System.debug('Fetching interviews based on menteeIds: ' + menteeIds);
        List<Interview__c> listSameKey = [
            SELECT Id, Intv_Mentee__c, Intv_Date__c, Intv_Name__c, RecordTypeId
            FROM Interview__c
            WHERE Intv_Mentee__c IN :menteeIds
            AND RecordTypeId IN: recordTypeIds
            ORDER BY Intv_Date__c ASC
        ];
    
        System.debug('Fetched Interviews: ' + listSameKey);
    
        // 면담을 연/월별로 그룹화
        Map<String, List<Interview__c>> interviewsByMonth = new Map<String, List<Interview__c>>();
        for (Interview__c interview : listSameKey) {
            System.debug('1');
         
                String key = '';  
        
                if (interview.Intv_Date__c != null && interview.Intv_Mentee__c != null) {
                    // key 값을 설정
                    key = interview.Intv_Mentee__c + '-' + interview.Intv_Date__c.year() + '-' + interview.Intv_Date__c.month();
                }
            System.debug('Grouping interview with key: ' + key);
            
            // 맵에 해당 key가 없다면 새로 생성
            if (!interviewsByMonth.containsKey(key)) {
                interviewsByMonth.put(key, new List<Interview__c>());
            }
    
            interviewsByMonth.get(key).add(interview);
        }
    
        System.debug('Grouped Interviews by Month: ' + interviewsByMonth);
    
        List<Interview__c> interviewsToUpdate = new List<Interview__c>();
    
        // `interviewsByMonth`의 각 키별로 면담 이름을 갱신
        for (String key : interviewsByMonth.keySet()) {
            List<Interview__c> interviewList = interviewsByMonth.get(key);
    
            // interviewList가 null이거나 비어있으면 건너뛰기
            if (interviewList != null && !interviewList.isEmpty()) { 
                Integer totalCount = interviewList.size();
                System.debug('Processing ' + totalCount + ' interviews for key: ' + key);
    
                // 면담 리스트 내 각 면담에 대해 이름 갱신
                for (Integer i = 0; i < totalCount; i++) {
                    Interview__c updateObj = interviewList.get(i);
                    System.debug('Processing Interview: ' + updateObj);
                    
                    // `Intv_Date__c`가 null인 경우 건너뛰기
                    if (updateObj != null && updateObj.Intv_Date__c != null) { 
                        Integer year = updateObj.Intv_Date__c.year();
                        Integer month = updateObj.Intv_Date__c.month();
                        String newName = 'No.' + year + '-' + (month < 10 ? '0' + String.valueOf(month) : String.valueOf(month)) +
                                         '-' + (i + 1) + '/' + totalCount;
                        System.debug('Generated New Name: ' + newName);
    
                        // 면담 이름을 갱신할 때 기존 이름과 다르면 갱신
                        if (updateObj.Intv_Name__c != newName) {
                            updateObj.Intv_Name__c = newName;
                            interviewsToUpdate.add(updateObj);
                        }
                    } else {
                        System.debug('Skipping Interview due to null Intv_Date__c');
                    }
                }
            } else {
                System.debug('Skipping key due to empty or null interviewList for key: ' + key);
            }
        }
    
        // 업데이트할 레코드가 있으면 업데이트
        if (!interviewsToUpdate.isEmpty()) {
            System.debug('Updating Interviews: ' + interviewsToUpdate);
            update interviewsToUpdate;
        } else {
            System.debug('No Interviews to update.');
        }
    }
    
    
}