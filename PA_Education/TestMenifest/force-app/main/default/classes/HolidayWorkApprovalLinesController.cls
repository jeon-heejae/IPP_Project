/**
 * Created by Kwanwoo.Jeon on 2024-01-31.
 */

public with sharing class HolidayWorkApprovalLinesController {
    public static String accessLevel = 'Read';
    public static String rowCause    = 'Manual';

    @AuraEnabled
    public static Map<String, Object> getApprovalLines() {
        Map<String, Schema.SObjectField> mapFields = Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap();
        Map<String, String> mapColumns = new Map<String, String>();
        for(String key : mapFields.keySet()) {
            Schema.DescribeFieldResult describe = mapFields.get(key).getDescribe();
            mapColumns.put(describe.getName(), describe.getLabel());
        }

        List<String> ApprovalLine1 = new List<String>();
        List<String> ApprovalLine2 = new List<String>();
        List<String> ApprovalLine3 = new List<String>();
        List<String> ApprovalLine4 = new List<String>();

        User objUser = [
                SELECT Id, Name, ApprovalLine1__c, ApprovalLine2__c, ApprovalLine3__c, ApprovalLine4__c
                FROM User
                WHERE Id =: UserInfo.getUserId()
        ];

        System.debug(objUser);

        //각 필드별 데이터를 리스트화
        if(objUser.ApprovalLine1__c != null) ApprovalLine1 = objUser.ApprovalLine1__c.split('/');
        if(objUser.ApprovalLine2__c != null) ApprovalLine2 = objUser.ApprovalLine2__c.split('/');
        if(objUser.ApprovalLine3__c != null) ApprovalLine3 = objUser.ApprovalLine3__c.split('/');
        if(objUser.ApprovalLine4__c != null) ApprovalLine4 = objUser.ApprovalLine4__c.split('/');

        //중복 아이디 제거
        Set<String> setApprover = new Set<String>();
        if(!ApprovalLine1.isEmpty()) setApprover.addAll(ApprovalLine1);
        if(!ApprovalLine2.isEmpty()) setApprover.addAll(ApprovalLine2);
        if(!ApprovalLine3.isEmpty()) setApprover.addAll(ApprovalLine3);
        if(!ApprovalLine4.isEmpty()) setApprover.addAll(ApprovalLine4);

        List<Map<String, Object>> listLabel  = new List<Map<String, Object>>();
        listLabel = setApprovalLine(listLabel, setApprover, ApprovalLine1, mapColumns);
        listLabel = setApprovalLine(listLabel, setApprover, ApprovalLine2, mapColumns);
        listLabel = setApprovalLine(listLabel, setApprover, ApprovalLine3, mapColumns);
        listLabel = setApprovalLine(listLabel, setApprover, ApprovalLine4, mapColumns);

        ApprovalLine__c objCustomSet =  ApprovalLine__c.getOrgDefaults();
        Decimal iLineLimit 	   = objCustomSet.LineLimit__c; 	//ApprovalLine 제한
        Decimal iApproverLimit = objCustomSet.ApproverLimit__c; //Approver 수 제한

        Map<String, Object> mapReturnValue = new Map<String, Object>{
                'listLabel' 	 => listLabel,
                'objUser'		 => objUser,
                'iLineLimit' 	 => iLineLimit,
                'iApproverLimit' => iApproverLimit
        };

        return mapReturnValue;
    }

    private static List<Map<String, Object>> setApprovalLine(List<Map<String, Object>> listLabel, Set<String> setApprover, List<String> listAppLine, Map<String, String> mapColumns) {
        Map<Id, User> mapUser = new Map<Id, User>([
                SELECT Id, Name
                FROM User
                WHERE Id IN :setApprover
        ]);

        List<User> listUser = new List<User>();
        Map<String, Object> data = new Map<String, Object>();
        Integer cnt = 0;
        for (String s : listAppLine){
            if (cnt == 0) {
                data.put('label', s);
            } else if (mapColumns.containsKey('ApprovalLine1__c') && cnt == 1){
                data.put('fieldName', s);
            } else {
                listUser.add(mapUser.get(s));
            }
            cnt++;
        }
        if(cnt > 0){
            data.put('userDatas', listUser);
            listLabel.add(data);
        }

        return listLabel;
    }

    @AuraEnabled
    public static String doSubmit(String sObjectName, String sComments, String sHistoryRecordId, List<User> objListUser){
        System.debug('sObjectName : '+ sObjectName + ' / sComments : '+ sComments +' / sHistoryRecordId : '+ sHistoryRecordId );

        //user이름 들어있는 리스트 listApprovalLine 으로 칭함.
        String returnValue;
        try{
            List<String> userList = new List<String>();
            for(Integer i = 0; i < objListUser.size(); i++){
                userList.add(objListUser[i].Id);
            }

            System.debug(userList);

            Integer iUserCnt = userList.size();
            String sQuery   = 'SELECT Id FROM '+ sObjectName +' WHERE Id = \''+ sHistoryRecordId + '\''   ;
            System.debug('sQuery :: ' + sQuery);
            SObject obj = Database.query(sQuery);

            switch on iUserCnt {
                when 1 { obj.put('Approver1__c', userList[0]); obj.put('Approver2__c', ''); 	obj.put('Approver3__c', ''); 	obj.put('Approver4__c', '');}
                when 2 { obj.put('Approver1__c', userList[0]); obj.put('Approver2__c', userList[1]); 	obj.put('Approver3__c', ''); 	obj.put('Approver4__c', '');}
                when 3 { obj.put('Approver1__c', userList[0]); obj.put('Approver2__c', userList[1]); 	obj.put('Approver3__c', userList[2]); 	obj.put('Approver4__c', '');}
                when 4 { obj.put('Approver1__c', userList[0]); obj.put('Approver2__c', userList[1]); 	obj.put('Approver3__c', userList[2]); 	obj.put('Approver4__c', userList[3]);}
            }
            update obj;


            if (sObjectName.contains('HolidayWork')) {
                List<HolidayWork__Share> holidayWorkShares = new List<HolidayWork__Share>();

                for(User u : objListUser) {
                    HolidayWork__Share holidayWorkSh = new HolidayWork__Share();
                    holidayWorkSh.ParentId       = sHistoryRecordId;
                    holidayWorkSh.AccessLevel 	 = accessLevel;
                    holidayWorkSh.RowCause	     = rowCause;
                    if(u.Id ==  UserInfo.getUserId()) continue;
                    holidayWorkSh.UserOrGroupId  = u.Id;

                    holidayWorkShares.add(holidayWorkSh);
                }

                if (!holidayWorkShares.isEmpty()) {
                    insert holidayWorkShares;
                }
            }else if (sObjectName.contains('ProjectBudget')) {
                //public인듯?
            }


            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments(sComments);
            req1.setObjectId(sHistoryRecordId);
            Approval.ProcessResult result = Approval.process(req1);

            returnValue = 'success/성공적으로 저장되었습니다./' + sHistoryRecordId ;

        } catch (Exception e) {
            returnValue = 'error/' + e.getMessage() + '클래스에러';
        }

        return returnValue;
    }
}