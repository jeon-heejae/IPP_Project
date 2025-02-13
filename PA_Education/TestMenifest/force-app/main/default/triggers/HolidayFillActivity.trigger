trigger HolidayFillActivity on Holiday__c (before update) {
    for(Holiday__c newHoliday : trigger.New){
        Holiday__c oldHoliday = trigger.oldMap.get(newHoliday.Id);
        If(newHoliday.Holiday_Unpaid__c!= oldHoliday.Holiday_Unpaid__c)
            newHoliday.Holiday_LastActivity__c = 'Unpaid Holiday was change from ' + string.valueOf(oldHoliday.Holiday_Unpaid__c ) + ' to ' + string.valueOf(newHoliday.Holiday_Unpaid__c) + '.';
    }    
}