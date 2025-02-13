/**
 * Created by Kwanwoo.Jeon on 2023-12-14.
 */

public without sharing class RewardHoliday_tr extends TriggerHandler{
    private static List<RewardHoliday__c> listNew {get; set;}
    private static List<RewardHoliday__c> listOld {get; set;}
    private static Map<Id, RewardHoliday__c> mapNew {get; set;}
    private static Map<Id, RewardHoliday__c> mapOld {get; set;}

    public RewardHoliday_tr() {
        listNew = (List<RewardHoliday__c>) Trigger.new;
        listOld = (List<RewardHoliday__c>) Trigger.old;
        mapNew  = (Map<Id, RewardHoliday__c>) Trigger.newMap;
        mapOld  = (Map<Id, RewardHoliday__c>) Trigger.oldMap;
    }

    public override void beforeInsert() {
    }
    public override void beforeUpdate() {
        changeBenefitPayment();
    }
    public override void afterInsert() {
    }
    public override void afterUpdate() {

    }
    
    //수당지급 여부 체크 시 해당 값 Holiday 오브젝트에 수량 업로드
    //afterUpdate에서는 필드가 락걸려서 업데이트 불가능 BeforeUpdate로 변경해서 진행
    public void changeBenefitPayment(){
        Map<Id, Decimal> mapUserIdToRewardCount = new Map<Id, Decimal>();
        Map<Id, Decimal> mapUserIdToRewardCountCancel = new Map<Id, Decimal>();
        for (RewardHoliday__c obj: listNew){
            System.debug('BenefitPaymentYn__c :: ' + obj.BenefitPaymentYn__c);
            if (obj.BenefitPaymentYn__c != mapOld.get(obj.Id).BenefitPaymentYn__c) {
                if(obj.BenefitPaymentYn__c){
                    obj.Paid_Holiday__c = obj.Remain_Holiday__c;
                    mapUserIdToRewardCount.put(obj.WorkUser__c, mapUserIdToRewardCount.get(obj.WorkUser__c) == null ? obj.Paid_Holiday__c : mapUserIdToRewardCount.get(obj.WorkUser__c) + obj.Paid_Holiday__c);
                }else{
                    System.debug('Paid_Holiday__c :: ' + obj.Paid_Holiday__c);
                    mapUserIdToRewardCountCancel.put(obj.WorkUser__c, mapUserIdToRewardCountCancel.get(obj.WorkUser__c) == null ? obj.Paid_Holiday__c : mapUserIdToRewardCountCancel.get(obj.WorkUser__c) + obj.Paid_Holiday__c);
                    obj.Paid_Holiday__c = 0;
                }
            }
        }

        if (!mapUserIdToRewardCount.isEmpty() || !mapUserIdToRewardCountCancel.isEmpty()) {
            list<Holiday__c> listHoliday = new List<Holiday__c>([SELECT Holiday_User__c, Holiday_BenefitPaymentDays__c from Holiday__c where Holiday_User__c in :mapUserIdToRewardCount.keySet() OR Holiday_User__c in :mapUserIdToRewardCountCancel.keySet()]);
            if (!listHoliday.isEmpty()) {
                for (Holiday__c obj : listHoliday){
                    if (mapUserIdToRewardCount.get(obj.Holiday_User__c) != null) {
                        obj.Holiday_BenefitPaymentDays__c += mapUserIdToRewardCount.get(obj.Holiday_User__c);
                    }
                    if (mapUserIdToRewardCountCancel.get(obj.Holiday_User__c) != null) {
                        obj.Holiday_BenefitPaymentDays__c -= mapUserIdToRewardCountCancel.get(obj.Holiday_User__c);
                    }
                }
                update listHoliday;
            }

        }
    }
}