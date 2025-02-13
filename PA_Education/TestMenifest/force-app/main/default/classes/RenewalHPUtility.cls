/**
 * =============================================
 * File Name    : RenewalHPUtility.cls
 * Author       : Gyubin Lee
 * Group        : Boundary
 * Date         : 2021. 12. 24
 * Description  : 유틸리티 클래스
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.1      2022. 04. 21    Gyubin Lee          Create
*/
public with sharing class RenewalHPUtility {

    public static String queryConstructor(String body, String tail) {
        return 'SELECT ' + body + ' FROM ' + tail;
    }
    
}