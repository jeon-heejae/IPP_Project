/************************************************************************************
* File Name   	    : CorporateCardBilling_tr
* Author	  		: Yeonlim
* Date				: 2024-01-12
* Modification Log
* ===================================================================================
* Ver      Date            Author          Modification
* ===================================================================================
* 1.0      2024-01-12      Yeonlim         Create
************************************************************************************/
public with sharing class CorporateCardBilling_tr extends TriggerHandler {
    private static List<CorporateCardBilling__c> listNew {get; set;}
    private static List<CorporateCardBilling__c> listOld {get; set;}
    private static Map<Id, CorporateCardBilling__c> mapNew {get; set;}
    private static Map<Id, CorporateCardBilling__c> mapOld {get; set;}

    public CorporateCardBilling_tr() {
        listNew = (List<CorporateCardBilling__c>) Trigger.new;
        listOld = (List<CorporateCardBilling__c>) Trigger.old;
        mapNew  = (Map<Id, CorporateCardBilling__c>) Trigger.newMap;
        mapOld  = (Map<Id, CorporateCardBilling__c>) Trigger.oldMap;
    }

    public override void beforeInsert() {
        doSetCardNumber();
    }

    /**
    * Event : before insert
    * Author : Yeonlim
    * Description : 법인카드 청구내역의 카드번호로 들어오는 값과 일치하는 법인카드 Object(Master)를 찾아서 넣어줌
    */
    public void doSetCardNumber() {
        Set<String> setCardNum = new Set<String>();

        for (CorporateCardBilling__c obj : listNew) {
            if (String.isBlank(obj.CorporateCard__c) && String.isNotBlank(obj.CardNumber__c)) {
                setCardNum.add(obj.CardNumber__c);
            }
        }

        if (!setCardNum.isEmpty()) {
            Map<String, String> mapCardNumToCardId = new Map<String, String>();

            for (CorporateCard__c obj : [
                    SELECT Id, CardNumber__c
                    FROM CorporateCard__c
                    WHERE CardNumber__c IN: setCardNum
            ]) {
                mapCardNumToCardId.put(obj.CardNumber__c, obj.Id);
            }

            for (CorporateCardBilling__c obj : listNew) {
                obj.CorporateCard__c = mapCardNumToCardId.get(obj.CardNumber__c);
            }
        }
    }

}