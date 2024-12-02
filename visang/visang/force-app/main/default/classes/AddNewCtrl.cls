public with sharing class AddNewCtrl {
    @AuraEnabled
    public static ListView returnListView(){
        ListView listContact = [
            SELECT Id, Name
            FROM ListView
            WHERE sObjectType ='Contact'
            LIMIT 1
        ];
        return listContact;
    }
    @AuraEnabled
    public static List<Map<String, String>> getTabletListCtrl(){
        List<Tablet__c> listTab = [
            SELECT Id, UseContact__c, PurchaseDate__c, Name
            FROM Tablet__c
            WHERE UseContact__c = null
            Order By PurchaseDate__c DESC
        ];
        List<Map<String, String>> listReturn = new List<Map<String, String>>();
        for(Tablet__c objTab : listTab){
            Map<String, String> mapInp = new Map<String, String>();
            mapInp.put('label', objTab.Name);
            mapInp.put('value', objTab.Id);
            listReturn.add(mapInp);
        }
        return listReturn;
        
    }
    @AuraEnabled
    public static List<Map<String, String>> getTeacherListCtrl(){
       List<Teacher__c> listTea = [
        SELECT Id, Name
        FROM Teacher__c
        LIMIT 30
       ];
       List<Map<String, String>> listReturn = new List<Map<String, String>>();
        for(Teacher__c objTea : listTea){
            Map<String, String> mapInp = new Map<String, String>();
            mapInp.put('label', objTea.Name);
            mapInp.put('value', objTea.Id);
            listReturn.add(mapInp);
        }
        System.debug('listReturn >>' + listReturn);
        return listReturn;
    }
    @AuraEnabled
    public static void saveRecord(
        Date ConBirthDate,
        String ConName,
        String ParName,
        String ParPhone,
        String ParEmail,
        String Address,
        String DetailAddress,
        String PostalCode,
        String CardType,
        String CardNumber,
        String Expiration,
        String CVC,
        Decimal AccountNumber,
        String Bank,
        String Years,
        Integer Amount,
        String MonthorYear,
        String selectedTeacher,
        String selectedTablet
    ){
        Contact objNewCon = new Contact();
        Parents__c objNewPar = new Parents__c();
        if(ParName != null){
            objNewPar.Name = ParName;
            objNewPar.Phone__c = ParPhone;
            objNewPar.Email__c = ParEmail;
            objNewPar.Address__c = Address;
            objNewPar.DetailAddress__c = DetailAddress;
            objNewPar.PostalCode__c = PostalCode;
            objNewPar.CardType__c = CardType;
            objNewPar.CardNumber__c = CardNumber;
            objNewPar.Expiration__c = Expiration;
            objNewPar.CVC__c = CVC;
            objNewPar.AccountNumber__c = AccountNumber;
            objNewPar.Bank__c = Bank;
            objNewPar.CheckContract__C = true;
            insert objNewPar;
            System.debug('objNewPar >>' + objNewPar);
        }
        if(conName != null){
            objNewCon.LastName = ConName;
            objNewCon.BirthdayDate__c = ConBirthDate;
            objNewCon.Parent__c = objNewPar.Id;
            objNewCon.EnglishLevel__c = 'Level 1';
            objNewCon.MathLevel__c = 'Level 1';
            objNewCon.StartClassDate__c = System.today();
            if(Years == 'oneYear'){
                objNewCon.EndClassDate__c = System.today().addYears(1);
            }else if(Years == 'twoYear'){
                objNewCon.EndClassDate__c = System.today().addYears(2);
            }
            objNewCon.Teacher__c = selectedTeacher;
            insert objNewCon;
            System.debug('objNewCon >>' + objNewCon); 
        }
        if(selectedTablet != null){
            Tablet__c objTab = new Tablet__c();
            objTab.Id = selectedTablet;
            objTab.UseContact__c = objNewCon.Id;
            objTab.StartDate__c = System.today();
            if(Years == 'oneYear'){
                objTab.EndDate__c = System.today().addYears(1);
            }else if(Years == 'twoYear'){
                objTab.EndDate__c = System.today().addYears(2);
            }
            update objTab;
        }
        if(conName != null && parName != null){
            ContractWay__c objContract = new ContractWay__c();
            objContract.Name = '{' + objNewCon.LastName + '} 학생 계약';
            objContract.Parents__c = objNewpar.Id;
            objContract.Contact__c = objNewCon.Id;
            Integer yearsAmount = 0;
            if(Years == 'oneYear'){
                yearsAmount = 1;
                objContract.EndDate__c = System.today().addYears(1);
            }else if(Years == 'TwoYear'){
                yearsAmount = 2;
                objContract.EndDate__c = System.today().addYears(2);
            }
            objContract.StartDate__c = System.today();
            if(MonthorYear == 'payYear'){
                objContract.Amount__c = Amount;
            }else if (MonthorYear == 'payMonth'){
                objContract.Amount__c = Amount * (yearsAmount * 12);
            }
            insert objContract;
        }
    }
}