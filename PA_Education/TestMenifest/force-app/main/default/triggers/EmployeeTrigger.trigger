/**
 * Created by Yeonlim on 2023-12-14.
 */

trigger EmployeeTrigger on Employee__c (before insert, before update, before delete, after insert, after update, after delete) {
    new Employee_tr().run();
}