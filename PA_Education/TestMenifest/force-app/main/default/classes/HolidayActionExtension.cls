public with sharing class HolidayActionExtension{
    private ApexPages.StandardController controller {get; set;}
    public HolidayAction__c hldyActn{get;set;}
    set<Date> holidaySet {get;set;}
    private string retId {get;set;}
    private final String recordId;

    public HolidayActionExtension(){

    }
    
    public HolidayActionExtension(ApexPages.StandardController stdctrl){
        system.debug('HolidayActionExtension');
        controller = stdctrl;
        retId =  ApexPages.currentPage().getParameters().get('retId');

        system.debug(ApexPages.currentPage().getParameters());
        controller = stdctrl;
        hldyActn = (HolidayAction__c )controller.getRecord();
        //Required 필드 초기값 지정
        hldyActn.Name = '휴가 신청';
        // TODO : 자동으로 자신의 userId가 들어가는데, 빈칸으로 비우는게 나을듯
//        hldyActn.FirstHolidayRequest__c = UserInfo.getUserId();
        hldyActn.FirstHolidayRequest__c = null;
        hldyActn.HolidayAction_Type__c = '--None--';
        hldyActn.HolidayAction_Days__c = 1;
        /*hldyActn.HolidayAction_Approver__c = UserInfo.getUserId();*/
        hldyActn.OwnerId = UserInfo.getUserId();
        hldyActn.HolidayAction_Date1__c = system.today().addDays(1);
        hldyActn.HolidayAction_Date2__c = system.today().addDays(2);
        hldyActn.HolidayAction_Date3__c = system.today().addDays(3);
        hldyActn.HolidayAction_Date4__c = system.today().addDays(4);
        hldyActn.HolidayAction_Date5__c = system.today().addDays(5);
        string usrId = UserInfo.getUserId();
        if(hldyActn.HolidayAction_Parent__c == null){
            string parentId = [SELECT Id FROM Holiday__c WHERE Holiday_User__c = :usrId limit 1].Id;
            hldyActn.HolidayAction_Parent__c = parentId;
        }


    }
    
    public void typeCheck(){
        system.debug('typeCheck');
        if(hldyActn.HolidayAction_Type__c == 'Alternative Holiday Register'){
            hldyActn.HolidayAction_Days__c = 0;
        }
        else if(hldyActn.HolidayAction_Type__c == 'Half-day Leave'){
            hldyActn.HolidayAction_HalfdayTime__c = 'AM';
            //반차 수정부분 
           // hldyActn.HolidayAction_Days__c = 0.5;
        }
        else{
            hldyActn.HolidayAction_Days__c = 1;
        }


    }
    //반차 0.5 기본값 설정
    public void halfCheck(){
        if(hldyActn.HolidayAction_Type__c=='Half-day Leave' && hldyActn.HolidayAction_HalfdayTime__c=='AM' ||  hldyActn.HolidayAction_HalfdayTime__c=='PM')
        {
            hldyActn.HolidayAction_Days__c =0.5;
        }
    }
    
    public void changeDay(){
        system.debug('changeDay');
        If(hldyActn.HolidayAction_Days__c >5 || hldyActn.HolidayAction_Days__c < 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Input days from 1 to 5.'));
            hldyActn.HolidayAction_Days__c = 1;
        }

    }


    public PageReference doCancel(){
        system.debug('doCancel');
        System.debug('doCancel retId :: ' + retId);
        return new PageReference('/apex/MyHolidayInfo?sfdc.userId='+retId);
    }
    public PageReference doSave(){
        system.debug('doSave');
        try{
            holidaySet = new set<Date>();
            holidaySet.add(hldyActn.HolidayAction_Date5__c);
            holidaySet.add(hldyActn.HolidayAction_Date4__c);
            holidaySet.add(hldyActn.HolidayAction_Date3__c);
            holidaySet.add(hldyActn.HolidayAction_Date2__c);
            holidaySet.add(hldyActn.HolidayAction_Date1__c);
            String subject = hldyActn.Name;
            if(String.isEmpty(subject))
                hldyActn.Name = '휴가 신청';
            if(hldyActn.HolidayAction_Days__c < 5){
                holidaySet.remove(hldyActn.HolidayAction_Date5__c);
                hldyActn.HolidayAction_Date5__c = null;
            }
            if(hldyActn.HolidayAction_Days__c < 4){
                holidaySet.remove(hldyActn.HolidayAction_Date4__c);
                hldyActn.HolidayAction_Date4__c = null;
            }
            if(hldyActn.HolidayAction_Days__c < 3){
                holidaySet.remove(hldyActn.HolidayAction_Date3__c);
                hldyActn.HolidayAction_Date3__c = null;
            }
            if(hldyActn.HolidayAction_Days__c < 2){
                holidaySet.remove(hldyActn.HolidayAction_Date2__c);
                hldyActn.HolidayAction_Date2__c = null;
            }
            if(hldyActn.HolidayAction_Days__c < 1){
                holidaySet.remove(hldyActn.HolidayAction_Date1__c);
                hldyActn.HolidayAction_Date1__c = null;
            }
            
            if(hldyActn.HolidayAction_Days__c != holidaySet.size()){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Dates is not correct.'));
                return null;
            }
            if(hldyActn.HolidayAction_Type__c =='Women Holiday'){
                integer year = system.today().year();                
                integer mon = system.today().month();
                date fromdt = date.newInstance(year, mon, 1);
                integer cnt = [SELECT Id FROM HolidayAction__c WHERE HolidayAction_Parent__c =:hldyActn.HolidayAction_Parent__c AND HolidayAction_Date1__c >= :fromdt AND HolidayAction_Type__c ='Women Holiday'].size();
                if(cnt > 0 ){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 
                    'Already use Women Holiday in this month.\r\n If the previous request was rejected then please modify that and resubmit.'));
                    return null;
                 }   
            }
            else If(hldyActn.HolidayAction_Type__c =='Alternative Holiday' && hldyActn.HolidayAction_AlternativeBase__c == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Alternative Holiday need base.'));
                return null;

            }
            else {
                        halfCheck();
            }
            insert hldyActn;
            

            System.debug('hldyActn.HolidayAction_Parent__c========================='+hldyActn.Id);
            /*HolidayAction__Share hldShr = new HolidayAction__Share();
            hldShr.ParentId = hldyActn.Id;
            hldShr.RowCause = 'Manual';
            hldShr.UserOrGroupId = hldyActn.HolidayAction_Approver__c ;
            hldShr.AccessLevel = 'Edit';
            insert hldShr;
            
            string message = ' ' + hldyActn.HolidayAction_Type__c + ' Requested.';
            if(hldyActn.HolidayAction_IsEmergency__c){
                system.debug(hldyActn);
                HolidayUtil.createEvent(hldyActn);
                message = ' ' + hldyActn.HolidayAction_Type__c + ' Created.';
            }
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(hldyActn.id);
            req1.setNextApproverIds(new list<string>{hldyActn.HolidayAction_Approver__c});
            Approval.ProcessResult result = Approval.process(req1); */    
        }catch (System.DmlException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getDmlMessage(i)));
            return null;
            }
        }
        System.debug('Save retId :: ' + retId);
        return new PageReference('/apex/MyHolidayInfo?sfdc.userId='+retId);
        /*
        PageReference pr = controller.save();
        if(pr == null)
            return null;
        String url = pr.getUrl();
        if(url == '/home/home.jsp')
            return new PageReference('/apex/MyHolidayInfo?sfdc.userId='+retId);
        else
            return pr;
        */
    }
    /*public void createFeed(string pWho, string pWhat, string pMessage){
        system.debug('createFeed');
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        mentionSegmentInput.id = pWho;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        
        textSegmentInput.text = pMessage;
        messageBodyInput.messageSegments.add(textSegmentInput);
        
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = pWhat;
        
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
    }*/
}