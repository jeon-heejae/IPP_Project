trigger Item on Item__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	if(trigger.isBefore){
		if(trigger.isInsert){
			
		}
	} else if (trigger.isAfter){
		if(trigger.isInsert){
			ItemUtil.generateBomWhenPbaOrProdItemCreated((List<Item__c>)Trigger.new); 
		}
	}
}