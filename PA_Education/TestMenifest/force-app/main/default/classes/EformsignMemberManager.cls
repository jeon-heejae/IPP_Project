/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-05-29     hs.jung          Create
*************************************************************************************/
public with sharing class EformsignMemberManager {

    public abstract class MemberWork extends EformsignTokenizedApiWorkflow {
        protected override EformsignUserInfoProvider.IUserInfoProvider createUserInfo() {
            return new EformsignUserInfoProvider.RepresentativeAdminProvider();
        }
    }

    public class ListGetter extends MemberWork {
        public ListGetter() {}

        protected override HttpResponse sendRequest() {
            Http http = new Http();
            HttpRequest req = this.requestBuilder.getMembersRequest();
            HttpResponse result = http.send(req);

            String responseBody = result.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            if (result.getStatusCode() == 200) {
                this.result = this.result.success(responseMap);
            } else {
                this.result = this.result.failure((String) responseMap.get('ErrorMessage'));
            }

            return result;
        }

        protected override void databaseLogic() {}
    }

    public class Enrollment extends MemberWork {
        String email;
        String name;
        public Enrollment(String email, String name) {
            this.email = email;
            this.name = name;
        }

        protected override HttpResponse sendRequest() {
            Http http = new Http();
            HttpRequest req = this.requestBuilder.getEnrollMemberRequest(this.email, this.name);
            HttpResponse result = http.send(req);

            String responseBody = result.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.debug('responseMap>>');
            System.debug(responseMap);

            String code = (String) responseMap.get('code');
            if (String.isNotEmpty(code) && code == '4000135') {
                this.result = this.result.failure((String) responseMap.get('ErrorMessage'));
            } else {
                this.result = this.result.success(responseMap);
            }

            return result;
        }

        protected override void databaseLogic() {}
    }

    public class Deletion extends MemberWork {
        String email;
        public Deletion(String email) {
            this.email = email;
        }

        protected override HttpResponse sendRequest() {
            Http http = new Http();
            HttpRequest req = this.requestBuilder.getDeleteMemberRequest(this.email);
            System.debug('req>>');
            System.debug(req);
            HttpResponse result = http.send(req);

            String responseBody = result.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.debug('responseMap>>');
            System.debug(responseMap);

            if (result.getStatusCode() == 200) {
                this.result = this.result.success(responseMap);
            } else {
                this.result = this.result.failure((String) responseMap.get('ErrorMessage'));
            }

            return result;
        }

        protected override void databaseLogic() {}
    }

}