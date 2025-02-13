/**
 * @description       : 프로젝트 수행팀 레코드 생성시, User.ApprovalLine1__c(휴가 승인) 및 User.ApprovalLine2__c(프로젝트 예산 승인) 업데이트
 * @author            : cj.sohn@daeunextier.com
 * @group             : DaeuNextier
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-01-18   cj.sohn@daeunextier.com   Initial Version
 * 1.5   2021-01-28   cj.sohn@daeunextier.com   User.ApprovalLine2__c(프로젝트 예산 승인) 업데이트 추가
**/

trigger PerformProjectTrigger on PerformProject__c (after insert, after update, before update) {
    new PerformProject_tr().run();

//    if (Trigger.isAfter) {
//        if(Trigger.isInsert || Trigger.isUpdate){
//            Map<Id, PerformProject__c> newMap = Trigger.newMap;
//            Map<Id, PerformProject__c> oldMap = Trigger.oldMap;
//
//            //  프로젝트 중복 제거
//            Set<Id> setProjectIds = new Set<Id>();
//            for(Id id : newMap.keySet()){
//                PerformProject__c performProject = newMap.get(id);
//                setProjectIds.add(performProject.Project__c);
//            }
//
//            Map<Id, PerformProject__c> mapGetRecords = new Map<Id, PerformProject__c>([SELECT Id, Project__c, Project__r.Business__c, IsPM__c, Employee__r.User__c FROM PerformProject__c WHERE Project__c IN: setProjectIds]);
//
//            //  프로젝트 수행팀 레코드별 사용자 Id
//            Map<Id, PerformProject__c> mapPerformProjectByUserId = new Map<Id, PerformProject__c>();
//            for(Id id : mapGetRecords.keySet()){
//                PerformProject__c performProject = mapGetRecords.get(id);
//                mapPerformProjectByUserId.put(performProject.Employee__r.User__c, performProject);
//            }
//
//            //  프로젝트에 해당하는 PM 정보 조회 및 프로젝트 사업부장 조회
//            List<PerformProject__c> listPerformProjects = [SELECT Id, Project__c, Project__r.Business__c, Employee__r.User__c FROM PerformProject__c WHERE Project__c IN: setProjectIds AND IsPM__c = true ORDER BY CreatedDate ASC];
//            Set<String> setBusiness = new Set<String>();
//            for(PerformProject__c pp : listPerformProjects){
//                setBusiness.add(pp.Project__r.Business__c);
//            }
//
//            List<Employee__c> listEmployees = [SELECT Id, Department__c, DeptPosition__c, User__c FROM Employee__c WHERE Department__c IN: setBusiness AND DeptPosition__c = 'Department Head' AND Status__c = TRUE];
//            Map<String, Id> mapUserIdByDeptPosition = new Map<String, Id>();
//            for(Employee__c employee : listEmployees){
//                mapUserIdByDeptPosition.put(employee.Department__c, employee.User__c);
//            }
//
//            Map<Id, Id> mapProjectManagersByProject = new Map<Id, Id>();
//            Map<Id, Id> mapBusinessManagersByProject = new Map<Id, Id>();
//            for(PerformProject__c pp : listPerformProjects){
//                mapProjectManagersByProject.put(pp.Project__c, pp.Employee__r.User__c);
//                mapBusinessManagersByProject.put(pp.Project__c, mapUserIdByDeptPosition.get(pp.Project__r.Business__c));
//            }
//            UserRole userRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'ceo'];
//            User ceo = [SELECT Id, Name FROM User WHERE UserRoleId =: userRole.Id ORDER BY CreatedDate DESC LIMIT 1];
//
//            //  프로젝트 수행팀에 해당하는 사용자 정보 조회
//            List<User> listUsers = [SELECT Id, Name, ApprovalLine1__c, ApprovalLine2__c FROM User WHERE Id IN: mapPerformProjectByUserId.keySet()];
//            for(User u : listUsers){
//                //  프로젝트 PM인 경우, ApprovalLine1__c에 대표님 Id를 반영하고, 프로젝트 수행원인 경우, ApprovalLine1__c에 PM Id를 반영
//                PerformProject__c performProject = mapPerformProjectByUserId.get(u.Id);
//                if(performProject.IsPM__c){
//                    u.ApprovalLine1__c = 'ApprovalLine1/ApprovalLine1/' + ceo.Id;
//                    if(mapBusinessManagersByProject.get(performProject.Project__c) == null){
//                        u.ApprovalLine2__c = 'ApprovalLine2/ApprovalLine2/' + ceo.Id;
//                    }else{
//                        u.ApprovalLine2__c = 'ApprovalLine2/ApprovalLine2/' + mapBusinessManagersByProject.get(performProject.Project__c) + '/'+ ceo.Id;
//                    }
//
//                }else{
//                    if(mapProjectManagersByProject.get(performProject.Project__c) == null){
//                        Trigger.new[0].addError('프로젝트 수행팀에 PM이 등록되지 않았습니다. 따라서 프로젝트 수행팀 구성원의 ApprovalLine)을 지정/변경할 수 없습니다. 프로젝트 수행팀에 PM을 먼저 등록 후 진행해주세요. PM을 변경하는 경우, 프로젝트 수행팀에 변경하려는 PM을 등록/수정 후 기존 PM의 PM여부를 체크해제해주세요');
//                    }else{
//                        u.ApprovalLine1__c = 'ApprovalLine1/ApprovalLine1/' + mapProjectManagersByProject.get(performProject.Project__c);
//                        if(mapBusinessManagersByProject.get(performProject.Project__c) == null){
//                            u.ApprovalLine2__c = 'ApprovalLine2/ApprovalLine2/' + mapProjectManagersByProject.get(performProject.Project__c) + '/' + ceo.Id;
//                        }else{
//                            u.ApprovalLine2__c = 'ApprovalLine2/ApprovalLine2/' + mapProjectManagersByProject.get(performProject.Project__c) + '/' + mapBusinessManagersByProject.get(performProject.Project__c) + '/' + ceo.Id;
//                        }
//                    }
//                }
//            }
//
//            //  User.ApprovalLine1__c, User.ApprovalLine2__c 데이터 반영
//            Database.SaveResult[] dbsr = Database.update(listUsers, false);
//            for(Database.SaveResult sr : dbsr){
//                if(!sr.isSuccess()){
//                    System.debug(sr.getErrors());
//                }
//            }
//        }
//    }
//
//    //2023.07.10 yj.kim 추가 : 1차평가 필요여부 = true 일때, 투입인력 평가 이메일 전송
//    if (Trigger.isBefore) {
//        if (Trigger.isUpdate) {
//
//            List<PerformProject__c> listNew = (List<PerformProject__c>) Trigger.new;
//            List<PerformProject__c> listOld =  (List<PerformProject__c>) Trigger.old;
//            Map<Id, PerformProject__c> oldMap = Trigger.oldMap;
//            System.debug('listNew : ' + listNew);
//
//            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
//
//            List<String> setEmail = new List<String>();
//            List<String> setProjectId = new List<String>();
//            String projectName = '';
//
//            for (PerformProject__c obj : listNew) {
//                if(oldMap.get(obj.Id).Fm_First_Evaluation_Check__c == false && obj.Fm_First_Evaluation_Check__c == true){
//                    setProjectId.add(obj.Project__c);
//                }
//            }
//
//            if(!setProjectId.isEmpty()){
//                List<Project__c> projectList = [
//                        SELECT PMEmail__c, Name
//                        FROM Project__c
//                        WHERE Id =: setProjectId
//                        LIMIT 1
//                ];
//
//                if(!projectList.isEmpty()){
//                    setEmail.add(projectList[0].PMEmail__c);
//                    projectName = projectList[0].Name;
//                }
//
//                if(!setEmail.isEmpty()){
//                    email.setToAddresses(setEmail);
//                    email.setSubject('[' + projectList[0].Name + '] 프로젝트 외주인력평가 안내');
//                    String body = '안녕하세요, <br/>';
//                    body += '[' + projectList[0].Name + '] 프로젝트 투입 1개월차 외주인력 평가를 진행해 주시기 바랍니다. <br/><br/>';
//                    body += '아래 링크를 누르시면 해당 프로젝트 레코드로 이동합니다. <br/>';
//                    body += '화면에서 [투입인력평가서] 버튼을 누르신 후 평가를 진행해주시기 바랍니다.';
//                    body += 'https://daeunextier--dev.sandbox.lightning.force.com/lightning/r/Project__c/' + listNew[0].Id + '/view <br/><br/>';
//                    body += '감사합니다.';
//                    email.setHtmlBody(body);
//
//                    OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'admin@daeunextier.com'];
//                    System.debug('owea : ' + owea);
//                    if ( owea.size() > 0 ) {
//                        email.setOrgWideEmailAddressId(owea.get(0).Id);
//                    }
//
//                    try{
//                        if(!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
//                        System.debug('success');
//                    }catch(Exception e){
//                        System.debug('error');
//                    }
//                }
//            }
//        }
//    }


}