public with sharing class ContactLevel_tr extends TriggerHandler {
    
    private List<Contact> listContactNew {get;set;}
    private List<Contact> listContactOld {get;set;}
    private Map<Id, Contact> mapContactNew {get; set;}
    private Map<Id, Contact> mapContactOld {get; set;}
    

    public ContactLevel_tr(){
        listContactNew=(List<Contact>) Trigger.new;
        listContactOld=(List<Contact>) Trigger.old;

        mapContactNew=(Map<Id,Contact>)Trigger.newMap;
        mapContactOld= (Map<Id,Contact>)Trigger.oldMap;
    }
    public override void beforeInsert(){
        
        
    }

    public override void afterInsert(){
        
    }

    public override void beforeUpdate(){
        
    }

    public override void afterUpdate(){
        //afterContactUpdate();
    }

    public override void beforeDelete(){
        
    }

    public void afterContactUpdate() {

        List<ContactLevelChange__c> listEnglishLC=new List<ContactLevelChange__c>(); //변경된 영어레벨 담을 학생레벨변경 타입 리스트
        List<ContactLevelChange__c> listMathLC=new List<ContactLevelChange__c>(); //변경된 수학레벨 담을 학생레벨변경 타입 리스트

        for(Contact newCon:listContactNew){
            Contact OldCon=mapContactOld.get(newCon.Id); //레벨 업데이트 전 학생 Contact 객체 

            if(newCon.EnglishLevel__c != OldCon.EnglishLevel__c) { // 영어레벨이 달라졌다면 학생레벨변경 객체 생성
                
                ContactLevelChange__c EnglishLC=new ContactLevelChange__c();

                EnglishLC.ChangeTarget__c=newCon.Id; //레벨 변경 학생
                EnglishLC.OriginalLevel__c=OldCon.EnglishLevel__c; //기존레벨
                EnglishLC.NewLevel__c=newCon.EnglishLevel__c; //변경된 레벨
                EnglishLC.Subject__c='영어'; //과목
                listEnglishLC.add(EnglishLC);
            }
        }

        for(Contact newCon:listContactNew){
            Contact OldCon=mapContactOld.get(newCon.Id);  //레벨 업데이트 전 학생 Contact 객체 

            if(newCon.MathLevel__c != OldCon.MathLevel__c) { //수학레벨이 달라졌다면 학생레벨변경 객체 생성

                ContactLevelChange__c MathLC=new ContactLevelChange__c();

                MathLC.ChangeTarget__c=newCon.Id; //레벨 변경 학생
                MathLC.OriginalLevel__c=OldCon.MathLevel__c; //기존레벨
                MathLC.NewLevel__c=newCon.MathLevel__c; //변경된 레벨
                MathLC.Subject__c='수학'; //과목
                listMathLC.add(MathLC);
            }
        }

        if(!listEnglishLC.isEmpty()){ 
            insert listEnglishLC; //학생레벨변경 레코드 삽입 (영어)
        }

        if(!listMathLC.isEmpty()){
            insert listMathLC; //학생레벨변경 레코드 삽입 (수학)
        }
        
    }
}