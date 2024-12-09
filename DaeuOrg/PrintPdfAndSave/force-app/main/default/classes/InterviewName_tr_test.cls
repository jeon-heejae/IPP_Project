@isTest
public class InterviewName_tr_test {

    private static Interview__c createInterview(Date interviewDate, Id employeeId) {
        Interview__c interview = new Interview__c(
            Intv_Date__c = interviewDate,
            Intv_Mentee__c = employeeId
        );
        insert interview;
        return interview;
    }

    @isTest
    static void testBeforeInsert() {
        Employee__c emp = new Employee__c(Name = '가가가');
        insert emp;
        Interview__c newInterview = createInterview(Date.today(), emp.Id);
        newInterview = [SELECT Intv_Name__c, Intv_Mentee__r.Name FROM Interview__c WHERE Id = :newInterview.Id];
        System.assertNotEquals(newInterview.Intv_Name__c, 'No.0000-00-0/0', '담당 멘티가 없음');
        System.assertEquals(newInterview.Intv_Mentee__r.Name, '가가가', '이름값이 잘 할당됨');
    }

    @isTest
    static void testAfterInsert() {
        Employee__c emp = new Employee__c(Name = '나나나');
        insert emp;
        Interview__c newInterview = createInterview(Date.today(), emp.Id);
        newInterview = [SELECT Intv_Name__c, Intv_Mentee__r.Name FROM Interview__c WHERE Id = :newInterview.Id];
        System.assertNotEquals(newInterview.Intv_Name__c, 'No.0000-00-0/0', 'afterinsert');
        System.assertEquals(newInterview.Intv_Mentee__r.Name, '나나나', '이름값이 잘 할당됨');
    }

    @isTest
    static void testAfterUpdate() {
        Employee__c emp = new Employee__c(Name = '다다다');
        insert emp;
        Interview__c newInterview = createInterview(Date.today(), emp.Id);
        newInterview.Intv_Date__c = Date.today().addDays(1);
        update newInterview;
        newInterview = [SELECT Intv_Name__c, Intv_Mentee__r.Name FROM Interview__c WHERE Id = :newInterview.Id];
        System.assertNotEquals(newInterview.Intv_Name__c, 'No.0000-00-0/0', 'after update');
        System.assertEquals(newInterview.Intv_Mentee__r.Name, '다다다', '이름값이 잘 할당됨');
    }

    @isTest
    static void testAfterDelete() {
        Employee__c emp = new Employee__c(Name = '라라라');
        insert emp;
        Interview__c newInterview = createInterview(Date.today(), emp.Id);
        delete newInterview;
        Integer count = [SELECT COUNT() FROM Interview__c WHERE Id = :newInterview.Id];
        System.assertEquals(count, 0, '레코드 삭제가 잘 이루어짐');
    }

    @isTest
    static void testBulkInsertUpdate() {
        Employee__c emp1 = new Employee__c(Name = '홍길동');
        Employee__c emp2 = new Employee__c(Name = '고길동');
        insert new List<Employee__c>{emp1, emp2};
        List<Interview__c> interviews = new List<Interview__c>{
            createInterview(Date.today(), emp1.Id),
            createInterview(Date.today().addDays(1), emp1.Id),
            createInterview(Date.today(), emp2.Id),
            createInterview(Date.today().addDays(2), emp2.Id)
        };
        for (Interview__c interview : interviews) {
            interview.Intv_Date__c = Date.today().addDays(3);
        }
        update interviews;
        interviews = [SELECT Id, Intv_Name__c, Intv_Mentee__r.Name FROM Interview__c WHERE Id IN :interviews];
        for (Interview__c interview : interviews) {
            System.assertNotEquals(interview.Intv_Name__c, 'No.0000-00-0/0', '할당값이 전달안됨');
            System.assertNotEquals(interview.Intv_Mentee__r.Name, null, '멘티값이 null');
        }
    }
}