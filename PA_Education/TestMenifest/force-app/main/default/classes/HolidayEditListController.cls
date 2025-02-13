public with sharing class HolidayEditListController{

    public list<HolidayCheck> hldChkLst {get;set;}
    public string addDays {get;set;}
    public string addDesc {get;set;}
    public string chkStr  {get;set;}
    public boolean resignChk {
        get{
             if(resignChk==null || resignChk ==false ){
                resignChk = true;
             }else{
                resignChk = false;
            }
            return resignChk;
        }
        set;
    }
    

    public HolidayEditListController(){
        search();
        chkStr = 'Check All';
    }


    public void doCreate() {
        list<User> usrLst = [SELECT Id, CreatedDate FROM User WHERE Id NOT IN (SELECT Holiday_User__c FROM Holiday__c) AND IsActive = true AND UserType = 'Standard'];
        if(usrLst.isEmpty()){
            System.debug('There is no new employee.');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'There is no new employee.'));
            return;
        }

        Set<Id> setUserIds = new Set<Id>();
        for (User usr : usrLst) {
            setUserIds.add(usr.Id);
        }
        List<Employee__c> listEmployees = [SELECT Id, User__c, JoinDate__c FROM Employee__c WHERE User__c IN :setUserIds AND JoinDate__c != null];
        Map<Id, Employee__c> mapJoinDateByUserId = new Map<Id, Employee__c>();
        if (listEmployees.size() > 0) {
            for (Employee__c employee : listEmployees) {
                mapJoinDateByUserId.put(employee.User__c, employee);
            }
        }

        list<Holiday__c> hLst = new list<Holiday__c>();
        for (User usr : usrLst) {
            Date joinDate = mapJoinDateByUserId.get(usr.Id) == null || mapJoinDateByUserId.get(usr.Id).JoinDate__c == null ? Date.valueOf(usr.CreatedDate) : mapJoinDateByUserId.get(usr.Id).JoinDate__c;
            Id employeeId = mapJoinDateByUserId.get(usr.Id) == null ? null : mapJoinDateByUserId.get(usr.Id).Id;
            Holiday__c h = new Holiday__c(Holiday_JoinDate__c = joinDate, Employee__c = employeeId, Holiday_LastActivity__c = 'Created.', Holiday_NoticeLevel__c = 'Not Need', Holiday_User__c = usr.Id);
            hLst.add(h);
        }
        insert hLst;
        
        list<Holiday__Share> hsLst = new list<Holiday__Share>();
        for(Holiday__c h : hLst){
            Holiday__Share hldShr = new Holiday__Share ();
            hldShr.ParentId = h.Id;
            hldShr.RowCause = Schema.Holiday__Share.RowCause.Holiday_Owner__c;
            hldShr.UserOrGroupId = h.Holiday_User__c ;
            hldShr.AccessLevel = 'Read';
            hsLst.add(hldShr);
        }
        insert hsLst;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'Create is complete.'));
        search();
    }
    
    public void doSave(){
        list<Holiday__c> hldLst = new list<Holiday__c>();
        for(HolidayCheck hc : hldChkLst){
            hldLst.add(hc.hld);
        }
        update hldLst;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'Update is complete.'));
        search();
    }
    
    public PageReference doCancel(){
        return new PageReference('/');
    }
    
    public void doSend(){
         for(HolidayCheck hc : hldChkLst){
            if(hc.chk){
                User usr = [SELECT Email,Name FROM User WHERE Id = :hc.hld.Holiday_User__c];
                boolean finish = HolidayUtil.sendEmail('Info', usr, hc.hld);
                if(finish)
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'Email send complete.'));
                else
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error occur during sending email.'));
                hc.chk = false;
            }
        }
        chkStr = 'Check All';
    }
    
    public void checkChange(){
        boolean chk = false;
        if(chkStr == 'Check All'){
            chkStr = 'Uncheck All';
            chk = true;
        }
        else{
            chkStr = 'Check All';
            chk = false;
        }
        
        
        for(HolidayCheck hc : hldChkLst)
                hc.chk = chk ;
    }

    /*public void doResignCheck(){
        if(resignChk==null || resignChk==false){
            resignChk = true;
        }else{
            resignChk = false;
        }
        
    }*/
    
    public void doResetUnpaid(){
         list<Holiday__c> hldLst = new list<Holiday__c>();
        for(HolidayCheck hc : hldChkLst){
            if(hc.chk && hc.hld.Holiday_Unpaid__c > 0){
                hc.hld.Holiday_Unpaid__c = 0;
                hldLst.add(hc.hld);
            }
        }
        update hldLst;
        search();
    }
    
    public void doResetUncountable(){
        string msg = UserInfo.getLastName() + ' had reset uncountable holidays.';
         list<Holiday__c> hldLst = new list<Holiday__c>();
        for(HolidayCheck hc : hldChkLst){
            if(hc.chk && hc.hld.Holiday_Uncountable__c> 0){
                hc.hld.Holiday_Uncountable__c = 0;
                hc.hld.Holiday_LastActivity__c = msg ;
                hldLst.add(hc.hld);
            }
        }
        update hldLst;
        search();
    }
    
    public void doAdd(){
        decimal day = 0;
        string msg = UserInfo.getLastName();
        try{
            day = decimal.valueOf(addDays);
        }catch(Exception e){
        }
        if(day == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Day is 0.'));
            return;
        }
        msg += ' had adding ' + string.valueOf(day) + ' day(s). Reason : ';
        if(addDesc==null || addDesc=='')
            msg += ' Additional Holidays.';
        else
            msg += ' ' + addDesc;
            
        list<Holiday__c> hldLst = new list<Holiday__c>();
        for(HolidayCheck hc : hldChkLst){
            if(hc.chk){
                hc.hld.Holiday_GivenHolidays__c += day ;
                hc.hld.Holiday_LastActivity__c = msg ;
                hldLst.add(hc.hld);
            }
        }
        update hldLst;
        search();
    }

    public void search(){
        boolean isChecked = resignChk;
        list<Holiday__c> hldLst = [SELECT Id,Name,Holiday_Additionaldays__c,Holiday_Calculated__c,Holiday_GivenHolidays__c,Holiday_IsActive__c,Holiday_IsAnnualleave__c,Holiday_JoinDate__c,
                  Holiday_LastActivity__c,Holiday_NoticeLevel__c,Holiday_PeriodEnd__c,Holiday_Remain__c,Holiday_StartDate__c,Holiday_Uncountable__c,Holiday_Unpaid__c,Holiday_UseDays__c,
                  Holiday_User__c,Holiday_WorkingYears__c FROM Holiday__c WHERE Holiday_IsActive__c =:isChecked ORDER BY Holiday_JoinDate__c];

        hldChkLst = new list<HolidayCheck>();

        for(Holiday__c hld : hldLst) {
            hldChkLst.add(new HolidayCheck(false, hld));
        }
        System.debug('hldLst.size() : ' + hldLst.size());
        chkStr = 'Check All';
    }    

    
    public class HolidayCheck{
        public boolean chk {get;set;}
        public Holiday__c hld {get;set;}
        public HolidayCheck(boolean pChk, Holiday__c pHld){
            chk = pChk;
            hld = pHld;
        }
    }
}