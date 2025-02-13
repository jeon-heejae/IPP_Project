/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-05-21     hs.jung          Create
*************************************************************************************/
public with sharing class EformsignUserInfoProvider {
    public EformsignUserInfoProvider() {}

    /*
    getUserId: 현재 유저의 ID 반환
    getUserEmail: 현재 유저 혹은 대표관리자 Email 반환
    isRepresentativeAdmin: 대표관리자용 정보인지 확인
    */
    public interface IUserInfoProvider {
        Id getCurrentUserId();
        String getUserEmail();
        Boolean isRepresentativeAdmin();
    }

    public abstract class AbstractUserInfoProvider implements IUserInfoProvider {
        public Id getCurrentUserId() {
            return UserInfo.getUserId();
        }
        public abstract String getUserEmail();
        public abstract Boolean isRepresentativeAdmin();
    }

    public class CurrentUserProvider extends AbstractUserInfoProvider {
        public override String getUserEmail() {
            return UserInfo.getUserEmail();
        }

        public override Boolean isRepresentativeAdmin() {
            return false;
        }
    }

    public class RepresentativeAdminProvider extends AbstractUserInfoProvider {
        public override String getUserEmail() {
            return EformsignEnvironment__c.getOrgDefaults().RepresentativeAdminEmail__c;
        }

        public override Boolean isRepresentativeAdmin() {
            return true;
        }
    }
}