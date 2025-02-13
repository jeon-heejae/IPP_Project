public with sharing class ExcelCopyUploadController {
    @AuraEnabled
    public static Boolean saveData(List<Map<String, String>> datas, String recordId) {
        try {
            Boolean flag = false;
            List<Contact> listCon = new List<Contact>();

            System.debug('recordId:' + recordId);

            // 기존 Contact 데이터 조회
            Map<String, Contact> existingContacts = new Map<String, Contact>();
            for (Contact c : [SELECT Id, LastName FROM Contact]) {
                existingContacts.put(c.LastName, c);
            }

            for (Map<String, String> mapDatas : datas) {
                System.debug('datas:' + mapDatas);
                Contact objCon;

                // 기존 데이터가 존재하면 기존 ID를 설정하여 업데이트
                if (existingContacts.containsKey(mapDatas.get('LastName'))) {
                    objCon = existingContacts.get(mapDatas.get('LastName'));
                } else {
                    objCon = new Contact();
                }

                // 필드 매핑
                objCon.Birthdate = Date.valueOf(mapDatas.get('Birthdate'));
                objCon.LastName = mapDatas.get('LastName');
                objCon.DetailAddress__c = mapDatas.get('Address');
                objCon.MobilePhone = mapDatas.get('MobilePhone');
                objCon.Phone = mapDatas.get('ParentPhone');

                listCon.add(objCon);
            }

            if (!listCon.isEmpty()) {
                upsert listCon;
                flag = true;
            }

            return flag;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
