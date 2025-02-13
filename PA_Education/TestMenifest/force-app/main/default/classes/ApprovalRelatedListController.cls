public class ApprovalRelatedListController {
    @AuraEnabled
    public static List<wrapTargetObj> doInit(String recordId) {
        System.debug('ApprovalRelatedListController doInit============================> Start');
        List<wrapTargetObj> listWrapObject = new List<wrapTargetObj>();
        List<ProcessInstanceStep> instanceStepList = [SELECT Id, ProcessInstanceId FROM ProcessInstanceStep
        WHERE Id =: recordId];
        // Approval, reject 시 조건문 진행
        if(!instanceStepList.isEmpty()) {
            ProcessInstanceStep instanceStepObj = instanceStepList.get(0);
            String instanceStepId = instanceStepObj.ProcessInstanceId;

            List<ProcessInstance> instanceList = [SELECT Id, TargetObjectId FROM ProcessInstance WHERE Id =: instanceStepId OR Id =: instanceStepId];
            System.debug('instanceList::' + instanceList);
            ProcessInstance instanceObj = instanceList.get(0);
            System.debug('instanceObj::' + instanceObj);
            String targetobjId = instanceObj.TargetObjectId;
            String instanceId  = instanceObj.Id;
            System.debug('instanceId::' + instanceId);


            // get Object ApiName
            String objectAPIName = '';
            String keyPrefix = targetobjId.substring(0,3);
            for( Schema.SObjectType obj : Schema.getGlobalDescribe().Values()) {
                String prefix = obj.getDescribe().getKeyPrefix();
                if(prefix == keyPrefix) {
                    objectAPIName = obj.getDescribe().getName();
                    break;
                }
            }
            System.debug('objectAPIName::: Approavl Status' + objectAPIName);
            List<ApprovalRelateList__c> targetApprovalList = new List<ApprovalRelateList__c>([
                    SELECT ObjectType__c, RelatedObject__c FROM ApprovalRelateList__c WHERE ObjectType__c =: objectAPIName
            ]);
            System.debug('targetApprovalList::' + targetApprovalList);
            if(!targetApprovalList.isEmpty()) {
                List<String> listRelatedObject = targetApprovalList[0].RelatedObject__c.split(',');            
                System.debug('targetApprovalList Middle::');

                for(String objeRelatedObject : listRelatedObject) {
                    List<String> relatedObject = objeRelatedObject.split(':');
                    //get FieldSet Dynamically
                    String fieldSetName = 'Approval_Related_List';
                    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
                    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(relatedObject[0]);
                    Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
                    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
                    List<Schema.FieldSetMember> targetObjField = fieldSetObj.getFields();
                    List<String> listFieldApi = new List<String>();
                    List<Map<String, String>> listFieldMap = new List<Map<String, String>>();

                    for(Schema.FieldSetMember f : targetObjField) {
                        listFieldApi.add(f.getFieldPath());
                        system.debug('getFieldPath:'+f.getFieldPath());
                        system.debug('getLabel:'+f.getLabel());
                        String fieldType = f.getType().name();
                        system.debug('getType:'+fieldType);

                        listFieldMap.add(new Map<String, String>{'label' => f.getLabel(), 'fieldName' => f.getFieldPath(), 'type' => fieldType});
                    }

                    String sQuery = 'SELECT Id, ' + String.join(listFieldApi, ',');
                    sQuery += ' FROM ' + relatedObject[0];
                    sQuery += ' WHERE ' + relatedObject[1] + ' = ' + '\'' + targetobjId + '\'';

                    system.debug('sQuery:'+sQuery);
                    List<SObject> listObject = Database.query(sQuery);
                    // mapListObject.put(objeRelatedObject, listObject);
                    // mapListColumn.put(objeRelatedObject, listFieldMap);
                    listWrapObject.add(new wrapTargetObj(listObject, listFieldMap, relatedObject[1], relatedObject[0]));
                }
            }

            System.debug('ApprovalRelatedListController doInit============================> End');
        }

        // Pendding시 조건문 진행
        List<ProcessInstanceWorkitem> processInstanceWorkItemList = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE Id =: recordId];
        System.debug('processInstanceWorkItemList::' + processInstanceWorkItemList);
        if(!processInstanceWorkItemList.isEmpty()) {
            ProcessInstanceWorkitem instanceWorkItemObj = processInstanceWorkItemList.get(0);
            String instanceWorkItemId = instanceWorkItemObj.ProcessInstanceId;
            System.debug('COME IN HERE CHECK');

            List<ProcessInstance> instanceList = [SELECT Id, TargetObjectId FROM ProcessInstance WHERE Id =: instanceWorkItemId];
            System.debug('instanceList:::' + instanceList);
            ProcessInstance instanceObj = instanceList.get(0);
            String targetobjId = instanceObj.TargetObjectId;
            String instanceId  = instanceObj.Id;

            // get Object ApiName
            String objectAPIName = '';
            String keyPrefix = targetobjId.substring(0,3);
            for( Schema.SObjectType obj : Schema.getGlobalDescribe().Values()) {
                String prefix = obj.getDescribe().getKeyPrefix();
                if(prefix == keyPrefix) {
                    objectAPIName = obj.getDescribe().getName();
                    break;
                }
            }
            System.debug('objectAPIName::=======CHECK' + objectAPIName);
            List<ApprovalRelateList__c> targetApprovalList = new List<ApprovalRelateList__c>([
                    SELECT ObjectType__c, RelatedObject__c FROM ApprovalRelateList__c WHERE ObjectType__c =: objectAPIName
            ]);
            if(!targetApprovalList.isEmpty()) {
                List<String> listRelatedObject = targetApprovalList[0].RelatedObject__c.split(',');
                // 19.07.16 해당 TargetObj의 아이콘 뿌려주기 위해 변수를 가공합니다
                for(String objeRelatedObject : listRelatedObject) {
                    List<String> relatedObject = objeRelatedObject.split(':');

                    //get FieldSet Dynamically
                    String fieldSetName = 'Approval_Related_List';
                    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
                    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(relatedObject[0]);
                    Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
                    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
                    List<Schema.FieldSetMember> targetObjField = fieldSetObj.getFields();
                    List<String> listFieldApi = new List<String>();
                    List<Map<String, String>> listFieldMap = new List<Map<String, String>>();

                    for(Schema.FieldSetMember f : targetObjField) {
                        listFieldApi.add(f.getFieldPath());
                        system.debug('getFieldPath:'+f.getFieldPath());
                        system.debug('getLabel:'+f.getLabel());
                        String fieldType = f.getType().name();
                        system.debug('getType:'+fieldType);

                        listFieldMap.add(new Map<String, String>{'label' => f.getLabel(), 'fieldName' => f.getFieldPath(), 'type' => fieldType});
                    }

                    String sQuery = 'SELECT Id, ' + String.join(listFieldApi, ',');
                    sQuery += ' FROM ' + relatedObject[0];
                    sQuery += ' WHERE ' + relatedObject[1] + ' = ' + '\'' + targetobjId + '\'';

                    system.debug('sQuery:'+sQuery);
                    List<SObject> listObject = Database.query(sQuery);
                    listWrapObject.add(new wrapTargetObj(listObject, listFieldMap, relatedObject[1], relatedObject[0]));
                }
            }
        }
        System.debug('End Pending Parshe ::::::::::');
        return listWrapObject;
    }
    public class wrapTargetObj {
        @AuraEnabled
        public List<SObject> mapListObject {get; set;}
        @AuraEnabled
        public List<Map<String, String>> mapListColumn {get; set;}
        @AuraEnabled
        public String targetObj {get; set;}
        @AuraEnabled
        public String searchObj {get; set;}


        public wrapTargetObj(List<SObject> fMapListObject, List<Map<String, String>> fMapListColumn, String fTargetObj, String fSearchObj) {
            mapListObject   = fMapListObject;
            mapListColumn   = fMapListColumn;
            targetObj       = fTargetObj;
            searchObj       = fSearchObj;

        }
    }
}