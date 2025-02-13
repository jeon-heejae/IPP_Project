/**
 * =============================================
 * File Name    : RenewalHPDaeuTrekRecord.cls
 * Author       : Chan Kang
 * Group        : Boundary
 * Date         : 2021. 12. 24
 * Description  : Trek Record 정보 찾기
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2021. 12. 24    Chan Kang           Create
   1.1      2022. 04. 15    Myeonghwan Kim      Use optimized query constructor
                                                Add query to fetch data in English
*/


public without sharing class RenewalHPDaeuTrekRecord {
//    @AuraEnabled
//    public static List<TrekRecord__c> doSearchTrekRecords() {
//        List<TrekRecord__c> listTrekRecords = [
//            SELECT Id, Account__r.Name, OrderNum__c, StartYear__c, ProjectName__c
//            FROM TrekRecord__c
//            WHERE HPCheckBox__c = true AND OrderNum__c != NULL
//            ORDER BY OrderNum__c ASC
//            LIMIT 9
//        ];
//
//        return listTrekRecords;
//    }

    @AuraEnabled
    public static List<TrekRecord__c> doSearchTrekRecords(Boolean isEnglish) {
//        Original Function
//        List<TrekRecord__c> listTrekRecords = [
//                SELECT
//                FROM TrekRecord__c
//                WHERE HPCheckBox__c = true AND OrderNum__c != NULL
//                ORDER BY OrderNum__c ASC
//                LIMIT 9
//        ];
        String body = isEnglish
                ? 'Id, Account__r.NameEng__c, OrderNum__c, StartYear__c, ProjectNameEng__c'
                : 'Id, Account__r.Name, OrderNum__c, StartYear__c, ProjectName__c';
        String tail = 'TrekRecord__c WHERE HPCheckBox__c = true AND OrderNum__c != NULL ORDER BY OrderNum__c ASC LIMIT 9';
        return Database.query(RenewalHPUtility.queryConstructor(body, tail));
    }

    @AuraEnabled
    public static List<TrekRecord__c> loadMoreTrekRecords(Boolean isEnglish) {
//        List<TrekRecord__c> listTrekRecords = [
//                SELECT Id, Account__r.Name, OrderNum__c, StartYear__c, ProjectName__c
//                FROM TrekRecord__c
//                WHERE HPCheckBox__c = true
//                ORDER BY OrderNum__c DESC
//        ];
        String body = isEnglish
            ? 'Id, Account__r.NameEng__c, OrderNum__c, StartYear__c, ProjectNameEng__c'
            : 'Id, Account__r.Name, OrderNum__c, StartYear__c, ProjectName__c';
        String tail = 'TrekRecord__c WHERE HPCheckBox__c = true ORDER BY OrderNum__c DESC';
        return Database.query(RenewalHPUtility.queryConstructor(body, tail));
    }

    @AuraEnabled
    public static TrekRecord__c getRecordById(String recordId, Boolean isEnglish) {
        TrekRecord__c trekRecord = new TrekRecord__c();
        if (isEnglish) {
            trekRecord = [SELECT Id, Account__r.NameEng__c, OrderNum__c, StartYear__c, OurApproachEng__c, ChallengeEng__c, ProjectNameEng__c FROM TrekRecord__c WHERE Id = :recordId];
        } else {
            trekRecord = [SELECT Id, Account__r.Name, OrderNum__c, StartYear__c, OurApproach__c, Challenge__c, ProjectName__c FROM TrekRecord__c WHERE Id = :recordId];
        }

//        TrekRecord__c trekRecord = [
//                SELECT Id, Account__r.Name, OrderNum__c, StartYear__c, OurApproach__c, Challenge__c, ProjectName__c
//                FROM TrekRecord__c
//                WHERE Id = :recordId
//        ];

        return trekRecord;
    }
}