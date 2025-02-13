public with sharing class ApprovalHistoryController {

    @AuraEnabled
    public static Map<String, Object> getListApprovalHistory(Id idTargetObject) {
        Boolean bIsPending = false, bIsSubmitter = false, bIsApprover = false;

        List<WrapperApprovalHistory> listWrapApprovalHistory = new List<WrapperApprovalHistory>();
        List<WrapperApprovalHistory> listWrapApprovalHistoryTemp = new List<WrapperApprovalHistory>();

        // ProcessInstance, ProcessInstanceHistory
        List<ProcessInstance> listProcessInstance = [SELECT     Id, TargetObjectId, TargetObject.Name, SubmittedById, SubmittedBy.Name
                                                                , (SELECT   Id, ProcessNodeId, StepStatus, CreatedDate, IsPending
                                                                            , ActorId, Actor.Name, OriginalActorId, OriginalActor.Name
                                                                   FROM     StepsAndWorkitems
                                                                   ORDER BY CreatedDate DESC)
                                                     FROM       ProcessInstance
                                                     WHERE      TargetObjectId = :idTargetObject
                                                     ORDER BY   CreatedDate DESC];

        Id usrId = UserInfo.getUserId();
        List<User> usrLst = new List<User>();
        usrLst = [SELECT Id FROM User WHERE DelegatedApproverId = :usrId];
        Set<Id> usrIdSet = new Set<Id>();
        for(User usr : usrLst)usrIdSet.add(usr.Id);

        String sPendingUser;

        Set<Id> setIdProcessNode = new Set<Id>();
        for(ProcessInstance objInstance : listProcessInstance) {
            System.debug('objInstance.SubmittedBy.Name : ' + objInstance.SubmittedBy.Name);
            if(!bIsSubmitter && objInstance.SubmittedById == UserInfo.getUserId()) bIsSubmitter = true;

            for(ProcessInstanceHistory objHistory : objInstance.StepsAndWorkitems) {
                if(objHistory.ProcessNodeId != null) setIdProcessNode.add(objHistory.ProcessNodeId);
                System.debug('objHistory.IsPending : ' + objHistory.IsPending + ', objHistory.ActorId : ' + objHistory.ActorId + ', ' + objHistory.Actor.Name);

                if(objHistory.IsPending) {
                    listWrapApprovalHistory.add(new WrapperApprovalHistory(objHistory));
                    bIsPending = true;

                    sPendingUser = new WrapperApprovalHistory(objHistory).idOriginActor;

                    if(objHistory.ActorId == UserInfo.getUserId()) bIsApprover = true;
                    if(usrIdSet.contains(objHistory.ActorId)) bIsApprover = true;
                } else {
                    listWrapApprovalHistoryTemp.add(new WrapperApprovalHistory(objHistory));    
                }
            }
        }

        listWrapApprovalHistory.addAll(listWrapApprovalHistoryTemp);

        // sj Test 
        Id idApp1 ;
        Id idApp2 ;
        Id idApp3 ;
        Id idApp4 ;

        String sAppName1;
        String sAppName2;
        String sAppName3;
        String sAppName4;

        if(Test.isRunningTest()) bIsPending = true;

        if(bIsPending){
           WrapperApprovalHistory curActor =  listWrapApprovalHistory[0];
           String sObjectName = idTargetObject.getSObjectType().getDescribe().getName();
           String sQuery   = 'SELECT Id, Approver1__c, Approver1__r.Name, ' +
                             '        Approver2__c, Approver2__r.Name, ' +
                             '        Approver3__c, Approver3__r.Name, ' +
                             '        Approver4__c, Approver4__r.Name ' +
                             ' FROM '+ sObjectName +' WHERE Id = \''+ idTargetObject + '\'' ; 
           SObject targeObject = Database.query(sQuery);



           List<Id> listId = new List<Id>();
           idApp1 = (Id)targeObject.get('Approver1__c');
           idApp2 = (Id)targeObject.get('Approver2__c');
           idApp3 = (Id)targeObject.get('Approver3__c');
           idApp4 = (Id)targeObject.get('Approver4__c');

           Map<Id, String> mapApprover = new Map<Id, String>();

            if(idApp1 != null) {
                listId.add(idApp1); 
                sAppName1 = (String)targeObject.getSObject('Approver1__r').get('Name');
                mapApprover.put(idApp1 , (String)targeObject.getSObject('Approver1__r').get('Name'));
            }
            if(idApp2 != null) {
                listId.add(idApp2); 
                sAppName2 = (String)targeObject.getSObject('Approver2__r').get('Name');
                mapApprover.put(idApp2 , (String)targeObject.getSObject('Approver2__r').get('Name'));
            }
            if(idApp3 != null) {
                listId.add(idApp3); 
                sAppName3 = (String)targeObject.getSObject('Approver3__r').get('Name');
                mapApprover.put(idApp3 , (String)targeObject.getSObject('Approver3__r').get('Name'));
            }
            if(idApp4 != null) {
                listId.add(idApp4); 
                sAppName4 = (String)targeObject.getSObject('Approver4__r').get('Name');
                mapApprover.put(idApp4 , (String)targeObject.getSObject('Approver4__r').get('Name'));
            }

           Boolean bFlag = false;
           for(id appId : listId) {
                if(bFlag){
                    WrapperApprovalHistory nextApprover = new WrapperApprovalHistory();
                    nextApprover.idOriginActor     = appId;
                    nextApprover.sOriginActorName  = mapApprover.get(appId);
                    nextApprover.sStepStatus       = '대기중';
                    nextApprover.sCreatedDate      = curActor.sCreatedDate;
                    listWrapApprovalHistory.add(0, nextApprover);
                }
                else if(curActor.idOriginActor == appId){
                    bFlag = true;
                } 
           }

        }

        // System Admin 전체 권한 부여
        User objUser = [SELECT  Id, ProfileId, Profile.Name
                        FROM    User
                        WHERE   Id = :UserInfo.getUserId()];

        if(objUser.Profile.Name == 'System Administrator' || objUser.Profile.Name == '시스템 관리자') {
            bIsSubmitter = true;
            bIsApprover = true;
        } 

        // ProcessInstanceNode : 승인프로세스의 한 단계에 대한 정보
        List<ProcessInstanceNode> listProcessNode = [SELECT Id, ProcessInstanceId, ProcessNodeId, ProcessNodeName, NodeStatus
                                                     FROM   ProcessInstanceNode
                                                     WHERE  ProcessNodeId IN :setIdProcessNode];

        Map<Id, ProcessInstanceNode> mapProcessNode = new Map<Id, ProcessInstanceNode>();
        for(ProcessInstanceNode objNode : listProcessNode) mapProcessNode.put(objNode.ProcessNodeId, objNode);

        for(WrapperApprovalHistory objWrapApprovalHistory : listWrapApprovalHistory) {
            ProcessInstanceNode objNode = mapProcessNode.get(objWrapApprovalHistory.idProcessNode);

            objWrapApprovalHistory.sProcessNodeName = objNode == null ? System.Label.Approval_InitialStep : objNode.ProcessNodeName;
        }



        //customlabel get
        //String customLabel = System.Label.Submit;

        //커스텀세팅으로 라인제한 수 컨트롤 custom setting controll
        //ApprovalLine__c objCustomSet =  ApprovalLine__c.getOrgDefaults();
        //Decimal iLineLimit = objCustomSet.LineLimit__c;
        //System.debug('iLineLimit >>> ' +iLineLimit);




        Map<String, Object> mapReturnValue = new Map<String, Object>{
            'bIsPending'                => bIsPending,
            'bIsSubmitter'              => bIsSubmitter,
            'bIsApprover'               => bIsApprover,
            'listWrapApprovalHistory'   => listWrapApprovalHistory,

            //sj추가
            'userId'                    => usrId,
            'idApp1'                    => idApp1,
            'idApp2'                    => idApp2,
            'idApp3'                    => idApp3,
            'idApp4'                    => idApp4,
            'sAppName1'                 => sAppName1,
            'sAppName2'                 => sAppName2,
            'sAppName3'                 => sAppName3,
            'sAppName4'                 => sAppName4,            
            'sPendingUser'              => sPendingUser
           
        };

        return mapReturnValue;
    }

    @AuraEnabled
    public static String doProcessWorkitemRequest(Id idTargetObject, String sActionName, String sComments, Id idAssignee) {
        String sReturnValue = '';

        try {
            List<ProcessInstance> listProcessInstance = [SELECT Id, TargetObjectId
                                                                , (SELECT   Id, ActorId, ProcessInstanceId
                                                                   FROM     WorkItems)
                                                         FROM   ProcessInstance
                                                         WHERE  TargetObjectId = :idTargetObject
                                                         AND    Status = 'Pending'];

            Id idWorkitem;
            for(ProcessInstance objInstance : listProcessInstance) {
                for(ProcessInstanceWorkItem objWorkItem : objInstance.WorkItems) idWorkitem = objWorkItem.Id;
            }

            if(sActionName == 'Reassign') {
                ProcessInstanceWorkItem objWorkItem = new ProcessInstanceWorkItem();

                objWorkItem.Id      = idWorkitem;
                objWorkItem.ActorId = idAssignee;

                update objWorkItem;

                sReturnValue = 'success/성공적으로 저장되었습니다.'; 
            } else {
                Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
                    
                request.setWorkitemId(idWorkitem);
                request.setAction(sActionName);
                request.setComments(sComments);

                Approval.ProcessResult result = Approval.process(request);

                if(result.isSuccess()) sReturnValue = 'success/성공적으로 저장되었습니다.';
                else sReturnValue = 'error/' + result.getErrors()[0].getMessage();   
            }          
        } catch(Exception e) {
            sReturnValue = 'error/' + e.getMessage();
        }

        return sReturnValue;
    }


    public class WrapperApprovalHistory {
        @AuraEnabled public string idProcessNode        {get; set;}
        @AuraEnabled public string sProcessNodeName     {get; set;}
        @AuraEnabled public string idOriginActor        {get; set;}
        @AuraEnabled public string sOriginActorName     {get; set;}
        @AuraEnabled public String sStepStatus          {get; set;}
        @AuraEnabled public String sCreatedDate         {get; set;}

        public WrapperApprovalHistory(){}

        public WrapperApprovalHistory(ProcessInstanceHistory objHistory) {
            this.idProcessNode      = objHistory.ProcessNodeId;
            this.idOriginActor      = objHistory.OriginalActorId;
            this.sOriginActorName   = objHistory.OriginalActor.Name;
            this.sStepStatus        = objHistory.StepStatus;
            this.sCreatedDate       = (String) objHistory.CreatedDate.format();

            //if(objHistory.StepStatus == 'Started')          this.sStepStatus = '제출됨';
            //else if(objHistory.StepStatus == 'Pending')     this.sStepStatus = '보류 중';
            //else if(objHistory.StepStatus == 'Reassigned')  this.sStepStatus = '재할당됨';
            //else if(objHistory.StepStatus == 'Approved')    this.sStepStatus = '승인됨';
            //else if(objHistory.StepStatus == 'Rejected')    this.sStepStatus = '거부됨';
            //else if(objHistory.StepStatus == 'Removed')     this.sStepStatus = '회수됨';            

            if(objHistory.StepStatus == 'Started')          this.sStepStatus = Label.Started;
            else if(objHistory.StepStatus == 'Pending')     this.sStepStatus = Label.Pending;
            else if(objHistory.StepStatus == 'Reassigned')  this.sStepStatus = Label.Reassigned;
            else if(objHistory.StepStatus == 'Approved')    this.sStepStatus = Label.Approved;
            else if(objHistory.StepStatus == 'Rejected')    this.sStepStatus = Label.Rejected;
            else if(objHistory.StepStatus == 'Removed')     this.sStepStatus = Label.Recalled;
        }
    }

}