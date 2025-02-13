/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-05-27     hs.jung          Create
*************************************************************************************/
public with sharing class EformsignTokenManager {
    private EformsignUserInfoProvider.IUserInfoProvider user;

    public EformsignTokenManager(EformsignUserInfoProvider.IUserInfoProvider user) {
        this.user = user;
    }

    public EformsignTokenManager() {
        this.user = new EformsignUserInfoProvider.CurrentUserProvider();
        System.debug(' user>>> ' + user);
    }

    public class MyCustomException extends Exception {
    }

    // visualforce page Ctrl에서 Token JSON으로 취득
    public String getAccessTokenForEmbeddeingJson() {
        EformsignToken__c accessToken = getUpsertAccessTokenSObject();
        System.debug('JSON.serialize(accessToken) > ' + JSON.serialize(accessToken));
        return JSON.serialize(accessToken);
    }

    // 최신 토근 취득 혹은 생성 (DB저장 있음)
    public EformsignToken__c getUpsertAccessTokenSObject() {
        EformsignToken__c recentToken = getRecentAccessToken();
        System.debug('1 최신 토근  recentToken ' + recentToken);
        if (recentToken != null && recentToken.IsUsableF__c) {
            return recentToken;
        }

        EformsignToken__c newToken = getAccessTokenSObject();
        EformsignTokenManager.upsertToken(JSON.serialize(newToken));
        System.debug('최신 토근 취득 혹은 생성 (DB저장 있음) : ' + newToken);
        return newToken;
    }

    // 최신 토근 취득 혹은 생성 (DB저장 없음)
    public EformsignToken__c getAccessTokenSObject() {
        System.debug( '최신 토근 취득 혹은 생성 (DB저장 없음) ');
        // 최근에 발급된 유효한 토큰이 있는지 확인
        EformsignToken__c recentToken = getRecentAccessToken();
        System.debug( 'recentToken >>> ' + recentToken);
        if (recentToken != null && recentToken.IsUsableF__c) {
            return recentToken;
        }

        HttpResponse tokenResponse = null;
        if (recentToken == null || !recentToken.IsRefreshableF__c) {
            // 토큰 신규 발급
            tokenResponse = requestNewToken();


        } else {
            // 토큰 갱신
            tokenResponse = requestRefreshToken(recentToken.RefreshToken__c, recentToken.AccessToken__c);
        }

        String responseBody = tokenResponse.getBody();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        String code = (String) responseMap.get('code');
        System.debug(responseBody);
        System.debug(code);

        // eformsign에 등록되지 않은 이메일
        if (code == '4000150') {
            //{"code":"4000150","ErrorMessage":"The account does not exist."}
            throw new MyCustomException('eformsign에 등록되지 않은 이메일입니다.');
        } else if (code == '4000074') {
            //{"code":"4000074","ErrorMessage":"No such member."}
            throw new MyCustomException('등록되지 않은 멤버입니다.');
        }

        EformsignToken__c newToken = convertToTokenObject(tokenResponse);
        if (recentToken != null) {
            newToken.Id = recentToken.Id;
        }
        return newToken;
    }

    private EformsignToken__c getRecentAccessToken() {
        System.debug('this.user.getCurrentUserId() >> ' + this.user.getCurrentUserId());
        System.debug(' user.isRepresentativeAdmin() >> ' + this.user.isRepresentativeAdmin());
        List<EformsignToken__c> tokens = [
                SELECT Id
                        , AccessToken__c
                        , RefreshToken__c
                        , IsUsableF__c
                        , IsRefreshableF__c
                        , IsRepresentativeAdminToken__c
                FROM EformsignToken__c
                WHERE
                        User__c = :this.user.getCurrentUserId()  // ToDo: User 분리
                // AND IsRepresentativeAdminToken__c = :this.user.isRepresentativeAdmin() 무슨 기능?
                ORDER BY CreatedDate DESC
                LIMIT 1
        ];
        System.debug(' tokens >> ' + tokens);
        if (tokens.isEmpty()) {
            return null;
        }

        return tokens[0];
    }

    @Future(Callout=true)
    public static void upsertToken(String serializedToken) {//Primitive type parameter required
        System.debug(' serializedToken >>> ' + serializedToken);
        EformsignToken__c efsToken = (EformsignToken__c) JSON.deserializeStrict(serializedToken, EformsignToken__c.class);
        upsert efsToken;
    }

    //Response를 EformsignToken__c에 매핑만 담당
    private EformsignToken__c convertToTokenObject(HttpResponse tokenResponse) {
        /**
         * New Token body
         * {
                "api_key": {
                    "name": "salesforce",
                    "alias": "app",
                    "company": {
                        "company_id": "f752333198f24c46ae2085e04169da1a",
                        "name": "메가존클라우드",
                        "api_url": "https://kr-api.eformsign.com"
                    }
                },
                "oauth_token": {
                    "expires_in": 3600,
                    "token_type": "JWT",
                    "refresh_token": "aaa",
                    "access_token": "aaaY"
                }
            }
         */
        /**
         * refresh Token body
            "oauth_token": {
                    "expires_in": 3600,
                    "token_type": "JWT",
                    "refresh_token": "aaa",
                    "access_token": "aaak"
                }
            }
         */
        String responseBody = tokenResponse.getBody();
        System.debug('responseBody:::: ' + responseBody);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        Map<String, Object> oauthTokenMap = (Map<String, Object>) responseMap.get('oauth_token');

        String accessToken = (String) oauthTokenMap.get('access_token');
        String refreshToken = (String) oauthTokenMap.get('refresh_token');
        Integer expiresIn = (Integer) oauthTokenMap.get('expires_in');
        System.debug(' accessToken >>>>> ' + accessToken);
        if (String.isEmpty(accessToken)) {
            throw new MyCustomException('Access token 값이 없습니다.');
        } else if (String.isEmpty(refreshToken)) {
            throw new MyCustomException('Refresh token 값이 없습니다.');
        } else if (expiresIn == null) {
            throw new MyCustomException('Expires in 값이 없습니다.');
        }
        EformsignToken__c token = new EformsignToken__c(
                AccessToken__c = accessToken
                , RefreshToken__c = refreshToken
                , ExpireIn__c = expiresIn
                , User__c = this.user.getCurrentUserId()  // ToDo: User 분리
                , IsRepresentativeAdminToken__c = this.user.isRepresentativeAdmin()
                , TokenIssuedDateTime__c = System.Now()
        );

        return token;
    }

    public HttpResponse requestNewToken() {
        HttpRequest req = getAccessTokenRequest();
        //HttpResponse try Catch절 내로
        HttpResponse result = null;
        Http http = new Http();
        result = http.send(req);
        System.debug('HttpResponse result  >>>> ' + result.getBody());

        System.debug( 'isRepresentativeAdmin(): ' + this.user.isRepresentativeAdmin());
        // 임시코드 =====================================
//        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(result.getBody());
//        Map<String, Object> oauthTokenMap = (Map<String, Object>) responseMap.get('oauth_token');
//        String accessToken = (String) oauthTokenMap.get('access_token');
//        String refreshToken = (String) oauthTokenMap.get('refresh_token');
//        Integer expiresIn = (Integer) oauthTokenMap.get('expires_in');
//        EformsignToken__c token = new EformsignToken__c(
//                AccessToken__c = accessToken
//                , RefreshToken__c = refreshToken
//                , ExpireIn__c = expiresIn
//                , User__c = this.user.getCurrentUserId()  // ToDo: User 분리
//                , IsRepresentativeAdminToken__c = this.user.isRepresentativeAdmin()
//                , TokenIssuedDateTime__c = System.Now()
//        );
//        upsert token;
        // 임시코드 =====================================
        return result;
    }

    private HttpResponse requestRefreshToken(String refreshToken, String accessToken) {
        HttpResponse result = new HttpResponse();
        HttpRequest req = getRefreshTokenRequest(refreshToken, accessToken);

        Http http = new Http();
        result = http.send(req);
        String responseBody = result.getBody();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        String code = (String) responseMap.get('code');
        System.debug(responseBody);
        System.debug(code);

        // eformsign 시스템 업데이트 등으로 토큰 재발급
        if (String.isNotEmpty(code) && code == '4010002') {
            System.debug('eformsign 시스템 업데이트 등으로 토큰 재발급');
            result = requestNewToken();
        }
        System.debug(result);

        return result;
    }

    private final String ENDPOINT_TOKEN_CREATE = 'https://api.eformsign.com/v2.0/api_auth/access_token';
    private final String POST_METHOD = 'POST';

    private HttpRequest getAccessTokenRequest() {
        EformsignEnvironment__c defaultConfig = EformsignApiEnvironmentManager.getInfo();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT_TOKEN_CREATE);
        req.setMethod(POST_METHOD);
        req.setHeader('eformsign_signature', 'Bearer ' + defaultConfig.Privatekey__c);
        req.setHeader('Content-Type', 'application/json');
        Blob apiKeyBlob = Blob.valueOf(defaultConfig.ApiKey__c);
        req.setHeader('Authorization', 'Bearer ' + EncodingUtil.base64Encode(apiKeyBlob));
        System.debug(' req  eformsign_signature :: ' + req.getHeader('eformsign_signature'));
        System.debug(' req  Authorization :: ' + req.getHeader('Authorization'));
        // JSON 본문 생성
        Map<String, Object> requestBody = new Map<String, Object>{
                'execution_time' => DateTime.now().getTime(),
                'member_id' => this.user.getUserEmail()  // ToDo: User 분리
        };
        req.setBody(JSON.serialize(requestBody));
        System.debug(' req:: ' + req);
        return req;
    }

    private HttpRequest getRefreshTokenRequest(String refreshToken, String accessToken) {
        EformsignEnvironment__c defaultConfig = EformsignApiEnvironmentManager.getInfo();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(defaultConfig.ApiBaseUrl__c + '/v2.0/api_auth/refresh_token?refresh_token=' + refreshToken);
        req.setMethod(POST_METHOD);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);

        return req;
    }
}