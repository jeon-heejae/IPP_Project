@isTest(SeeAllData=true)
private class ApprovalHistoryController_Test {

    @isTest
    static void doTest() {
        Test.startTest();
        //User, 넘길 objName의 obj, 
        User objUser1 = TestObjectCreator.objUser;
        User objUser2 = objUser1.clone(false);
        User objUser3 = objUser1.clone(false);
        User objUser4 = objUser1.clone(false);

        objUser2.Username            = 'atestclass@test.com';
        objUser2.CommunityNickname   = 'auser';

        objUser3.Username            = 'datestclass@test.com';
        objUser3.CommunityNickname   = 'dauser';

        objUser4.Username            = 'natestclass@test.com';
        objUser4.CommunityNickname   = 'nauser';

        insert objUser1;
        insert objUser2;
        insert objUser3;
        insert objUser4;


        Expense__c objExpInsert = TestObjectCreator.objExpense;
		objExpInsert.Approver1__c = UserInfo.getUserId();
	    objExpInsert.Approver2__c = objUser2.Id;
	    objExpInsert.Approver3__c = objUser3.Id;
	    objExpInsert.Approver4__c = objUser4.Id;
        insert objExpInsert;


        // ProcessDefinitionId => 승인프로세스 id
        // TargetObjectId,     => 승인프로세스 태울/태운 레코드id
        // Status,  => pending, approved, removed..
        // LastActorId, 44444441=> 마지막 승인자
        // SubmittedById,  => submit 누른사람

	    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();

        req1.setObjectId(objExpInsert.id);
	    Approval.ProcessResult result = Approval.process(req1);

        //String testV1 = Expense__c.
        List<ProcessInstance> listProcessInstance = [SELECT     Id, TargetObjectId, TargetObject.Name, SubmittedById, SubmittedBy.Name
                , (SELECT   Id, ProcessNodeId, StepStatus, CreatedDate, IsPending
                , ActorId, Actor.Name, OriginalActorId, OriginalActor.Name
        FROM     StepsAndWorkitems
        ORDER BY CreatedDate DESC)
        FROM       ProcessInstance
        WHERE      ProcessDefinition.TableEnumOrId = 'Expense__c'
        LIMIT 1];
        // ProcessInstanceWorkItem pi = listProcessInstance[0].ProcessInstanceWorkItem[0];

        Expense__c objExp = new Expense__c();
        objExp = [ SELECT  Id
        FROM  Expense__c
        WHERE  Id =:listProcessInstance[0].TargetObjectId Limit 1
        ];

        objExp.Approver1__c = UserInfo.getUserId();
        objExp.Approver2__c = objUser2.Id;
        objExp.Approver3__c = objUser3.Id;
        objExp.Approver4__c = objUser4.Id;
        update objExp;


        Profile p = [select id from Profile where Name='System Administrator'];
        User objUser5 = objUser1.clone(false);
        objUser5.ProfileId = p.id;
        User objUser6 = objUser1.clone(false);

        List<ProcessInstance> listProcessInstance2 = [SELECT     Id, TargetObjectId, TargetObject.Name, SubmittedById, SubmittedBy.Name, Status
                , (SELECT   Id, ProcessNodeId, StepStatus, CreatedDate, IsPending
                , ActorId, Actor.Name, OriginalActorId, OriginalActor.Name
        FROM     StepsAndWorkitems
        ORDER BY CreatedDate DESC)
        FROM       ProcessInstance
        WHERE      ProcessDefinition.TableEnumOrId = 'Expense__c' AND Status = 'Pending'
        LIMIT 1];
        Expense__c objExp2 = new Expense__c();
        objExp2 = [ SELECT  Id
        FROM  Expense__c
        WHERE  Id =:listProcessInstance2[0].TargetObjectId Limit 1
        ];



        objExp2.Approver2__c = objUser5.Id;
        objExp2.Approver3__c = objUser6.Id;
        update objExp2;



        //프로세스 생성
        /*ProcessDefinition pd = new ProcessDefinition();
        pd.Name = 'test프로세스';
        pd.Type = 'Approval';
        pd.TableEnumOrId = 'Expense__c';
        pd.LockType = 'Workitem';
        pd.State  = 'Active';
        insert pd;
        //승인프로세스 태운것들
        ProcessInstance  pi = new ProcessInstance ();
        pi.TargetObjectId   = objExp.Id;
        pi.SubmittedById    = UserInfo.getUserId();
        pi.ProcessDefinitionId =  pd.id;
        pi.Status = 'pending';
        insert pi;
        ProcessInstanceWorkitem pw = new ProcessInstanceWorkitem();
        pw.ProcessInstanceId = pi.id;
        pw.OriginalActorId	= UserInfo.getUserId();
        pw.ActorId = UserInfo.getUserId();
        insert pw;
        ProcessNode pn = new ProcessNode ();
        pn.ProcessDefinitionId = pd.id;*/


        // ProcessInstanceHistory pih = new ProcessInstanceHistory();
        // ProcessInstance pi = new ProcessInstance();

        // ProcessInstance.ProcessInstanceHistory

        ApprovalHistoryController.getListApprovalHistory(objExp.Id);
        ApprovalHistoryController.doProcessWorkitemRequest(objExp.Id, 'Removed', '코멘트', UserInfo.getUserId());
        ApprovalHistoryController.doProcessWorkitemRequest(objExp.Id, 'Reassign', '코멘트', objUser3.Id);
        ApprovalHistoryController.doProcessWorkitemRequest(objExp2.Id, 'Pending', '코멘트', objUser5.Id);

        Test.stopTest();
    }
}