/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-05-28     hs.jung          Create
*************************************************************************************/
public with sharing class EformsignApiEnvironmentManager {
    public class EmbadingEnvInfoWrapper {
        @AuraEnabled public String apiBaseUrl;
        @AuraEnabled public String companyId;
        @AuraEnabled public String countryCode;
        @AuraEnabled public String languageCode;
        public EmbadingEnvInfoWrapper(EformsignEnvironment__c envInfo) {
            System.debug('envInfo >>> ' + envInfo);
            apiBaseUrl = envInfo.ApiBaseUrl__c;
            companyId = envInfo.CompanyId__c;
            countryCode = extractCountryCode(envInfo.ApiBaseUrl__c);
            languageCode = UserInfo.getLanguage().substring(0, 2);
        }

        public String extractCountryCode(String url) {
            // 정규식 패턴
            Pattern p = Pattern.compile('https://(.*?)-api\\.eformsign\\.com');
            Matcher m = p.matcher(url);

            // 정규식 패턴과 일치하는지 확인
            if (m.find()) {
                return m.group(1); // 첫 번째 그룹(.*? 부분)을 반환합니다.
            } else {
                return null;
            }
        }
    }

    public static String getEmbadingEnvInfoJson() {
        return JSON.serialize(getEmbadingEnvInfo());
    }

    public static EmbadingEnvInfoWrapper getEmbadingEnvInfo() {
        EformsignEnvironment__c defaultConfig = EformsignEnvironment__c.getOrgDefaults(); // Method does not exist or incorrect signature: getOrgDefaults from the type EformsignEnvironment__c
        EmbadingEnvInfoWrapper embadingEnvInfoWrapper = new EmbadingEnvInfoWrapper(defaultConfig);

        return embadingEnvInfoWrapper;
    }

    public static EformsignEnvironment__c getInfo() {
        EformsignEnvironment__c defaultConfig = EformsignEnvironment__c.getOrgDefaults();

        return defaultConfig;
    }

    public class NoInfoException extends Exception {}
    public static void saveEnvironmentInfo(
            String apiKey
            , String privateKey
            , String companyId
            , String adminEmail
    ) {

        EformsignEnvironment__c defaultConfig = new EformsignEnvironment__c();
        defaultConfig.ApiKey__c = apiKey;
        defaultConfig.Privatekey__c = privateKey;
        defaultConfig.CompanyId__c = companyId;
        defaultConfig.RepresentativeAdminEmail__c = adminEmail;

        EformsignEnvironment__c existConfig = getInfo();
        if(existConfig != null) {
            defaultConfig.Id = existConfig.Id;
        }

        upsert defaultConfig;
    }

    public static void updateBaseUrl(HttpResponse tokenResponse) {
        String responseBody = tokenResponse.getBody();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        Map<String, Object> apiKeyMap = (Map<String, Object>) responseMap.get('api_key');
        Map<String, Object> companyMap = (Map<String, Object>) apiKeyMap.get('company');
        String apiBaseUrl = (String) companyMap.get('api_url');

        EformsignEnvironment__c defaultConfig = getInfo();
        if (defaultConfig.ApiBaseUrl__c == apiBaseUrl) {
            return;
        }

        updateBaseUrl(apiBaseUrl);
    }

    public static void updateBaseUrl(String apiBaseUrl) {
        Boolean isSuccess = true;
        // 기본 조직 수준 값 가져오기
        EformsignEnvironment__c defaultConfig = getInfo();

        if(defaultConfig == null) {
            throw new NoInfoException();
        }

        defaultConfig.ApiBaseUrl__c = apiBaseUrl;
        upsert defaultConfig;

        // WithoutSharing withoutSharing = new WithoutSharing();
        // withoutSharing.upsertEformsignEnvironment(defaultConfig);
    }

    // without sharing을 사용한 내부 클래스
    // private without sharing class WithoutSharing {
    //     public void upsertEformsignEnvironment(EformsignEnvironment__c defaultConfig) {
    //         upsert defaultConfig;
    //     }
    // }
}