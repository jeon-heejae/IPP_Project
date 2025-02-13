/**
 * Created by JWJANG on 2023-02-15.
 */
public with sharing class HolidayHistoryInsert {

    final static String OBJECT_API_NAME = 'Holiday__c';
    final static String FIELD_SET_API_NAME = 'HolidayHistory';

    public static void doHolidayHistoryInsert(List<SObject> listNew, Map<Id, SObject> mapOld) {
        List<Map<String, Object>> listFieldMap = DN_Util.getFieldSet(OBJECT_API_NAME, FIELD_SET_API_NAME);

        List<HolidayHistory__c> listHolidayHistories = new List<HolidayHistory__c>();
        
        HolidayHistory__c tempHolidayHistory;
        Holiday__c tempOld;
        
        String apiName;
        String dataType;
        
        for(SObject obj : listNew) {
            tempOld = (Holiday__c) mapOld.get(obj.Id);

            for(Map<String, Object> objMap : listFieldMap) {
                if(obj.get((String)objMap.get('apiName')) != tempOld.get((String)objMap.get('apiName'))) {
                    apiName = (String)objMap.get('apiName');
                    dataType = (String)objMap.get('type');
                    System.debug(String.format('apiName : {0}, type : {1}', new List<Object>{ apiName, dataType }));
                    System.debug('objMap::::' + JSON.serialize(objMap));

                    tempHolidayHistory = new HolidayHistory__c();
                    tempHolidayHistory.Holiday__c = obj.Id;
                    tempHolidayHistory.Field__c = (String)objMap.get('label');

                    if(dataType == 'BOOLEAN') {
//                        tempHolidayHistory.Original_Value__c = String.valueOf((Boolean)tempOld.get(apiName));
//                        tempHolidayHistory.New_Value__c = String.valueOf((Boolean)obj.get(apiName));
                    } else if(dataType == 'DATE') {
//                        tempHolidayHistory.Original_Value__c = String.valueOf((Date)tempOld.get(apiName));
//                        tempHolidayHistory.New_Value__c = String.valueOf((Date)obj.get(apiName));
                    } else if(dataType == 'DATETIME') {
//                        tempHolidayHistory.Original_Value__c = String.valueOf((Datetime)tempOld.get(apiName));
//                        tempHolidayHistory.New_Value__c = String.valueOf((Datetime)obj.get(apiName));
                    } else if(dataType == 'NUMBER') {
                        tempHolidayHistory.Original_Value__c = String.valueOf((Decimal)tempOld.get(apiName));
                        tempHolidayHistory.New_Value__c = String.valueOf((Decimal)obj.get(apiName));
                    } else if(dataType == 'CURRENCY') {
//                        tempHolidayHistory.Original_Value__c = String.valueOf((Decimal)tempOld.get(apiName));
//                        tempHolidayHistory.New_Value__c = String.valueOf((Decimal)obj.get(apiName));
                    } else if(dataType == 'DECIMAL') {
                        tempHolidayHistory.Original_Value__c = String.valueOf((Decimal)tempOld.get(apiName));
                        tempHolidayHistory.New_Value__c = String.valueOf((Decimal)obj.get(apiName));
                    } else if(dataType == 'DOUBLE') {
                        tempHolidayHistory.Original_Value__c = String.valueOf((Decimal)tempOld.get(apiName));
                        tempHolidayHistory.New_Value__c = String.valueOf((Decimal)obj.get(apiName));
                    } else if(dataType == 'PERCENT') {
//                        tempHolidayHistory.Original_Value__c = String.valueOf((Decimal)tempOld.get(apiName));
//                        tempHolidayHistory.New_Value__c = String.valueOf((Decimal)obj.get(apiName));
                    } else if(dataType == 'PICKLIST') {
//                        String strBeforeLabel = '';
//                        String strBeforeValue = (String)tempOld.get(apiName);
//
//                        String strNewLabel = '';
//                        String strNewValue = (String)obj.get(apiName);
//
//                        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(OBJECT_API_NAME);
//                        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
//                        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(apiName).getDescribe();
//                        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
//                        for (Schema.PicklistEntry pickListVal : ple) {
//                            if(pickListVal.getValue() == strBeforeValue) {
//                                strBeforeLabel = pickListVal.getLabel();
//                            }
//
//                            if(pickListVal.getValue() == strNewValue) {
//                                strNewValue = pickListVal.getLabel();
//                            }
//                        }
//
//                        tempHolidayHistory.Original_Value__c = strBeforeLabel;
//                        tempHolidayHistory.New_Value__c = strNewValue;
                    }
                    else if(dataType == 'REFERENCE') {
//                        tempHolidayHistory.Original_Value__c = String.valueOf(tempOld.get(apiName));
//                        tempHolidayHistory.New_Value__c = String.valueOf(obj.get(apiName));
                    }
                    else {
                        tempHolidayHistory.Original_Value__c = (String)tempOld.get(apiName);
                        tempHolidayHistory.New_Value__c = (String)obj.get(apiName);
                    }

                    tempHolidayHistory.User__c = UserInfo.getUserId();
                    tempHolidayHistory.ChangeDT__c = DateTime.now();
                    listHolidayHistories.add(tempHolidayHistory);
                }
            }
        }

        System.debug(String.format('listHolidayHistories[{0}] : {1}', new List<Object> { listHolidayHistories.size(), listHolidayHistories }));
        if(!listHolidayHistories.isEmpty()) {
            insert listHolidayHistories;
        }
    }
}