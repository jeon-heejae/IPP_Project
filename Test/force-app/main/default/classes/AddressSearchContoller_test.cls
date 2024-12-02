@IsTest
public with sharing class AddressSearchContoller_test {
    @TestSetup
    static void makeData(){
        Contact contactTest=new Contact();
        
        contactTest.LastName='Test';
        contactTest.PostalCode__c= '10';
        contactTest.RoadAddress__c='Test_add';
        contactTest.DetailAddress__c='Test_Detail';

        insert contactTest;
    }

    @IsTest
    public static void testGetAddressData(){
        Contact testContact=[
            SELECT Id
            FROM Contact
            WHERE LastName='Test'
        ];

        System.Test.startTest();
        Map<String,String> testResult=new Map<String,String>();
        testResult=AddressSearchController.getAddressData(testContact.Id);
        System.Test.stopTest();

        System.assertEquals('10', testResult.get('PostalCode__c'));
        System.assertEquals('Test_add',testResult.get('RoadAddress__c'));
        System.assertEquals('Test_Detail', testResult.get('DetailAddress__c'));
    }

    @IsTest
    public static void testSaveAddressData(){
        Contact testContact=[
            SELECT Id
            FROM Contact
            WHERE LastName='Test'
        ];
        Map<String,String> testInput=new Map<String,String>();
        testInput.put('PostalCode__c','20');
        testInput.put('RoadAddress__c','Test_add_new');
        testInput.put('DetailAddress__c','Test_Detail_new');

        System.Test.startTest();
        AddressSearchController.saveAddressData(testContact.Id, testInput);
        System.Test.stopTest();

        Contact testContactNew=[
            SELECT ID, PostalCode__c,RoadAddress__c,DetailAddress__c
            FROM Contact
            WHERE Id= :testContact.Id
        ];
        System.assertEquals(testContactNew.PostalCode__c,'20');
        System.assertEquals(testContactNew.RoadAddress__c,'Test_add_new');
        System.assertEquals(testContactNew.DetailAddress__c,'Test_Detail_new');
    }

    @IsTest
    public static void testSearchAddress(){
        String keyword='상원12길';
        String mockResponse='{"results":{"common":{"errorMessage":"정상","countPerPage":"100","totalCount":"1","errorCode":"0","currentPage":"1"},"juso":[{"zipNo":"04791","jibunAddr":"서울특별시 성동구 성수동1가 13-277 이노시스빌딩","roadAddr":"서울특별시 성동구 상원12길 1 (성수동1가)"}]}}';
       
        System.Test.setMock(HttpCalloutMock.class, new AddressHttpCalloutMock());
        System.Test.startTest();
        System.debug('test');
        String testResult=AddressSearchController.searchAddress(keyword);
        System.Test.stopTest();
    }


    public class AddressHttpCalloutMock implements HttpCalloutMock {

        String responseBody;

        
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            System.debug(response);
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"results":{"common":{"errorMessage":"정상","countPerPage":"100","totalCount":"1","errorCode":"0","currentPage":"1"},"juso":[{"zipNo":"04791","jibunAddr":"서울특별시 성동구 성수동1가 13-277 이노시스빌딩","roadAddr":"서울특별시 성동구 상원12길 1 (성수동1가)"}]}}');
            response.setStatusCode(200);
            return response;
        }
    }
}