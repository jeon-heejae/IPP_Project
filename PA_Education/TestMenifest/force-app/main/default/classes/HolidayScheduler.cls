global class HolidayScheduler implements Schedulable {

    global void execute(SchedulableContext SC) {
        HolidayUpdateStatusBatch  batch = new HolidayUpdateStatusBatch () ;
        date today = system.today();
        date firstDate = system.today().addMonths(6).addDays(10);
        date secondDate = system.today().addMonths(2);
        string todayStr = string.valueOf(today.year()) + '-' + ('0'+string.valueOf(today.month())).right(2) + '-' + ('0'+string.valueOf(today.day())).right(2);
        string firstDateStr = string.valueOf(firstDate.year()) + '-' +  ('0'+string.valueOf(firstDate.month())).right(2) + '-' + ('0'+string.valueOf(firstDate.day())).right(2);
        string secondDateStr = string.valueOf(secondDate.year()) + '-' + ('0'+string.valueOf(secondDate.month())).right(2) + '-' + ('0'+string.valueOf(secondDate.day())).right(2);
        string query  = ' SELECT Holiday_User__c,Holiday_JoinDate__c, Holiday_IsAnnualleave__c,Holiday_PeriodEnd__c,Holiday_Calculated__c,Holiday_GivenHolidays__c,Holiday_UseDays__c,Holiday_Remain__c ';
        query += ' FROM Holiday__c ';
        query += ' where Holiday_PeriodEnd__c in( ' + todayStr + ' ,  ' + firstDateStr  + ' , ' + secondDateStr   + ' )';
        list<Holiday__c> hLst = Database.query(query);
        system.debug(query);
        system.debug(hLst);
        
        batch.query=query;
        Database.executeBatch(batch,10);
    }
}