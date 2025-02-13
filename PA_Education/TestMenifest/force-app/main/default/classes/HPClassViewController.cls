/************************************************************************************
* File Name   		: HPClassViewController.cls
* Author	  		: SJ.Kang
* Date				: 2021.12.06
* Tester	  		: HPClassViewController.cls
* Description 		:
* Modification Log
* ===================================================================================
* Ver      Date            Author          Modification
* ===================================================================================
1.0      2021.12.06        SJ.Kang          Create
1.1      2022.01.19        CJ.Sohn          조회 레코드 및 강의 신청 메소드 수정
*************************************************************************************/

public without sharing class HPClassViewController {
    @AuraEnabled
    public static List<WrapperClass> doSearchClasses() {
        //  전체 실적 리스트를 받아 리턴.
        List<Class__c> listClasses = new List<Class__c>();
        listClasses = [
                SELECT Id, ClassName__c, Subject__c, Target__c, Times__c, Tuition__c, FORMAT(StartDate__c), FORMAT(EndDate__c), OrderNum__c
                FROM   Class__c
                ORDER BY StartDate__c DESC ,CreatedDate DESC
        ];

        List<WrapperClass> listWrapperClasses = new List<WrapperClass>();
        if(!listClasses.isEmpty()){
            Integer idx = 1;
            for(Class__c objClass : listClasses){
                listWrapperClasses.add(new WrapperClass(idx, objClass));
                idx++;
            }
        }

        return listWrapperClasses;
    }

    @AuraEnabled
    public static Class__c getRecordById(String recordId) {
        Class__c objClass = [
                SELECT Id, ClassName__c, Subject__c, Target__c, Times__c, Tuition__c, FORMAT(StartDate__c), FORMAT(EndDate__c), OrderNum__c, fm_Status__c
                FROM   Class__c
                WHERE Id = :recordId
        ];

        return objClass;
    }

    @AuraEnabled
    public static String doSaveApplyTo(Map<String, Object> paramMap){
        String Mobile = String.valueOf(paramMap.get('Mobile'));
        String Register = String.valueOf(paramMap.get('Register'));
        String ClassId = String.valueOf(paramMap.get('ClassId'));
        String BirthDate = String.valueOf(paramMap.get('BirthDate'));

        Registration__c objRegistration = new Registration__c();
        objRegistration.Mobile__c = Mobile;
        objRegistration.Register__c = Register;
        objRegistration.Class__c = ClassId;
        objRegistration.Birthdate__c = Date.valueOf(BirthDate);
        objRegistration.PersonalInformationUseAgreement__c = true;

        insert objRegistration;

        return '0';
    }

    public class WrapperClass {
        @AuraEnabled public String IndexNumber;
        @AuraEnabled public String Id;
        @AuraEnabled public String ClassName;
        @AuraEnabled public String Subject;
        @AuraEnabled public String Target;
        @AuraEnabled public String Times;
        @AuraEnabled public String StartDate;
        @AuraEnabled public String EndDate;
        @AuraEnabled public String IsEnd;
        @AuraEnabled public String Tuition;
        @AuraEnabled public Integer OrderNum;

        public WrapperClass(Integer idx, Class__c objClass){
            this.IndexNumber = idx == null ? '' : String.valueOf(idx);
            this.Id = objClass.Id == null ? '' : String.valueOf(objClass.Id);
            this.ClassName = objClass.ClassName__c == null ? '' : objClass.ClassName__c;
            this.Subject = objClass.Subject__c == null ? '' : objClass.Subject__c;
            this.Target = objClass.Target__c == null ? '' : objClass.Target__c;
            this.Times = objClass.Times__c == null ? '1' : objClass.Times__c;
            this.Tuition = objClass.Tuition__c == null ? '0' : String.valueOf(Integer.valueOf(objClass.Tuition__c));
            this.StartDate = objClass.StartDate__c == null ? '' : objClass.StartDate__c.format('yyyy-MM-dd HH:MM');
            this.EndDate = objClass.EndDate__c == null ? '' : objClass.EndDate__c.format('yyyy-MM-dd HH:MM');
            this.IsEnd = (objClass.EndDate__c != null && DateTime.now() <= objClass.EndDate__c) ? 'false' : 'true';
            this.OrderNum = objClass.OrderNum__c == null ? 0 : Integer.valueOf(objClass.OrderNum__c);
        }
    }
}