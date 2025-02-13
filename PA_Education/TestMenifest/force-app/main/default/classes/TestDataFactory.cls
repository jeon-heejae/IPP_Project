@isTest
public class TestDataFactory {

    public static Profile getProfile(String P_name) { 

        Profile pf = [SELECT Id FROM Profile WHERE Name= :P_name];                  
        
        return pf;
    }
    
    public static User createUser(Profile pf) {
        
        User user = new User(Alias = 'testUser'
                            , Email='SysAdminTestuser@earth.org'
                            , EmailEncodingKey='UTF-8'
                            , LastName='Testing'
                            , LanguageLocaleKey='en_US'
                            , LocaleSidKey='en_US'
                            , EmployeeNumber='AC100000'
                            , ProfileId = pf.Id
                            , TimeZoneSidKey='Asia/Seoul'
                            , UserName='SysAdminTestuser@earth.org');
                                
        insert user;
        
        return user;
    }
    
}