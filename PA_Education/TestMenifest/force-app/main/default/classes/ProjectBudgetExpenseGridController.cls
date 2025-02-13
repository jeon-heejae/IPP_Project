public without sharing class ProjectBudgetExpenseGridController {

    private final Project__c myPrj{get; set;}
    public List<DataWrapper> prjExpBgtList{get; set;}
    private ApexPages.StandardController controller {get; set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ProjectBudgetExpenseGridController(ApexPages.StandardController stdController) {
        controller = stdController;
        this.myPrj = (Project__c)stdController.getRecord();
       setList();
    }

    public void setList(){
        Id prjId = this.myPrj.Id;
        List<ProjectBudgetDetail__c> prjExpLst = [SELECT toLabel(Category2__c), Amount__c 
                                               FROM ProjectBudgetDetail__c 
                                              WHERE ProjectBudget__r.Project__c =:prjId
                                                AND ProjectBudget__r.Status__c in ('승인완료','Approved')];

        List<ExpenseDetail__c> expDtlLst = [SELECT toLabel(Category2__c), Amount__c FROM ExpenseDetail__c WHERE Expense__r.Project__c = :prjId
                                             AND Expense__r.ApprovalStatus__c in ('승인완료','Approved')];

        Map<String,DataWrapper> prjExpBgtMap = new Map<String, DataWrapper>();
        DataWrapper dwSumInit = new DataWrapper();   
        dwSumInit.type = '계';
        dwSumInit.budgetAmount = 0;
        prjExpBgtMap.put(dwSumInit.type,dwSumInit);

        for(ProjectBudgetDetail__c prjExp : prjExpLst){
            DataWrapper dw = prjExpBgtMap.get(prjExp.Category2__c);
            if(dw == null){
                dw = new DataWrapper();   
                dw.type = prjExp.Category2__c;
            }
            dw.budgetAmount += prjExp.Amount__c;
            prjExpBgtMap.put(dw.type,dw);  
            
            DataWrapper dwSum = prjExpBgtMap.get('계');
            dwSum.budgetAmount += prjExp.Amount__c;
            prjExpBgtMap.put(dwSum.type,dwSum);        
        }
        for(ExpenseDetail__c expDtl : expDtlLst){
            DataWrapper dw = prjExpBgtMap.get(expDtl.Category2__c);
            if(dw == null){
                dw = new DataWrapper();   
                dw.type = expDtl.Category2__c;
            }
            dw.expenseAmount += expDtl.Amount__c;  
            prjExpBgtMap.put(dw.type,dw);    
            
            DataWrapper dwSum = prjExpBgtMap.get('계');
            dwSum.expenseAmount += expDtl.Amount__c;  
            prjExpBgtMap.put(dwSum.type,dwSum);          
        }
        prjExpBgtList = prjExpBgtMap.values();
        prjExpBgtList.sort();
    }

    public class DataWrapper implements Comparable {
        public String type{get;set;}
        public Decimal budgetAmount{get;set;}
        public Decimal expenseAmount{get;set;}
        public Decimal remainAmount{
            get{
                return budgetAmount - expenseAmount;
            }
            set;
        }
        public DataWrapper(){
            budgetAmount = 0;
            expenseAmount = 0;
        }
        public Integer compareTo(Object compareTo){
            DataWrapper compareToWrapper = (DataWrapper)compareTo;
            if (type == compareToWrapper.type) return 0;
            if (type == '계') return 1;
            return -1; 
        }
    }
}