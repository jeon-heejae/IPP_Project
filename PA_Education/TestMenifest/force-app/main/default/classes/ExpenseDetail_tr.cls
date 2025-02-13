public without sharing class ExpenseDetail_tr extends TriggerHandler {
    private static List<ExpenseDetail__c> listNew {get; set;}
    private static List<ExpenseDetail__c> listOld {get; set;}
    private static Map<Id, ExpenseDetail__c> mapNew {get; set;}
    private static Map<Id, ExpenseDetail__c> mapOld {get; set;}

    public ExpenseDetail_tr() {
        ExpenseDetail_tr.listNew = (List<ExpenseDetail__c>) Trigger.new;
        ExpenseDetail_tr.listOld = (List<ExpenseDetail__c>) Trigger.old;
        ExpenseDetail_tr.mapNew  = (Map<Id, ExpenseDetail__c>) Trigger.newMap;
        ExpenseDetail_tr.mapOld  = (Map<Id, ExpenseDetail__c>) Trigger.oldMap;      
    }

    /************************************************************************************
    *   Context override
    *************************************************************************************/

    public override void beforeInsert() {
        categoryMapping();
    }
    public override void beforeUpdate() {
        categoryMapping();
    }

    public override void afterInsert() {
        setCorporateCardBilling();
    }

    public override void afterUpdate() {
        checkPriorExpense();
    }
    public override void afterDelete() { }

    public static void categoryMapping() {
        System.debug('listNew Tr : '+ listNew);
        System.debug('listOld Tr : '+ listOld);

    	List<ExpenseDetail__c> listExpenseDetail = new List<ExpenseDetail__c>();
        for(ExpenseDetail__c objExp : listNew) {
            System.debug('objExp.Type__c  : ' + objExp.Type__c);
            System.debug('objExp.Category2__c  : ' + objExp.Category2__c);

            if (objExp.Category2__c == '고객접대') {
                objExp.Type__c = '업무추진비-접대비';
            } else if (objExp.Category2__c == '교육/훈련') {
                objExp.Type__c = '교육훈련비';
            } else if (objExp.Category2__c == '도서인쇄비') {
                objExp.Type__c = '도서인쇄비';
            } else if (objExp.Category2__c == '소모품비') {
                objExp.Type__c = '소모품비-사무용품';
            } else if (objExp.Category2__c == '교통비' || objExp.Category2__c == '업무출장 - 지방' || objExp.Category2__c == '업무출장 - 해외') {
                objExp.Type__c = '여비교통비';
            } else if (objExp.Category2__c == '식비' || objExp.Category2__c == '회의' || objExp.Category2__c == '회식비' || objExp.Category2__c == '동호회 활동비') {
                objExp.Type__c = '복리후생비';
            } else if (objExp.Category2__c == '기타') {
                objExp.Type__c = '기타';
            } else if (objExp.Category2__c == '통신비') {
                objExp.Type__c = '통신비';
            } else {
                objExp.Type__c = '기타';
            }
            System.debug('objExp.Type__c 바뀐후  : ' + objExp.Type__c);
            listExpenseDetail.add(objExp);
        }
        System.debug('listExpenseDetail : ' + listExpenseDetail);
    }

    //경비신청 insert 시 해당 신청내역의 청구내역 레코드 업데이트
    public static void setCorporateCardBilling() {
        Map<Id,ExpenseDetail__c> mapCBToED = new Map<Id, ExpenseDetail__c>();
        Map<Id,ExpenseDetail__c> mapPEAToED = new Map<Id, ExpenseDetail__c>();
        for(ExpenseDetail__c obj :  listNew) {
            if (obj.CorporateCardBilling__c != null) {
                if (mapCBToED.keySet().contains(obj.CorporateCardBilling__c)) {
                    obj.addError('중복된 청구내역이 존재합니다.');
                }else{
                    mapCBToED.put(obj.CorporateCardBilling__c, obj);
                }
            }

            if (obj.PriorExpenseApplication__c != null) {
                if (mapPEAToED.keySet().contains(obj.PriorExpenseApplication__c)) {
                    obj.addError('중복된 경비사전승인이 존재합니다.');
                }else{
                    mapPEAToED.put(obj.PriorExpenseApplication__c, obj);
                }
            }

        }

        if (!mapCBToED.isEmpty()) {
            List<CorporateCardBilling__c> listCB = new List<CorporateCardBilling__c>([
                SELECT  Id, ExpenseDetail__c
                FROM    CorporateCardBilling__c
                WHERE   Id IN: mapCBToED.keySet()
            ]);
            if (!listCB.isEmpty()) {
                for (CorporateCardBilling__c obj: listCB){
                    if (obj.ExpenseDetail__c != null && obj.ExpenseDetail__c != mapCBToED.get(obj.id).Id) {
                        mapCBToED.get(obj.Id).addError('이미 경비 신청이 존재하는 청구내역입니다.');
                    }else{
                        obj.ExpenseDetail__c = mapCBToED.get(obj.id).Id;
                    }
                }
                update listCB;
            }
        }

        if (!mapPEAToED.isEmpty()) {
            List<PriorExpenseApplication__c> listPEA = new List<PriorExpenseApplication__c>([
                    SELECT  Id, ExpenseDetail__c
                    FROM    PriorExpenseApplication__c
                    WHERE   Id IN: mapPEAToED.keySet()
            ]);
            if (!listPEA.isEmpty()) {
                for (PriorExpenseApplication__c obj: listPEA){
                    if (obj.ExpenseDetail__c != null && obj.ExpenseDetail__c != mapPEAToED.get(obj.id).Id) {
                        mapPEAToED.get(obj.Id).addError('이미 경비 신청이 존재하는 사전승인입니다.');
                    }else{
                        obj.ExpenseDetail__c = mapPEAToED.get(obj.id).Id;
                    }
                }
                update listPEA;
            }
        }
    }

    //경비신청 update 시 경비사전승인 Lookup 필드 및 레코드 확인
    public static void checkPriorExpense() {
        Map<Id,ExpenseDetail__c> mapCBToED = new Map<Id, ExpenseDetail__c>();
        Map<Id,ExpenseDetail__c> mapPEAToED = new Map<Id, ExpenseDetail__c>();
        for(ExpenseDetail__c obj :  listNew) {
            if (obj.PriorExpenseApplication__c != null && obj.PriorExpenseApplication__c != mapOld.get(obj.Id).PriorExpenseApplication__c) {
                if (mapPEAToED.keySet().contains(obj.PriorExpenseApplication__c)) {
                    obj.addError('중복된 경비사전승인이 존재합니다.');
                }else{
                    mapPEAToED.put(obj.PriorExpenseApplication__c, obj);
                }
            }
        }

        if (!mapPEAToED.isEmpty()) {
            List<PriorExpenseApplication__c> listPEA = new List<PriorExpenseApplication__c>([
                    SELECT  Id, ExpenseDetail__c, Name
                    FROM    PriorExpenseApplication__c
                    WHERE   Id IN: mapPEAToED.keySet()
            ]);
            if (!listPEA.isEmpty()) {
                for (PriorExpenseApplication__c obj: listPEA){
                    if (obj.ExpenseDetail__c != null && obj.ExpenseDetail__c != mapPEAToED.get(obj.id).Id && !mapNew.containsKey(obj.ExpenseDetail__c)) {
                        mapPEAToED.get(obj.Id).addError(obj.Name + '은 이미 경비 신청이 존재하는 사전승인입니다.');
                    }else{
                        obj.ExpenseDetail__c = mapPEAToED.get(obj.id).Id;
                    }
                }
                update listPEA;
            }
        }
    }
}