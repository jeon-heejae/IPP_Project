/**
 * Created by Kwanwoo.Jeon on 2024-02-21.
 */

trigger ApplicationTrainingCenterTrigger on ApplicationTrainingCenter__c (before insert, before update, before delete, after insert, after update, after delete) {
    new ApplicationTrainingCenter_tr().run();
}