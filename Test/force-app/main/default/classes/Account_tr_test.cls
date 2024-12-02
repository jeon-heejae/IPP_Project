@isTest
public with sharing class Account_tr_test {
    @TestSetup
    static void Account_tr_testSetup(){
        
    }
    @isTest
    static void Account_tr_test(){
        System.Test.startTest();
        Account objAccount=new Account();
        objAccount.Name='Test Account';
        insert objAccount;
        System.Test.stopTest();
    }
}