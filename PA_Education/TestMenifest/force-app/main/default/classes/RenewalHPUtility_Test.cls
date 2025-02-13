/**
 * ===================================================================================
 * File Name   : RenewalHPUtility_Test.cls
 * Author      : Gyubin.Lee
 * Date        : 2022. 06. 09
 * Target      : RenewalHPUtility.cls
 * Description : RenewalHPUtility_Test.cls Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
 * 1.0      2022. 06. 09    Gyubin.Lee          Create
 * ===================================================================================
 */

@IsTest
private class RenewalHPUtility_Test {
  @IsTest
  static void queryConstructorTest() {
    Test.startTest();
    String body = 'Id';
    String tail = 'Accounts';
    String query = RenewalHPUtility.queryConstructor(body, tail);
    System.assertEquals(
      'SELECT Id FROM Accounts',
      query,
      '쿼리가 유효해야 합니다.'
    );
    Test.stopTest();
  }
  
}