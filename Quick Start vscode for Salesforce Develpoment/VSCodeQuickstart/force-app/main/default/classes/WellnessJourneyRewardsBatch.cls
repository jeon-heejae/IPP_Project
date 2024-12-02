public class WellnessJourneyRewardsBatch implements Database.Batchable<sObject>{

   
 
    public Database.QueryLocator start(Database.BatchableContext bc){
        Date quarter=System.today().addMonths(-3);
        String query='SELECT Id, name, OwnerId, Owner.Name,Owner.Username,Owner.Email  FROM Wellness_Journey__c WHERE Status__c=\'Complete\' AND Completion_Date__c>=:quarter Order by OwnerId';
        return Database.getQueryLocator(query);
    }
 
    public void execute(Database.BatchableContext bc, List<Wellness_Journey__c> scope){
        List<Wellness_Journey__c> lstWellnessJourney=(List<Wellness_Journey__c>)scope;

        List<Map<String,List<Wellness_Journey__c>>> lstMapWellnessJourney=new List<Map<String,List<Wellness_Journey__c>>>();
        Map<String,List<Wellness_Journey__c>> mapWellnessJourney=new Map<String,List<Wellness_Journey__c>>();
        
        Integer cnt=0;
        for(Wellness_Journey__c objWJ:lstWellnessJourney){
            if(!mapWellnessJourney.containsKey(objWJ.OwnerId)) {
                mapWellnessJourney.put(objWJ.OwnerId,new List<Wellness_Journey__c>());
            }
            else{
                List<Wellness_Journey__c> lstWJ=mapWellnessJourney.get(objWJ.OwnerId);
                lstWJ.add(objWJ);
                mapWellnessJourney.put(objWj.OwnerId,lstWJ);
            }
            cnt++;

            if(cnt>=12){
                Map<String,List<Wellness_Journey__c>> mapResult=new Map<String,List<Wellness_Journey__c>>();
                mapResult.put('userId',objWJ.OwnerId);
                mapResult.put('fullName',objWJ.Owner.Name);
                mapResult.put('email',objWJ.Owner.Email);
                mapResult.put('userName',objWJ.Owner.Username);

                lstMapWellnessJourney.add(mapWellnessJourney);
            }
        }

        String json=JSON.serialize(lstMapWellnessJourney);

        Integer status=

    }
 
    public void finish(Database.BatchableContext bc){
    }
 }