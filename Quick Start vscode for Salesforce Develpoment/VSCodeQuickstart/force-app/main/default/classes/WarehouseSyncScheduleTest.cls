@isTest
private class WarehouseSyncScheduleTest {
    
    @isTest
    static void testScheduleExecution() {
        // 테스트 시작 전 예약된 작업 수를 가져옵니다.
        Integer initialJobsCount = [SELECT COUNT() FROM CronTrigger];
        
        // 모의 HTTP 응답 설정 (WarehouseCalloutService에서 사용됨)
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        
        Test.startTest();
        
        // 스케줄 작업 생성
        String jobId = System.schedule('Warehouse Sync Job Test', 
                                       '0 0 1 * * ?',  // 매일 오전 1시에 실행
                                       new WarehouseSyncSchedule());
        
        // 스케줄된 작업 실행
        Test.stopTest();
        
        // 테스트 종료 후 예약된 작업 수를 가져옵니다.
        Integer finalJobsCount = [SELECT COUNT() FROM CronTrigger];
        
        // 새로운 스케줄 작업이 생성되었는지 확인
        System.assertEquals(initialJobsCount + 1, finalJobsCount, 'A new scheduled job should be created');
        
        // 스케줄된 작업이 존재하는지 확인
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                          FROM CronTrigger 
                          WHERE Id = :jobId];
        System.assertEquals('0 0 1 * * ?', ct.CronExpression, 'Cron expression should match');
        System.assertEquals(0, ct.TimesTriggered, 'Scheduled job should not have run yet');
        System.assertNotEquals(null, ct.NextFireTime, 'Next fire time should be set');
        
        // Queueable 작업이 추가되었는지 확인
        List<AsyncApexJob> jobs = [SELECT Id, ApexClass.Name 
                                   FROM AsyncApexJob 
                                   WHERE JobType = 'Queueable' 
                                   AND ApexClass.Name = 'WarehouseCalloutService'];
        System.assertEquals(1, jobs.size(), 'WarehouseCalloutService should be queued');
    }
    
    // WarehouseCalloutService를 위한 모의 HTTP 응답 클래스
    private class WarehouseCalloutServiceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('[{"_id": "55d66226726b611100aaf741", "replacement": true, "quantity": 5, "name": "Generator 1000 kW", "maintenanceperiod": 365, "lifespan": 120, "cost": 5000, "sku": "100003"}]');
            response.setStatusCode(200);
            return response;
        }
    }
}