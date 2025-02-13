/**
 * Created by Kwanwoo.Jeon on 2023-12-13.
 */

trigger UserTrigger on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new User_tr().run();
}