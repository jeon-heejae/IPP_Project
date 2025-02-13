/**
 * @description       : 
 *                      
 * @author            : hyunsoo.song@daeunextier.com
 * @group             :
 * @last modified on  : 2022-11-14
 * @last modified by  : hyunsoo.song@daeunextier.com
 * Modifications Log
 * Ver     Date             Author               Modification
 * 1.0   2022-11-14   hyunsoo.song@daeunextier.com   Initial Version
 */
@isTest
public with sharing class Outsoursing_tr_test {
    @isTest
    static void doTest(){
        Account AC = new Account();
        AC.Name = '테스트계정';
        AC.ShortName__c ='Test Short Name';
        insert AC;

        Item__c MasterIT = new Item__c();
        MasterIT.Name = '품목마스터';
        MasterIT.Code__c = 'ZX0000001';
        insert MasterIT;

        Item__c IT = new Item__c();
        IT.Name = '품목테스트';
        IT.Code__c = 'ZZ0000001';
        IT.ProductItem__c = MasterIT.Id;
        insert IT;

        ProcessProduct__c PP = new ProcessProduct__c();
        PP.Date__c = system.today();
        PP.PartList__c = IT.Code__c;
        PP.TraceabilityAssemsetId__c = 1;
        insert PP;


        Inventory__c IV = new Inventory__c();
        IV.Name = 'ZZ0000001000001';
        IV.Account__c = AC.id;
        IV.Item__c = IT.Id;
        IV.Assemset_Seq__c = 1;
        insert IV;

        Test.startTest();

        Outsoursing__c OS = new Outsoursing__c();
        OS.Item__c = IT.Id;
        OS.Inventory__c = IV.Id;
        insert OS;

        Test.stopTest();
    }
}