/**
 * Created by Kwanwoo.Jeon on 2024-02-02.
 */
@IsTest
public with sharing class CreateHoliday_test {
    @IsTest
    static void doTest(){
        test.StartTest();
        CreateHoliday_sc s = new CreateHoliday_sc() ;
        String sch = '0 1 0 * * ?';
        system.schedule('Test HolidayScheduler', sch, s);
        test.StopTest();
    }
}