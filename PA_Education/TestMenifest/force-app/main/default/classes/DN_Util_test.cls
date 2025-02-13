/**
 * Created by Kwanwoo.Jeon on 2023-12-22.
 */
@IsTest
public with sharing class DN_Util_test {
    @IsTest
    static void doTest(){
        DN_Util.getFieldSet('Holiday__c', 'HolidayHistory');
        DN_Util.getPickListValues('HolidayWorkDetail__c', 'WorkingTime__c', true);

    }
}