public class AttendanceStudentController {
    @AuraEnabled
    public static List<Contact> getAttendingStudents(Id OfflineClassId) {

        //Id OfflineClassId='a00NS00000FT7dOYAT';
        
        OfflineClass__c objOfflineClass=[SELECT Teacher__c FROM OfflineClass__c where id=:OfflineClassId];

        Teacher__c objTeacher=[SELECT Id,NextClass__c FROM Teacher__c where id=:objOfflineClass.Teacher__c];
        
        List<Contact> listStudent
        =[SELECT Id, LastName, BirthdayDate__c  FROM Contact WHERE OfflineClassDate__c=:objTeacher.NextClass__c AND Teacher__c=:objTeacher.Id];
        
        System.debug(listStudent);
        return listStudent;
    }
}