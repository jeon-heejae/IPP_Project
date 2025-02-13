/**
 * Created by Kwanwoo.Jeon on 2024-02-21.
 */

public without sharing class ApplicationTrainingCenter_tr extends TriggerHandler{
    private static List<ApplicationTrainingCenter__c> listNew { get; set; }
    private static List<ApplicationTrainingCenter__c> listOld { get; set; }
    private static Map<Id, ApplicationTrainingCenter__c> mapNew { get; set; }
    private static Map<Id, ApplicationTrainingCenter__c> mapOld { get; set; }

    public ApplicationTrainingCenter_tr() {
        listNew = (List<ApplicationTrainingCenter__c>) Trigger.new;
        listOld = (List<ApplicationTrainingCenter__c>) Trigger.old;
        mapNew = (Map<Id, ApplicationTrainingCenter__c>) Trigger.newMap;
        mapOld = (Map<Id, ApplicationTrainingCenter__c>) Trigger.oldMap;
    }

    public override void beforeInsert() {
//        checkDate();
        insertCheckSortFalse();
        insertCheckThisMonth();
        insertCheckConfirmedRecord();
    }

    public override void beforeUpdate() {
        updateCheckConfirmedRecord();
    }

    public override void beforeDelete() {
        checkStatus();
    }

    public override void afterUpdate() {
        updateUserInfo();
    }

    /**
    * Event : before insert
    * Author : Kwanwoo.Jeon
    * Description : 사용일(Date1__c)은 신청월 기준 다음달 일자만 선택 가능 -> component 컨트롤러에서 체크로 변경
    */
//    public void checkDate() {
//        Date minDate = Date.newInstance(date.today().year(), date.today().month()+1,1);
//        Date maxDate = Date.newInstance(date.today().year(), date.today().month() +1, Date.daysInMonth(date.today().year(), date.today().month() +1 ));
//
//        for (ApplicationTrainingCenter__c obj:listNew){
//            if (obj.Date1__c < minDate || obj.Date1__c > maxDate) {
//                obj.addError('사용일은 신청월 기준 다음달 일자만 선택 가능합니다.');
//            }
//        }
//    }

    /**
    * Event : before Delete
    * Author : Kwanwoo.Jeon
    * Description : 상태가 신청이 아닐 경우 삭제 시 Validate
    */
    public void checkStatus() {
        for (ApplicationTrainingCenter__c obj:listOld){
            if (obj.Status__c != '신청') {
                obj.addError('신청 상태의 수련원 신청 레코드만 삭제 가능합니다.');
            }
        }
    }

    /**
    * Event : before insert
    * Author : Jueun.Jo
    * Description : 구분(Sort__c)값이 '수련원 신청-비활성'(False)인 레코드가 있을 경우 Validate (모바일 listview new 버튼 비활 못해서)
    */
    public void insertCheckSortFalse() {
        List<ApplicationTrainingCenter__c> listTarget = new List<ApplicationTrainingCenter__c>();
        for (ApplicationTrainingCenter__c obj : listNew) {
            listTarget.add(obj);
        }

        if (!listTarget.isEmpty()) {
            List<ApplicationTrainingCenter__c> listSort = new List<ApplicationTrainingCenter__c>([
                    SELECT      Id
                    FROM        ApplicationTrainingCenter__c
                    WHERE       Sort__c = 'False'
            ]);

            if (!listSort.isEmpty()) {
                for (ApplicationTrainingCenter__c obj : listTarget){
                    obj.addError('수련원 신청 기간이 아닙니다');
                }
            }
        }
    }

    /**
    * Event : before insert
    * Author : Kwanwoo.Jeon
    * Description : 신청으로 저장 시, 신청월에 상태가 확정인 본인 레코드가 있을 경우 Validate
    */
    public void insertCheckThisMonth() {
        List<ApplicationTrainingCenter__c> listTarget = new List<ApplicationTrainingCenter__c>();
        for (ApplicationTrainingCenter__c obj : listNew) {
            if (obj.Status__c == '신청') {
                System.debug('obj ' + obj);
                listTarget.add(obj);
            }
        }

        if (!listTarget.isEmpty()) {
            List<AggregateResult> listOwnerId = new List<AggregateResult>([
                    SELECT      OwnerId
                    from        ApplicationTrainingCenter__c
                    WHERE       Status__c in ('확정', '신청')
                    AND         Date1__c = NEXT_MONTH
                    GROUP BY    OwnerId
            ]);

            if (!listOwnerId.isEmpty()) {
                Set<Id> setOwnerId = new Set<Id>();
                for (AggregateResult obj : listOwnerId){
                    System.debug('contain id : ' + (Id)obj.get('OwnerId'));
                    setOwnerId.add((Id)obj.get('OwnerId'));
                }
                if (!setOwnerId.isEmpty()) {
                    for (ApplicationTrainingCenter__c obj : listTarget){
                        System.debug('obj.OwnerId :: ' + obj.OwnerId);
                        if (setOwnerId.contains(obj.OwnerId)) {
                            obj.addError('이미 해당월에 신청 혹은 확정이력이 있습니다.');
                        }
                    }
                }
            }
        }
    }

    /**
    * Event : before insert
    * Author : Kwanwoo.Jeon
    * Description : 신청 or 확정으로 저장 시, 객실유형이 동일하면서 상태가 확정이면서 사용일1 or 사용일2가 동일한 레코드가 있을 경우 Validate
    */
    public void insertCheckConfirmedRecord() {
        Map<Date, Map<String, Boolean>> mapTarget = new Map<Date, Map<String, Boolean>>();
        List<ApplicationTrainingCenter__c> listTarget = new List<ApplicationTrainingCenter__c>();
        for (ApplicationTrainingCenter__c obj : listNew){
            if (new List<String>{'신청','확정'}.contains(obj.Status__c) ) {
                listTarget.add(obj);
                mapTarget.put(obj.Date1__c, new Map<String, Boolean>());
                if (obj.Date2__c != null) { mapTarget.put(obj.Date2__c, new Map<String, Boolean>()); }
            }
        }

        if (!listTarget.isEmpty()) {
            list<ApplicationTrainingCenter__c> listConfirm = new List<ApplicationTrainingCenter__c>([
                    SELECT  RoomType__c, Date1__c, Date2__c, Special__c
                    FROM    ApplicationTrainingCenter__c
                    WHERE   (Status__c = '확정'
                    OR       Special__c = true)
                    And     (Date1__c IN :mapTarget.keySet()
                    OR       Date2__c IN :mapTarget.keySet())
            ]);

            for (ApplicationTrainingCenter__c objConf: listConfirm){
                if (mapTarget.get(objConf.Date1__c) != null) {
                    if (objConf.Special__c) {
                        mapTarget.get(objConf.Date1__c).put('special',true);
                    }else{
                        mapTarget.get(objConf.Date1__c).put(objConf.RoomType__c,true);
                    }

                }
                if (objConf.Date2__c != null && mapTarget.get(objConf.Date2__c) != null) {
                    if (objConf.Special__c) {
                        mapTarget.get(objConf.Date2__c).put('special',true);
                    }else{
                        mapTarget.get(objConf.Date2__c).put(objConf.RoomType__c,true);
                    }
                }
            }

            for (ApplicationTrainingCenter__c obj: listTarget){
                if (mapTarget.get(obj.Date1__c).get('special') != null || mapTarget.get(obj.Date1__c).get(obj.RoomType__c) != null) {
                    obj.addError('선택한 객실/일자에 이미 확정된 신청건이 있습니다');
                }else if (obj.Date2__c != null && (mapTarget.get(obj.Date2__c).get('special') != null || mapTarget.get(obj.Date2__c).get(obj.RoomType__c) != null)) {
                    obj.addError('선택한 객실/일자에 이미 확정된 신청건이 있습니다');
                }
            }
        }
    }
    /**
    * Event : before Update
    * Author : Kwanwoo.Jeon
    * Description : 확정으로 업데이트 시, 객실유형이 동일하면서 상태가 확정이면서 사용일1 or 사용일2가 동일한 레코드가 있을 경우 Validate
    */
    public void updateCheckConfirmedRecord() {
        // date -> 날짜 -> object
        Map<Date, Map<String, Boolean>> mapCheckData = new Map<Date, Map<String, Boolean>>();
        List<ApplicationTrainingCenter__c> listTarget = new List<ApplicationTrainingCenter__c>();
        Map<String, Boolean> mapDuplicateCheck = new Map<String, Boolean>();
        for (ApplicationTrainingCenter__c obj : listNew){
            if (obj.Status__c =='확정' && mapOld.get(obj.Id).Status__c != '확정' ) {
                listTarget.add(obj);
                //Date1
                mapCheckData.put(obj.Date1__c, new Map<String, Boolean>());
                String strDateRoom1 = String.valueOf(obj.Date1__c) + obj.RoomType__c;
                if (mapDuplicateCheck.get(strDateRoom1) == null) {
                    mapDuplicateCheck.put(strDateRoom1, false);
                }else if (mapDuplicateCheck.get(strDateRoom1) != null && !mapDuplicateCheck.get(strDateRoom1)) {
                    mapDuplicateCheck.put(strDateRoom1, true);
                }
                //Date2
                if (obj.Date2__c != null) {
                    mapCheckData.put(obj.Date2__c, new Map<String, Boolean>());
                    String strDateRoom2 = String.valueOf(obj.Date2__c) + obj.RoomType__c;
                    if (mapDuplicateCheck.get(strDateRoom2) == null) {
                        mapDuplicateCheck.put(strDateRoom2, false);
                    }else if(mapDuplicateCheck.get(strDateRoom2) != null && !mapDuplicateCheck.get(strDateRoom2)) {
                        mapDuplicateCheck.put(strDateRoom2, true);
                    }
                }
            }
        }

        //이미 해당 날짜/객실에 확정된 데이터가 있다면 에러처리 //todo
        if (!listTarget.isEmpty()) {
            list<ApplicationTrainingCenter__c> listConfirm = new List<ApplicationTrainingCenter__c>([
                    SELECT  RoomType__c, Date1__c, Date2__c, Special__c
                    FROM    ApplicationTrainingCenter__c
                    WHERE   (Status__c = '확정'
                    OR       Special__c = true)
                    And     (Date1__c IN :mapCheckData.keySet()
                    OR       Date2__c IN :mapCheckData.keySet())
            ]);

            for (ApplicationTrainingCenter__c objConf: listConfirm){
                if (mapCheckData.get(objConf.Date1__c) != null) {
                    if (objConf.Special__c) {
                        mapCheckData.get(objConf.Date1__c).put('special',true);
                    }else{
                        mapCheckData.get(objConf.Date1__c).put(objConf.RoomType__c,true);
                    }

                }
                if (objConf.Date2__c != null && mapCheckData.get(objConf.Date2__c) != null) {
                    if (objConf.Special__c) {
                        mapCheckData.get(objConf.Date2__c).put('special',true);
                    }else{
                        mapCheckData.get(objConf.Date2__c).put(objConf.RoomType__c,true);
                    }
                }
            }

            for (ApplicationTrainingCenter__c obj: listTarget){
                //Date 1
                String dateRom1= String.valueOf(obj.Date1__c) + obj.RoomType__c;
                if (mapDuplicateCheck.get(dateRom1)) {
                    obj.addError('선택한 레코드 중 같은 객실/일자가 있습니다.');
                    continue;
                }
                if (mapCheckData.get(obj.Date1__c).get('special') != null || mapCheckData.get(obj.Date1__c).get(obj.RoomType__c) != null) {
                    obj.addError('선택한 객실/일자에 이미 확정된 신청건이 있습니다');
                }


                //Date2
                if (obj.Date2__c != null) {
                    String dateRom2= String.valueOf(obj.Date2__c) + obj.RoomType__c;
                    if (mapDuplicateCheck.get(dateRom2)) {
                        obj.addError('선택한 레코드 중 같은 객실/일자가 있습니다.');
                        continue;
                    }

                    if (mapCheckData.get(obj.Date2__c).get('special') != null || mapCheckData.get(obj.Date2__c).get(obj.RoomType__c) != null) {
                        obj.addError('선택한 객실/일자에 이미 확정된 신청건이 있습니다');
                    }
                }
            }
        }
    }

    /**
    * Event : after Update
    * Author : Kwanwoo.Jeon
    * Description : 확정으로 업데이트 시, 해당 Owner User의 총사용횟수(-), 최근 사용 일자 업데이트
     *              취소로 업데이트 시, 해당 Owner User의 총사용횟수(+), 최근 사용 일자 업데이트
    */
    public void updateUserInfo(){
        list<ApplicationTrainingCenter__c> listConfirm = new List<ApplicationTrainingCenter__c>();
        list<ApplicationTrainingCenter__c> listCancle = new List<ApplicationTrainingCenter__c>();
        Map<Id, User> mapUser = new Map<Id, User>();
        for (ApplicationTrainingCenter__c obj : listNew) {
            if (obj.Status__c == '확정' && mapOld.get(obj.Id).Status__c != '확정') {
                listConfirm.add(obj);
                mapUser.put(obj.OwnerId, null);
            } else if (obj.Status__c == '취소' && mapOld.get(obj.Id).Status__c != '취소') {
                listCancle.add(obj);
                mapUser.put(obj.OwnerId, null);
            }
        }

        if (!mapUser.keySet().isEmpty()) {
            mapUser.putAll([
                    SELECT id, TrainingCenterUsedCount__c, TrainingCenterLastUsedDate__c
                    FROM User
                    WHERE Id IN : mapUser.keySet()
            ]);
            if (!listConfirm.isEmpty()) {
                for (ApplicationTrainingCenter__c obj: listConfirm){
                    if (mapUser.get(obj.OwnerId).TrainingCenterUsedCount__c != null) {
                        mapUser.get(obj.OwnerId).TrainingCenterUsedCount__c += 1;
                    }else{
                        mapUser.get(obj.OwnerId).TrainingCenterUsedCount__c = 1;
                    }
                    mapUser.get(obj.OwnerId).TrainingCenterLastUsedDate__c = obj.Date2__c == null? obj.Date1__c : obj.Date2__c;
                }
            }

            if (!listCancle.isEmpty()) {
                List<AggregateResult> listATCLastDate = new List<AggregateResult>([
                        SELECT OwnerId, MAX(Date1__c) Date1, MAX(Date2__c) Date2
                        FROM ApplicationTrainingCenter__c
                        WHERE Status__c = '확정'
                        AND OwnerId IN : mapUser.keySet()
                        AND (Date1__c = LAST_N_MONTHS:12 OR Date1__c = THIS_YEAR)
                        GROUP BY OwnerId
                ]);

                Map<Id, Date> mapOwnerToLastDate = new Map<Id, Date>();
                for (AggregateResult ar: listATCLastDate){
                    Date date1 = (Date) ar.get('Date1');
                    Date date2 = (Date) ar.get('Date2');
                    mapOwnerToLastDate.put((Id) ar.get('OwnerId'), date2 != null && date2 > date1? date2 : date1);
                }
                for (ApplicationTrainingCenter__c obj : listCancle){
                    if (mapUser.get(obj.OwnerId).TrainingCenterUsedCount__c != null) {
                        mapUser.get(obj.OwnerId).TrainingCenterUsedCount__c -= 1;
                    }else{
                        mapUser.get(obj.OwnerId).TrainingCenterUsedCount__c = 0;
                    }
                    mapUser.get(obj.OwnerId).TrainingCenterLastUsedDate__c =
                            mapOwnerToLastDate.get(obj.OwnerId) != null? mapOwnerToLastDate.get(obj.OwnerId) : null;
                }
            }
            update mapUser.values();
        }
    }
}