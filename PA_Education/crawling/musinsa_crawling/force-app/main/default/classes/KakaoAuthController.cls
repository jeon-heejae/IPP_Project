public with sharing class KakaoAuthController {
    public String authorizationCode { get; set; }
    public String accessToken { get; set; }

    public KakaoAuthController() {
        // URL에서 Authorization Code 추출
        authorizationCode = ApexPages.currentPage().getParameters().get('code');
    }

    public PageReference processAuthorizationCode() {
        if (authorizationCode == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Authorization Code is missing.'));
            return null;
        }

        // Kakao API 호출을 통해 Access Token 교환
        String clientId = 'b01d65589185dedc1c0c56f172202ae0';
        String clientSecret = 'qTPxHb9Gu4OdcxmavhGx3dNpoun6T9Eq';
        String redirectUri = 'https://daeunextier-1f-dev-ed--c.develop.vf.force.com/apex/KakaoRedirectPage'; // 실제 리디렉션 URL 확인

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://kauth.kakao.com/oauth/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('grant_type=authorization_code' +
                    '&client_id=' + clientId +
                    '&client_secret=' + clientSecret +
                    '&redirect_uri=' + EncodingUtil.urlEncode(redirectUri, 'UTF-8') +
                    '&code=' + authorizationCode);

        try {
            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                // Access Token 처리
                Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                // accessToken = (String) response.get('access_token');
                // System.debug('Access Token: ' + accessToken);

                // 저장하거나 이후 작업에 사용
                saveAccessToken(response);
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to fetch access token. HTTP Status: ' + res.getStatusCode()));
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error during token request: ' + e.getMessage()));
        }
        return null;
    }

    private static void saveAccessToken(Map<String,Object> response) {
        try {
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
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error saving access token: ' + e.getMessage()));
        }
    }

    
}