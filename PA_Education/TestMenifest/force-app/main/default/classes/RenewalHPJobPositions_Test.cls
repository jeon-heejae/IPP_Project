/************************************************************************************
 * File Name   : RenewalHPJobPositions_Test.cls
 * Author      : SungJu.Kang
 * Date        : 2022. 01. 03
 * Target      : RenewalHPJobPositions.cls
 * Description : RenewalHPJobPositions.cls Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2022. 01. 03   SungJu.Kang            Create
*************************************************************************************/

@IsTest
private class RenewalHPJobPositions_Test {
    @IsTest
    static void itShould() {
        Test.startTest();
        JobPosition__c objJobPosition = new JobPosition__c();
        objJobPosition.WorkType__c = '정규직';
        objJobPosition.RecruitmentCategory__c = '공개채용';
        objJobPosition.Position__c = 'Developer';
        objJobPosition.Career__c = '신입';
        objJobPosition.Year__c = '2022';
        objJobPosition.OrderNum__c = 1;
        insert objJobPosition;

        RenewalHPJobPositions.getPositions(true);
        RenewalHPJobPositions.getPositions(false);
        RenewalHPJobPositions.loadMorePositions(true);
        RenewalHPJobPositions.loadMorePositions(false);

        Map<String, Object> mapTarget = new Map<String, Object>();
        mapTarget.put('Mobile', 01024451509);
        mapTarget.put('Applicant','Applicant');
        mapTarget.put('JobPositionId', objJobPosition.Id);
        mapTarget.put('BirthDate' , Date.today());
        mapTarget.put('Email' , 'sjyk@naver.com');

        RenewalHPJobPositions.doSaveApplyTo(mapTarget,'testclass', 'testdate','jpg');





        Test.stopTest();
    }
}