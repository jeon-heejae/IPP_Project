/**
 * =============================================
 * File Name    : RenewalHPDaeuPerfomance.cls
 * Author       : Chan Kang
 * Group        : Boundary
 * Date         : 2021. 12. 24
 * Description  : 대유 넥스티어 홈페이지 내 Performance 정보 가져오기
*/


public without sharing class RenewalHPDaeuPerfomance {
    @AuraEnabled
    public static List<Performance__c> getPerformances() {
        List<Performance__c> performances = [
                SELECT Id, fm_Year__c, Sales__c, HeadCount__c
                FROM Performance__c
        ];

        return performances;
    }
}