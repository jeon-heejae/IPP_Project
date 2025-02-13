/**
 * Created by jihwa on 2023-11-28.
 */
@isTest
public with sharing class WinnerBingoBoardController_test {
    @IsTest
    static void test_init(){
        Test.startTest();
        WinnerBingoBoardController.getInitData('ljh');
        Test.stopTest();
    }
}