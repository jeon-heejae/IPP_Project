public class ProjectBudgetController {
	@AuraEnabled
	public static Map<String, Object> getInitData(Id recordId, Id parentId) {
        //String objectType = recordId.getsobjecttype().getDescribe().getLabel();
        ProjectBudget__c prjBgt; 
        List<ProjectBudgetDetail__c> prjBgtDtlLst;
        if(recordId == null){
            Project__c prj = [SELECT Id, Name FROM Project__c WHERE Id = :parentId limit 1];
            prjBgt = new ProjectBudget__c(Name = prj.Name + ' 예산 신청', Project__c = prj.Id, Status__c = '작성중');
        }
        else{
            prjBgt = [SELECT Id, Name, Status__c, Project__c,ru_TotalAmount__c, BusinessManager__c FROM ProjectBudget__c WHERE Id = :recordId];
            prjBgtDtlLst = [SELECT Id, Amount__c, UnitPrice__c, Memo__c, Quantity__c, Category2__c, ProjectBudget__c FROM ProjectBudgetDetail__c WHERE ProjectBudget__c = :recordId];
        }
        Map<String, Object> mapReturnValue = new Map<String, Object>{
        	'prjBgt' => prjBgt,
            'prjBgtDtlLst' => prjBgtDtlLst,
            'typePckLst' => getPicklistValue('ProjectBudgetDetail__c', 'Category2__c'),
            'bizMngHlpTxt' => ProjectBudget__c.BusinessManager__c.getDescribe().getInlineHelpText()
		};
        return mapReturnValue;
    }
    
     public static List<Map<String, String>> getPicklistValue(String sObjectStr, String fieldName) {
		List<Map<String, String>> options = new List<Map<String, String>>();
		
		Schema.SObjectType sobject_type = Schema.getGlobalDescribe().get(sObjectStr);
		Schema.DescribeSObjectResult sobjectDescribe = sobject_type.getDescribe();
		Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();
		
		List<Schema.PicklistEntry> pickListValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
		
		for(Schema.PicklistEntry pickListEntry : pickListValues) { 
			if (pickListEntry.isActive()) options.add(new Map<String, String>{'value' => pickListEntry.getValue(), 'label' => pickListEntry.getLabel(), 'default' => String.valueOf(pickListEntry.isDefaultValue())}); 
		}
		
		return options;
	}
    @AuraEnabled
	public static String doSave(ProjectBudget__c prjBgt, List<ProjectBudgetDetail__c> prjBgtDtlLst, Id recordId) {

		try {
			if(prjBgtDtlLst == null)
                prjBgtDtlLst = new List<ProjectBudgetDetail__c>();
			
			upsert prjBgt;
            if(recordId == null){
                for(ProjectBudgetDetail__c prjBgtDtl : prjBgtDtlLst){
                    prjBgtDtl.ProjectBudget__c = prjBgt.Id;
                }
            }
            upsert prjBgtDtlLst;
			return '저장되었습니다. / '+ prjBgt.Name;		

		} catch(DMLException dmlExcep) {
			System.debug('dmlExcep.getMessage() : ' + dmlExcep.getMessage());
			return '에러가 발생했습니다. / '+dmlExcep.getMessage();
		} 
	}
}