@isTest
private class sensitiveInformationViewController_test {

    static String uniqueUsername;
    static String uniqueNickname;

    @testSetup 
    static void setupTestData() { 
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueOf(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
        Integer randomInt = Integer.valueOf(Math.rint(Math.random() * 1000000));
        uniqueUsername = orgId + dateString + randomInt + '@test' + orgId + '.org';  
        uniqueNickname = orgId + dateString;

        UserRole r = [SELECT Id FROM UserRole WHERE Name='Platform Member'];
        Profile p = [SELECT Id FROM Profile WHERE Name='Daeu Nextier Employee'];
        
        User testUser = new User(
            LastName = '대유',     
            Alias = '대유',
            Email = 'Daeu@nextier.com',
            Username = uniqueUsername,
            CommunityNickname = uniqueNickname,
            UserRoleId = r.Id, 
            ProfileId = p.Id,  
            EmailEncodingKey = 'UTF-8', 
            TimeZoneSidKey = 'Asia/Seoul', 
            LocaleSidKey = 'ko_KR',  
            LanguageLocaleKey = 'ko', 
            CurrencyIsoCode = 'KRW', 
            IsActive = true,  
            Position__c = '13' 
        );

        insert testUser;

        System.runAs(testUser) { //System.DmlException
            Employee__c employee = new Employee__c(
                User__c = testUser.Id,
                Gender__c = '남성',
                CurrentAddress__c = '상원12길34',
                Birthday__c = Date.newInstance(1990, 1, 1),
                EnglishName__c = 'Daeu',
                IdNumber__c = '123456-1234567',
                AddressNumber__c = '01010',
                WeddingAnniversary__c = Date.newInstance(2015, 5, 10),
                JoinArmyDate__c = Date.newInstance(2010, 6, 1),
                DischargeDate__c = Date.newInstance(2012, 6, 1),
                MilitaryServiceDiv__c = '미필',
                MilitaryType__c = '공군',
                Class__c = '상병',
                MilitaryTypeDescription__c = '가나다라마',
                Dependents__c = '4',
                UpdateDate__c = Date.newInstance(2018, 11, 01),
                DismissalDate__c = Date.newInstance(2025, 11, 01),
                Reason__c = '건강 악화',
                Clear__c = '청산 완료',
                Position__c = '13',  // 직급을 채워줘야 함
                OwnerId = testUser.Id
            );

            insert employee;

            // PermissionSetAssignment 추가
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ViewPersonalInfoPermission' LIMIT 1];
            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = testUser.Id,
                PermissionSetId = ps.Id
            );
            insert psa;
        }
    }

    @isTest
    static void testGetEmpInfo() {
        setupTestData();
        
        User currentUser = [SELECT Id FROM User WHERE Username =: uniqueUsername LIMIT 1];
        Employee__c employee = [SELECT Id FROM Employee__c WHERE User__c =: currentUser.Id LIMIT 1];
        
        System.runAs(currentUser) {
            Test.startTest();
            Employee__c result = sensitiveInformationViewController.getEmpInfo(employee.Id);
            Test.stopTest();

            System.assertNotEquals(null, result, '직원정보가 null값');
            System.assertEquals('남성', result.Gender__c, '성별이 남성으로 나와야함');
            System.assertEquals('Daeu', result.EnglishName__c, '영어이름이 Daeu로 나와야함');
        }
    }

    @isTest
    static void testIsCheck() {
        setupTestData();

        User currentUser = [SELECT Id FROM User WHERE Username =: uniqueUsername LIMIT 1];
        Employee__c employee = [SELECT Id, User__c FROM Employee__c WHERE User__c = :currentUser.Id LIMIT 1];

        // 테스트용 UserRole 변경 (CEO 또는 관리부)
        UserRole ceoRole = [SELECT Id FROM UserRole WHERE Name='CEO' LIMIT 1];
        currentUser.UserRoleId = ceoRole.Id;
        update currentUser;
        
        System.runAs(currentUser) {
            Test.startTest();
            Boolean result = sensitiveInformationViewController.isCheck(employee.Id);
            Test.stopTest();

            System.assertEquals(true, result, '로그인한 유저의 Id와 Emp 레코드의 User__c Id값이 일치 또는 역할이 CEO일 경우');
        }
    }

    @isTest
    static void testUpdateEmpInfo() {
        setupTestData();
        
        User currentUser = [SELECT Id FROM User WHERE Username =: uniqueUsername LIMIT 1];
        Employee__c employee = [SELECT Id, Gender__c FROM Employee__c WHERE User__c = :currentUser.Id LIMIT 1];
        employee.Gender__c = '여성';  

        System.runAs(currentUser) {
            Test.startTest();
            Boolean result = sensitiveInformationViewController.updateEmpInfo(employee);
            Test.stopTest();

            System.assertEquals(true, result, '업데이트 성공');
            System.assertEquals('여성', [SELECT Gender__c FROM Employee__c WHERE Id = :employee.Id].Gender__c, '성별이 여성으로 데이터가 나와야함');
        }
    }

    @isTest
    static void testGetPicklistValues() {
        setupTestData();

        User currentUser = [SELECT Id FROM User WHERE Username =: uniqueUsername LIMIT 1];

        System.runAs(currentUser) {
            Test.startTest();
            Map<String, List<String>> result = sensitiveInformationViewController.getPicklistValues();
            Test.stopTest();

            System.assertNotEquals(null, result, 'pickValue가 Null값이기에 오류발생');
            System.assert(result.containsKey('Gender__c'), '픽리스트에 성별에 대한 리스트가 나와야함');
            System.assert(result.containsKey('MilitaryServiceDiv__c'), '픽리스트에 병역구분에 대한 리스트가 나와야함');
            System.assert(result.containsKey('MilitaryType__c'), '픽리스트에 군별 대한 리스트가 나와야함');
        }
    }

    @isTest
    static void testHasPermissionSet() {
        setupTestData();

        User currentUser = [SELECT Id FROM User WHERE Username =: uniqueUsername LIMIT 1];
        
        System.runAs(currentUser) {
            Test.startTest();
            Boolean result = sensitiveInformationViewController.hasPermissionSet();
            Test.stopTest();

            System.assertEquals(true, result, 'PermissionSet이 제대로 할당되었는지 확인');
        }
    }
}