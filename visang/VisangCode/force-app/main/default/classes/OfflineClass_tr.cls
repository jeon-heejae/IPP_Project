public with sharing class OfflineClass_tr extends TriggerHandler {
    
    private List<OfflineClass__c> listOfflineClassNew {get;set;}
    
    

    


    public OfflineClass_tr(){
        listOfflineClassNew= (List<OfflineClass__c>)Trigger.new;
        
    }
    public override void beforeInsert(){
        
        
    }

    public override void afterInsert(){
        afterOfflineClassInsert();
    }

    public override void beforeUpdate(){
        
    }

    public override void afterUpdate(){
    }

    public override void beforeDelete(){
        
    }

    public void afterOfflineClassInsert() {
        //new에 선생님 Id와 강의 일정 담겨있음
        List<Id> listTeacherId=new List<Id>();
        List<Date> listNextOffline=new List<Date>();

        for(OfflineClass__c objOffline:listOfflineClassNew){
            listTeacherId.add(objOffline.Teacher__c);
            listNextOffline.add(objOffline.ClassDate__c);
        }
        
        //학생들 가져오기
        List<Contact> listContact=new List<Contact>();
        listContact=[
            SELECT Id,Teacher__c,OfflineClassDate__c 
            FROM Contact 
            WHERE Teacher__c=:listTeacherId
            ];       

        Integer teacherIndex;    
        for(Contact con:listContact){
            //리스트의 앞쪽부터 인자와 동일한 객체가 있는지 찾으며, 존재한다면 그 인덱스를 리턴. 
            //존재하지 않는다면 -1을 리턴.
            teacherIndex=listTeacherId.indexOf(con.Teacher__c);

            if(teacherIndex!=-1){
                con.OfflineClassDate__c=listNextOffline[teacherIndex];
            }
        }

        if(!listContact.isEmpty()){
            update listContact;
        }

        List<Teacher__c> listTeacher=new List<Teacher__c>();
        for(Id objId:listTeacherId){
            teacherIndex=listTeacherId.indexOf(objId);

            if(teacherIndex!=-1){
                Teacher__c objTeacher=new Teacher__c();
                objTeacher.Id=listTeacherId[teacherIndex];
                objTeacher.NextClass__c=listNextOffline[teacherIndex];
                listTeacher.add(objTeacher);
            }
        }
        
        if(!listTeacher.isEmpty()){
            update listTeacher;
        }
        
        Map<Id, String> teacherNames = new Map<Id, String>();
        for (Teacher__c teacher : [
            SELECT Id, Name 
            FROM Teacher__c 
            WHERE Id IN :listTeacherId
        ]) {
            teacherNames.put(teacher.Id, teacher.Name);
        }

        // Event 생성
        List<Event> listEvent = new List<Event>();
        for (Integer i = 0; i < listTeacherId.size(); i++) {
            Id teacherId = listTeacherId.get(i);
            Date classDate = listNextOffline.get(i);

            // 시간 설정
            Time startTime = Time.newInstance(21, 0, 0, 0);  // 오후 9시
            Time endTime = Time.newInstance(22, 0, 0, 0);    // 오후 10시

            DateTime startDateTime = DateTime.newInstance(classDate, startTime);
            DateTime endDateTime = DateTime.newInstance(classDate, endTime);

            Event newEvent = new Event();
            String teacherName = teacherNames.get(teacherId);
            newEvent.Subject = teacherName + ' 선생님 화상강의';
            newEvent.StartDateTime = startDateTime;
            newEvent.EndDateTime = endDateTime;
            newEvent.Description = teacherName + ' 선생님의 화상 강의 일정입니다.';
            listEvent.add(newEvent);
        }

        if (!listEvent.isEmpty()) {
            insert listEvent;
        }
        

    }
}