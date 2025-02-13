/**
 * Created by Kwanwoo.Jeon on 2024-01-04.
 */

public without sharing class CardBillingModalController {
    @AuraEnabled
    public static List<Map<String, Object>> getData(Integer intYear, Integer intMonth, String budgetType, List<Id> listSelected){
        Map<String, List<CorporateCardOwner__c>> mapCardOwnerDate = new Map<String, List<CorporateCardOwner__c>>();
        // 기간별 사용자의 경우 종료일이 기준월 -6 보다(12월 조회 시 6월종료 카드부터) 클 때 조회
        for (CorporateCardOwner__c obj: [
                SELECT CorporateCard__c, StartDate__c, EndDate__c
                FROM CorporateCardOwner__c
                WHERE User__c = :UserInfo.getUserId()
                AND EndDate__c >= :Date.newInstance(intYear, intMonth - 6, 1)
        ]){
            if (mapCardOwnerDate.get(obj.CorporateCard__c) == null) {
                mapCardOwnerDate.put(obj.CorporateCard__c, new List<CorporateCardOwner__c>{obj});
            }else{
                mapCardOwnerDate.get(obj.CorporateCard__c).add(obj);
            }
        }

        List<CorporateCardBilling__c> listCCB = new List<CorporateCardBilling__c>();
        // 24.01.22  하형석 이사님 요청으로 사용일자 기준으로 조회되던걸 그 달에 생성된 청구내역 조회하는것 으로 변경

        if (budgetType == '임원 및 감사님') {
            // 사용목적이 임원 및 감사님의 경우 대리상신 반영 : owner가 본인, 실사용 상관X  + 기간별 사용자
            // 자격증 외의 경우 레코드 생성날짜 기준으로 조회
            listCCB = [
                    SELECT  Id, CorporateCard__c, BillingDate__c, CorporateCard__r.CardNickname__c, fm_CardCompany__c, StoreName__c,
                            BusinessType__c, StoreAddress__c, BillingAmount__c, CurrencyIsoCode,
                            CorporateCard__r.RealUser__r.Name, CorporateCard__r.OwnerId
                    FROM    CorporateCardBilling__c
                    WHERE   (ExpenseDetail__c = NULL OR Id IN: listSelected)
                    AND     (CorporateCard__r.OwnerId = :UserInfo.getUserId() OR CorporateCard__c IN: mapCardOwnerDate.keySet())
                    AND     CreatedDate >= :Date.newInstance(intYear, intMonth + 1, 1)
                    AND     CreatedDate < :Date.newInstance(intYear, intMonth + 2, 1)
                    ORDER BY CorporateCard__r.CardNickname__c, BillingDate__c
            ];
        } else if(budgetType == '자격증') {
            // 임원 및 감사님 외의 사용목적은 Owner와 실사용자가 본인 + 기간별 사용자
            // 자격증의 경우 청구날짜 기준으로 조회
            listCCB = [
                    SELECT      Id, CorporateCard__c, BillingDate__c, CorporateCard__r.CardNickname__c, fm_CardCompany__c, StoreName__c,
                                BusinessType__c, StoreAddress__c, BillingAmount__c, CurrencyIsoCode,
                                CorporateCard__r.RealUser__r.Name, CorporateCard__r.OwnerId
                    FROM        CorporateCardBilling__c
                    WHERE       (ExpenseDetail__c = NULL OR Id IN: listSelected)
                    AND         ((CorporateCard__r.OwnerId = :UserInfo.getUserId() AND CorporateCard__r.RealUser__c = :UserInfo.getUserId()) OR CorporateCard__c in: mapCardOwnerDate.keySet())
                    AND         BillingDate__c >= :Date.newInstance(intYear, intMonth, 1)
                    AND         BillingDate__c < :Date.newInstance(intYear, intMonth + 1, 1)
                    ORDER BY    CorporateCard__r.CardNickname__c, BillingDate__c
            ];
        }else{
            // 임원 및 감사님 외의 사용목적은 Owner와 실사용자가 본인 + 기간별 사용자
            // 자격증 외의 경우 레코드 생성날짜 기준으로 조회
            listCCB = [
                    SELECT      Id, CorporateCard__c, BillingDate__c, CorporateCard__r.CardNickname__c, fm_CardCompany__c, StoreName__c,
                                BusinessType__c, StoreAddress__c, BillingAmount__c, CurrencyIsoCode,
                                CorporateCard__r.RealUser__r.Name, CorporateCard__r.OwnerId
                    FROM        CorporateCardBilling__c
                    WHERE       (ExpenseDetail__c = NULL OR Id IN: listSelected)
                    AND         ((CorporateCard__r.OwnerId = :UserInfo.getUserId() AND CorporateCard__r.RealUser__c = :UserInfo.getUserId())
                    OR          CorporateCard__c IN: mapCardOwnerDate.keySet())
                    AND         CreatedDate >= :Date.newInstance(intYear, intMonth + 1, 1)
                    AND         CreatedDate < :Date.newInstance(intYear, intMonth + 2, 1)
                    ORDER BY    CorporateCard__r.CardNickname__c, BillingDate__c
            ];
        }

        if (!mapCardOwnerDate.isEmpty() && !listCCB.isEmpty()) {
            for(Integer i = 0; i < listCCB.size(); i++){
                if (listCCB[i].CorporateCard__r.OwnerId != UserInfo.getUserId() && mapCardOwnerDate.containsKey(listCCB[i].CorporateCard__c)) {
                    Boolean check = false;
                    for (CorporateCardOwner__c objOwner : mapCardOwnerDate.get(listCCB[i].CorporateCard__c)){
                        if (listCCB[i].BillingDate__c >= objOwner.StartDate__c && listCCB[i].BillingDate__c <= objOwner.EndDate__c) {
                            check = true;
                        }
                    }
                    if (!check) {
                        listCCB.remove(i);
                        i--;
                    }
                }
            }
        }

        List<Map<String, Object>> listResult = new List<Map<String, Object>>();
        for (CorporateCardBilling__c obj : listCCB) {
            Map<String, Object> mapResult = new Map<String, Object>();
            mapResult.put('Id',                         obj.Id);
            mapResult.put('CorporateCard',              obj.CorporateCard__c);
            mapResult.put('BillingDate',                String.valueOf(obj.BillingDate__c));
            mapResult.put('CorporateCardNickName',      obj.CorporateCard__r.CardNickname__c);
            mapResult.put('CardCompany',                obj.fm_CardCompany__c);
            mapResult.put('StoreName',                  obj.StoreName__c);
            mapResult.put('BusinessType',               obj.BusinessType__c);
            mapResult.put('StoreAddress',               obj.StoreAddress__c);
            mapResult.put('BillingAmount',              obj.BillingAmount__c);
            mapResult.put('CurrencyIsoCode',            obj.CurrencyIsoCode);
            mapResult.put('CorporateCardRealUserName',  obj.CorporateCard__r.RealUser__r.Name);
            mapResult.put('CorporateCardOwnerId',       obj.CorporateCard__r.OwnerId);

            listResult.add(mapResult);
        }

        return listResult;
    }

    public class DataWrapper{
        public String  Category2 {get;set;}
        public Decimal amount {get;set;}
        public Integer cnt {get;set;}

        public DataWrapper(AggregateResult ar){
            Category2    = (String)ar.get('Category2__c');
            amount       = (Decimal)ar.get('Amount');
            cnt          = (Integer)ar.get('Cnt');
        }
    }
}