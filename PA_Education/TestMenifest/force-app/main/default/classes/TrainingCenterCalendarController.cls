/**
 * Created by Kwanwoo.Jeon on 2024-02-16.
 */

/*
* ==================================================================================
*   File Name   : TrainingCenterCalendarController.cls
*   Author      : Kwanwoo.Jeon
*   Date        : 2024.02.16
*   Tester      : TrainingCenterCalendarController_Test.cls
*   Description : 수련원 신청 캘랜더 화면 컨트롤러
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2024.02.16    Kwanwoo.Jeon       Create
* ==================================================================================
*/

public without sharing class TrainingCenterCalendarController {

    /**
     * Query Data
     *
     * @param sObjectName       checked Objects
     * @param strRegion         Selected Region
     * @param strArea           Selected Area
     * @param mapDealer         Dealer list
     * @return List<EventObj>
     *     EventObj:
     *          - Id : record Id
     *          - title : record title
     *          - startDateTime : record start date(DateTime)
     *          - description : record description
     *          - owner : record owner
    **/
    @AuraEnabled
    public static Map<String,Object> getEvents(map<String,Boolean> mapCheckboxValue, String selectedPick){
        Map<String,Object> mapRtn = new Map<String, Object>();
        System.debug('mapCheckboxValue' + mapCheckboxValue);
        System.debug(mapCheckboxValue.get('main'));
        List<EventObj> listEventObj = new List<EventObj>();

        set<String> setCheckboxValue = new set<String>();
        for (String strCheckbox : mapCheckboxValue.keySet()){
            if (mapCheckboxValue.get(strCheckbox)) {
                switch on strCheckbox {
                    when 'main' { setCheckboxValue.add('본채'); }
                    when 'gram1' { setCheckboxValue.add('글램핑1'); }
                    when 'gram2' { setCheckboxValue.add('글램핑2'); }
                    when 'gram3' { setCheckboxValue.add('글램핑3'); }
                    when 'gram4' { setCheckboxValue.add('글램핑4'); }
                }
            }
        }

        System.debug('setCheckboxValue' + setCheckboxValue);

        //확정건 조회
        if (selectedPick == 'All' || selectedPick == '확정') {
            List<ApplicationTrainingCenter__c> listATCConfirm = new List<ApplicationTrainingCenter__c>([
                    SELECT      Id, Date1__c, Date2__c, Status__c, fm_UseDate__c, RoomType__c, Special__c
                    FROM        ApplicationTrainingCenter__c
                    WHERE       (Status__c = '확정'
                    OR          Special__c = TRUE)
                    AND         RoomType__c IN :setCheckboxValue
                    AND         Date1__c >= LAST_N_MONTHS:1
                    AND         Date1__c <= NEXT_N_MONTHS:2
                    ORDER BY    RoomType__c

            ]);

            if (!listATCConfirm.isEmpty()) {
                for (ApplicationTrainingCenter__c obj: listATCConfirm){
                    String strTitle = String.format('{0}[{1}]{2}'
                            , new List<Object>{ obj.RoomType__c == '본채'? '\uD83C\uDFE0' : '\uD83C\uDFD5\uFE0F'
                                    , obj.Special__c? '특별사유' : obj.Status__c
                                    , obj.RoomType__c});
                    Datetime dt = datetime.newInstance(obj.Date1__c.year(), obj.Date1__c.month(), obj.Date1__c.day(), obj.RoomType__c == '본채'? 1: 2, 0, 0);
                    EventObj eObj = new EventObj(obj.id, strTitle, obj.Date1__c, '', UserInfo.getUserId(), '#06a3e14d');

                    listEventObj.add(eObj);
                    if (obj.Date2__c != null) {
                        EventObj eObj2 = eObj.clone();
                        eObj2.startDateTime = obj.Date2__c;
                        listEventObj.add(eObj2);
                    }
                }
            }
        }

        if (selectedPick == 'All' || selectedPick == '신청 현황') {
            //신청건 조회
            Map<Date, Map<String,Integer>> mapApplication = new Map<Date, Map<String,Integer>>();
            //Date 1
            List<AggregateResult> listATCApplication = new List<AggregateResult>([
                    SELECT      RoomType__c, Date1__c, COUNT(id) cnt
                    FROM        ApplicationTrainingCenter__c
                    WHERE       Status__c = '신청'
                    AND         Special__c = FALSE
                    AND         RoomType__c IN :setCheckboxValue
                    AND         Date1__c >= LAST_N_MONTHS:1
                    AND         Date1__c <= NEXT_N_MONTHS:2
                    GROUP BY    RoomType__c, Date1__c
                    ORDER BY    RoomType__c
            ]);
            if (!listATCApplication.isEmpty()) {
                for (AggregateResult obj : listATCApplication){
                    Integer tempSum;
                    if (mapApplication.get((Date)obj.get('Date1__c')) != null) {
                        Map<String, Integer> tempMap = mapApplication.get((Date)obj.get('Date1__c'));
                        if (mapApplication.get((Date)obj.get('Date1__c')).get((String)obj.get('RoomType__c')) != null) {
                            tempSum = mapApplication.get((Date)obj.get('Date1__c')).get((String)obj.get('RoomType__c')) + (Integer)obj.get('cnt');
                            tempMap.put((String)obj.get('RoomType__c'), tempSum);
                        }else{
                            tempSum = (Integer)obj.get('cnt');
                            tempMap.put((String)obj.get('RoomType__c'), tempSum);
                        }
                    }else{
                        tempSum = (Integer)obj.get('cnt');
                        mapApplication.put((Date)obj.get('Date1__c'), new Map<String, Integer>{
                                (String)obj.get('RoomType__c') => tempSum
                        });
                    }
                }
            }

            //Date 2
            List<AggregateResult> listATCApplication2 = new List<AggregateResult>([
                    SELECT      RoomType__c, Date2__c, COUNT(id) cnt
                    FROM        ApplicationTrainingCenter__c
                    WHERE       Status__c = '신청'
                    AND         Special__c = FALSE
                    AND         Date2__c != NULL
                    AND         RoomType__c IN :setCheckboxValue
                    AND         Date1__c >= LAST_N_MONTHS:1
                    AND         Date1__c <= NEXT_N_MONTHS:2
                    GROUP BY    RoomType__c, Date2__c
                    ORDER BY    RoomType__c
            ]);

            if (!listATCApplication2.isEmpty()) {
                for (AggregateResult obj : listATCApplication2){
                    Integer tempSum;
                    if (mapApplication.get((Date)obj.get('Date2__c')) != null) {
                        Map<String, Integer> tempMap = mapApplication.get((Date)obj.get('Date2__c'));
                        if (mapApplication.get((Date)obj.get('Date2__c')).get((String)obj.get('RoomType__c')) != null) {
                            tempSum = mapApplication.get((Date)obj.get('Date2__c')).get((String)obj.get('RoomType__c')) + (Integer)obj.get('cnt');
                            tempMap.put((String)obj.get('RoomType__c'), tempSum);
                        }else{
                            tempSum = (Integer)obj.get('cnt');
                            tempMap.put((String)obj.get('RoomType__c'), tempSum);
                        }
                    }else{
                        tempSum = (Integer)obj.get('cnt');
                        mapApplication.put((Date)obj.get('Date2__c'), new Map<String, Integer>{
                                (String)obj.get('RoomType__c') => tempSum
                        });
                    }
                }
            }


            if (!mapApplication.isEmpty()) {
                for (Date dateKey : mapApplication.keySet()){
                    for (String key : mapApplication.get(dateKey).keySet()){
                        String strTitle = String.format('{0}[{1}]{2} : {3}명'
                                , new List<Object>{ key == '본채'? '\uD83C\uDFE0' : '\uD83C\uDFD5\uFE0F'
                                        , '신청'
                                        , key
                                        , mapApplication.get(dateKey).get(key)});
                        Datetime dt = datetime.newInstance(dateKey.year(), dateKey.month(), dateKey.day(), key == '본채'? 3: 4, 0, 0);
                        EventObj eObj = new EventObj('', strTitle, dt, '', UserInfo.getUserId());

                        listEventObj.add(eObj);
                    }
                }
            }
        }

        mapRtn.put('listEventObj', listEventObj);
        List<ApplicationTrainingCenter__c> listActive = new List<ApplicationTrainingCenter__c>([
                SELECT  sort__c
                FROM    ApplicationTrainingCenter__c
                WHERE   sort__c != '수련원신청'
                AND     sort__C != NULL
        ]);
        System.debug(listActive);
        mapRtn.put('isCreateActive', Boolean.valueOf(listActive[0].sort__c));
        mapRtn.put('DateNextMonth', Date.newInstance(date.today().year(), date.today().month()+1,1));

        return mapRtn;
    }

    @AuraEnabled
    public static Map<String,Object> modalSave(Map<String, object> mapTrainingCenter){
        Map<String,String> rtnMap = new Map<String,String>();
        rtnMap.put('status','SUCCESS');
        rtnMap.put('msg', '');
        System.debug(mapTrainingCenter);
        try {
            //신청 가능 여부 확인
            List<ApplicationTrainingCenter__c> listActive = new List<ApplicationTrainingCenter__c>([
                    SELECT  sort__c
                    FROM    ApplicationTrainingCenter__c
                    WHERE   sort__c != '수련원신청'
                    AND     sort__C != NULL
            ]);
            System.debug(listActive);
            if (!Boolean.valueOf(listActive[0].sort__c)) {
                rtnMap.put('status','ERROR');
                rtnMap.put('msg', '수련원 신청 기간이 아닙니다');
                return rtnMap;
            }

            //Date 이번달 체크
            Date minDate = Date.newInstance(date.today().year(), date.today().month()+1,1);
            Date maxDate = Date.newInstance(date.today().year(), date.today().month() +1, Date.daysInMonth(date.today().year(), date.today().month() +1 ));
            if (Date.valueOf((String) mapTrainingCenter.get('Date1__c')) < minDate || Date.valueOf((String) mapTrainingCenter.get('Date1__c')) > maxDate) {
                rtnMap.put('status','ERROR');
                rtnMap.put('msg', '사용일은 신청월 기준 다음달 일자만 선택 가능합니다.');
                return rtnMap;
            }

            ApplicationTrainingCenter__c objATC = new ApplicationTrainingCenter__c();
            objATC.RoomType__c     = (String) mapTrainingCenter.get('RoomType__c');
            objATC.UseType__c      = (String) mapTrainingCenter.get('UseType__c');
            objATC.Bigo__c         = (String) mapTrainingCenter.get('Bigo__c');
            objATC.Date1__c        = Date.valueOf((String) mapTrainingCenter.get('Date1__c'));

            if (mapTrainingCenter.get('MemberNumber__c') != '') { objATC.MemberNumber__c = Decimal.valueOf((String) mapTrainingCenter.get('MemberNumber__c')); }
            if (mapTrainingCenter.get('Date2__c') != '') { objATC.Date2__c = Date.valueOf((String) mapTrainingCenter.get('Date2__c')); }


            insert objATC;
        }catch(Exception e){
            System.debug(String.format('[Error] {0}, Line : {1}', new List<Object>{ e.getMessage(), e.getLineNumber() }));
            System.debug(e.getMessage());

            rtnMap.put('status','ERROR');
            String msg = '';
            if (e.getMessage().contains('선택한 객실/일자에 이미 확정된 신청건이 있습니다')) {
                msg = '선택한 객실/일자에 이미 확정된 신청건이 있습니다.';
            }else if (e.getMessage().contains('이미 해당월에 신청 혹은 확정이력이 있습니다.')) {
                msg = '이미 해당월에 신청 혹은 확정이력이 있습니다.';
            }else if (e.getMessage().contains('사용일은 신청월 기준 다음달 일자만 선택 가능합니다')) {
                msg = '사용일은 신청월 기준 다음달 일자만 선택 가능합니다.';
            }else{
                msg = e.getMessage();
            }
            rtnMap.put('msg', msg);
        }



        return rtnMap;
    }

    /**
     * Event Wrapper : event data used in calendar
     */
    public class EventObj {
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public DateTime startDateTime {get;set;}
        @AuraEnabled
        public String description {get;set;}
        @AuraEnabled
        public String owner {get;set;}
        @AuraEnabled
        public String backgroundColor {get;set;}

        public EventObj(String i,String t, DateTime s, String d, String o){
            this.Id             = i;
            this.title          = t;
            this.startDateTime  = s;
            this.description    = d;
            this.owner          = o;
        }
        public EventObj(String i,String t, DateTime s, String d, String o, String bg){
            this.Id             = i;
            this.title          = t;
            this.startDateTime  = s;
            this.description    = d;
            this.owner          = o;
            this.backgroundColor= bg;
        }
    }
}