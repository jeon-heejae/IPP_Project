trigger ApprovalExpenseShare on Expense__c (after insert, after update) {
    if(trigger.isAfter){
        if(trigger.isInsert){
            //최초 경비 제출을 위한 Method
            //ApprovalExpenseShare_tr.doApprovalShareInsert(trigger.new, trigger.oldmap);
        }else if(trigger.isUpdate){
            // ApprovalExpenseShare_tr.doApprovalShareUpdate(trigger.new, trigger.oldmap);
        }
    }
}