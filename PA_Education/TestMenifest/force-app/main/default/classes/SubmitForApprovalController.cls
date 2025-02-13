/************************************************************************************
* File Name   	    : SubmitForApprovalController
* Author	  		: Yeonlim
* Date				: 2023-12-15
* Modification Log
* ===================================================================================
* Ver      Date            Author          Modification
* ===================================================================================
* 1.0      2023-12-15      Yeonlim           Create
************************************************************************************/
public with sharing class SubmitForApprovalController {

    @AuraEnabled
    public static Map<String, String> doApproval(String recordId, String comment){
        String strStatus = 'SUCCESS';
        String strMessage = '승인이 완료되었습니다.';

        try {
            List<Approval.ProcessSubmitRequest> listApprovalReq = new List<Approval.ProcessSubmitRequest>();

            Approval.ProcessSubmitRequest approvalReq;
            approvalReq = new Approval.ProcessSubmitRequest();
            approvalReq.setComments(comment);
            approvalReq.setObjectId(recordId);
            listApprovalReq.add(approvalReq);

            Approval.ProcessResult[] processResults = Approval.process(listApprovalReq);
            Boolean isSuccess = false;
            for(Approval.ProcessResult result : processResults) {
                if(result.isSuccess()) {
                    isSuccess = true;
                }
            }

            if(!isSuccess) {
                strStatus = 'ERROR';
                strMessage = '요청에 실패하였습니다.';
            }

        } catch (Exception e) {
            strStatus = 'ERROR';
            strMessage = 'ERROR : ' + e.getMessage() + ' [Line : ' + e.getLineNumber() + ']';
            System.debug(strMessage);
        }

        return new Map<String, String>{
                'strStatus'  => strStatus,
                'strMessage' => strMessage
        };
    }
}