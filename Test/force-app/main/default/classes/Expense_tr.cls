public with sharing class Expense_tr extends TriggerHandler {
    
    private List<Expense__c> listExpenseNew {get;set;}
    
    

    


    public Expense_tr(){
        listExpenseNew=(List<Expense__c>) Trigger.new;
        
    }
    public override void beforeInsert(){
        
        
    }

    public override void afterInsert(){
        afterExpenseInsert();
    }

    public override void beforeUpdate(){
        
    }

    public override void afterUpdate(){
    }

    public override void beforeDelete(){
        
    }

    public void afterExpenseInsert() {
        Set<Id> setProject_Id=new Set<Id>();
        for(Expense__c e:listExpenseNew){
            setProject_Id.add(e.Project__c);
        }
    
        List<Project__c> listProject=new List<Project__c>();
        listProject=[
            select id,LastExpenseDate__c,EndDate__c
            from Project__c
            where id in:setProject_Id 
            and EndDate__c> :System.today()
        ];

        
        for(Project__c p:listProject){
            p.LastExpenseDate__c=date.today();
        }

        if(!listProject.isEmpty()){
            update listProject;
        }

        
    }



}