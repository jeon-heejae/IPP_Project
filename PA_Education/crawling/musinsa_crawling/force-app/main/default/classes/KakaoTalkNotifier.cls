public with sharing class KakaoTalkNotifier {

    @AuraEnabled
    public static Map<String, String> sendProductInfo(String query) {
        String accessToken = getValidAccessToken();

        // Fetch product information using Naver API
        List<Map<String, String>> productList = request_naver.searchBlog(query);

        if (productList.isEmpty()) {
            throw new CalloutException('No product information found.');
        }

        // Prepare the product info for Kakao message
        Map<String, String> productInfo = productList[0];
        String productTitle = productInfo.get('title');
        String productPrice = productInfo.get('lprice');
        String productLink = productInfo.get('link');
        // 메시지 구성 (개행 문자 제거 및 텍스트 간격 조정)
        String rawMessage = 
            '🔥 상품 정보 🔥\n\n' +
            '📌 상품명: ' + productTitle + '\n' +
            '💰 가격: ' + productPrice + '원\n\n' +
            '상품 상세 정보는 아래 링크에서 확인하세요!\n' +
            productLink;
        

        // Send message and get the response body
        Map<String, String> responseMap = sendMessage(accessToken, rawMessage, productLink);

        saveIFLog(responseMap);
        
        return new Map<String, String>{
            'requestBody' => responseMap.get('requestBody'),
            'responseBody' => responseMap.get('responseBody')
        };
    }

    private static void saveIFLog(Map<String, String> mapResponse){
        String strRequestBody=mapResponse.get('requestBody');
        String strResponseBody=mapResponse.get('responseBody');

        IF_KakaoTalk_log__c objLog=new IF_KakaoTalk_log__c();
        objLog.Request2__c=strRequestBody;
        objLog.Response2__c=strResponseBody;
        objLog.Name=Datetime.now().month() + '_' + Datetime.now().day() + '_' + Datetime.now().hour() + 'log';

        insert objLog;
        
    }
    private static String getValidAccessToken() {
        List<Kakao_Token__c> tokens = [
            SELECT Access_Token__c 
            FROM Kakao_Token__c 
            ORDER BY CreatedDate 
            DESC LIMIT 1];

        if (tokens.isEmpty()) {
            throw new CalloutException('Access Token is not available. Please reauthorize.');
        }
        return tokens[0].Access_Token__c;
        
    }
    

    private static Map<String, String> sendMessage(String accessToken, String message, String linkUrl) {
        String apiUrl = 'https://kapi.kakao.com/v2/api/talk/memo/default/send';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiUrl);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded;charset=utf-8');

        // // URL 인코딩된 템플릿 객체 생성
        // String templateObject = '{"object_type":"text","text":"' + message + '","link":{"web_url":"' + linkUrl + '"}}';
        // String payload = 'template_object=' + EncodingUtil.urlEncode(templateObject, 'UTF-8');
        // payload.replace('\n', '%0A');
        // JSON 객체 생성
        Map<String, Object> templateObject = new Map<String, Object>{
            'object_type' => 'text',
            'text' => message,
            'link' => new Map<String, String>{
                'web_url' => linkUrl,
                'mobile_web_url' => linkUrl
            }
        };

        // JSON 직렬화 후 URL 인코딩
        String encodedTemplateObject = EncodingUtil.urlEncode(JSON.serialize(templateObject), 'UTF-8');

        // 최종 payload 설정
        String payload = 'template_object=' + encodedTemplateObject;
        request.setBody(payload);

        String strDecodePayload='template_object=' + JSON.serialize(templateObject);
        //System.debug(strDecodePayload);
        
        // String encodedString = 'template_object=%7B%22button_title%22%3A%22%EC%83%81%ED%92%88+%EB%B3%B4%EB%9F%AC+%EA%B0%80%EA%B8%B0%22%2C%22link%22%3A%7B%22mobile_web_url%22%3A%22https%3A%2F%2Flink.coupang.com%2Fre%2FPCSNAVERPCSDP%3FpageKey%3D8466310124%26ctag%3D8466310124%26lptag%3DI24496300892%26itemId%3D24496300892%26vendorItemId%3D91509459662%26spec%3D10305199%22%2C%22web_url%22%3A%22https%3A%2F%2Flink.coupang.com%2Fre%2FPCSNAVERPCSDP%3FpageKey%3D8466310124%26ctag%3D8466310124%26lptag%3DI24496300892%26itemId%3D24496300892%26vendorItemId%3D91509459662%26spec%3D10305199%22%7D%2C%22text%22%3A%22%F0%9F%94%A5+%EC%83%81%ED%92%88+%EC%A0%95%EB%B3%B4+%F0%9F%94%A5%5Cn%5Cn%F0%9F%93%8C+%EC%83%81%ED%92%88%EB%AA%85%3A+1%2B1%2B1%2B1%2B1+SW19+%EC%97%90%EC%8A%A4%EB%8D%94%EB%B8%94%EC%9C%A0%EB%82%98%EC%9D%B8%ED%8B%B4+%EB%AF%B8%EB%93%9C%EB%82%98%EC%9E%87+%EC%98%A4+%EB%93%9C+%ED%8D%BC%ED%93%B8+%ED%96%A5%EC%88%98+%EC%83%98%ED%94%8C%EC%A6%9D%EC%A0%95+50ml%5Cn%F0%9F%92%B0+%EA%B0%80%EA%B2%A9%3A+531000%EC%9B%90%5Cn%5Cn%EC%83%81%ED%92%88+%EC%83%81%EC%84%B8+%EC%A0%95%EB%B3%B4%EB%8A%94+%EC%95%84%EB%9E%98+%EB%A7%81%ED%81%AC%EC%97%90%EC%84%9C+%ED%99%95%EC%9D%B8%ED%95%98%EC%84%B8%EC%9A%94%21%22%2C%22object_type%22%3A%22text%22%7D';

        // // URL 디코딩 수행
        // String decodedString = EncodingUtil.urlDecode(encodedString, 'UTF-8');

        // // 결과 디버깅
        // System.debug('Decoded String: ' + decodedString);


        Map<String, String> responseMap = new Map<String, String>();
        responseMap.put('requestBody', strDecodePayload);

        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                responseMap.put('responseBody', response.getBody());
            } else {
                responseMap.put('responseBody', 'Failed to send message. HTTP Status: ' + response.getStatusCode() + ', Response: ' + response.getBody());
            }
        } catch (Exception e) {
            responseMap.put('responseBody', 'Error during message sending: ' + e.getMessage());
        }

        return responseMap;
    }

    @AuraEnabled
    public static Boolean saveKeyword(String strKeyword){ //스케줄 등록 위한 검색어 저장
        Boolean flag=false;

        List<Kakao_Token__c> tokens = [
            SELECT Id, Search_Keyword__c
            FROM Kakao_Token__c 
            ORDER BY CreatedDate DESC LIMIT 1
        ];

        if(!tokens.isEmpty()){
            Kakao_Token__c token=tokens[0];

            token.Search_Keyword__c=strKeyword;
            Database.UpsertResult ur=Database.upsert(token,false);
            
            if(ur.isSuccess()){
                flag=true;
            }
            else{
                flag=false;
            }
        }

        return flag;
    }

}
