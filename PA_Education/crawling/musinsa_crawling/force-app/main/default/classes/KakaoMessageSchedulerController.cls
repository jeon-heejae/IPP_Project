public with sharing class KakaoMessageSchedulerController {
    @AuraEnabled
    public static Boolean scheduleDailyJob(String jobName, String cronExpression) {
        try {
            // 기존에 등록된 동일한 작업 삭제
            List<CronTrigger> existingJobs = [
                SELECT Id, State 
                FROM CronTrigger 
                WHERE CronJobDetail.Name = :jobName
            ];
            for (CronTrigger job : existingJobs) {
                System.abortJob(job.Id);
            }

            // 새 작업 등록
            String jobId = System.schedule(
                jobName,
                cronExpression,
                new KakaoMessage_sc()
            );
            System.debug('Job Scheduled with ID: ' + jobId);
            return true;
        } catch (Exception e) {
            System.debug('Error scheduling job: ' + e.getMessage());
            return false;
        }
    }
}