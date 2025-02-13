/**
 * Created by sjhyk on 2022-01-20.
 */

@IsTest
private class HPClassViewController_Test {
    @IsTest
    static  void itShould() {
        Test.startTest();
        Class__c objClass = new Class__c();
        objClass.StartDate__c = Datetime.now();
        objClass.Subject__c = 'TestSubject';
        insert objClass;

        Map<String, Object> mapTarget = new Map<String, Object>();
        mapTarget.put('Mobile', 01024451509);
        mapTarget.put('Register','테스트');
        mapTarget.put('ClassId', objClass.Id);
        mapTarget.put('BirthDate' , Date.today());

        HPClassViewController.doSaveApplyTo(mapTarget);

        HPClassViewController.doSearchClasses();
        HPClassViewController.getRecordById(objClass.Id);

        Test.stopTest();
    }
}