/**
 * Created by JWJANG on 2023-10-04.
 */
public with sharing class ExpenseApplicationTriggerHandler extends TriggerHandler {
    private static List<Expense__c> listNew {get; set;}
    private static List<Expense__c> listOld {get; set;}
    private static Map<Id, Expense__c> mapNew {get; set;}
    private static Map<Id, Expense__c> mapOld {get; set;}

    public ExpenseApplicationTriggerHandler() {
        listNew = (List<Expense__c>) Trigger.new;
        listOld = (List<Expense__c>) Trigger.old;
        mapNew = (Map<Id, Expense__c>) Trigger.newMap;
        mapOld = (Map<Id, Expense__c>) Trigger.oldMap;
    }

    public override void beforeInsert() { }

    public override void beforeUpdate() { }

    public override void afterInsert() { }

    public override void afterUpdate() {
//        updateTotalExpense();
        updateBudgetUsedAmount();
    }

    /**
     * Expense Application (Expense__c) 변경 시, 프로젝트 별 경비신청금액 업데이트
     */
//    private void updateTotalExpense() {
//        System.debug('[updateTotalExpense] Start !!!');
//        try {
//            // 대상 프로젝트 조회
//            List<AggregateResult> listEDToProjectId = [
//                    SELECT Expense__r.Project__c
//                    FROM ExpenseDetail__c
//                    WHERE Expense__c IN :mapNew.keySet()
//                    AND Expense__r.BudgetType__c = '프로젝트'
//                    GROUP BY Expense__r.Project__c
//            ];
//
//            if(!listEDToProjectId.isEmpty()) {
//                Set<String> setProjectId = new Set<String>();
//                for(AggregateResult objExpenseDetail : listEDToProjectId) {
//                    setProjectId.add(String.valueOf(objExpenseDetail.get('Expense__r.Project__c')));
//                }
//                System.debug(String.format('Target Project ID : [{0}] {1}', new List<Object>{ setProjectId.size(), setProjectId }));
//
//                // 프로젝트 경비신청 금액 합산
//                List<ExpenseDetail__c> listExpenseDetail = [
//                        SELECT Id, Amount__c, fm_approvalStatus__c, Project_Name__c, Expense__r.Project__c
//                        FROM ExpenseDetail__c
//                        WHERE Expense__r.Project__c IN :setProjectId AND fm_approvalStatus__c IN ('Consider', 'Approved')
//                ];
//
//                Map<String, Project__c> mapProject = new Map<String, Project__c>();
//                for(ExpenseDetail__c objExpenseDetail : listExpenseDetail) {
//                    Project__c objProject = mapProject.get(objExpenseDetail.Expense__r.Project__c);
//                    if(objProject == null) {
//                        objProject = new Project__c(Id = objExpenseDetail.Expense__r.Project__c, TotalExpense__c = 0);
//                    }
//
//                    objProject.TotalExpense__c += objExpenseDetail.Amount__c;
//                    mapProject.put(objProject.Id, objProject);
//                }
//                System.debug(String.format('Target Project : [{0}] {1}', new List<Object>{ mapProject.size(), mapProject }));
//
//                if(!mapProject.isEmpty()) {
//                    update mapProject.values();
//                }
//            }
//        } catch (Exception e) {
//            System.debug(String.format('[{0}] {1}', new List<Object>{ e.getLineNumber(), e.getMessage() }));
//        }
//
//        System.debug('[updateTotalExpense] End !!!');
//    }

    /**
    * Expense Application (Expense__c) 승인 시, 예산, 프로젝트 오브젝트의 사용금액 내역에 추가
    */
    private void updateBudgetUsedAmount(){
        Map<Id,Decimal> mapBudgetIdToExpense = new Map<Id, Decimal>();
        Map<Id,Id> mapPrjToBudget = new Map<Id, Id>();

        for (Expense__c obj : listNew){
            if (obj.ApprovalStatus__c != mapOld.get(obj.Id).ApprovalStatus__c && new list<String>{'Approved', '승인완료'}.contains(obj.ApprovalStatus__c)) {
                if (mapBudgetIdToExpense.get(obj.Budget__c) == null) {
                    mapBudgetIdToExpense.put(obj.Budget__c, obj.TotalAmount__c);
                }else{
                    mapBudgetIdToExpense.put(obj.Budget__c, mapBudgetIdToExpense.get(obj.Budget__c) + obj.TotalAmount__c);
                }

                if (obj.BudgetType__c == '프로젝트' && obj.Project__c != null) {
                    mapPrjToBudget.put(obj.Project__c, obj.Budget__c);
                }
            }
        }
        if (!mapBudgetIdToExpense.isEmpty()) {
            set<Id> setOverBudget = new Set<Id>();

            //Budget__c에 사용한 비용 가감
            List<Budget__c> listBudget = new List<Budget__c>([
                    SELECT  Id, UsedAmount__c, fm_RemainingAmount__c, Project__r.Contract__c, Project__r.Contract__r.IsContract__c
                    FROM    Budget__c
                    WHERE   Id IN : mapBudgetIdToExpense.keySet()
            ]);

            System.debug('listBudget :: ' + listBudget);
            if (!listBudget.isEmpty()) {
                for (Budget__c obj : listBudget){
                     //예산초과 체크
                    if (obj.fm_RemainingAmount__c < mapBudgetIdToExpense.get(obj.Id)) {
                        //프로젝트가 아닌 경우 OR 프로젝트가 인데 계약필드가 있고 계약이 성사된 경우에만 예산초과 validation 적용

                        if (!mapPrjToBudget.values().contains(obj.Id)
                                || (mapPrjToBudget.values().contains(obj.Id) && obj.Project__r.Contract__c != null && obj.Project__r.Contract__r.IsContract__c)) {
                            setOverBudget.add(obj.Id);
                            break;
                        }
                    }
                        obj.UsedAmount__c = obj.UsedAmount__c == null?  mapBudgetIdToExpense.get(obj.Id) : obj.UsedAmount__c + mapBudgetIdToExpense.get(obj.Id);
                }
                update listBudget;
            }

            System.debug('setOverBudget :: ' + setOverBudget);

            //Project__c에 사용한 비용 가감
            List<Project__c> listPrj = new List<Project__c>([
                    SELECT  Id, TotalExpense__c, fm_RemainingExpense__c
                    FROM    Project__c
                    WHERE   Id IN : mapPrjToBudget.keySet()
            ]);
            if (!listPrj.isEmpty()) {
                for (Project__c obj : listPrj){
                    if (!setOverBudget.contains(mapPrjToBudget.get(obj.Id))) {
                        obj.TotalExpense__c = obj.TotalExpense__c == null? mapBudgetIdToExpense.get(mapPrjToBudget.get(obj.Id)) : obj.TotalExpense__c + mapBudgetIdToExpense.get(mapPrjToBudget.get(obj.Id));
                    }

                }
                update listPrj;
            }

            for (Expense__c obj : listNew){
                if (setOverBudget.contains(obj.Budget__c)) {
                    obj.addError('신청금액이 예산을 초과합니다.');
                }
            }

        }
    }
}