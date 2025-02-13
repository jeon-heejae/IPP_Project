/************************************************************************************
* File Name   	    : User_tr TestClass
* Author	  		: Yeonlim
* Date				: 2023-12-18
* Modification Log
* ===================================================================================
* Ver      Date            Author          Modification
* ===================================================================================
* 1.0      2023-12-18         Yeonlim           Create
************************************************************************************/
@IsTest
public with sharing class User_tr_test {
    @IsTest
    public static void User_tr_test() {
        Profile objProfile = [SELECT Id FROM Profile WHERE Name = 'Daeu Nextier Employee' LIMIT 1];
        System.debug('objProfile :: ' + objProfile);
        User objUser = new User(
                Username            = 'test@daeu.com',
                LastName            = 'test',
                Email               = 'test@daeu.com',
                Alias               = 'test',
                TimeZoneSidKey      = 'America/New_York',
                LocaleSidKey        = 'en_US',
                EmailEncodingKey    = 'ISO-8859-1',
                LanguageLocaleKey   = 'en_US',
                ProfileId           = objProfile.Id,
                User_PersonalNo__c  = '991224-2000000',
                Title               = '사원',
                Type__c             = '내부직원',
                User_JoinDate__c    = date.today(),
                Position__c = '9'
        );

        System.debug('objUser : ' + objUser);
        insert objUser;
    }
}