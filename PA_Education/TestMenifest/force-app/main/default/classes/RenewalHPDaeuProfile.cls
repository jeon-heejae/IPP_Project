/**
 * =============================================
 * File Name    : RenewalHPDaeuProfile.cls
 * Author       : Chan Kang
 * Group        : Boundary
 * Date         : 2021. 12. 24
 * Description  : 연혁 정보 찾기
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2021. 12. 24    Chan Kang           Create
   1.1      2022. 04. 15    Gyubin Lee          Use optimized query constructor
                                                Add query to fetch data in English
*/


public without sharing class RenewalHPDaeuProfile {
    @AuraEnabled
    public static Map<Decimal, List<CompanyHistory__c>> doSearchCompanyHistory(Boolean isEnglish) {
        //전체 회사 연혁 리스트를 받아온다.
        String body = isEnglish
                ? 'Id,Year__c,Month__c,OrderNum__c,DescriptionEng__c'
                : 'Id,Year__c,Month__c,OrderNum__c,Description__c';
        String tail = 'CompanyHistory__c ORDER BY Year__c DESC, OrderNum__c ASC';
        List<CompanyHistory__c> listCompanyHistories = Database.query(RenewalHPUtility.queryConstructor(body, tail));
        Map<Decimal, List<CompanyHistory__c>> mapCompanyHistoriesByYear = new Map<Decimal, List<CompanyHistory__c>>();

        if(!listCompanyHistories.isEmpty()){
            for(CompanyHistory__c objCompanyHistory : listCompanyHistories){
                if(mapCompanyHistoriesByYear.containsKey(objCompanyHistory.Year__c) && mapCompanyHistoriesByYear.keySet().size() <= 5){
                    mapCompanyHistoriesByYear.get(objCompanyHistory.Year__c).add(objCompanyHistory);
                }else if(!mapCompanyHistoriesByYear.containsKey(objCompanyHistory.Year__c) && mapCompanyHistoriesByYear.keySet().size() < 5){
                    mapCompanyHistoriesByYear.put(objCompanyHistory.Year__c, new List<CompanyHistory__c>());
                    mapCompanyHistoriesByYear.get(objCompanyHistory.Year__c).add(objCompanyHistory);
                }else{
                    break;
                }
            }
        }

        return mapCompanyHistoriesByYear;

        /*
        listCompanyHistories = [
                SELECT Id, Year__c
                FROM   CompanyHistory__c
                ORDER BY Year__c desc ,OrderNum__c desc
        ];
        System.debug('listCompanyHistories>>>>' + listCompanyHistories);

        Decimal testYear = 3000;
        Integer i=0;
        // Record가 있는 회사 연혁 중 5번째 년도 찾기
        for(CompanyHistory__c obj : listCompanyHistories) {
//            System.debug('testYear>>>' + testYear);

            if(obj.Year__c < testYear && i < 5){
                testYear = obj.Year__c;
                System.debug('testYear1>>>' + testYear);
                i++;
            }
        }
        //5개년도의 리스트 새로 뽑기
        List<CompanyHistory__c> listTarget = new List<CompanyHistory__c>();
        listTarget = [
                SELECT   Id,Year__c,Month__c,OrderNum__c,Description__c
                FROM     CompanyHistory__c
                WHERE    Year__c >=: testYear
                ORDER BY Year__c DESC , OrderNum__c DESC
        ];
        System.debug('listTarget>>>>' + listTarget);

        return listTarget;
         */
    }
}