public with sharing class ItemUtil {

	public static void generateBomWhenPbaOrProdItemCreated(List<Item__c> items){
		List<ProcessInfo__c> boms = new List<ProcessInfo__c>();
		for(Item__c i : items){
			if(i.Type__c == 'PBA' || i.Type__c == '제품' || i.Type__c == '재공품'){
				ProcessInfo__c p = new ProcessInfo__c();
				p.Name = i.Name;
				p.Item__c = i.Id;
				
				boms.add(p);
			}
		}
		insert boms;
	}
}