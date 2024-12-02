public with sharing class AnonymousApex {
    public AnonymousApex() {
       //1) Contact 10건만 조회하여 Map에 key : Id(Contact), value : Birthdate 형식으로 구현
       List<Contact> listContact = new List<Contact>();
       listContact = [
           SELECT Id, BirthDate
           FROM Contact
           LIMIT 10
       ];
       Map<Id, Date> mapBirthDate = new Map<Id, Date>();
       for(Contact objCon : listContact){
           mapBirthDate.put(objCon.Id, objCon.BirthDate);
       }
       //System.debug('mapBirthDate : ' + mapBirthDate);

        //2)프로젝트 Object 전체 조회한 후 Map에 key : Id(Project__c), value : List<Expense__c>형식으로 구현
       List<Project__c> listProject = new List<Project__c>();
       listProject = [
           SELECT Id
           FROM Project__c
       ];

       Set<Id> setProjectId = new Set<Id>();
       for(Project__c objProject : listProject){
           setProjectId.add(objProject.Id);
       }

       List<Expense__c> listExpense = new List<Expense__c>();
       listExpense = [
           SELECT Id, Project__c,Spending__c
           FROM Expense__c
           WHERE Project__c IN :setProjectId
       ];

       Map<Id, List<Expense__c>> mapListExpense = new Map<Id, List<Expense__c>>();

       for(Expense__c objExpense : listExpense){
           if(!mapListExpense.containsKey(objExpense.Project__c)){
               mapListExpense.put(objExpense.Project__c, new List<Expense__c>());
           }
           mapListExpense.get(objExpense.Project__c).add(objExpense);
       }
       
       
      

       //3. 프로젝트 정보의 경비를 조회하여 Map에 key : Id, value : Integer(경비의 합) 형식으로 구현
       Map<Id,Integer> mapSum=new Map<Id,Integer>();

       Integer sum=0;

       for(Expense__c ex:listExpense){
            if(!mapSum.containsKey(ex.Project__c)){
                sum=0;
                mapSum.put(ex.Project__c,sum);
            }
            sum+=Integer.valueOf(ex.Spending__c);
            mapSum.put(ex.Project__c,sum);
       }

    

   
    
 


        
    
       

        

    
        //4. 1에서 조회된 Contact 레코드들의 TestDate를 Today로 업데이트하기 
       List<Contact> listNewContact=new List<Contact>();
        for(Contact c: listContact){
            Contact con=new Contact();
            con.Id=c.Id;
            con.Birthdate=System.today();
            listNewContact.add(con);
            System.debug(con);
        }
        if(!listNewContact.isEmpty()){
            update listNewContact;
        }


        






        
        String CRON = '0 30 15 * * ? *'; 
        System.schedule('스케줄 이름', CRON, new ExpenseInfoDelete_sc());
        
        List<Expense__c> expenses = [SELECT Id, Project__c  FROM Expense__c];

Set<Id> projectIds = new Set<Id>();
for (Expense__c exp : expenses) {
    projectIds.add(exp.Project__c);
}

List<Project__c> projects = [SELECT Id  FROM Project__c WHERE Id IN :projectIds];

System.debug('결과: ' + projects.size());
    }
}