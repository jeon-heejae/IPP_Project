global with sharing class ExpenseInfoDelete_ba implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    global Boolean isError = false;
    global String strId;

    public ExpenseInfoDelete_ba() {
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date dateThreeMonthAgo = Date.today().addMonths(-3);
        String strQuery = 'SELECT Id ';
        strQuery += '   FROM Expense__c';
        strQuery += '   WHERE  Project__r.EndDate__c < :dateThreeMonthAgo  ';
        strQuery += '   ORDER BY Description__c  ';

        return DataBase.getQueryLocator(strQuery);
    }

    global void execute(Database.BatchableContext BC, List<Expense__c> listTarget){
        try {
            //Code Block
            for(Expense__c objExpense : listTarget){
                objExpense.Description__c = null;
            }

            update listTarget;
        }catch(Exception e) {
            this.isError = true;
            System.debug('Error ===================> Error : ' + e.getMessage() + '/' + e.getLineNumber());
        }
    }

    global void finish(Database.BatchableContext BC) {
    }
}