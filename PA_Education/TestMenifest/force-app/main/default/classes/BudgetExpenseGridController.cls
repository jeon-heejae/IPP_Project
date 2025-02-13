/**
 * Created by Kwanwoo.Jeon on 2024-01-15.
 */

public with sharing class BudgetExpenseGridController {

    /**
     * @description doInit
     */
    @AuraEnabled
    public static dataWrapper doInit(Id recordId){
        dataWrapper dw = new dataWrapper();
        Budget__c objBudget = [
                SELECT  Id, fm_BudgetAmount__c, UsedAmount__c, fm_RemainingAmount__c
                FROM    Budget__c
                WHERE   Id =: recordId
        ];


        list<AggregateResult> listExp = new List<AggregateResult>([
                SELECT      Category2__c, SUM(Amount__c) amount, COUNT(Id) cnt
                FROM        ExpenseDetail__c
                WHERE       Expense__r.Budget__c = :recordId
                AND         Expense__r.ApprovalStatus__c IN ('승인완료','Approved')
                GROUP BY    Category2__c
        ]);

        dw.objBudget = objBudget;
        dw.listExp = listExp;
        return dw;
    }
    public class dataWrapper{
        @AuraEnabled
        public Budget__c objBudget {get;set;}
        @AuraEnabled
        public list<AggregateResult> listExp {get;set;}
    }
}