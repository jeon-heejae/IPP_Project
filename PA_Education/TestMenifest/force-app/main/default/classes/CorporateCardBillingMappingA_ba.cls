/************************************************************************************
 * Description : 매입내역(CATS_TMP_ACQUIRE__c)을 법인카드청구내역(CorporateCardBilling__c)로
 *               데이터 매핑작업 배치
 *
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-12-09     yr.lee          Create
*************************************************************************************/

public with sharing class CorporateCardBillingMappingA_ba implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date dateLastMonth = Date.today().addMonths(-1);
        Integer year = dateLastMonth.year();
        Integer month = dateLastMonth.month();
        Date batchMonthStart = Date.newInstance(year, month, 1); // 해당월의 1일
        Date batchMonthEnd = dateLastMonth.toStartOfMonth().addMonths(1).addDays(-1); // 해당월의 말일
        String strBatchMonthStart = String.valueOf(batchMonthStart);
        String strBatchMonthEnd = String.valueOf(batchMonthEnd);

        String strQuery;
        strQuery =  ' SELECT Id, CardNo__c, PurchTot__c, Abroad__c, MccName__c, Class__c,' +
                ' SettDate__c, MerchAddr1__c, MerchBizNo__c, MerchName__c, PurchDate__c, PurchTime__c,' +
                ' VAT__c, VATYN__c, Tips1__c, Seq__c, ApprDate__c ';
        strQuery += ' FROM   CATS_TMP_ACQUIRE__c';
        strQuery += ' WHERE  ApprDate__c  >= :strBatchMonthStart '; 
        strQuery += ' AND    ApprDate__c  <= :strBatchMonthEnd ';
        System.debug('CorporateCardBillingMappingA_ba Query : ' + strQuery);

        return Database.getQueryLocator(strQuery);
    }

    public void execute(Database.BatchableContext bc, List<CATS_TMP_ACQUIRE__c> listTarget) {
        try {
            System.debug('listTarget :: ' + listTarget);
            Set<String> setCardNo = new Set<String>();
            Map<String, Id> mapCardNo = new Map<String, Id>();
            for(CATS_TMP_ACQUIRE__c objCTA : listTarget){
                setCardNo.add(objCTA.CardNo__c);
            }
            List<CorporateCard__c> listCorporateCards = [
                    SELECT Id, CardNumber__c
                    FROM CorporateCard__c
                    WHERE CardNumber__c IN :setCardNo
            ];
            for(CorporateCard__c objCC : listCorporateCards){
                mapCardNo.put(objCC.CardNumber__c, objCC.Id);
            }


            List<CorporateCardBilling__c> listCCBUpsert = new List<CorporateCardBilling__c>();
            CorporateCardBilling__c objTemp;
            for(CATS_TMP_ACQUIRE__c objCTA : listTarget){
                objTemp = new CorporateCardBilling__c();
                objTemp.CorporateCard__c = mapCardNo.get(objCTA.CardNo__c); //해당 카드번호에 맞는 값 찾기
                objTemp.Seq__c = String.valueOf(objCTA.Seq__c);
                //objTemp.CorporateCard__c = 'a3sF6000000V78pIAC';
                objTemp.CardNumber__c = objCTA.CardNo__c;
                objTemp.BillingAmount__c = objCTA.PurchTot__c;
                objTemp.BusinessType__c = objCTA.MccName__c;
                objTemp.ExpectedBillingDate__c = objCTA.SettDate__c != null ? Date.valueOf(objCTA.SettDate__c) : null;
                objTemp.StoreAddress__c = objCTA.MerchAddr1__c;
                objTemp.StoreBusinessNumber__c = objCTA.MerchBizNo__c;
                objTemp.StoreName__c = objCTA.MerchName__c;
                objTemp.VAT__c = objCTA.VAT__c;
                objTemp.VATYN__c = objCTA.VATYN__c;
                objTemp.Tips1__c = (objCTA.Tips1__c != null && objCTA.Tips1__c != '') ? Decimal.valueOf(objCTA.Tips1__c) : 0;
                objTemp.CountryType__c = '';
                if(objCTA.Abroad__c == 'A') objTemp.CountryType__c = '국내매출';
                if(objCTA.Abroad__c == 'B') objTemp.CountryType__c = '국외매출';
                if(objCTA.Class__c == 'A'){
                    objTemp.CancelClassification__c = '취소없음';
                    objTemp.Acquire__c = objCTA.Id;
                }
                if(objCTA.Class__c == 'B'){
                    objTemp.CancelClassification__c = '매입취소';
                    objTemp.AcquireCancel__c = objCTA.Id;
                }

                //BillingDate__c 설정
                String strDate = objCTA.ApprDate__c;
                String strTime = objCTA.PurchTime__c;
                if(objCTA.PurchTime__c == null || objCTA.PurchTime__c == '') strTime = '000000';
                if(strTime.length() != 6) strTime = '000000';

                //BillingDate__c 설정 - 시, 분, 초
                Integer hour = Integer.valueOf(strTime.substring(0, 2));
                Integer minute = Integer.valueOf(strTime.substring(2, 4));
                Integer second = Integer.valueOf(strTime.substring(4, 6));
                //BillingDate__c 설정 - 년, 월, 일
                Integer year = Integer.valueOf(strDate.substring(0, 4));
                Integer month = Integer.valueOf(strDate.substring(5, 7));
                Integer day = Integer.valueOf(strDate.substring(8, 10));
                Datetime billingDatetime = Datetime.newInstance(year, month, day, hour, minute, second);
                objTemp.BillingDate__c = billingDatetime;
                listCCBUpsert.add(objTemp);
                System.debug('objTemp :: ' + objTemp);
            }
            upsert listCCBUpsert Seq__c;
        }
        catch(Exception e) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] to = new String[]{
                    'yerin.lee@daeunextier.com'
            };
            email.setToAddresses(to);
            email.setSubject('대유넥스티어 법인카드경비신청 Batch 에러');
            String body = '[Error Message]<br/>';
            body += e.getMessage();
            body += '<br/><br/>[Line Number]<br/>';
            body += e.getLineNumber();
            body += '<br/><br/>[Cause]<br/>';
            body += e.getCause();
            body += '<br/><br/>[Type Name]<br/>';
            body += e.getTypeName();
            email.setHtmlBody(body);
            System.debug('body :: ' + e.getMessage());
            OrgWideEmailAddress[] emailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'admin@daeunextier.com'];
            if(emailAddress.size() > 0){
                email.setOrgWideEmailAddressId(emailAddress.get(0).Id);
            }
            if(!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        }
    }

    public void finish(Database.BatchableContext bc) {

    }
}