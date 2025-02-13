/**
 * Created by Kwanwoo.Jeon on 2024-02-02.
 */

global without sharing class CreateHoliday_sc implements Schedulable{
    global void execute(SchedulableContext SC) {
        HolidayManageController.doCreate();
    }
}