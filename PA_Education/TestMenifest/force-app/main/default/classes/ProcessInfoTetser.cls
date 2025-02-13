/**
 * Object       : ProcessInfoTetser.cls
 * Function     : 
 * Author       : yohan.kang
 * Date         : 2015.03.21
 * Tester 		: ProcessInfo.trigger
 					ProcessInfoUtil.Cls
 * page			: 
 * Description  : 
 */
@isTest
private class ProcessInfoTetser {
    @isTest
    static void itShould(){
        Item__c IT = new Item__c();
        IT.Name = '품목테스트';
        IT.Code__c = 'ZZ0000001';
        insert IT;
        
        ProcessInfo__c PI = new ProcessInfo__c();
        PI.Name = '공정정보테스트';
        PI.Item__c = IT.Id;
        insert PI;
        
        

        PI.Name = '공정정보테스트수정';
        update PI;
        
        ProcessInfoDetail__c PID = new ProcessInfoDetail__c();
        PID.ProcessInfo__c = PI.Id;
        PID.Item__c = IT.Id;
        PID.Seq__c = 1;
        insert PID;
        
        ProcessInfoUtil.TestMe(PI, PID);

        delete PID;
    }
}