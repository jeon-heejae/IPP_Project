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

        Test.startTest();  // Test limits 구분
        Interview__c newInterview = createInterview(Date.today(), emp.Id);
        Test.stopTest();

        newInterview = [SELECT Intv_Name__c, Intv_Mentee__r.Name FROM Interview__c WHERE Id = :newInterview.Id];
        
        // 'No.0000-00-0/0'을 제외한 값이 생성되었는지 확인
        System.assertNotEquals(newInterview.Intv_Name__c, 'No.0000-00-0/0', '면담 이름이 정상적으로 설정되지 않았습니다.');
        System.assertEquals(newInterview.Intv_Mentee__r.Name, '가가가', '멘티 이름이 잘 할당되었습니다.');
    }

    @isTest
    static void testAfterInsert() {
        Employee__c emp = new Employee__c(Name = '나나나');
        insert emp;

        Test.startTest();
        Interview__c newInterview = createInterview(Date.today(), emp.Id);
        Test.stopTest();

        newInterview = [SELECT Intv_Name__c, Intv_Mentee__r.Name FROM Interview__c WHERE Id = :newInterview.Id];
        
        System.assertNotEquals(newInterview.Intv_Name__c, 'No.0000-00-0/0', 'after insert');
        System.assertEquals(newInterview.Intv_Mentee__r.Name, '나나나', '멘티 이름이 잘 할당됨');
    }

    @isTest
    static void testAfterUpdate() {
        Employee__c emp = new Employee__c(Name = '다다다');
        insert emp;
        Interview__c newInterview = createInterview(Date.today(), emp.Id);

        // 면담일자 업데이트
        newInterview.Intv_Date__c = Date.today().addDays(1);
        update newInterview;

        Test.startTest();
        newInterview = [SELECT Intv_Name__c, Intv_Mentee__r.Name FROM Interview__c WHERE Id = :newInterview.Id];
        Test.stopTest();

        System.assertNotEquals(newInterview.Intv_Name__c, 'No.0000-00-0/0', '면담 이름이 업데이트되지 않았습니다.');
        System.assertEquals(newInterview.Intv_Mentee__r.Name, '다다다', '멘티 이름이 잘 할당되었습니다.');
    }

    @isTest
    static void testAfterDelete() {
        Employee__c emp = new Employee__c(Name = '라라라');
        insert emp;
        Interview__c newInterview = createInterview(Date.today(), emp.Id);

        delete newInterview;

        Test.startTest();
        Integer count = [SELECT COUNT() FROM Interview__c WHERE Id = :newInterview.Id];
        Test.stopTest();

        System.assertEquals(count, 0, '면담 레코드가 삭제되지 않았습니다.');
    }

    @isTest
    static void testBulkInsertUpdate() {
        Employee__c emp1 = new Employee__c(Name = '홍길동');
        Employee__c emp2 = new Employee__c(Name = '고길동');
        insert new List<Employee__c>{emp1, emp2};

        // 면담 데이터 생성
        List<Interview__c> interviews = new List<Interview__c>{
            createInterview(Date.today(), emp1.Id),
            createInterview(Date.today().addDays(1), emp1.Id),
            createInterview(Date.today(), emp2.Id),
            createInterview(Date.today().addDays(2), emp2.Id)
        };

        // 면담일자 수정
        for (Interview__c interview : interviews) {
            interview.Intv_Date__c = Date.today().addDays(3);
        }

        Test.startTest();
        update interviews;
        Test.stopTest();

        // 면담 리스트 재조회
        interviews = [SELECT Id, Intv_Name__c, Intv_Mentee__r.Name FROM Interview__c WHERE Id IN :interviews];
        for (Interview__c interview : interviews) {
            // 이름이 'No.0000-00-0/0'이 아닌지 확인
            System.assertNotEquals(interview.Intv_Name__c, 'No.0000-00-0/0', '면담 이름이 정상적으로 업데이트되지 않았습니다.');
            System.assertNotEquals(interview.Intv_Mentee__r.Name, null, '멘티 이름이 null이 아닙니다.');
        }
    }
}