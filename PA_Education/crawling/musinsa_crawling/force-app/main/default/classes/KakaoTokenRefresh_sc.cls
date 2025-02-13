public with sharing class KakaoTokenRefresh_sc implements Schedulable{
    public void execute(SchedulableContext sc) {
        // 토큰 만료 확인
        List<Kakao_Token__c> tokens = [
            SELECT Id, Access_Token__c, refresh_token__c, expire_day__c 
            FROM Kakao_Token__c 
            ORDER BY CreatedDate DESC LIMIT 1];

        if (tokens.isEmpty()) {
            System.debug('No tokens found. Please authorize Kakao login.');
            return;
        }

        Kakao_Token__c token = tokens[0];
        DateTime currentDateTime = DateTime.now();

        if (token.expire_day__c < currentDateTime) {
            System.debug('Token expired. Refreshing Access Token...');
            refreshAccessToken(token.Id);
        } else {
            System.debug('Token is still valid.');
        }
    }

    @future(callout=true)
    private static void refreshAccessToken(Id tokenId) { //future method는 기본타입만 매개변수로 전달 가능
        // 레코드 다시 쿼리
        Kakao_Token__c token = [
            SELECT Id, Access_Token__c, refresh_token__c, expire_day__c 
            FROM Kakao_Token__c 
            WHERE Id = :tokenId
            LIMIT 1
        ];
        String clientId = 'b01d65589185dedc1c0c56f172202ae0';
        String clientSecret = 'qTPxHb9Gu4OdcxmavhGx3dNpoun6T9Eq';

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://kauth.kakao.com/oauth/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('grant_type=refresh_token' +
                    '&client_id=' + clientId +
                    '&client_secret=' + clientSecret +
                    '&refresh_token=' + token.refresh_token__c);

        try {
            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                insertToken(response);
                System.debug('Access Token refreshed successfully.');
            } else {
                System.debug('Failed to refresh Access Token. HTTP Status: ' + res.getStatusCode());
                System.debug('Response Body: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Error during token refresh: ' + e.getMessage());
        }
    }

    private static void insertToken(Map<String, Object> response) {

        Kakao_Token__c objToken = new Kakao_Token__c();
        objToken.Access_Token__c = (String) response.get('access_token');

        DateTime today=DateTime.now();
        objToken.Name = today.addHours(-3) + '_Access Token';
            
        if (response.containsKey('expires_in')) {
            objToken.expires_sec__c = (Integer) response.get('expires_in');
        }
        if (response.containsKey('refresh_token')) {
            objToken.refresh_token__c = (String) response.get('refresh_token');
            objToken.refresh_token_expires_sec__c=(Integer) response.get('refresh_token_expires_in');
        }

        insert objToken;
    }
}