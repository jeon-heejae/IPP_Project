public without sharing class ExpenseBudgetGridController {

    private final Expense__c myExpense {get; set;}
    public List<DataWrapper> expenseBudgetList {
        get {
            if(expenseBudgetList == null) {
                expenseBudgetList = new List<DataWrapper>();
            }
            return expenseBudgetList;
        } 
        set;
    }
    private ApexPages.StandardController controller {get; set;}

    public ExpenseBudgetGridController(ApexPages.StandardController stdController) {
    controller = stdController;
        this.myExpense = (Expense__c)stdController.getRecord();
        setList();
    }

    public void setList(){
        Id expenseId = this.myExpense.Id;
        List<AggregateResult> listExpenseDetail = [
                SELECT      toLabel(Category2__c), Sum(Amount__c) Amount, COUNT(Id) Cnt
                FROM        ExpenseDetail__c
                WHERE       Expense__c =:expenseId
                GROUP BY    Category2__c];

        for(AggregateResult ar : listExpenseDetail){
            expenseBudgetList.add(new DataWrapper(ar));
        }

        system.debug('after total : '+ expenseBudgetList);
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