@RestResource(urlMapping='/apiTest3')
global without sharing class IF_HeeJae_001 {
    global class Input {
        
        public String strLevel;
        
    }

    global class Output {
        public Result result;
        public ResultData resultData;
    }

    global class Result {
        public String resultCode;
        public String resultMessage;
    }

    global class ResultData {
        public List<Contact> listcontact;
        public String StrSource;
        
        public ResultData() {
            listcontact= new list<Contact>();
        }
    }

    // @TestVisible
    // private static void getIF_Contact(Input input){
    //     IF_Contact__c obj = new IF_Contact__c();
    //     obj.LastName__c = input.strLastName;
    //     obj.Email__c = input.strEmail;
    //     obj.Level__c = input.strLevel;
    //     obj.SourceOrg__c = input.strSource;
    //     insert obj;
    // }
//Contact 넘기기
    @HttpPost
    global static Output doPost() {
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = '';
        Result objResult = new Result();
        ResultData resultData = new ResultData();

        Output objOutput = new Output();

        String requestBody = '';
        try {
            RestRequest request = RestContext.request;
            requestBody = request.requestBody.toString();
            if(String.isBlank(requestBody)) {
                strStatus = 'ERROR';
                strCode = '-1';
                strMessage = 'request body value does not exist';
            } else {
                Input input = (Input)JSON.deserialize(requestBody, Input.class);
                if(String.isBlank(input.strLevel)) {
                    strStatus = 'ERROR';
                    strCode = '0001';
                    strMessage = 'apiTest : value is empty';
                } else {
                    List<Contact> listContacts = [
                        SELECT Id, LastName, Email, Level__c
                        FROM Contact
                        WHERE Level__c = :input.strLevel
                    ];
                    for(Contact objContact : listContacts) {
                        resultData.listcontact.add(objContact);
                    }
                    resultData.StrSource='전희재';
                    
                }
            }
        } catch(Exception e) {
            strStatus = 'ERROR';
            strCode = '-1';
            strMessage = e.getMessage() + ' Line : ' + e.getLineNumber();
        }

        objResult.resultCode = strCode;
        objResult.resultMessage = strMessage;
        objOutput.resultData = resultData;
        objOutput.result = objResult;

        return objOutput;
    }
// 정보 가져오기
    public IF_HeeJae_001(){

        Map<String, Object> mapSendData = new Map<String, Object>();
        // 데이터 넣기 ex) mapSendData.put('data', 'testData');
        mapSendData.put('strLevel','Primary');
        String strSendData= JSON.serialize(mapSendData);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String token = '00DdM000009hJQP!AQEAQKz6GVHTJc9T5qcciPSBkFM8bNqgEt.D7q8ZNCv_ei27p9uspF_PMftjWA4YZordfSGj4r2XawlMH63opFddJzGVmM_i'; //위에서 발급한 토큰 입력
        request.setEndpoint('https://daeunextier-1f-dev-ed.develop.my.salesforce.com/services/apexrest/apiTest3');
        request.setBody(strSendData);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + token); //사이에 띄어쓰기 주의
        request.setHeader('Content-Type', 'application/json');
        /*request.setTimeout(110000);*/
        HttpResponse response = http.send(request);
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        if(response.getStatusCode() == 200){
            //System.debug('response >> ' + results);
            //System.debug('Value: '+results.get('resultData'));
            Map<String, Object> resultData = (Map<String, Object>) results.get('resultData');
            List<Object> contacts = (List<Object>) resultData.get('listcontact');

            List<IF_Contact__c> listIF = new List<IF_Contact__c>();

            for (Object contactObj : contacts) {
                Map<String, Object> contact = (Map<String, Object>) contactObj;
                IF_Contact__c ifc = new IF_Contact__c();
                ifc.LastName__c = (String) contact.get('LastName');
                ifc.Email__c = (String) contact.get('Email');
                ifc.Level__c = (String) contact.get('Level__c');
                ifc.SourceOrg__c = resultData.get('strSource');
                listIF.add(ifc);
            }
           
            insert listIF;   
        }
        else{
            throw new CalloutException('FAILED TO ACCESS');
            }
        }   
}