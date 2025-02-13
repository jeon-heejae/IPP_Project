/************************************************************************************
 * File Name   : RenewalHPServiceSolution_Test.cls
 * Author      : SungJu.Kang
 * Date        : 2022. 01. 03
 * Target      : RenewalHPServiceSolution.cls
 * Description : RenewalHPServiceSolution.cls Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2022. 01. 03   SungJu.Kang            Create
*************************************************************************************/

@IsTest
private class RenewalHPServiceSolution_Test {
    @IsTest
    static void itShould() {
        Test.startTest();
        SolutionDelivery__c objSolutionDelivery = new SolutionDelivery__c();
        objSolutionDelivery.Title__c = 'TestTitle';
        insert objSolutionDelivery;

        RenewalHPServiceSolution.getDeliveries(true);
        RenewalHPServiceSolution.getDeliveries(false);
        //RenewalHPServiceSolution.loadMoreDeliveries();
        RenewalHPServiceSolution.getDeliveryById(objSolutionDelivery.Id, true);
        RenewalHPServiceSolution.getDeliveryById(objSolutionDelivery.Id, false);

        Test.stopTest();

    }
}