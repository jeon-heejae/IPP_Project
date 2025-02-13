/**
 * Created by user on 2024-08-09.
 */

public with sharing class TaxFileUploadController {

    @AuraEnabled
    public static List<CorporateCardBilling__c> getBillingList(Integer Year, Integer Month) {

        // DateTime startDate = DateTime.newInstance(Year, Month, 1,0,0,0);//
        // DateTime endDate = startDate.addMonths(1);

        DateTime startDate = DateTime.newInstance(Year, Month,1,0,0,0);//
        DateTime endDate = startDate.addmonths(1).addDays(15);
        endDate = DateTime.newInstance(endDate.year(), endDate.month(),1,0,0,0);

        System.debug('startDate :: ' + JSON.serialize(startDate));
        System.debug('endDate :: ' + JSON.serialize(endDate));

        List<CorporateCardBilling__c> BillingList = [
                SELECT Id, Name, BillingDate__c, StoreBusinessNumber__c, BillingAmount__c
                FROM CorporateCardBilling__c
                WHERE BillingDate__c  >= :startDate
                AND BillingDate__c < :endDate
                AND StoreBusinessNumber__c != ''
                ORDER BY BillingDate__c DESC
        ];
        System.debug(BillingList);

        return BillingList;
    }

    @AuraEnabled
    public static Map<String, String> updateBillingList(List<CorporateCardBilling__c> billingList , List<List<String>> data){

        Map<String,List<String>> dataMap = new Map<String,List<String>>();
        for (List<String> d : data){
            String beforeD = d[0];
            String afterD = beforeD.replaceAll('[^0-9]', '');
            dataMap.put(afterD,d);
        }

        System.debug('billingList: ' + billingList);
        List<CorporateCardBilling__c> updateBillingList = new List<CorporateCardBilling__c>();
        for (CorporateCardBilling__c b : billingList){
            String busNumber        = b.StoreBusinessNumber__c;
            if (busNumber == null) {
                busNumber = '';
            }
            String cleanedBusNumber = busNumber != '' ? busNumber.replaceAll('[^0-9]', '') : '';
            if(cleanedBusNumber!='' && dataMap.containsKey(cleanedBusNumber)) {
                List<String> mData     = dataMap.get(cleanedBusNumber);
                b.Tax_StoreType__c     = mData[1];
                b.Tax_BusinessType1__c = mData[2];
                b.Tax_BusinessType2__c = mData[3];
                b.Tax_deduction1__c    = mData[4];
                b.Tax_deduction2__c    = mData[5];
                updateBillingList.add(b);
            }

        }

        Database.SaveResult[] sR = Database.update(updateBillingList, false);

        Map<String, String> resultMap = new Map<String, String>();
        //List<String> SuccessList = new List<String>;
        //List<String> FailList    = new List<String>;
        Integer i = 0;
        for (Database.SaveResult a : sR) {
            if (a.isSuccess()) {
                resultMap.put(updateBillingList[i].Name, 'Success');
            } else {
                String mss;
                for(Database.Error err : a.getErrors()){
                    mss += ' ' + err.getMessage();
                }
                resultMap.put(updateBillingList[i].Name, 'Fail-' + mss);
            }
            i++;
        }
        System.debug('resultMap: ' + resultMap);

        return resultMap;
    }


}