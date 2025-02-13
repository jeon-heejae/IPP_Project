/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-05-21     hs.jung          Create
*************************************************************************************/
public with sharing class EformsignSObjectInfoService {

    public static String getSObjectInfoJson(String objectApiName) {
        return JSON.serialize(getSObjectInfo(objectApiName));
    }

    public static Map<String, ObjectInfo> getSObjectInfo(String objectApiName) {
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType sObjectType = globalDescribe.get(objectApiName);
        if (sObjectType == null) {
            return null;
        }

        Schema.DescribeSObjectResult objDescribe = sObjectType.getDescribe();
        Map<String, ObjectInfo> result = new Map<String, ObjectInfo>();
        result.put('object', new ObjectInfo(objDescribe));
        System.debug(result);

        return result;
    }

    public class ObjectInfo {
        @AuraEnabled public String api;
        @AuraEnabled public String label;
        @AuraEnabled public List<FieldInfo> fields;
        @AuraEnabled public List<FieldInfo> efsFields;

        public ObjectInfo(Schema.DescribeSObjectResult objDescribe) {
            this.api = objDescribe.getName();
            this.label = objDescribe.getLabel();

            this.fields = getFieldInfos(objDescribe);
            this.efsFields = getconvertedFieldTypes(this.fields);
        }

        private List<FieldInfo> getFieldInfos(Schema.DescribeSObjectResult objDescribe) {
            List<FieldInfo> fieldInfos = new List<FieldInfo>();
            Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();

            for (Schema.SObjectField field : fieldMap.values()) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                // https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_enum_Schema_DisplayType.htm
                if (fieldDescribe.isAccessible() && fieldDescribe.isCreateable()) {
                    fieldInfos.add(new FieldInfo(fieldDescribe));
                }
            }

            return fieldInfos;
        }

        private List<FieldInfo> getconvertedFieldTypes(List<FieldInfo> fields) {
            Map<String, TypeInfo> fieldTypes = createFieldTypes();
            List<FieldInfo> result = new List<FieldInfo>();
            for (FieldInfo f : fields) {
                TypeInfo typeInfo = fieldTypes.get(f.type.toLowerCase());
                if (typeInfo != null && typeInfo.isUsed) {
                    result.add(new FieldInfo(f, typeInfo.type));
                }
            }

            return result;
        }

        private Map<String, TypeInfo> createFieldTypes() {
            final String LABEL_TYPE = 'LABEL';

            Map<String, TypeInfo> fieldTypes = new Map<String, TypeInfo>();
            // String
            fieldTypes.put('address', new TypeInfo(LABEL_TYPE));
            fieldTypes.put('url', new TypeInfo(LABEL_TYPE));
            fieldTypes.put('email', new TypeInfo(LABEL_TYPE));
            fieldTypes.put('phone', new TypeInfo(LABEL_TYPE));
            fieldTypes.put('picklist', new TypeInfo(LABEL_TYPE));
            fieldTypes.put('string', new TypeInfo(LABEL_TYPE));
            fieldTypes.put('textarea', new TypeInfo(LABEL_TYPE));
            fieldTypes.put('combobox', new TypeInfo(LABEL_TYPE));
            // String add Percent
            fieldTypes.put('percent', new TypeInfo(LABEL_TYPE));

            // Date
            fieldTypes.put('date', new TypeInfo(LABEL_TYPE));
            fieldTypes.put('time', new TypeInfo(LABEL_TYPE));
            // Date convert local Time
            fieldTypes.put('datetime', new TypeInfo(LABEL_TYPE));

            // Number
            fieldTypes.put('currency', new TypeInfo(LABEL_TYPE));
            fieldTypes.put('double', new TypeInfo(LABEL_TYPE));
            fieldTypes.put('integer', new TypeInfo(LABEL_TYPE));
            fieldTypes.put('long', new TypeInfo(LABEL_TYPE));
            // No Use
            fieldTypes.put('multipicklist', new TypeInfo(null));
            fieldTypes.put('anytype', new TypeInfo(null));
            fieldTypes.put('base64', new TypeInfo(null));
            fieldTypes.put('encryptedstring', new TypeInfo(null));
            fieldTypes.put('id', new TypeInfo(null));
            fieldTypes.put('location', new TypeInfo(null));
            fieldTypes.put('reference', new TypeInfo(null));
            fieldTypes.put('boolean', new TypeInfo(null));
            fieldTypes.put('datacategorygroupreference', new TypeInfo(null));

            /*
                // 타입 상세 설정 시, 사용
                final String STRING_TYPE = 'TEXTBOX';
                final String NUMBER_TYPE = 'NUMBER';
                final String DATE_TYPE = 'DATEPICKER';
                // String
                fieldTypes.put('address', new TypeInfo(STRING_TYPE));
                fieldTypes.put('url', new TypeInfo(STRING_TYPE));
                fieldTypes.put('email', new TypeInfo(STRING_TYPE));
                fieldTypes.put('phone', new TypeInfo(STRING_TYPE));
                fieldTypes.put('picklist', new TypeInfo(STRING_TYPE));
                fieldTypes.put('string', new TypeInfo(STRING_TYPE));
                fieldTypes.put('textarea', new TypeInfo(STRING_TYPE));
                fieldTypes.put('combobox', new TypeInfo(STRING_TYPE));
                // String add Percent
                fieldTypes.put('percent', new TypeInfo(STRING_TYPE));

                // Date
                fieldTypes.put('date', new TypeInfo(DATE_TYPE));
                fieldTypes.put('time', new TypeInfo(DATE_TYPE));
                // Date convert local Time
                fieldTypes.put('datetime', new TypeInfo(DATE_TYPE));

                // Number
                fieldTypes.put('currency', new TypeInfo(NUMBER_TYPE));
                fieldTypes.put('double', new TypeInfo(NUMBER_TYPE));
                fieldTypes.put('integer', new TypeInfo(NUMBER_TYPE));
                fieldTypes.put('long', new TypeInfo(NUMBER_TYPE));
            */
            return fieldTypes;
        }
    }

    public class FieldInfo {
        @AuraEnabled public String api;
        @AuraEnabled public String label;
        @AuraEnabled public String type;
        @AuraEnabled public List<PicklistOption> picklistOptions;

        public FieldInfo(Schema.DescribeFieldResult fieldDescribe) {
            this.api = fieldDescribe.getName();
            this.label = fieldDescribe.getLabel();
            this.type = String.valueOf(fieldDescribe.getType());

            if (this.type.equalsIgnoreCase('PICKLIST') || this.type.equalsIgnoreCase('MULTIPICKLIST') || this.type.equalsIgnoreCase('COMBOBOX')) {
                List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
                this.picklistOptions = new List<PicklistOption>();
                for (Schema.PicklistEntry entry : picklistEntries) {
                    if (entry.isActive()) {
                        this.picklistOptions.add(new PicklistOption(entry.getLabel(), entry.getValue()));
                    }
                }
            }
        }

        public FieldInfo(FieldInfo fieldInfo, String type) {
            this.api = fieldInfo.api;
            this.label = fieldInfo.label;
            this.picklistOptions = fieldInfo.picklistOptions;
            this.type = type;
        }
    }

    public class PicklistOption {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }

        public PicklistOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    public class TypeInfo {
        private Boolean isUsed;
        private String type; // e.g) "String", "Date", "Number", null
        public TypeInfo(String type) {
            this.type = type;
            if (type == null) {
                isUsed = false;
            } else {
                isUsed = true;
            }
        }
    }

    // 필드 타입 반환
    public static String getFieldType(String objectApiName, String fieldApiName) {
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType sObjectType = globalDescribe.get(objectApiName);
        Schema.DescribeSObjectResult sObjectDescribe = sObjectType.getDescribe();

        // 필드의 데이터 타입을 취득
        Map<String, Schema.SObjectField> fieldMap = sObjectDescribe.fields.getMap();
        Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldApiName).getDescribe();

        return String.valueOf(fieldDescribe.getType());
    }

    public static String getStartFieldId() {
        return 'SF/';
    }
}