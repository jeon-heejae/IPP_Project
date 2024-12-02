public with sharing class getNaverNewsCtrl {
    @AuraEnabled
    public static List<Object> webCallout(String keyWord){
        Http            http        = new Http();
        HttpRequest     request     = new HttpRequest();
        HttpResponse    response    = new HttpResponse();

        String CliendId = 'gSSkZ2wZx036fC4QCNIv';
        String ClientSecret = 'jKgzjOnVq4';
        String apiUrl = 'https://openapi.naver.com/v1/search/news.json';
        apiUrl += '?query=' + EncodingUtil.urlEncode(keyWord, 'UTF-8');
        
        request.setMethod('GET');
        request.setEndpoint(apiUrl);
        request.setHeader('X-Naver-Client-Id', CliendId);
        request.setHeader('X-Naver-Client-Secret', ClientSecret);
        response = http.send(request);
        String responseBody = response.getBody();
        // System.debug('responseBody >>' + responseBody);
        Map<String, Object> mapresponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        // System.debug('mapresponse >>' + mapresponse);
        
        List<Object> listNews = (List<Object>)mapresponse.get('items');
        System.debug('listNews >>' + listNews);
        return listNews;

    }
}