/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-05-28     hs.jung          Create
*************************************************************************************/
public with sharing class EformsignApiRequestBuilder {
    private final String GET_METHOD = 'GET';
    private final String POST_METHOD = 'POST';
    private final String DELETE_METHOD = 'DELETE';

    private String accessToken;
    private EformsignEnvironment__c defaultConfig;

    public EformsignApiRequestBuilder(String accessToken) {
        this.accessToken = accessToken;
        this.defaultConfig = EformsignApiEnvironmentManager.getInfo();
    }

    private HttpRequest createDefaultRequest() {
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + this.accessToken);

        return req;
    }

    public HttpRequest getDocumentInfoRequest(String documentId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(
                this.defaultConfig.ApiBaseUrl__c
                        + '/v2.0/api/documents/' + documentId
                        + '?include_fields=true&include_histories=true'
        );
        req.setMethod(GET_METHOD);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + this.accessToken);

        return req;
    }

    public HttpRequest getDocumentDownloadRequest(String documentId, String fileName, Boolean hasAuthFile) {
        HttpRequest req = new HttpRequest();

        String fileType = 'document';
        if(hasAuthFile){
            fileType += ',audit_trail';
        }

        req.setEndpoint(
                this.defaultConfig.ApiBaseUrl__c
                        + '/v2.0/api/documents/' + documentId
                        + '/download_files?file_type=' + fileType
                        + '&file_name=' + EncodingUtil.urlEncode(fileName,'UTF-8')
        );
        req.setMethod(GET_METHOD);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + this.accessToken);

        return req;
    }

    public HttpRequest getDocumentDeleteRequest() {
        HttpRequest req = createDefaultRequest();
        req.setMethod(DELETE_METHOD);
        req.setEndpoint(
                this.defaultConfig.ApiBaseUrl__c
                        + '/v2.0/api/documents'
        );

        return req;
    }

    public HttpRequest getDocumentCancelRequest() {
        HttpRequest req = createDefaultRequest();
        req.setMethod(POST_METHOD);
        req.setEndpoint(
                this.defaultConfig.ApiBaseUrl__c
                        + '/v2.0/api/documents/cancel'
        );

        return req;
    }

    public HttpRequest getMembersRequest() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(this.defaultConfig.ApiBaseUrl__c + '/v2.0/api/members');
        req.setMethod(GET_METHOD);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + this.accessToken);

        return req;
    }

    public HttpRequest getEnrollMemberRequest(String email, String name) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(this.defaultConfig.ApiBaseUrl__c + '/v2.0/api/members');
        req.setMethod(POST_METHOD);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + this.accessToken);

        // JSON 데이터 생성
        String jsonData = '{"account": {'
                + '"id": "' + email + '"'
                + ',"password": "' + EformsignUtils.generateRandomPassword(20) + '"'
                + ',"name": "' + name + '"'
                + ',"enabled": true'
                + '}}';

        System.debug('jsonData>>');
        System.debug(jsonData);

        req.setBody(jsonData);

        return req;
    }

    public HttpRequest getDeleteMemberRequest(String email) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(this.defaultConfig.ApiBaseUrl__c + '/v2.0/api/members/' + email);
        req.setMethod(DELETE_METHOD);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + this.accessToken);

        return req;
    }

    //월별 이용 통계
    public HttpRequest getCurrentStatus() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(this.defaultConfig.ApiBaseUrl__c + '/v2.0/api/companies/' +
                this.defaultConfig.CompanyId__c + '/use_status?term=monthly&date=' +
                String.valueOf(Date.today().year()) +
                String.valueOf(Date.today().month()));
        System.debug(req.getEndpoint());
        req.setMethod(GET_METHOD);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + this.accessToken);

        return req;
    }

    public HttpRequest getTemplateDeleteRequest(String templateId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(
                this.defaultConfig.ApiBaseUrl__c
                        + '/v2.0/api/forms/' + templateId
        );
        req.setMethod(DELETE_METHOD);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + this.accessToken);

        return req;
    }
}