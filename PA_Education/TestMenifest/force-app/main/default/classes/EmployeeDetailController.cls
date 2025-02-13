/**
 * Created by attar on 2020-11-17.
 */

public with sharing class EmployeeDetailController {
    public static Employee objEmployees {get; set;}
    public static List<Qualification__c> empLicense {get; set;}
    public static List<Career> empCareer{get; set;}
    public static String location {get; set;}
    public static String work {get; set;}

    public EmployeeDetailController(ApexPages.standardController controller){
        if (objEmployees == null) {
            objEmployees = new Employee();
        }

        if (empLicense == null) {
            empLicense = new List<Qualification__c>();
        }

        if (empCareer == null) {
            empCareer = new List<Career>();
        }

        String recordId = ApexPages.currentPage().getParameters().get('recordId');
        objEmployees = doGetData(recordId);
    }

//    @AuraEnabled
//    public static Boolean doFind(String recordId) {
//        List<Employee__c> listObj = new List<Employee__c>([
//                SELECT Reason__c, Clear__c
//                FROM Employee__c
//                WHERE Id = :recordId
//        ]);
//
//        if (listObj.get(0).Reason__c == null && listObj.get(0).Clear__c == null) {
//            return true;
//        }
//        else {
//            return false;
//        }
//    }


    @AuraEnabled
    public static Employee doGetData(String recordId){
        Employee employee = new Employee();

        System.debug(recordId);
        List<Employee__c> listEmployee = new List<Employee__c>([
                SELECT Name, Birthday__c,
                        CurrentAddress__c, MobilePhone__c,
                        Department__c,
                        ExitDate__c,
                        MilitaryServiceDiv__c,
                        JoinDate__c,
                        UpdateDate__c,
                        Position__c,
                        Dependents__c,
                        DismissalDate__c,
                        Clear__c,
                        Reason__c
                FROM Employee__c
                WHERE Id =:recordId
        ]);

        List<Qualification__c> listLicense = new List<Qualification__c>([
                SELECT Name
                FROM Qualification__c
                WHERE Employee_Name__c =: recordId
        ]);

        List<EducationalHistory__c> listEducation = new List<EducationalHistory__c>([
                SELECT Degree__c
                FROM EducationalHistory__c
                WHERE Employee_Name__c =:recordId
                ORDER BY GraduatedDate__c DESC LIMIT 1
        ]);

        List<Career__c> listCareer = new List<Career__c>([
                SELECT Name, CareerExitDate__c, CareerJoinDate__c
                FROM Career__c
                WHERE Employee_Name__c =:recordId
        ]);

        Employee__c objEmployees = listEmployee.get(0);

        if (objEmployees.Position__c == '1' || objEmployees.Position__c == '10') {
            location = '본사';
            work = '관리 및 컨설팅';
        }

        else {
            location = '외주처';
            work = '시스템 개발';
        }

        if (!listLicense.isEmpty()) {
            for(Qualification__c objQualification : listLicense) {
                empLicense.add(objQualification);
            }
        }

        if (!listEducation.isEmpty()) {
            EducationalHistory__c objEducationalHistory = listEducation.get(0);
            employee.education = objEducationalHistory.Degree__c;
        }

        if (!listCareer.isEmpty()) {
            for(Career__c objCareer : listCareer) {
                Career obj = new Career();

                obj.company = objCareer.Name;
                if (objCareer.CareerExitDate__c != null && objCareer.CareerJoinDate__c != null) {
                    obj.period = String.valueOf(objCareer.CareerExitDate__c.year() - objCareer.CareerJoinDate__c.year() + 1);
                }
                empCareer.add(obj);
            }
        }
        else {
            Career obj = new Career();

            obj.company = '없음';
            obj.period = '';
            empCareer.add(obj);
        }

        if (objEmployees.Birthday__c != null) {
            String strBirthYear = String.valueOf(objEmployees.Birthday__c.year());
            String strBirthMonth = String.valueOf(objEmployees.Birthday__c.month());
            String strBirthDay = String.valueOf(objEmployees.Birthday__c.day());
            String strBirthDate = strBirthYear + '.' + strBirthMonth + '.' + strBirthDay;

            employee.birthday = strBirthDate;
        }
        else {
            employee.birthday = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;년&nbsp;&nbsp;&nbsp;&nbsp;월&nbsp;&nbsp;&nbsp;&nbsp;일';
        }

        if (objEmployees.ExitDate__c != null) {
            String strExitYear = String.valueOf(objEmployees.ExitDate__c.year());
            String strExitMonth = String.valueOf(objEmployees.ExitDate__c.month());
            String strExitDay = String.valueOf(objEmployees.ExitDate__c.day());
            String strExitDate = strExitYear + '년' + strExitMonth + '월' + strExitDay + '일';

            employee.exitDate = strExitDate;
        }
        else {
            employee.exitDate = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;년&nbsp;&nbsp;&nbsp;&nbsp;월&nbsp;&nbsp;&nbsp;&nbsp;일';
        }

        if (objEmployees.JoinDate__c != null) {
            String strJoinYear = String.valueOf(objEmployees.JoinDate__c.year());
            String strJoinMonth = String.valueOf(objEmployees.JoinDate__c.month());
            String strJoinDay = String.valueOf(objEmployees.JoinDate__c.day());
            String strJoinDate = strJoinYear + '년' + strJoinMonth + '월' + strJoinDay + '일';

            employee.joinDate = strJoinDate;
        }
        else {
            employee.joinDate = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;년&nbsp;&nbsp;&nbsp;&nbsp;월&nbsp;&nbsp;&nbsp;&nbsp;일';
        }

        if (objEmployees.UpdateDate__c != null) {
            String strUpdateYear = String.valueOf(objEmployees.UpdateDate__c.year());
            String strUpdateMonth = String.valueOf(objEmployees.UpdateDate__c.month());
            String strUpdateDay = String.valueOf(objEmployees.UpdateDate__c.day());
            String strUpdateDate = strUpdateYear + '년' + strUpdateMonth + '월' + strUpdateDay + '일';

            employee.updateDate = strUpdateDate;
        }
        else {
            employee.updateDate = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;년&nbsp;&nbsp;&nbsp;&nbsp;월&nbsp;&nbsp;&nbsp;&nbsp;일';
        }

        employee.name = objEmployees.Name;
        employee.currentAddress = objEmployees.CurrentAddress__c;
        employee.mobilePhone = objEmployees.MobilePhone__c;
        employee.department = objEmployees.Department__c;
        employee.reason = objEmployees.Reason__c;
        //employee.militaryType = objEmployees.MilitaryType__c;
        employee.militaryServiceDiv = objEmployees.MilitaryServiceDiv__c;
        //employee.clear = objEmployees.Clear__c;

        //2023.06.13 yj.kim 추가
        employee.dependents = objEmployees.Dependents__c;
        employee.goldClear = objEmployees.Clear__c;
        if (objEmployees.DismissalDate__c != null) {
            String strDismissalYear = String.valueOf(objEmployees.DismissalDate__c.year());
            String strDismissalMonth = String.valueOf(objEmployees.DismissalDate__c.month());
            String strDismissalDay = String.valueOf(objEmployees.DismissalDate__c.day());
            String strDismissalDate = strDismissalYear + '년' + strDismissalMonth + '월' + strDismissalDay + '일';

            employee.dismissalDate = strDismissalDate;
        }else{
            employee.dismissalDate = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;년&nbsp;&nbsp;&nbsp;&nbsp;월&nbsp;&nbsp;&nbsp;&nbsp;일';
        }

        return employee;
    }

    @AuraEnabled
    public static void doSaveData(String paramReason, String paramClear, String recordId) {
        List<Employee__c> listObj = new List<Employee__c>([
                SELECT Name
                FROM Employee__c
                WHERE Id = :recordId
        ]);
/*        if (paramReason != null) {
            listObj.get(0).Reason__c = paramReason;
        }
        if (paramClear != null) {
            listObj.get(0).Clear__c = paramClear;
        }*/
        update listObj;
    }

    public class Employee {
        public String name{get; set;}
        public String birthday{get; set;}
        public String currentAddress{get; set;}
        public String mobilePhone{get; set;}
        public String department{get; set;}
        public String exitDate{get; set;}
        public String reason{get; set;}
        //public String militaryType{get; set;}
        public String militaryServiceDiv{get; set;}
        //public String clear{get; set;}
        public String joinDate{get; set;}
        public String education{get; set;}
        public String strId {get; set;}
        public String updateDate{get; set;}

        //2023.06.13 yj.kim 추가
        public String dependents {get; set;}
        public String dismissalDate {get; set;}
        public String goldClear {get; set;}
    }

    public class Career {
        public String company{get; set;}
        public String period{get; set;}
    }
}