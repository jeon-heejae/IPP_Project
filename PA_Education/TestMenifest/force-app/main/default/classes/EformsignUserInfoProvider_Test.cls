/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-06-27     hs.jung          Create
*************************************************************************************/
@IsTest
private class EformsignUserInfoProvider_Test {

    @IsTest
    static void testCurrentUserProvider() {
        EformsignUserInfoProvider.CurrentUserProvider currentUserProvider = new EformsignUserInfoProvider.CurrentUserProvider();

        Id currentUserId = UserInfo.getUserId();
        System.assertEquals(currentUserId, currentUserProvider.getCurrentUserId(), 'The current user ID should match');

        String currentUserEmail = UserInfo.getUserEmail();
        System.assertEquals(currentUserEmail, currentUserProvider.getUserEmail(), 'The current user email should match');

        System.assertEquals(false, currentUserProvider.isRepresentativeAdmin(), 'The current user should not be a representative admin');
    }

    @IsTest
    static void testRepresentativeAdminProvider() {
        EformsignEnvironment__c orgDefaults = new EformsignEnvironment__c(
                Name = 'TestOrgDefaults',
                RepresentativeAdminEmail__c = 'admin@example.com'
        );
        insert orgDefaults;

        EformsignUserInfoProvider.RepresentativeAdminProvider representativeAdminProvider = new EformsignUserInfoProvider.RepresentativeAdminProvider();

        Id currentUserId = UserInfo.getUserId();
        System.assertEquals(currentUserId, representativeAdminProvider.getCurrentUserId(), 'The current user ID should match');

        String adminEmail = 'admin@example.com';
        System.assertEquals(adminEmail, representativeAdminProvider.getUserEmail(), 'The representative admin email should match');
        System.assertEquals(true, representativeAdminProvider.isRepresentativeAdmin(), 'The representative admin flag should be true');
    }

    @IsTest
    static void testRepresentativeAdminProviderWithoutOrgDefaults() {
        // Ensure there are no EformsignEnvironment__c records
        EformsignEnvironment__c orgDefaults = new EformsignEnvironment__c(
                Name = 'TestOrgDefaults',
                RepresentativeAdminEmail__c = 'admin@example.com'
        );
        insert orgDefaults;
        delete [SELECT Id FROM EformsignEnvironment__c];

        // Create an instance of RepresentativeAdminProvider
        EformsignUserInfoProvider.RepresentativeAdminProvider representativeAdminProvider = new EformsignUserInfoProvider.RepresentativeAdminProvider();

        // Test getUserEmail (should handle the absence of org defaults)
//        try {
//            String adminEmail = representativeAdminProvider.getUserEmail();
//            System.assert(false, 'Expected an exception due to missing org defaults');
//        } catch (Exception e) {
//            System.assert(true, 'Expected exception was thrown');
//        }
    }
}