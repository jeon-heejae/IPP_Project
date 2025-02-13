/**
 * ==================================================================================
 * File Name         : HPTrekRecordsViewController
 * Author            : Changjoo.Sohn
 * Group             : Daeu Nextier
 * Description       : 
 * Modification Logs
 * ==================================================================================
 *   Ver     Date          Author          Modification
 * ==================================================================================
 *   1.0   2022-01-18     Changjoo.Sohn   Initial Version
**/
public without sharing class HPTrekRecordsViewController {
    @AuraEnabled
    public static List<WrapperTrekRecord> doSearchTrekRecords() {
        //  전체 실적 리스트를 받아 리턴.
        List<TrekRecord__c> listTrekRecords = [
                SELECT Id, OrderNum__c, StartYear__c, Account__r.Name, ProjectName__c, Challenge__c, OurApproach__c, ApproachSolution__c
                FROM TrekRecord__c
                ORDER BY StartYear__c DESC, OrderNum__c ASC
        ];

        List<WrapperTrekRecord> listWrapperTrekRecords = new List<WrapperTrekRecord>();
        if(!listTrekRecords.isEmpty()){
            Integer idx = 1;
            for(TrekRecord__c objTrekRecord : listTrekRecords){
                listWrapperTrekRecords.add(new WrapperTrekRecord(idx, objTrekRecord));
                idx++;
            }
        }

        return listWrapperTrekRecords;
    }

    @AuraEnabled
    public static TrekRecord__c getRecordById(String recordId) {
        TrekRecord__c objTrekRecord = [
                SELECT Id, Account__r.Name, OrderNum__c, StartYear__c, OurApproach__c, Challenge__c, ProjectName__c, ApproachSolution__c
                FROM TrekRecord__c
                WHERE Id = :recordId
        ];

        return objTrekRecord;
    }

    public class WrapperTrekRecord {
        @AuraEnabled public String IndexNumber;
        @AuraEnabled public String Id;
        @AuraEnabled public String AccountName;
        @AuraEnabled public String ProjectName;
        @AuraEnabled public String StartYear;
        @AuraEnabled public String ApproachSolution;
        @AuraEnabled public String Challenge;
        @AuraEnabled public String OurApproach;
        @AuraEnabled public Integer OrderNum;

        public WrapperTrekRecord(Integer idx, TrekRecord__c objTrekRecord){
            this.IndexNumber = idx == null ? '' : String.valueOf(idx);
            this.Id = objTrekRecord.Id == null ? '' : String.valueOf(objTrekRecord.Id);
            this.AccountName = objTrekRecord.Account__r.Name == null ? '' : objTrekRecord.Account__r.Name;
            this.ProjectName = objTrekRecord.ProjectName__c == null ? '' : objTrekRecord.ProjectName__c;
            this.StartYear = objTrekRecord.StartYear__c == null ? '' : objTrekRecord.StartYear__c;
            this.ApproachSolution = objTrekRecord.ApproachSolution__c == null ? '' : objTrekRecord.ApproachSolution__c;
            this.Challenge = objTrekRecord.Challenge__c == null ? '' : objTrekRecord.Challenge__c;
            this.OurApproach = objTrekRecord.OurApproach__c == null ? '' : objTrekRecord.OurApproach__c;
            this.OrderNum = objTrekRecord.OrderNum__c == null ? 0 : Integer.valueOf(objTrekRecord.OrderNum__c);
        }
    }
}