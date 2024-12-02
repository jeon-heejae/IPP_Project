@isTest
private class WarehouseCalloutServiceTest {
    
    @isTest
    static void testRunWarehouseEquipmentSync() {
        // 모의 HTTP 응답 설정
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        
        Test.startTest();
        // queueable 작업 실행
        System.enqueueJob(new WarehouseCalloutService());
        Test.stopTest();
        
        // 결과 검증
        // List<Product2> updatedProducts = [
        //     SELECT Id, Warehouse_SKU__c, Replacement_Part__c, Cost__c, Current_Inventory__c, Lifespan_Months__c, Maintenance_Cycle__c, ProductCode, Name 
        //     FROM Product2];
        
        
        // Product2 product = updatedProducts[0];
        // System.assertEquals('SKU-1234', product.Warehouse_SKU__c);
        // System.assertEquals(true, product.Replacement_Part__c);
        // System.assertEquals(100, product.Cost__c);
        // System.assertEquals(50, product.Current_Inventory__c);
        // System.assertEquals(10, product.Lifespan_Months__c);
        // System.assertEquals(30, product.Maintenance_Cycle__c);
        // System.assertEquals('ID-1234', product.ProductCode);
        // System.assertEquals('Test Product', product.Name);
    }
    
    // HTTP 호출을 모의하는 내부 클래스
    private class WarehouseCalloutServiceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('[{"_id": "ID-1234", "replacement": true, "quantity": 50, "name": "Test Product", "maintenanceperiod": 30, "lifespan": 10, "cost": 100, "sku": "SKU-1234"}]');
            response.setStatusCode(200);
            return response;
        }
    }
    
    @isTest
    static void testGetProductList() {
        // 모의 HTTP 응답 생성
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setBody('[{"_id": "ID-1234", "replacement": true, "quantity": 50, "name": "Test Product", "maintenanceperiod": 30, "lifespan": 10, "cost": 100, "sku": "SKU-1234"}]');
        
        Test.startTest();
        List<Product2> products = WarehouseCalloutService.getProductList(mockResponse);
        Test.stopTest();
        
        // 결과 검증
    
        Product2 product = products[0];
        System.assertEquals('SKU-1234', product.Warehouse_SKU__c);
        System.assertEquals(true, product.Replacement_Part__c);
        System.assertEquals(100, product.Cost__c);
        System.assertEquals(50, product.Current_Inventory__c);
        System.assertEquals(10, product.Lifespan_Months__c);
        System.assertEquals(30, product.Maintenance_Cycle__c);
        System.assertEquals('ID-1234', product.ProductCode);
        System.assertEquals('Test Product', product.Name);
    }
    
    @isTest
    static void testGetResponse() {
        // 모의 HTTP 응답 설정
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        
        Test.startTest();
        HttpResponse response = WarehouseCalloutService.getResponse();
        Test.stopTest();
        
        // 결과 검증
        System.assertEquals(200, response.getStatusCode(), 'Status code should be 200');
        System.assertNotEquals(null, response.getBody(), 'Response body should not be null');
    }
}