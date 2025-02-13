/**
 * Created by JWJANG on 2023-02-15.
 */

public with sharing class DN_Util {

    // 설명 : Field Set 을 이용하여 Dynamic 하게 화면 구성할 시 사용 (Table, 등등)
    public static List<Map<String, Object>> getFieldSet(String strObjectAPIName, String strFieldSetAPIName) {
        System.debug('OBJECT_API_NAME :::: ' + strObjectAPIName);
        System.debug('FIELD_SET_API_NAME:::: ' + strFieldSetAPIName);

        List<Map<String, Object>> listReturnFieldSet = new List<Map<String, Object>>();
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(strObjectAPIName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(strFieldSetAPIName);

        if(fieldSetObj != null) {
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetObj.getFields()) {
                listReturnFieldSet.add(new Map<String, Object>{
                        'apiName' => fieldSetMemberObj.getFieldPath()
                        , 'type' => String.valueOf(fieldSetMemberObj.getType())
                        , 'label' => fieldSetMemberObj.getLabel()
                        , 'required' => fieldSetMemberObj.getRequired()
                });
            }
        }
        return listReturnFieldSet;
    }

    // PickList Return Value
    // [{label: '', value: ''}, {label: '', value: ''}]
    public static List<Map<String, String>> getPickListValues(String objectType, String selectedField, Boolean isNone) {
        List<Map<String, String>> pickListValuesList = new List<Map<String, String>>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        if(isNone) {
            pickListValuesList.add(new Map<String, String>{
                    'label' => '--None--',
                    'value' => 'none'
            });
        }

        for(Schema.PicklistEntry pickListVal : ple) {
            pickListValuesList.add(new Map<String, String>{
                    'label' => pickListVal.getLabel(),
                    'value' => pickListVal.getValue()
            });
        }
        return pickListValuesList;
    }

    public static Boolean isExistField(String objectName, String fieldName){
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType sObjectType = globalDescribe.get(objectName);

        if (sObjectType == null) return false;
        Map<String, Schema.SObjectField> fields = sObjectType.getDescribe().fields.getMap();

        if (fields.containsKey(fieldName)) return true;
        else return false;
    }

    public static String getLightningURL(){
        return URL.getOrgDomainUrl().toExternalForm();
    }

}