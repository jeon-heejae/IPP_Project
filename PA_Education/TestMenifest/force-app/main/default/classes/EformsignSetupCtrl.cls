/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-05-28     hs.jung          Create
*************************************************************************************/
global with sharing class EformsignSetupCtrl {

    public class NoInfoException extends Exception {}

    @AuraEnabled
    public static EformsignEnvironment__c getEnvironmentInfo() {
        return EformsignApiEnvironmentManager.getInfo();
    }

    @AuraEnabled
    public static void saveEnvironmentInfo(Map<String, String> infos) {

        if (infos.isEmpty()) {
            throw new NoInfoException();
        }

        for (String key : infos.keySet()) {
            if (String.isBlank(infos.get(key))) {
                throw new NoInfoException();
            }
        }

        String apiKey = infos.get('apiKey');
        String privateKey = infos.get('privateKey');
        String companyId = infos.get('companyId');
        String adminEmail = infos.get('adminEmail');
        if (
                String.isBlank(apiKey)
                        || String.isBlank(privateKey)
                        || String.isBlank(companyId)
                        || String.isBlank(adminEmail)
        ) {
            throw new NoInfoException();
        }

        EformsignApiEnvironmentManager.saveEnvironmentInfo(apiKey, privateKey, companyId, adminEmail);
    }

    @AuraEnabled
    public static Boolean checkEnvironmentInfo() {
        EformsignTokenManager tokenManager = new EformsignTokenManager(new EformsignUserInfoProvider.RepresentativeAdminProvider());
        System.debug( 'tokenManager > ' + tokenManager);
        HttpResponse tokenResponse = tokenManager.requestNewToken();
        return (tokenResponse.getStatusCode() == 200);
    }


    private static final Set<String> PERMISSION_SET_NAMES = new Set<String> {'eformsign'};
    @AuraEnabled(cacheable=true)
    public static List<PermissionSet> getPermissionSets() {
        // 권한 집합 ID 조회
        List<PermissionSet> result = [SELECT Id, Label FROM PermissionSet WHERE Name = :PERMISSION_SET_NAMES LIMIT 1];
        if (result.isEmpty()) {
            return null;
        }

        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<PermissionSetAssignment> getUsersAssignedToPermissionSet() {
        List<PermissionSetAssignment> assignments = [
                SELECT Assignee.Id, Assignee.Name, Assignee.Email, PermissionSet.Label
                FROM PermissionSetAssignment
                WHERE PermissionSet.Label IN :PERMISSION_SET_NAMES
                AND Assignee.IsActive = TRUE
        ];
        System.debug(' assignments>> '+ assignments);
        return assignments;
    }

    @AuraEnabled
    public static Object getEfsMembers() {
        EformsignTokenizedApiWorkflow mng = new EformsignMemberManager.ListGetter();
        Object result = mng.execute();

        return result;
    }

    @AuraEnabled
    public static Object enrollEfsMember(String email, String name) {
        EformsignTokenizedApiWorkflow mng = new EformsignMemberManager.Enrollment(email, name);
        Object result = mng.execute();

        return result;
    }

    @AuraEnabled
    public static Object deleteEfsMember(String email) {
        EformsignTokenizedApiWorkflow mng = new EformsignMemberManager.Deletion(email);
        Object result = mng.execute();

        return result;
    }
}