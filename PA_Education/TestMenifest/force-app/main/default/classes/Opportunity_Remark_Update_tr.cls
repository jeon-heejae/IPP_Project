public with sharing class Opportunity_Remark_Update_tr {
    public static void DoOpportunityRemarkUpdate(List<Task> objs) {
        List<String> splitList = new List<String>();
        string strSplit = '';
        string strSplitAll ='';
        List<Task> targetTask = new List<Task>();
        
        for(Task obj:objs){
            if(targetTask<>null) targetTask.add(obj);
        }
        
        if(!targetTask.isEmpty()){
            Set<Id> opportunityId = new Set<Id>();
            for (Task obj:targetTask){
                splitList.add('--------------일자 : '+obj.ActivityDate.format()+'--------------♬');
                splitList.add('제목 : ' + obj.Subject + '♬');
                splitList.add('내용 : ' + obj.Description + '♬');
                splitList.add('------------------------------------------------------♬♬');
                opportunityId.add(obj.WhatId);
            }
            
            if(splitList.size() > 0){
                for(String getList : splitList){
                    strSplit += getList.replaceAll('♬','\n');
                }
            }
            
            List<Opportunity__c> opptyList = new List<Opportunity__c>();
            opptyList = [ SELECT Id, Remark__c FROM Opportunity__c WHERE Id=:opportunityId];
            
            if(!opptyList.isEmpty()){
                for(Opportunity__c opptyobj:opptyList){
                    if(opptyobj.Remark__c <> null || opptyobj.Remark__c <> ''){
                        system.debug('opptyobj.Remark__c========>'+opptyobj.Remark__c);
                        strSplitAll += strSplit + '\n' + opptyobj.Remark__c;
                        opptyobj.Remark__c = strSplitAll.replaceAll('null','');
                    }
                    update opptyobj;
                }        
            }
        }
    }
/****************************************************************************************************
*   테스트메소드
****************************************************************************************************/
    
    @TestVisible private static Void testMe(Task objs){
        System.debug('----------------Opportunity_Remark_Update_tr Test Start');
        
        List<Task> testTask = new List<Task>();
        testTask.add(objs);
        
    }
    
}