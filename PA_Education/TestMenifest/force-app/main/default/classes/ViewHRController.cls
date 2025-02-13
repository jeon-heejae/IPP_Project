/************************************************************************************
 * File Name   : ViewHRController.cls
 * Author      : Jihun.Jung
 * Date        : 2019.01.16
 * Tester      : ViewHRController_test.cls
 * Description : 인력 현황 보드 컴포넌트 컨트롤러
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2019.01.16      Jihun.Jung          Create
   1.1      2019.01.17      Soyoung.Jung        Lighting Component 반영
*************************************************************************************/
public with sharing class ViewHRController {
    /*
     월단위 12개월
    주단위 52개+@ L중 옵션은 해당연도 전체, 선택한 분기/반기, 지정 범위
    일단위 365일 중 주단위로 분기/월, 지정 범위
    월 선택시sds
    View(Month)
    임직원/월 1   / 2   / 3 / 4 / 5 / 6 / 7 / 8 / 9 / 10 / 11 / 12
     정지훈      1.00 / 1.00 /~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     황명길     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     주 선택시 dasd
     View(Week) 전체/반기/분기(기본)/지정 (지정시 From 월 To 월)
    임직원/주 1(1) / 1(2) / 1(3) / 1(4) / 2(5) / 2(6) / 2(7) / 2(8) / 3(9) / 4(10)~~~~
     정지훈    1.00   / 1.00  / ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     황명길 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     일 선택시
     View(Day) 분기/월(지정) (지정시 From 일자 To 일자)
    임직원/일 월(12.1) / 화(12.2) / 수(12.3) / 목(12.4) / 금(12.5) / 월(12.8)~~~~~~~~~~~~
     정지훈  1.00       / 1.00 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     황명길 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    임직원 상세정보 표시 옵션ss
    이름(기본) 부서, 직급, 직책, 프로젝트 경력 

    임직원 클릭시 프로젝트 수행팀을 조회(HR 조회 조건과 동일하게 Row단위로)

    flow
    조회를 위한 기본정보 셋팅
    임직원 목록 셀렉트 옵션 리스트등
    조회 타입 기간 선택 후 조회시
    먼저 기간에 따른 임직원의 프로젝트 수행 목록을 가져옴
    조회 타입의 맵과 프로젝트 수행 목록을 조합하여 테이블을 생성
    */

    @AuraEnabled
    public static Map<String, Object> getInitData() {
        // 사원의 총 레코드 갯수
        Integer iEmployeeCnt = [SELECT COUNT() FROM Employee__c];

        // Return Map
        Map<String, Object> mapInitData = new Map<String, Object>{
            'iEmployeeCnt'  => iEmployeeCnt
        };

        return mapInitData;
    }
    
    @AuraEnabled
    public static Map<String, Object> queryHRView(String pFromDt, String pToDt, String pType, Boolean pIncludeHoliday, Integer pOffset, Integer pLimit) {
        Date dFromDt = Date.valueOf(pFromDt);
        Date dToDt = Date.valueOf(pToDt);

        pOffset = Integer.valueOf(pOffset);
        pLimit = Integer.valueOf(pLimit);

        System.debug('queryHRView -> pFromDt : : '+pFromDt);
        System.debug('queryHRView -> pToDt : : '+pToDt);
        System.debug('queryHRView -> pType : : '+pType);


        // 사원에서 유저 아이디 추출, 본부가 키인 사원 맵 생성
        List<Employee__c> listEmployeeTemp = new List<Employee__c>();
        Map<String, List<Employee__c>> mapDeptEmployee = new Map<String, List<Employee__c>>();

        List<Employee__c> empLst = new List<Employee__c>();
        empLst = [SELECT    Id, User__c, toLabel(Position__c), Name, Department__c 
                  FROM      Employee__c
                  WHERE     Status__c = true
                  ORDER BY  Department__c, Position__c
                  LIMIT     :pLimit
                  OFFSET    :pOffset];

        Set<Id> setIdUser = new Set<Id>();
        Set<Id> setIdEmployee = new Set<Id>();
        for(Employee__c emp : empLst){
            setIdUser.add(emp.User__c);
            setIdEmployee.add(emp.Id);

            listEmployeeTemp = mapDeptEmployee.get(emp.Department__c);
            if(listEmployeeTemp == null) {
                listEmployeeTemp = new List<Employee__c>();
            }
            listEmployeeTemp.add(emp);
            mapDeptEmployee.put(emp.Department__c, listEmployeeTemp);
        }

        // 수행 프로젝트에서 날짜 조건으로 데이터 추출
        List<PerformProject__c> ppLst = new List<PerformProject__c>();
        ppLst = [SELECT     Employee__c, Employee__r.Department__c, fm_FromDate__c, fm_ToDate__c, Ratio__c
                 FROM       PerformProject__c
                 WHERE      Employee__c IN :setIdEmployee
                 AND        fm_FromDate__c <= :dToDt
                 AND        fm_ToDate__c >= :dFromDt
                 ORDER BY   fm_FromDate__c];

        // 사원 아이디를 키로 수행 프로젝트 리스트 맵 생성
        Map<Id,List<PerformProject__c>> ppMap = new Map<Id,List<PerformProject__c>>();
        for(PerformProject__c pp : ppLst){
            List<PerformProject__c> nstPpLst = ppMap.get(pp.Employee__c);
            if(nstPpLst == null){
                nstPpLst = new List<PerformProject__c>();
            }
            nstPpLst.add(pp);
            ppMap.put(pp.Employee__c, nstPpLst);
        }

        Map<Id, List<HolidayAction__c>> haMap = new Map<Id, List<HolidayAction__c>>();

        if(pIncludeHoliday) {
            // 승인 된 휴가에서 날짜 조건으로 데이터 추출
            List<HolidayAction__c> haLst = new List<HolidayAction__c>();
            haLst = [SELECT OwnerId, HolidayAction_Date1__c, HolidayAction_Date2__c, HolidayAction_Date3__c, HolidayAction_Date4__c, HolidayAction_Date5__c
                            , fm_MinDate__c, fm_MaxDate__c, HolidayAction_Days__c
                     FROM   HolidayAction__c
                     WHERE  HolidayAction_IsConfirm__c = true
                     AND    OwnerId IN :setIdUser
                     AND    fm_MinDate__c <= :dToDt
                     AND    fm_MaxDate__c >= :dFromDt];

            // 휴가의 오너 아이디를 키로 휴가 리스트 맵 생성
            for(HolidayAction__c ha : haLst){
                List<HolidayAction__c> nstHaLst = haMap.get(ha.OwnerId);
                if(nstHaLst == null){
                    nstHaLst = new List<HolidayAction__c>();
                }
                nstHaLst.add(ha);
                haMap.put(ha.OwnerId, nstHaLst);            
            }
        }

        // 데이터 추출 로직
        // 조건 별 헤더 맵 생성 (Year-Month, Month-Week, Week-Day)
        Set<Object> setTemporary = new Set<Object>();
        Map<String, Set<Object>> mapHeader = new Map<String, Set<Object>>();
        // 데이터 리스트
        List<DateWrapper> dwLst = new List<DateWrapper>();
        // 데이터 맵 (EmployeeId-WrapperList)
        Map<Id, List<DateWrapper>> mapDataWrapper = new Map<Id, List<DateWrapper>>();

        String sDeptPosition = '';
        List<WrapperRow> listWrapRow = new List<WrapperRow>();

        for(Employee__c emp : empLst){
            dwLst = new List<DateWrapper>();

            Map<Date, DateWrapper> empDwDailyMap = getDateTable(dFromDt, dToDt, emp);
            Map<String, DateWrapper> empDwWeeklyMap = new Map<String, DateWrapper>();
            Map<String, DateWrapper> empDwMonthlyMap = new Map<String, DateWrapper>();

            // 수행 프로젝트 리스트
            List<PerformProject__c> empPpLst = ppMap.get(emp.Id);
            if(empPpLst == null)empPpLst = new List<PerformProject__c>();
            
            // 프로젝트 수행 기간 안에서의 투입 비율을 일 단위로 계산
            for(PerformProject__c pp : empPpLst){
                Date frDt = pp.fm_FromDate__c >= dFromDt ? pp.fm_FromDate__c : dFromDt;
                Date toDt = pp.fm_toDate__c <= dToDt ? pp.fm_toDate__c : dToDt;
                for(Integer i = 0;frDt.addDays(i) <= toDt; i++){
                    Date flagDate = frDt.addDays(i);
                    DateWrapper dwDaily = empDwDailyMap.get(flagDate);
                    if(dwDaily == null) continue;
                    dwDaily.workRatio += (pp.Ratio__c == null ? 100 : pp.Ratio__c) / 100; 
                }
            }

            if(pIncludeHoliday) {
                // 휴가 리스트
                List<HolidayAction__c> empHaLst = haMap.get(emp.User__c);
                if(empHaLst == null) empHaLst = new List<HolidayAction__c>();

                // 일 단위로 휴가 비율 계산
                for(HolidayAction__c ha : empHaLst){
                    if(ha.HolidayAction_Days__c < 1 && dFromDt <= ha.HolidayAction_Date1__c && dToDt >= ha.HolidayAction_Date1__c){
                        DateWrapper dwDaily = empDwDailyMap.get(ha.HolidayAction_Date1__c);
                        if(dwDaily != null) dwDaily.holidayRatio = 0.5; 
                    }
                    else if(dFromDt <= ha.HolidayAction_Date1__c && dToDt >= ha.HolidayAction_Date1__c){
                        DateWrapper dwDaily = empDwDailyMap.get(ha.HolidayAction_Date1__c);
                        if(dwDaily != null) dwDaily.holidayRatio = 1; 
                    }
                    if(ha.HolidayAction_Date5__c != null && dFromDt <= ha.HolidayAction_Date5__c && dToDt >= ha.HolidayAction_Date5__c){
                        DateWrapper dwDaily = empDwDailyMap.get(ha.HolidayAction_Date5__c);
                        if(dwDaily != null) dwDaily.holidayRatio = 1; 
                    }
                    if(ha.HolidayAction_Date4__c != null && dFromDt <= ha.HolidayAction_Date4__c && dToDt >= ha.HolidayAction_Date4__c){
                        DateWrapper dwDaily = empDwDailyMap.get(ha.HolidayAction_Date4__c);
                        if(dwDaily != null) dwDaily.holidayRatio = 1; 
                    }
                    if(ha.HolidayAction_Date3__c != null && dFromDt <= ha.HolidayAction_Date3__c && dToDt >= ha.HolidayAction_Date3__c){
                        DateWrapper dwDaily = empDwDailyMap.get(ha.HolidayAction_Date3__c);
                        if(dwDaily != null) dwDaily.holidayRatio = 1; 
                    }
                    if(ha.HolidayAction_Date2__c != null && dFromDt <= ha.HolidayAction_Date2__c && dToDt >= ha.HolidayAction_Date2__c){
                        DateWrapper dwDaily = empDwDailyMap.get(ha.HolidayAction_Date2__c);
                        if(dwDaily != null) dwDaily.holidayRatio = 1; 
                    }
                }
            }
            
            for(DateWrapper dwDaily : empDwDailyMap.values()) {
                switch on pType {
                    when 'DAILY' {
                        dwDaily.totalRatio = ((dwDaily.workRatio + dwDaily.holidayRatio) / dwDaily.totalDay).setScale(1, System.RoundingMode.DOWN);
                    }
                    when 'WEEKLY' {
                        DateWrapper dwWeekly = empDwWeeklyMap.get(dwDaily.weekInYear);

                        if(dwWeekly == null) {
                            dwWeekly = dwDaily;
                        } else {
                            dwWeekly.workRatio += dwDaily.workRatio;
                            dwWeekly.holidayRatio += dwDaily.holidayRatio;
                            dwWeekly.totalDay += 1;
                        }

                        dwWeekly.totalRatio = ((dwWeekly.workRatio + dwWeekly.holidayRatio) / dwWeekly.totalDay).setScale(1, System.RoundingMode.DOWN);
                        empDwWeeklyMap.put(dwWeekly.weekInYear,dwWeekly);
                    }
                    when 'MONTHLY' {
                        DateWrapper dwMonthly = empDwMonthlyMap.get(dwDaily.numOfMon);

                        if(dwMonthly == null) {
                            dwMonthly = dwDaily;
                        } else {
                            dwMonthly.workRatio += dwDaily.workRatio;
                            dwMonthly.holidayRatio += dwDaily.holidayRatio;
                            dwMonthly.totalDay += 1;
                        }

                        dwMonthly.totalRatio = ((dwMonthly.workRatio + dwMonthly.holidayRatio) / dwMonthly.totalDay).setScale(1, System.RoundingMode.DOWN);
                        empDwMonthlyMap.put(dwMonthly.numOfMon,dwMonthly);
                    }
                }
            }

            switch on pType {
                when 'DAILY' {
                    dwLst.addAll(empDwDailyMap.values());

                    // 헤더 맵 생성
                    for(DateWrapper dateWrap : dwLst) {
                        // YYYY-MM-W                                                                       
                        setTemporary = mapHeader.get(dateWrap.numOfYear + '-' + dateWrap.weekInYear);
                        if(setTemporary == null) setTemporary = new Set<Object>();

                        setTemporary.add(dateWrap.flagDate);
                        //system.debug('setTemporary : :'+setTemporary);
                        
                        //system.debug('mapHeader  weekInYear : :'+dateWrap.weekInYear);
                        
                        mapHeader.put(dateWrap.numOfYear + '-'  + dateWrap.weekInYear, setTemporary);
                        //system.debug('mapHeader : :'+mapHeader);
                    }
                }
                when 'WEEKLY' {
                    dwLst.addAll(empDwWeeklyMap.values());

                    // 헤더 맵 생성
                    for(DateWrapper dateWrap : dwLst) {
                        // YYYY-MM
                        setTemporary = mapHeader.get(dateWrap.numOfYear + '-' + dateWrap.numOfMon);
                        if(setTemporary == null) setTemporary = new Set<Object>();
                        
                        setTemporary.add(dateWrap.weekInYear == null ? null : Integer.valueOf(dateWrap.weekInYear));
                        mapHeader.put(dateWrap.numOfYear + '-' + dateWrap.numOfMon, setTemporary);
                    }
                }
                when 'MONTHLY' {
                    dwLst.addAll(empDwMonthlyMap.values());

                    // 헤더 맵 생성
                    for(DateWrapper dateWrap : dwLst) {
                        // YYYY
                        setTemporary = mapHeader.get(dateWrap.numOfYear);
                        if(setTemporary == null) setTemporary = new Set<Object>();

                        setTemporary.add(dateWrap.numOfMon == null ? null : Integer.valueOf(dateWrap.numOfMon));
                        mapHeader.put(dateWrap.numOfYear, setTemporary);   
                    }
                }
            }

            mapDataWrapper.put(emp.Id, dwLst);

            WrapperRow objWrapRow = new WrapperRow();
            objWrapRow.objEmployee = emp;
            objWrapRow.listDateWrapper = dwLst;

            // 부서가 바뀔 때마다 table의 row span 계산
            if(sDeptPosition != emp.Department__c) {
                objWrapRow.iRowSpan = mapDeptEmployee.get(emp.Department__c).size();    
            }

            listWrapRow.add(objWrapRow);
            // 현재 사원의 부서 (비교 용도)
            sDeptPosition = emp.Department__c;
        }

        //for(DateWrapper dw : dwLst){
        //    String dataStr = 'Employee Name : ' + dw.empObj.Name;
        //    dataStr += ', Department__c : ' + dw.empObj.Department__c;
        //    dataStr += ', Position__c : ' + dw.empObj.Position__c;
        //    dataStr += ', numOfYear : ' + dw.numOfYear;
        //    dataStr += ', numOfMon : ' + dw.numOfMon;
        //    dataStr += ', weekInYear : ' + dw.weekInYear;
        //    dataStr += ', weekInMonth : ' + dw.weekInMonth;
        //    dataStr += ', dayOfWeek : ' + dw.dayOfWeek;
        //    dataStr += ', totalDay : ' + dw.totalDay;
        //    dataStr += ', workRatio : ' + dw.workRatio;
        //    dataStr += ', holidayRatio : ' + dw.holidayRatio;
        //    dataStr += ', totalRatio : ' + dw.totalRatio;
        //    system.debug(dataStr);
        //}

        // Header Main, Sub List
        List<WrapperHeader> listMainHeader = new List<WrapperHeader>();
        List<WrapperHeader> listSubHeader = new List<WrapperHeader>();

        List<String> listKey = new List<String>();
        
        String sKey2;
        for(String sKey : mapHeader.keySet()) {
            Set<Object> setHeaderValues = mapHeader.get(sKey);

            if(sKey.indexOf('-') != -1) {                
                listKey = sKey.split('-');


                if(pType=='DAILY') {
                    // Daily : YYYY-W
                    sKey = listKey[1];
                    sKey2 = listKey[0];

                    // i)
                    //Date dFirstDate;
                    //for(Object objHeaderValue : setHeaderValues) {
                    //    dFirstDate = Date.valueOf(objHeaderValue);
                    //    break;
                    //}

                    // ii) set<Object> 형의 setHeaderValues의 날짜값을 받아온다.
                    Date dFirstDate = Date.valueOf(new List<Object>(setHeaderValues)[0]);

                    Datetime dateMon = Datetime.newInstance(Date.valueOf(dFirstDate), Time.newInstance(0, 0, 0, 0));
                    sKey2 = dateMon.format('M');

                }
                else {
                    // Weekly : YYYY-MM
                    sKey = listKey[1];
                    sKey2 = listKey[0];

                }


            }


            System.debug('ljk - - sKey2 : :'+sKey);  
            //System.debug('ljk - - sYearHeader : :'+sYearHeader);  
            //System.debug('ljk - - sMonHeader : :'+sMonHeader);  

            // Main header
            listMainHeader.add(new WrapperHeader(sKey, pType, sKey2, setHeaderValues.size()));

            // Sub header
            for(Object objValue : setHeaderValues) {
                listSubHeader.add(new WrapperHeader(objValue, pType));
            }
        }

        System.debug('mapHeader : ' + mapHeader);
        System.debug('listMainHeader : ' + listMainHeader);
        System.debug('listSubHeader : ' + listSubHeader);

        // Return Map
        Map<String, Object> mapReturnValue = new Map<String, Object>{
            'listMainHeader'    => listMainHeader,
            'listSubHeader'     => listSubHeader,
            'mapDeptEmployee'   => mapDeptEmployee, // 서브 헤더, 사원
            'listWrapRow'       => listWrapRow
        };

        System.debug('mapReturnValue : ' + mapReturnValue);
        return mapReturnValue;
    }

    public static Map<Date, DateWrapper> getDateTable(Date dFromDt, Date dToDt, Employee__c emp){
        Map<Date, DateWrapper> dateTable = new Map<Date, DateWrapper>();
        for(Integer i = 0;dFromDt.addDays(i) <= dToDt; i++){
            Date pDt = dFromDt.addDays(i);
            DateWrapper dw = new DateWrapper(pDt);
            if(dw.totalDay == 0) continue;
            dw.empObj = emp;
            dateTable.put(pDt,dw);
        }
        return dateTable;
    }

    //월 주차를 쓸것인지 년 주차를 쓸것인지 확인 필요
    public class DateWrapper {
        @AuraEnabled public Employee__c empObj;
        @AuraEnabled public Date flagDate;
        //Daily 에 추가될 mon 변수
        @AuraEnabled public Date dailyMon;
        @AuraEnabled public String numOfYear;
        @AuraEnabled public String numOfMon;
        @AuraEnabled public String weekInYear;
        @AuraEnabled public String weekInMonth;
        @AuraEnabled public String dayOfWeek;
        @AuraEnabled public Decimal workRatio = 0;
        @AuraEnabled public Decimal holidayRatio = 0;
        @AuraEnabled public Decimal totalRatio = 0;
        @AuraEnabled public Decimal totalDay = 0;

        public DateWrapper(Date pDt){
            flagDate = pDt;
            DateTime dt = DateTime.newInstance(pDt, Time.newInstance(0, 0, 0, 0));  
            numOfYear = dt.format('Y');
            numOfMon = dt.format('M');
            weekInYear = dt.format('w');
            weekInMonth = dt.format('W');
            dayOfWeek = dt.format('u');
            //평일만 영업일로 계산
            if(Integer.valueOf(dayOfWeek) < 6){
                totalDay = 1;
            }  
            DateTime dt1stDay = DateTime.newInstance(pDt.toStartOfMonth(), Time.newInstance(0, 0, 0, 0));          
            //월 해당일자의 월의 첫번째 날이 토, 일인경우 월주차를 1 차감하여 평일부터 1주차가 되도록 조정
            if(Integer.valueOf(dt1stDay.format('u')) > 5){
                weekInMonth = String.ValueOf(Integer.valueOf(weekInMonth) - 1);
            }
            // 53주
            if(numOfMon == '12' && weekInYear == '1') {
                numOfYear = String.valueOf(Integer.valueOf(numOfYear) - 1);
                weekInYear = '53';
            }
        }
    }

    // Header Wrapper
    public class WrapperHeader {
        @AuraEnabled public String sHeader {get; set;}
        @AuraEnabled public String sType {get; set;}
        @AuraEnabled public Integer iColSpan {get; set;}
        //월,년 변수 추가
        //@AuraEnabled public String sMonHeader {get; set;}
        //@AuraEnabled public String sDayHeader {get; set;}
        @AuraEnabled public String sHeader2 {get; set;}
        @AuraEnabled public String sType2 {get; set;}

        // Main
        public WrapperHeader(String sHeader, String pType, String sHeader2, Integer iColSpan) {
            this.sHeader = sHeader;
            this.sHeader2 = sHeader2;
            this.iColSpan = iColSpan;


            system.debug('WrapperHeader-> sHeader : '+ sHeader);
            system.debug('WrapperHeader-> pType : '+ pType);
            system.debug('WrapperHeader-> iColSpan : '+ iColSpan);



            // 라벨 작업 필요
            switch on pType {
                when 'DAILY' {                    
                    this.sType = '주'; 
                    this.sType2 = '월';
                }
                when 'WEEKLY' {                       
                    this.sType = '월';
                    this.sType2 = '년';
                }
                when 'MONTHLY' {
                    this.sType = '년'; 
                }
            }
        }

        // Sub
        public WrapperHeader(Object header, String pType) {
            // 라벨 작업 필요
            switch on pType {
                when 'DAILY' {
                    DateTime dt = DateTime.newInstance(Date.valueOf(header), Time.newInstance(0, 0, 0, 0));
                    this.sHeader = String.valueOf(Date.valueOf(header).day());
                    this.sType = '(' + listDays.get(Integer.valueOf(dt.format('u'))) + ')'; 
                }
                when 'WEEKLY' {

                    this.sHeader = String.valueOf(header);
                    this.sType = '주'; 
                }  
                when 'MONTHLY' {
                    this.sHeader = String.valueOf(header);
                    this.sType = '월'; 
                }
            }
        }
    }

    // Row Wrapper
    public class WrapperRow {
        @AuraEnabled public Employee__c objEmployee {get; set;}
        @AuraEnabled public List<DateWrapper> listDateWrapper {get; set;}
        @AuraEnabled public Integer iRowSpan {get; set;}

        public WrapperRow() {
            listDateWrapper = new List<DateWrapper>();
        }
    }

    private static List<String> listDays {
        get {
            if(listDays == null) {
                listDays = new List<String>{'일', '월', '화', '수', '목', '금', '토'};
            }

            return listDays;
        }
        set;
    }

}