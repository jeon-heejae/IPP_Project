/**
 * =============================================
 * File Name    : RenewalHPServiceSolution.cls
 * Author       : Chan Kang
 * Group        : Boundary
 * Date         : 2021. 12. 24
 * Description  : 서비스 솔루션 찾기
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2021. 12. 24    Chan Kang           Create
   1.1      2022. 04. 15    Gunwoo Kim          Use optimized query constructor
                                                Add query to fetch data in English
*/

public without sharing class RenewalHPServiceSolution {
  @AuraEnabled
  public static List<SolutionDelivery__c> getDeliveries(Boolean isEnglish) {
    //        List<SolutionDelivery__c> deliveries = [
    //            SELECT Id, Title__c, Summary__c, Description__c FROM SolutionDelivery__c ORDER BY Id DESC LIMIT 5
    //        ];
    //        return deliveries;

    String body = isEnglish
      ? 'Id, Title__c, SummaryEng__c, DescriptionEng__c, SubTitle__c'
      : 'Id, Title__c, Summary__c, Description__c, SubTitle__c';
    String tail = 'SolutionDelivery__c ORDER BY Name ASC LIMIT 5';
    return Database.query(RenewalHPUtility.queryConstructor(body, tail));
  }

  //    @AuraEnabled
  //    public static List<SolutionDelivery__c> loadMoreDeliveries(Boolean isEnglish) {
  //        List<SolutionDelivery__c> deliveries = [
  //                SELECT Id, Title__c, Description__c, Summary__c FROM SolutionDelivery__c ORDER BY Id DESC
  //        ];
  //        return deliveries;
  //
  //    }

  @AuraEnabled
  public static SolutionDelivery__c getDeliveryById(
    String recordId,
    Boolean isEnglish
  ) {
    SolutionDelivery__c delivery = new SolutionDelivery__c();
    if (isEnglish) {
      delivery = [
        SELECT Id, Title__c, DescriptionEng__c, SummaryEng__c, Subtitle__c
        FROM SolutionDelivery__c
        WHERE Id = :recordId
      ];
    } else {
      delivery = [
        SELECT Id, Title__c, Description__c, Summary__c, Subtitle__c
        FROM SolutionDelivery__c
        WHERE Id = :recordId
      ];
    }

    return delivery;
  }
}