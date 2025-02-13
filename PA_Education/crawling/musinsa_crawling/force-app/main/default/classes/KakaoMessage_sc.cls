public with sharing class KakaoMessage_sc implements Schedulable { //스케줄러에서는 http 콜아웃을 할 수 없다. -> future 메서드를 사용하거나 queueable을 사용해야 함.
    public void execute(SchedulableContext sc) {
        
        try {
            List<Kakao_Token__c> tokens = [
                SELECT Search_Keyword__c 
                FROM Kakao_Token__c 
                ORDER BY CreatedDate DESC LIMIT 1
            ];
            if (!tokens.isEmpty()) {
                String keyword = tokens[0].Search_Keyword__c;
                System.enqueueJob(new KakaoMessage_qa(keyword));
            } else {
                System.debug('No keyword found. Scheduler execution skipped.');
            }
        } catch (Exception e) {
            System.debug('Error in KakaoScheduler: ' + e.getMessage());
        }
    }
}
