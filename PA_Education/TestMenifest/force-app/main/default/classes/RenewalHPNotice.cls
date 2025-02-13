/**
 * =============================================
 * File Name    : RenewalHPJobPositions.cls
 * Author       : Chan Kang
 * Group        : Boundary
 * Date         : 2021. 1. 4
 * Description  : 긴급공지
*/

public without sharing class RenewalHPNotice {
    @AuraEnabled
    public static List<UrgentNotice__c> getUrgentNotice() {
        List<UrgentNotice__c> listUrgentNotice = [
            SELECT Subject__c, Description__c
            FROM UrgentNotice__c
            WHERE StartDate__c <= TODAY AND EndDate__c >= TODAY
        ];
        return listUrgentNotice;
    }
}