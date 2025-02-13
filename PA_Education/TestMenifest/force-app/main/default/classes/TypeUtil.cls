/**
 * @description       : SOQL 타입 유틸 클래스
 * @author            : jonghyun.kim@daeunextier.com
 * @group             : 
 * @last modified on  : 07-03-2020
 * @last modified by  : jonghyun.kim@daeunextier.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   07-03-2020   jonghyun.kim@daeunextier.com   Initial Version
**/
public abstract class TypeUtil {
    public TypeUtil() {}

    public static List<SObject> createSObjectList(SObject record) {
        String listType = 'List<' + record.getSObjectType() + '>';
        List<SObject> records = (List<SObject>) create(listType);

        records.add(record);

        return records;
    }

    public static Object create(String objectName) {
        return Type.forName(objectName).newInstance();
    }

    /*
    사용 안함. Test 2020.11.16
    public static SObjectField feildTypeCasting(String field) {
        List<String> splitString = field.split('\\.');

        // store the object/field names
        String objectName = splitString[0];
        String fieldName = splitString[1];

        // get the SObjectType
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);

        // get the fields on the object
        Map<String, SObjectField> fieldMap = objectType.getDescribe().fields.getMap();

        // The key to the map is the api name of the field
        Schema.SobjectField theField = fieldMap.get(fieldName);

        return theField;
    }
    */

}