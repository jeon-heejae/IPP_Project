/**
 * Created by yj.kim on 2023-07-04.
 */

public without sharing class EmployeeEvaluationBtnController {

    public String recordId { get; set; }

    public EmployeeEvaluationBtnController(ApexPages.StandardController controller) {
        recordId = ApexPages.currentPage().getParameters().get('Id');
        System.debug('recordId : ' + recordId);
    }

    @AuraEnabled
    public static Map<String, Object> doInit(String recordId){
        System.debug('doInit recordId : ' + recordId);

        List<InternalWrapper> listInWrapper = new List<InternalWrapper>();
        List<externalWrapper> listExWrapper = new List<externalWrapper>();

        List<PerformProject__c> projectTeam = new List<PerformProject__c>();

        String projectName = '';
        Boolean firstEvaluation = false;

        Project__c projectObj = [
                SELECT Completed__c
                FROM Project__c
                WHERE Id =: recordId
        ];
        System.debug('완료여부 : ' + projectObj.Completed__c);

        //외주직원 1차평가
        if(projectObj.Completed__c == false){
            System.debug('외주직원 1차평가');
            projectTeam = [
                    SELECT Id, Project__c, Employee__c, Employee__r.Type__c, Employee__r.Name, Project__r.Name, Employee__r.MainRole__c,
                            Employee__r.O_Company__r.Name, fm_FromDate__c, fm_ToDate__c
                    FROM PerformProject__c
                    WHERE Project__c =: recordId AND IsPM__c = FALSE AND Fm_First_Evaluation_Check__c = TRUE AND First_evaluation_YN__c = FALSE
            ];

            if(!projectTeam.isEmpty()){
                firstEvaluation = true;
            }
        }

        //최종평가
        if(projectObj.Completed__c == true){
            System.debug('최종평가');
            projectTeam = [
                    SELECT Id, Project__c, Employee__c, Employee__r.Type__c, Employee__r.Name, Project__r.Name, Employee__r.MainRole__c,
                            Employee__r.O_Company__r.Name, fm_FromDate__c, fm_ToDate__c
                    FROM PerformProject__c
                    WHERE Project__c =: recordId AND IsPM__c = FALSE
            ];
        }

        System.debug('projectTeam : ' + projectTeam);
        if(!projectTeam.isEmpty()){
            projectName = projectTeam[0].Project__r.Name;
            for(PerformProject__c obj : projectTeam){
                if(obj.Employee__r.Type__c == '내부직원'){

                    InternalWrapper inObj = new InternalWrapper();
                    inObj.performProjectId = obj.Id;
                    inObj.project = obj.Project__c;
                    inObj.employeeId = obj.Employee__c;
                    inObj.employeeName = obj.Employee__r.Name;
                    inObj.mainRole = obj.Employee__r.MainRole__c;
                    inObj.competency = null;
                    inObj.communication = null;
                    inObj.cooperation = null;
                    inObj.passion = null;
                    inObj.attitude = null;
                    inObj.addWork = null;
                    inObj.addComment = null;
                    inObj.fromDate = obj.fm_FromDate__c;
                    inObj.toDate = obj.fm_ToDate__c;

                    listInWrapper.add(inObj);
                }else if(obj.Employee__r.Type__c == '외부직원'){

                    externalWrapper exObj = new externalWrapper();
                    exObj.performProjectId = obj.Id;
                    exObj.project = obj.Project__c;
                    exObj.employeeId = obj.Employee__c;
                    exObj.employeeName = obj.Employee__r.Name;
                    exObj.mainRole = obj.Employee__r.O_Company__r.Name;
                    exObj.competency = null;
                    exObj.communication = null;
                    exObj.cooperation = null;
                    exObj.passion = null;
                    exObj.attitude = null;
                    exObj.addWork = null;
                    exObj.addComment = null;
                    exObj.fromDate = obj.fm_FromDate__c;
                    exObj.toDate = obj.fm_ToDate__c;

                    listExWrapper.add(exObj);
                }
            }
        }

        Map<String, Object> mapReturnValue = new Map<String, Object>{
                'projectName'     => projectName,
                'InternalWrapper' => listInWrapper,
                'externalWrapper' => listExWrapper,
                'firstEvaluation' => firstEvaluation
        };
        System.debug('mapReturnValue : ' + mapReturnValue);

        return mapReturnValue;
    }

    @AuraEnabled
    public static Map<String, Object> doSave(List<Map<String, Object>> inList, List<Map<String, Object>> exList, Boolean firstEvaluation){
        System.debug('inList : ' + inList);
        System.debug('exList : ' + exList);
        System.debug('firstEvaluation : ' + firstEvaluation);

        Map<String, Object> mapInListData = new Map<String, Object>();
        Map<String, Object> mapExListData = new Map<String, Object>();
        List<PJT_Employee_evaluation__c> insertList = new List<PJT_Employee_evaluation__c>();

        List<String> firstPerformList = new List<String>();
        List<String> finalPerformList = new List<String>();

        String status = 'SUCCESS';
        String message = '성공적으로 저장되었습니다.';

        try {
            //내부직원이 있을시
            if (!inList.isEmpty()) {
                for(Object obj : inList){
                    mapInListData = (Map<String, Object>) obj;
                    PJT_Employee_evaluation__c evalObj = new PJT_Employee_evaluation__c();
                    if(firstEvaluation == false){
                        evalObj.Evaluation_Type__c = '최종평가';
                        finalPerformList.add(String.valueOf(mapInListData.get('performProjectId')));
                    }
                    evalObj.Project__c = String.valueOf(mapInListData.get('project'));                          //프로젝트 Id
                    evalObj.Name__c = String.valueOf(mapInListData.get('employeeId'));                          //이름
                    System.debug('fromDate : ' + mapInListData.get('fromDate'));
                    System.debug('toDate : ' + mapInListData.get('toDate'));
                    evalObj.InputDate__c = mapInListData.get('fromDate') != null ? formatToDate(String.valueOf(mapInListData.get('fromDate'))) : null;   //투입일자
                    evalObj.WithdrawDate__c = mapInListData.get('toDate') != null ? formatToDate(String.valueOf(mapInListData.get('toDate'))) : null;    //철수일자                                  //철수일자
                    evalObj.Competency__c = String.valueOf(mapInListData.get('competency'));                    //competency
                    evalObj.Communication_Skill__c = String.valueOf(mapInListData.get('communication'));           //Communication Skill
                    evalObj.Cooperation__c = String.valueOf(mapInListData.get('cooperation'));                   //Cooperation
                    evalObj.Passion__c = String.valueOf(mapInListData.get('passion'));                       //Passion
                    evalObj.Attitude__c = String.valueOf(mapInListData.get('attitude'));                        //attitude
                    evalObj.Addtional_Work__c = String.valueOf(mapInListData.get('addWork'));                   //기타수행업무
                    evalObj.Additional_Comment__c = String.valueOf(mapInListData.get('addComment'));            //비고(기타의견)
                    insertList.add(evalObj);
                }
            }

            if(!exList.isEmpty()){
                for(Object obj : exList){
                    mapExListData = (Map<String, Object>) obj;
                    PJT_Employee_evaluation__c evalObj = new PJT_Employee_evaluation__c();
                    if(firstEvaluation == true){
                        evalObj.Evaluation_Type__c = '1차평가';
                        firstPerformList.add(String.valueOf(mapExListData.get('performProjectId')));
                    }else if(firstEvaluation == false){
                        evalObj.Evaluation_Type__c = '최종평가';
                        finalPerformList.add(String.valueOf(mapExListData.get('performProjectId')));
                    }
                    evalObj.Project__c = String.valueOf(mapExListData.get('project'));                          //프로젝트 Id
                    evalObj.Name__c = String.valueOf(mapExListData.get('employeeId'));                          //이름
                    evalObj.InputDate__c = mapExListData.get('fromDate') != null ? formatToDate(String.valueOf(mapExListData.get('fromDate'))) : null;   //투입일자
                    evalObj.WithdrawDate__c = mapExListData.get('toDate') != null ? formatToDate(String.valueOf(mapExListData.get('toDate'))) : null;    //철수일자
                    evalObj.Competency__c = String.valueOf(mapExListData.get('competency'));                    //competency
                    evalObj.Communication_Skill__c = String.valueOf(mapExListData.get('communication'));           //Communication Skill
                    evalObj.Cooperation__c = String.valueOf(mapExListData.get('cooperation'));                   //Cooperation
                    evalObj.Passion__c = String.valueOf(mapExListData.get('passion'));                       //Passion
                    evalObj.Attitude__c = String.valueOf(mapExListData.get('attitude'));                        //attitude
                    evalObj.Addtional_Work__c = String.valueOf(mapExListData.get('addWork'));                   //기타수행업무
                    evalObj.Additional_Comment__c = String.valueOf(mapExListData.get('addComment'));            //비고(기타의견)
                    insertList.add(evalObj);
                }
            }

            if(!insertList.isEmpty()){
                insert insertList;

                List<PerformProject__c> updateList = new List<PerformProject__c>();
                //1차평가 완료될경우, 프로젝트 수행팀 1차평가 여부 Field Update
                if(!firstPerformList.isEmpty()){
                    List<PerformProject__c> ppObj = [
                            SELECT Id
                            FROM PerformProject__c
                            WHERE Id =: firstPerformList
                    ];
                    System.debug('ppObj : ' + ppObj);
                    for(PerformProject__c obj : ppObj){
                        obj.First_evaluation_YN__c = true;
                        updateList.add(obj);
                    }
                    update updateList;
                }
                //최종평가 완료될경우, 최종평가 여부 Field Update
                if(!finalPerformList.isEmpty()){
                    List<PerformProject__c> ppObj = [
                            SELECT Id
                            FROM PerformProject__c
                            WHERE Id =: finalPerformList
                    ];
                    System.debug('ppObj : ' + ppObj);
                    for(PerformProject__c obj : ppObj){
                        obj.Final_Evaluation_YN__c = true;
                        updateList.add(obj);
                    }
                    update updateList;
                }

            }
        }catch(Exception e){
            System.debug('doSave line : ' + e.getLineNumber());
            System.debug('doSave message : ' + e.getMessage());
            status = 'ERROR';
            message = e.getMessage();
        }

        Map<String, Object> mapReturnValue = new Map<String, Object>{
            'status'  => status,
            'message' => message
        };
        return mapReturnValue;
    }

    public static Date formatToDate(String beforeDate){
        Date afterDate = Date.newInstance(Integer.valueOf(beforeDate.left(4)), Integer.valueOf(beforeDate.mid(5,2)), Integer.valueOf(beforeDate.right(2)));
        return afterDate;
    }

    //내부직원
    public class InternalWrapper {
        @AuraEnabled
        public Id project {get; set;}             //프로젝트명
        @AuraEnabled
        public Id employeeId {get; set;}          //Employee Id
        @AuraEnabled
        public String employeeName {get; set;}    //이름
        @AuraEnabled
        public String mainRole {get; set;}        //역할
        @AuraEnabled
        public String competency {get; set;}      //프로젝트 수행능력
        @AuraEnabled
        public String communication {get; set;}   //Skill 소통능력
        @AuraEnabled
        public String cooperation {get; set;}     //협업
        @AuraEnabled
        public String passion {get; set;}         //열정, 적극성
        @AuraEnabled
        public String attitude {get; set;}        //업무수행 태도, 자세
        @AuraEnabled
        public String addWork {get; set;}         //기타 수행업무
        @AuraEnabled
        public String addComment {get; set;}      //평가자의견
        @AuraEnabled
        public Date fromDate {get; set;}          //시작일
        @AuraEnabled
        public Date toDate {get; set;}            //종료일
        @AuraEnabled
        public Id performProjectId {get; set;}    //프로젝트 수행팀 Id
    }

    //외부직원
    public class externalWrapper {
        @AuraEnabled
        public Id project {get; set;}             //프로젝트명
        @AuraEnabled
        public Id employeeId {get; set;}          //Employee Id
        @AuraEnabled
        public String employeeName {get; set;}    //이름
        @AuraEnabled
        public String mainRole {get; set;}        //역할[외주계약사]
        @AuraEnabled
        public String competency {get; set;}      //프로젝트 수행능력
        @AuraEnabled
        public String communication {get; set;}   //Skill 소통능력
        @AuraEnabled
        public String cooperation {get; set;}     //협업
        @AuraEnabled
        public String passion {get; set;}         //열정, 적극성
        @AuraEnabled
        public String attitude {get; set;}        //업무수행 태도, 자세
        @AuraEnabled
        public String addWork {get; set;}         //기타 수행업무
        @AuraEnabled
        public String addComment {get; set;}      //평가자의견
        @AuraEnabled
        public Date fromDate {get; set;}          //시작일
        @AuraEnabled
        public Date toDate {get; set;}            //종료일
        @AuraEnabled
        public Id performProjectId {get; set;}    //프로젝트 수행팀 Id
    }

}