public with sharing class request_naver {
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> searchBlog(String query) {
        String clientId = 'gK0pRWlP0W9ZqheiIdah'; // 네이버 애플리케이션 클라이언트 아이디
        String clientSecret = 'em3MQkSUzc'; // 네이버 애플리케이션 클라이언트 시크릿
        Map<String, Object> mapResult=new Map<String,Object>();
        List<Object> listMapResult=new List<Object>();
        List<Map<String, String>> results = new List<Map<String, String>>(); //최종종결과 담을 컬렉션


        // URL 인코딩
        String encodedQuery = EncodingUtil.urlEncode(query, 'UTF-8');
        String apiUrl = 'https://openapi.naver.com/v1/search/shop.json?query=' + encodedQuery+ '&sort=sim';
        System.debug('apiUrl: '+apiUrl);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiUrl);
        request.setMethod('GET');
        request.setHeader('X-Naver-Client-Id', clientId);
        request.setHeader('X-Naver-Client-Secret', clientSecret);

        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                //System.debug('response.getBody: '+response.getBody());
                
            // JSON 응답 처리
            mapResult = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> items = (List<Object>) mapResult.get('items');

            if (items == null || items.isEmpty()) {
                throw new CalloutException('No items found in the API response.');
            }
                Map<String, String> extractedData = new Map<String, String>();
                ////최저가 하나만 담으려면
                // List<Object> items = (List<Object>) mapResult.get('items');
                // Map<String,Object> mapItem=(Map<String,Object>) items[0];


                // Map<String, String> extractedData = new Map<String, String>();
                // // Extract the lowest price,title,link
                // extractedData.put('lprice', (String) mapItem.get('lprice'));

                // String title = (String) mapItem.get('title');
                // title = title.replace('<b>', '').replace('</b>', '');
                // extractedData.put('title', title);

                // extractedData.put('link', (String) mapItem.get('link'));

                // results.add(extractedData);

                //가격 비교후 최저가 담기기
 
                 String strLprice = '';
                 String strTitle = '';
                 String strLink = '';
                 Integer intLprice = 99999999; // 초기값 설정
 
                 for (Object obj : items) {
                     Map<String, Object> mapItem = (Map<String, Object>) obj;
                     Integer itemLprice = Integer.valueOf((String) mapItem.get('lprice')); // 가격 변환
 
                     if (itemLprice < intLprice) {
                         intLprice = itemLprice;
                         strLprice = String.valueOf(itemLprice);
                         strTitle = (String) mapItem.get('title');
                         strLink = (String) mapItem.get('link');
                     }
                 }
 
                // Extract the lowest price,title,link
                extractedData.put('lprice', strLprice);

                String title = strTitle.replace('<b>', '').replace('</b>', '');
                extractedData.put('title', title);

                extractedData.put('link', strLink);

                results.add(extractedData);
                System.debug('results: '+results);
                return results;
                
            } else {
                //System.debug('Error: '+response.getStatus());
                throw new CalloutException('Failed to fetch data. HTTP Status: ' + response.getStatusCode());
            }
        } catch (Exception e) {
            //System.debug('Exception: '+e.getMessage());
            throw new CalloutException('Error during API call: ' + e.getMessage());
        }
    }

    
}