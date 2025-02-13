/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-05-28     hs.jung          Create
   1.0      2024-07-02     hs.jung          Modified   템플릿 dml 바꿈
*************************************************************************************/
public with sharing class EformsignTemplateManager {

    public abstract class TemplateWork extends EformsignTokenizedApiWorkflow {
        protected override EformsignUserInfoProvider.IUserInfoProvider createUserInfo() {
            return new EformsignUserInfoProvider.RepresentativeAdminProvider();
        }
    }

    public class Deletion extends TemplateWork {
        private final String templateId;

        public Deletion(String templateId) {
            System.debug(' templateId>> ' + templateId);
            this.templateId = templateId;
        }

        @TestVisible
        protected override HttpResponse sendRequest() {
            Http http = new Http();

            HttpRequest req = this.requestBuilder.getTemplateDeleteRequest(this.templateId);
            System.debug(req.getEndpoint());
            HttpResponse result = http.send(req);
            System.debug(result);
            System.debug(result.getStatusCode());

            /*
                - 성공 시
                {
                    "code": "-1",
                    "message": "Completed.",
                    "status": "200"
                }
                - 실패 시
                {
                    "code": "4030009",
                    "ErrorMessage": "You do not have access."
                }
                {
                    "code": "4000046",
                    "ErrorMessage": "There is no template."
                }
            */
            String responseBody = result.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            String code = (String) responseMap.get('code');
            String message = (String) responseMap.get('message');
            String status = (String) responseMap.get('status');
            String ErrorMessage = (String) responseMap.get('ErrorMessage');

            System.debug('code: ' + code);
            System.debug('message: ' + message);
            System.debug('status: ' + status);
            System.debug('ErrorMessage: ' + ErrorMessage);

            if (code != '-1') {

            }

            return result;
        }

        @TestVisible
        protected override void databaseLogic() {
            List<EformsignTemplate__c> templates = [
                    SELECT Id
                    FROM EformsignTemplate__c
                    WHERE TemplateId__c = :this.templateId  // Unique로 하나만 존재
            ];

//            if (!templates.isEmpty()) {
//                templates[0].IsDeletedInEformsign__c = true;
//                templates[0].DeployedTemplateVersion__c = null;
//                update templates[0];
//            }
            if (!templates.isEmpty()) {
                delete templates[0];
            }
        }
    }
}