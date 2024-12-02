public class LeadConversionController {

    @AuraEnabled
    public static Map<String, List<Map<String, String>>> getTeachersAndTablets() {
        Map<String, List<Map<String, String>>> result = new Map<String, List<Map<String, String>>>();
        
        // 선생님 정보 쿼리 
        List<Map<String, String>> teachers = new List<Map<String, String>>();
        for(Teacher__c teacher : [SELECT Id, Name FROM Teacher__c]) {
            teachers.add(new Map<String, String>{
                'label' => teacher.Name,
                'value' => teacher.Id
            });
        }
        result.put('teachers', teachers);
        
        // 태블릿 정보 쿼리 
        List<Map<String, String>> tablets = new List<Map<String, String>>();
        for(Tablet__c tablet : [SELECT Id, Name FROM Tablet__c WHERE StartDate__c =null AND UseContact__c=null]) {
            tablets.add(new Map<String, String>{
                'label' => tablet.Name,
                'value' => tablet.Id
            });
        }
        result.put('tablets', tablets);
        
        return result;
    }

    @AuraEnabled
    public static void saveLead(Map<String,Object> contractData) {
        Id leadId = (Id)contractData.get('leadId');

        Lead lead = [SELECT Id, LastName, Email, MobilePhone, EnglishLevel__c, MathLevel__c, ParName__c, 
                     ParPhone__c, ParEmail__c, ConAddress__c, ConDetailAddress__c, ConPostalCode__c,
                     ConBirthDate__c, ParCardType__c, ParExpiration__c, ParCVC__c, ParCardNumber__c,
                     ParInstallment__c, ParBank__c, ParAccountNumber__c, Stage__c
                     FROM Lead 
                     WHERE Id = :leadId];
        
        try {
            Parents__c parent=createParent(lead);
            Contact stuedent=createStudent(lead, parent.Id,contractData);
            createContractWay(lead,contractData,parent.Id,stuedent.Id);
            createTablet(contractData,stuedent);
             // Update Lead status
            lead.Stage__c = 'Closed - Converted';
            update lead;
            System.debug('Lead converted successfully');
        } catch (Exception e) {
            System.debug('Error during lead conversion: ' + e.getMessage());
            throw new AuraHandledException('Error during lead conversion: ' + e.getMessage());
        }
    }

    
    @AuraEnabled
    public static Parents__c createParent(Lead lead) {
       
        // Create new parent
        Parents__c parent = new Parents__c(
            Name = lead.ParName__c,
            Email__c = lead.ParEmail__c,
            Phone__c = lead.ParPhone__c,
            Address__c = lead.ConAddress__c,
            PostalCode__c = lead.ConPostalCode__c,
            DetailAddress__c = lead.ConDetailAddress__c,
            CheckContract__c =true
        );
        if (lead.ParBank__c != null) {
            parent.Bank__c = lead.ParBank__c;
            parent.AccountNumber__c = Decimal.valueOf(lead.ParAccountNumber__c);
        } else {
            parent.CardType__c = lead.ParCardType__c;
            parent.Expiration__c = lead.ParExpiration__c;
            parent.CVC__c = lead.ParCVC__c;
            parent.CardNumber__c = lead.ParCardNumber__c;
        }

        System.debug('parent: ' + parent);

        // Use DML options to allow duplicates
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        parent.setOptions(dml);

        Database.SaveResult result = Database.insert(parent, false);

        if (!result.isSuccess()) {
            for(Database.Error err : result.getErrors()) {
                System.debug('parent error: '+err.getMessage());
            }
        }

        return parent;
    }

    @AuraEnabled
    public static Contact createStudent(Lead lead,Id parentId,Map<String,Object> contractData){
        Integer period = Integer.valueOf(contractData.get('contractPeriod'));
        // Create new student
        Contact student = new Contact(
            LastName = lead.LastName,
            Email = lead.Email,
            Phone = lead.MobilePhone,
            EnglishLevel__c = lead.EnglishLevel__c,
            MathLevel__c = lead.MathLevel__c,
            BirthdayDate__c = lead.ConBirthDate__c,
            Parent__c = parentId,
            Teacher__c=(String)contractData.get('selectedTeacher'),
            EndClassDate__c=Date.today().addYears(period)
        );

        System.debug('student: ' + student);

        // Use DML options to allow duplicates
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        student.setOptions(dml);

        Database.SaveResult result2 = Database.insert(student, false);

        if (!result2.isSuccess()) {
            for(Database.Error err : result2.getErrors()) {
                System.debug('student error: '+err.getMessage());
            }
        }

        return student;
    }

    @AuraEnabled
    public static void createContractWay(Lead lead,Map<String,Object> contractData,
    Id parentId,Id studentId){
        Integer period = Integer.valueOf(contractData.get('contractPeriod'));
        System.debug(period);
        Decimal amount=(Decimal)contractData.get('amount');
        String paymentMethod=(String)contractData.get('paymentMethod');

        ContractWay__c contract=new ContractWay__c();
        contract.Name='{'+lead.LastName+'}'+' 학생 계약';
        if(paymentMethod=='Monthly'){ // 월분할 결제인 경우 총 금액은 *계약 기간 *12
            contract.Amount__c=amount*period*12;
        }
        else{
            contract.Amount__c=amount;
        }
        contract.StartDate__c=Date.today();
        contract.EndDate__c=Date.today().addYears(period);
        contract.Contact__c=studentId;
        contract.Parents__c=parentId;

        System.debug('ContractWay: '+contract);
        Database.SaveResult result = Database.insert(contract, false);

        if (!result.isSuccess()) {
            for(Database.Error err : result.getErrors()) {
                System.debug('contract error: '+err.getMessage());
            }
        }
    }

    @AuraEnabled
    public static void createTablet(Map<String,Object> contractData,Contact student){
        try {
            Tablet__c tablet=new tablet__c();
            tablet.Id=(String)contractData.get('selectedTablet');
            tablet.UseContact__c=student.Id;
            tablet.StartDate__c=System.today();
            Integer period = Integer.valueOf(contractData.get('contractPeriod'));
            tablet.Enddate__c=System.today().addYears(period);
            System.debug('Tablet: '+tablet);
            Database.SaveResult result = Database.update(tablet, false);

            if (!result.isSuccess()) {
                for(Database.Error err : result.getErrors()) {
                    System.debug('tablet error: '+err.getMessage());
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}