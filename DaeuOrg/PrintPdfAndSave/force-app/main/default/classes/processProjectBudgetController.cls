public with sharing class processProjectBudgetController {
    
    @AuraEnabled
    public static String executeBatchProcess() {
        try {
            projectYearlyMonth_ba2 batch = new projectYearlyMonth_ba2();
            Database.executeBatch(batch, 200);
            return 'Batch Process Started Successfully';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
        
}