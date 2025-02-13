/**
 * =============================================
 * File Name    : RenewalHPClassInformation.cls
 * Author       : Chan Kang
 * Group        : Boundary
 * Date         : 2021. 12. 24
 * Description  : 교육 커리큘럼 찾기, 생성
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2021. 12. 24    Chan Kang           Create
   1.1      2022. 04. 15    Gunwoo Kim          Use optimized query constructor
                                                Add query to fetch data in English
*/

public without sharing class RenewalHPClassInformation {
    @AuraEnabled
    public static List<Class__c> getClassInformation(Boolean isEnglish) {
//        List<Class__c> classInformation = [
//            SELECT Id, Subject__c, Type__c, Target__c, StartDate__c, EndDate__c, Tuition__c, Times__c, ClassName__c
//            FROM Class__c
//            WHERE OrderNum__c != NULL AND OrderNum__c != 0
//            ORDER BY OrderNum__c ASC
//            LIMIT 9
//        ];
//        return classInformation;
        String body = isEnglish
                ? 'Id, SubjectEng__c, Type__c, Target__c, StartDate__c, EndDate__c, Tuition__c, Times__c, ClassNameEng__c'
                : 'Id, Subject__c, Type__c, Target__c, StartDate__c, EndDate__c, Tuition__c, Times__c, ClassName__c';
        String tail = 'Class__c WHERE OrderNum__c != NULL AND OrderNum__c != 0 ORDER BY OrderNum__c ASC LIMIT 9';
        return Database.query(RenewalHPUtility.queryConstructor(body, tail));
    }


    @AuraEnabled
    public static List<Class__c> loadMoreClasses(Boolean isEnglish) {
//        List<Class__c> classInformation = [
//                SELECT Id, Subject__c, Type__c, Target__c, StartDate__c, EndDate__c, Tuition__c, Times__c, ClassName__c
//                FROM Class__c
//                ORDER BY Id DESC
//        ];
        String body = isEnglish
                ? 'Id, SubjectEng__c, Type__c, Target__c, StartDate__c, EndDate__c, Tuition__c, Times__c, ClassNameEng__c'
                : 'Id, Subject__c, Type__c, Target__c, StartDate__c, EndDate__c, Tuition__c, Times__c, ClassName__c';
        String tail = 'Class__c ORDER BY Id DESC';
        return Database.query(RenewalHPUtility.queryConstructor(body, tail));
//        return classInformation;
    }

    @AuraEnabled
    public static String doSaveApplyTo(Map<String, Object> paramMap,String fileName, String base64Data, String contentType){
        String Mobile = String.valueOf(paramMap.get('Mobile'));
        String Register = String.valueOf(paramMap.get('Register'));
        String ClassId = String.valueOf(paramMap.get('ClassId'));
        String BirthDate = String.valueOf(paramMap.get('BirthDate'));

        Registration__c objRegistration = new Registration__c();

        objRegistration.Mobile__c = Mobile;
        objRegistration.Register__c = Register;
        objRegistration.Class__c = ClassId;
        objRegistration.Birthdate__c = Date.valueOf(BirthDate);
        objRegistration.PersonalInformationUseAgreement__c = true;

        insert objRegistration;

        return '0';
    }
}