@isTest
private class MaintenanceRequestHelperTest {
    @testSetup
    static void setupTestData() {
        // 테스트 데이터 생성
        Vehicle__c vehicle = new Vehicle__c(Name = 'Test Vehicle');
        insert vehicle;
        
        // Product2 생성 시 필요한 필드 추가
        Product2 equipment = new Product2(
            Name = 'Test Equipment',
            Maintenance_Cycle__c = 10,
            Replacement_Part__c = true,  // 이 필드가 필요할 수 있습니다
            Current_Inventory__c = 5,    // 재고 관련 필드
            Lifespan_Months__c = 12,     // 수명 관련 필드
            Cost__c = 100,               // 비용 관련 필드
            Warehouse_SKU__c = 'TEST-SKU-001'  // SKU 필드
        );
        insert equipment;
        
        Case maintenanceRequest = new Case(
            Subject = 'Test Maintenance Request',
            Type = 'Repair',
            Status = 'New',
            Vehicle__c = vehicle.Id
        );
        insert maintenanceRequest;
        
        Equipment_Maintenance_Item__c emi = new Equipment_Maintenance_Item__c(
            Equipment__c = equipment.Id,
            Maintenance_Request__c = maintenanceRequest.Id
        );
        insert emi;
    }

    @isTest
    static void testUpdateWorkOrders() {
        // 기존 Maintenance Request를 가져옵니다.
        Case maintenanceRequest = [SELECT Id, Status FROM Case LIMIT 1];
        
        // Maintenance Request를 닫습니다.
        Test.startTest();
        maintenanceRequest.Status = 'Closed';
        update maintenanceRequest;
        Test.stopTest();
        
        // 새로운 Maintenance Request가 생성되었는지 확인합니다.
        List<Case> newCases = [SELECT Id, Type, Status, Vehicle__c, Date_Due__c FROM Case WHERE Id != :maintenanceRequest.Id];
        System.assertEquals(1, newCases.size(), 'A new maintenance request should be created');
        
        Case newCase = newCases[0];
        System.assertEquals('Routine Maintenance', newCase.Type, 'The new case should be of type Routine Maintenance');
        System.assertEquals('New', newCase.Status, 'The new case should have a status of New');
        System.assertEquals(maintenanceRequest.Vehicle__c, newCase.Vehicle__c, 'The new case should be associated with the same vehicle');
        System.assertNotEquals(null, newCase.Date_Due__c, 'The new case should have a due date');
        
        // 새로운 Equipment Maintenance Item이 생성되었는지 확인합니다.
        List<Equipment_Maintenance_Item__c> newEMIs = [SELECT Id, Maintenance_Request__c, Equipment__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c = :newCase.Id];
        System.assertEquals(1, newEMIs.size(), 'A new Equipment Maintenance Item should be created');
    }
    
    @isTest
    static void testNoUpdateForNonMaintenanceRequests() {
        // Maintenance Request가 아닌 Case를 생성합니다.
        Case nonMaintenanceCase = new Case(
            Subject = 'Non-Maintenance Case',
            Type = 'Electrical',
            Status = 'New'
        );
        insert nonMaintenanceCase;
        
        Test.startTest();
        nonMaintenanceCase.Status = 'Closed';
        update nonMaintenanceCase;
        Test.stopTest();
        
        // 새로운 Case가 생성되지 않았는지 확인합니다.
        List<Case> newCases = [SELECT Id FROM Case WHERE Id != :nonMaintenanceCase.Id];
        System.assertEquals(1, newCases.size(), 'No new case should be created for non-maintenance requests');
    }
    
        @isTest
    static void testBulkUpdate() {
        // Product2 레코드 생성
        Product2 equipment = new Product2(
            Name = 'Bulk Test Equipment',
            Maintenance_Cycle__c = 10,
            Replacement_Part__c = true,
            Current_Inventory__c = 100,
            Lifespan_Months__c = 12,
            Cost__c = 100,
            Warehouse_SKU__c = 'BULK-TEST-SKU-001'
        );
        insert equipment;

        // 여러 개의 Maintenance Request를 생성합니다.
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 200; i++) {
            cases.add(new Case(
                Subject = 'Bulk Test ' + i,
                Type = 'Repair',
                Status = 'New'
            ));
        }
        insert cases;

        // Equipment Maintenance Items 생성
        List<Equipment_Maintenance_Item__c> emis = new List<Equipment_Maintenance_Item__c>();
        for (Case c : cases) {
            emis.add(new Equipment_Maintenance_Item__c(
                Equipment__c = equipment.Id,
                Maintenance_Request__c = c.Id
            ));
        }
        insert emis;

        Test.startTest();
        for (Case c : cases) {
            c.Status = 'Closed';
        }
        update cases;
        Test.stopTest();

        // 새로운 Case들이 생성되었는지 확인합니다.
        List<Case> newCases = [SELECT Id FROM Case WHERE Id NOT IN :cases];
        System.assertEquals(200, newCases.size(), '200 new cases should be created for bulk update');
    }
}