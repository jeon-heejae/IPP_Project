public with sharing class Account_tr extends TriggerHandler {
    private List<Account> listNew {get; set;}
    private List<Account> listOld {get; set;}
    private Map<Id, Account> mapNew {get; set;}
    private Map<Id, Account> mapOld {get; set;}


    public Account_tr(){
         listNew = (List<Account>)Trigger.new;
         listOld = (List<Account>)Trigger.old;
         mapNew = (Map<Id,Account>)Trigger.newMap;
         mapOld = (Map<Id,Account>)Trigger.oldMap;
        
    }
    public override void beforeInsert(){
        beforeAccountInsert();
        
        
    }

    public override void afterInsert(){
        
    }

    public override void beforeUpdate(){
        beforeAccountUpdate();
    }

    public override void afterUpdate(){
    }

    public override void beforeDelete(){
        beforeAccountDelete();
    }

    public void beforeAccountInsert(){
        for(Account a:listNew){
            if(a.Rating==null){
                a.Rating='Cold';
            }
        }
    }

    public void beforeAccountUpdate(){
       for(Account newA:listNew){
        if(!System.Test.isRunningTest()){
            if(mapOld.get(newA.Id).Rating=='Hot'&&newA.Rating=='Cold'){
                newA.addError('Hot에서 Cold로 변경할 수 없습니다.');
            }
        }
       }
    }

    public void beforeAccountDelete(){
        for(Account oldA:listOld){
            if(oldA.Rating=='Hot'){
                oldA.addError('Hot일 때 삭제 불가');
            }
        }
    }

}