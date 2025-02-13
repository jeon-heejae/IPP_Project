public with sharing class HolidayUtil{
    public static void createEvent(HolidayAction__c hlAct){
        date date1 = hlAct.HolidayAction_Date1__c;
        date date2 = hlAct.HolidayAction_Date2__c;
        date date3 = hlAct.HolidayAction_Date3__c;
        date date4 = hlAct.HolidayAction_Date4__c;
        date date5 = hlAct.HolidayAction_Date5__c;
        Event e;
        if(hlAct.HolidayAction_Days__c >= 1){
            e = setEvent(hlAct,date1);
            insert e;
        }
        if(hlAct.HolidayAction_Days__c > 1){
            e = setEvent(hlAct,date2);
            insert e;
        }
        if(hlAct.HolidayAction_Days__c > 2){
            e = setEvent(hlAct,date3);
            insert e;
        }
        if(hlAct.HolidayAction_Days__c > 3){
            e = setEvent(hlAct,date4);
            insert e;
        }
        if(hlAct.HolidayAction_Days__c > 4){
            e = setEvent(hlAct,date5);
            insert e;
        }
        shareFinance(hlAct);
    }
    
    public static Event setEvent(HolidayAction__c hlAct,date dt){
        string userId = hlAct.OwnerId;
        string actId = hlAct.Id;
        string subject = hlAct.Name;
        Event e = new Event();
        e.OwnerId = hlAct.OwnerId;
        e.ActivityDate = dt;
        e.EndDateTime = dt;
        e.StartDateTime = dt;
        e.IsAllDayEvent = true;        
        e.Subject = 'On holiday';
        e.ShowAs = 'OutOfOffice';
        if(hlAct.HolidayAction_Type__c =='Half-day Leave'){
            e.IsAllDayEvent = false;
            e.Subject = 'Half-day Leave';
            if(hlAct.HolidayAction_HalfdayTime__c == 'AM')
                e.EndDateTime = e.EndDateTime.addHours(3);
            else{
                e.StartDateTime = e.EndDateTime.addHours(3);
                e.ActivityDateTime = e.EndDateTime.addHours(3);
                e.ActivityDate = e.ActivityDateTime.date();
                e.EndDateTime = e.EndDateTime.addHours(9);            
            }
        }
        e.Description = hlAct.HolidayAction_Description__c;
        e.WhatId = hlAct.Id;
        
        return e;
    }
    
    public static boolean sendEmail(string pType, User pUsr, Holiday__c pHld){
        try{
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new string[]{pUsr.Email};
            string subject = '';
            string msgBody =  pUsr.Name + '님 안녕하세요. \r\n\r\n';
            if(pHld.Holiday_IsAnnualleave__c)
                subject = '연차';
            else
                subject = '월차';
            if(pType == 'Info'){
                msgBody += '귀하의 '+ subject + '내역에 대한 안내 메일입니다. \r\n';
                subject += ' 내역 안내';
            }
            else if(pType == '1st'){
                subject += ' 사용 촉진 안내';
                msgBody += '근로기준법 제60조제1항·제3항 및 제4항에 따른 유급휴가의 사용 촉진 안내 메일입니다. \r\n';
                msgBody += '10일 내로 서면을 통해 사용 계획을 회신 부탁드립니다. \r\n';
            }
            else if(pType == '2nd'){
                subject += ' 소멸 안내';
                msgBody += '근로기준법 제60조제7항에 따른 유급휴가의 소멸 안내 메일입니다. \r\n';
                msgBody += '사용기한까지 사용하지 않은 휴가는 소멸되오니 계획 등록 부탁드립니다. \r\n';
                msgBody += '단 프로젝트 일정등의 이유로 사용이 불가피한 경우 기한 만료 후 관리자에게 문의 하시기 바랍니다. \r\n';
            }
            msgBody += '아래의 휴가 관련 내역을 휴가 사용에 참고하시기 바랍니다. \r\n\r\n';
            msgBody += '입사일자 : ' + date.valueOf(pHld.Holiday_JoinDate__c).format() + '\r\n';
            msgBody += '사용기한 : ' + date.valueOf(pHld.Holiday_PeriodEnd__c != null ? pHld.Holiday_PeriodEnd__c : Date.newInstance(Date.today().year(), 12, 31)).format() + '\r\n';
            msgBody += '휴가일수 : ' + string.valueOf(pHld.Holiday_Calculated__c) + '일\r\n';
            msgBody += '추가일수 : ' + string.valueOf(pHld.Holiday_GivenHolidays__c) + '일\r\n';
            msgBody += '사용일수 : ' + string.valueOf(pHld.Holiday_UseDays__c) + '일\r\n';
            msgBody += '잔여일수 : ' + string.valueOf(pHld.Holiday_Remain__c) + '일\r\n';
            msgBody += '\r\n';
            msgBody += '자세한 내역은 ' + URL.getSalesforceBaseUrl().toExternalForm() + '/_ui/core/userprofile/UserProfilePage?tab=My_Holiday_Info 에서 확인 가능합니다.\r\n';
            msgBody += '귀하의 노고에 감사드립니다.\r\n\r\n';
            msgBody += 'DaeU NexTier Inc.\r\n';
            msgBody += '\r\n';
            msgBody += 'Tel: 82-2-553-9981 | Email: admin@daeunextier.com\r\n';
            msgBody += 'Web: www.daeunextier.com | Facebook: www.facebook.com/daeunextier\r\n';
            msgBody += 'YouTube: 쉽고 빠르고 합리적인 가격의 IT 서비스';
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            email.setPlainTextBody(msgBody );
            
            if(!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }catch(Exception e){
            return false;
        }
        return true;
    }

    /**
     *  @author            : cj.sohn@daeunextier.com
     *  @description       : 휴가 최종 승인 안내 메일 발송
     *                      [프로젝트 투입 직원] → 부대표님, 전무님, 해당 사업부장, 관리직원
                            [본사근무직원] → 대표님, 부대표님, 전무님, 전사업부장, 관리직원
                            [영업팀] → 대표님, 부대표님, 전무님, 전사업부장, 관리직원
                            [임원 및 PM] → 대표님, 전사업부장, 관리직원
     *  @last modified on  : 2021-01-18
     **/
    public static boolean sendEmailForConfirmedHoliday(List<Employee__c> fEmailRecipients, Project__c fProject, HolidayAction__c fHolidayAction, Employee__c fEmployee){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] to = new String[]{};
        String[] cc = new String[]{};

        //  부서별 사원 정리
        Map<String, List<Employee__c>> employeesByDepartments = new Map<String, List<Employee__c>>();
        for(Employee__c employee : fEmailRecipients){
            if(employeesByDepartments.containsKey(employee.Department__c)){
                employeesByDepartments.get(employee.Department__c).add(employee);
            }else{
                employeesByDepartments.put(employee.Department__c, new List<Employee__c>());
                employeesByDepartments.get(employee.Department__c).add(employee);
            }
        }
        if(fHolidayAction.Project__c != null){
            if(fHolidayAction.Position__c.equals('프로젝트 팀원') && (fEmployee != null && fEmployee.Position__c != '임원')){
                //  [프로젝트 투입 직원] → 부대표님, 전무님, 해당 사업부장, 관리직원
                List<Employee__c> recipients = (employeesByDepartments.get(fProject.Business__c) == null ? new List<Employee__c>() : employeesByDepartments.get(fProject.Business__c));
                //  부대표님 + 관리직원
                if(employeesByDepartments.get('MGMT') != null && employeesByDepartments.get('MGMT').size() > 0){
                    recipients.addAll(employeesByDepartments.get('MGMT'));
                }
                //  이응도 전무님
                if(employeesByDepartments.get('General Manager') != null && employeesByDepartments.get('General Manager').size() > 0){
                    for(Employee__c objEmployee : employeesByDepartments.get('General Manager')){
                        if(objEmployee.Name == '이응도')
                            recipients.add(objEmployee);
                    }
                }
                //  해당 사업부장
                for(Employee__c employee: recipients){
                    to.add(employee.Email__c);
                }
            }else{
                //  [임원 및 PM] → 대표님, 전사업부장, 관리직원
                for(Employee__c employee : fEmailRecipients){
                    to.add(employee.Email__c);
                }
            }
        }else{
            //  [본사근무직원] → 대표님, 부대표님, 전무님, 전사업부장, 관리직원
            //  [영업팀] → 대표님, 부대표님, 전무님, 전사업부장, 관리직원
            for(Employee__c employee : fEmailRecipients){
                to.add(employee.Email__c);
            }
        }
        email.setToAddresses(to);
        email.setSubject('[' + fHolidayAction.HolidayAction_UserName__c + '] 휴가 사용 안내');
        String body = fHolidayAction.HolidayAction_UserName__c + ' 휴가 안내드립니다.<br/>';
        body += '휴가 기간(총 ' + fHolidayAction.HolidayAction_Days__c +'일): ' + fHolidayAction.Holiday_Date_Detail__c + '<br/>';
        body += '휴가 사유: ' + fHolidayAction.Name + (fHolidayAction.HolidayAction_Description__c != null ? '(' + fHolidayAction.HolidayAction_Description__c + ')<br/>' : '<br/>');
        body += '승인자: ' + fHolidayAction.FirstHolidayRequest__r.Name + '<br/>';
        if(fProject != null){
            body += '진행중인 프로젝트: ' + fProject.Name + '<br/>';
        }
        body += '<hr/>';
        body += '(주)대유넥스티어 | Tel: 82-2-553-9981<br/>';
        body += 'Web: www.daeunextier.com | Facebook: www.facebook.com/daeunextier';
        email.setHtmlBody(body);

        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'admin@daeunextier.com'];
        if ( owea.size() > 0 ) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }

        try{
            if(!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }catch(exception e){
            return false;
        }
        return true;
    }
    
    public static boolean shareFinance(HolidayAction__c hlAct){
        try{
            hlAct = [SELECT Owner.Name, HolidayAction_Type__c, HolidayAction_Days__c, HolidayAction_Date1__c, HolidayAction_Date2__c,
                            HolidayAction_Date3__c, HolidayAction_Date4__c, HolidayAction_Date5__c, HolidayAction_HalfdayTime__c
                       FROM HolidayAction__c 
                      WHERE Id = :hlAct.Id];
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            HolidayShare__C hs = HolidayShare__C.getOrgDefaults();
            String[] toAddresses = new string[]{hs.Addresses__c};
            string subject = '[휴가사용] - '+ hlAct.Owner.Name;
            string msgBody = hs.Name__c + '님 안녕하세요. \r\n\r\n';
            msgBody += hlAct.Owner.Name + '님의 휴가 사용내역 공유 드립니다.\r\n';
            msgBody += '휴가 유형 : ' + hlAct.HolidayAction_Type__c + '\r\n';
            msgBody += '휴가 일수 : ' + (hlAct.HolidayAction_Type__c=='Half-day Leave' ? '0.5' : String.valueOf(hlAct.HolidayAction_Days__c))+ '일\r\n';
            
            if(hlAct.HolidayAction_Days__c >= 1)
                msgBody += '휴가 일자 : ' + hlAct.HolidayAction_Date1__c.format() + 
                           (hlAct.HolidayAction_Type__c=='Half-day Leave' ? ' ' + String.valueOf(hlAct.HolidayAction_HalfdayTime__c) : '') + '\r\n';
            if(hlAct.HolidayAction_Days__c > 1)
                msgBody += '휴가 일자 : ' + hlAct.HolidayAction_Date2__c + '\r\n';
            if(hlAct.HolidayAction_Days__c > 2)
                msgBody += '휴가 일자 : ' + hlAct.HolidayAction_Date3__c + '\r\n';
            if(hlAct.HolidayAction_Days__c > 3)
                msgBody += '휴가 일자 : ' + hlAct.HolidayAction_Date4__c + '\r\n';
            if(hlAct.HolidayAction_Days__c > 4)
                msgBody += '휴가 일자 : ' + hlAct.HolidayAction_Date5__c + '\r\n';
                
            msgBody += '\r\n';            
            msgBody += '자세한 내역은 ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + hlAct.Id + ' 에서 확인 가능합니다.\r\n';
            msgBody += '고맙습니다.\r\n\r\n';
            msgBody += 'DaeU NexTier Inc.\r\n';
            msgBody += '\r\n';
            msgBody += 'Tel: 82-2-553-9981 | Email: admin@daeunextier.com\r\n';
            msgBody += 'Web: www.daeunextier.com | Facebook: www.facebook.com/daeunextier\r\n';
            msgBody += 'YouTube: 쉽고 빠르고 합리적인 가격의 IT 서비스';
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            email.setPlainTextBody(msgBody );
            
            if(!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }catch(Exception e){
            return false;
        }
        return true;
    }
}