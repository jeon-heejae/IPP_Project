public with sharing class AddressSearchController {
    @AuraEnabled
    public static Map<String, String> getAddressData(String recordId) {
        Contact contact = [SELECT Id, PostalCode__c, RoadAddress__c, DetailAddress__c FROM Contact WHERE Id = :recordId];
        
        Map<String, String> addressData = new Map<String, String>();
        addressData.put('PostalCode__c', contact.PostalCode__c);
        addressData.put('RoadAddress__c', contact.RoadAddress__c);
        addressData.put('DetailAddress__c', contact.DetailAddress__c);
        
       
        return addressData;
    }
    
    @AuraEnabled
    public static void saveAddressData(String recordId, Map<String, String> addressData) {
        Contact contact = new Contact(
            Id = recordId,
            PostalCode__c= addressData.get('PostalCode__c'),
            RoadAddress__c = addressData.get('RoadAddress__c'),
            DetailAddress__c = addressData.get('DetailAddress__c')
        );
        System.debug(contact.Id);
        System.debug(contact.PostalCode__c);
        System.debug(contact.RoadAddress__c);
        System.debug(contact.DetailAddress__c);
        update contact;
        
    }
    
    @AuraEnabled
    public static String searchAddress(String keyword) {
        // API 키 설정 
        String apiKey = 'devU01TX0FVVEgyMDI0MDgyMjE2NTcyNjExNTAzMDM=';
        
        // API 엔드포인트 URL
        String endpointUrl = 'https://business.juso.go.kr/addrlink/addrLinkApi.do?';
        
        // API 요청 파라미터 설정
        Map<String, String> params = new Map<String, String>();
        
        params.put('currentPage','1');
        params.put('countPerPage','100');
        params.put('keyword',keyword.replaceAll(' ', ''));
        params.put('confmKey',apiKey);
        params.put('resultType','json');
        params.put('firstSort','road');

        for(String key : params.keySet()) {
            endpointUrl += key + '=' + params.get(key)+'&';
        }
        endpointUrl = endpointUrl.removeEnd('&');
        //System.debug(endpointUrl);
        
        // HTTP 요청 생성 및 전송
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response= new HttpResponse();
        
        request.setEndpoint(endpointUrl);
        request.setMethod('GET');
        request.setTimeout(110000);
        response = http.send(request);
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        //System.debug(results);
        // API 응답 처리
    if (response.getStatusCode() == 200) {
        
        Map<String, Object> resultData = (Map<String, Object>) results.get('results');
        List<Object> jusoList = (List<Object>) resultData.get('juso');
        //System.debug(jusoList);
    
        List<Map<String, String>> addressList = new List<Map<String, String>>();
        
        for (Object juso : jusoList) {
            Map<String, Object> jusoMap = (Map<String, Object>) juso;
            Map<String, String> addressMap = new Map<String, String>();
            
            // 도로명 주소와 우편번호, 지번 추출
            addressMap.put('roadAddress', (String)jusoMap.get('roadAddr'));
            addressMap.put('zipCode', (String)jusoMap.get('zipNo'));
            addressMap.put('jibunAddress', (String)jusoMap.get('jibunAddr'));
            //System.debug(addressMap);
            //System.debug(addressMap.get('roadAddress'));
            //System.debug(addressMap.get('zipCode'));
            addressList.add(addressMap);
        }
        System.debug(addressList);
    
        
        return JSON.serialize(addressList);
    }
         else {
            throw new AuraHandledException('주소 검색 중 오류가 발생했습니다. 상태 코드: ' + response.getStatusCode());
        }
    }
}


