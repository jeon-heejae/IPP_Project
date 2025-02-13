/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-06-28     hs.jung          Create
*************************************************************************************/
@isTest
public class EformsignDocumentManager_Test {
    @isTest
    static void testDownloadClassInstantiation() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        Account objAcc = TestObjectCreator.objAccount;
        insert objAcc;

        EformsignEnvironment__c defaultConfig = new EformsignEnvironment__c();
        defaultConfig.ApiKey__c = 'apiKey';
        defaultConfig.Privatekey__c = 'privateKey';
        defaultConfig.CompanyId__c = 'companyId';
        defaultConfig.RepresentativeAdminEmail__c = 'https://kr-api.eformsign.com';
        defaultConfig.ApiBaseUrl__c = 'https://kr-api.eformsign.com';
        insert defaultConfig;

        EformsignToken__c objEformsignToken = new EformsignToken__c();
        objEformsignToken.Name = 'eftkName';
        objEformsignToken.AccessToken__c = 'et54345344535632sdfsdrt32';
        objEformsignToken.RefreshToken__c = 'et54345344535632sdfsdrt3223';
        objEformsignToken.User__c = UserInfo.getUserId();
        objEformsignToken.TokenIssuedDateTime__c = System.today() + 2 ;
        objEformsignToken.ExpireIn__c = 3600;
        insert objEformsignToken;

        EformsignTemplate__c objEformsignTemplate = new EformsignTemplate__c();
        objEformsignTemplate.Name = 'test';
        objEformsignTemplate.ObjectApiName__c = 'Account';
        objEformsignTemplate.TemplateId__c = 'TemplateId';
        insert objEformsignTemplate;

        EformsignDocument__c objEfsDoc = new EformsignDocument__c();
        objEfsDoc.Name =' test';
        objEfsDoc.DocumentId__c =' test1';
        objEfsDoc.DocumentCurrentStatus__c =' 1';
        objEfsDoc.EformsignTemplate__c  = objEformsignTemplate.Id;
        objEfsDoc.TargetObjectRecordId__c = objAcc.Id;
        insert objEfsDoc;

        String myString = 'StringToBlob';
        Blob myBlob = Blob.valueOf(myString);
        ContentVersion cv = new ContentVersion();
        cv.Title = 'test';
        cv.PathOnClient = 'test';
        cv.VersionData = myBlob;
        insert cv;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.ShareType = 'V';
        cdl.LinkedEntityId = objEfsDoc.Id;
        insert cdl;

        test.startTest();
        EformsignDocumentManager.Download efDownloadInstance = new EformsignDocumentManager.Download(objEfsDoc.Id, true);
        efDownloadInstance.execute();
        EformsignDocumentManager.StatusSyncer efStatusSyncer = new EformsignDocumentManager.StatusSyncer(objEfsDoc.Id);
        efStatusSyncer.execute();
//        efStatusSyncer.databaseLogic();
        EformsignDocumentManager.Cancelation efCancelation = new EformsignDocumentManager.Cancelation(objEfsDoc.Id, '');
        efCancelation.execute();
        EformsignDocumentManager.Deletion efDeletion = new EformsignDocumentManager.Deletion(objEfsDoc.Id);
        efDeletion.execute();

//        HttpResponse response = efDownloadInstance.sendRequest();
        test.stopTest();
    }

    @isTest
    static void testForStatusSyncer() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        Account objAcc = TestObjectCreator.objAccount;
        insert objAcc;

        EformsignEnvironment__c defaultConfig = new EformsignEnvironment__c();
        defaultConfig.ApiKey__c = 'apiKey';
        defaultConfig.Privatekey__c = 'privateKey';
        defaultConfig.CompanyId__c = 'companyId';
        defaultConfig.RepresentativeAdminEmail__c = 'https://kr-api.eformsign.com';
        defaultConfig.ApiBaseUrl__c = 'https://kr-api.eformsign.com';
        insert defaultConfig;

        EformsignToken__c objEformsignToken = new EformsignToken__c();
        objEformsignToken.Name = 'eftkName';
        objEformsignToken.AccessToken__c = 'et54345344535632sdfsdrt32';
        objEformsignToken.RefreshToken__c = 'et54345344535632sdfsdrt3223';
        objEformsignToken.User__c = UserInfo.getUserId();
        objEformsignToken.TokenIssuedDateTime__c = System.today() + 2 ;
        objEformsignToken.ExpireIn__c = 3600;
        insert objEformsignToken;

        EformsignTemplate__c objEformsignTemplate = new EformsignTemplate__c();
        objEformsignTemplate.Name = 'test';
        objEformsignTemplate.ObjectApiName__c = 'Account';
        objEformsignTemplate.TemplateId__c = 'TemplateId';
        insert objEformsignTemplate;

        EformsignDocument__c objEfsDoc = new EformsignDocument__c();
        objEfsDoc.Name =' test';
        objEfsDoc.DocumentId__c =' test1';
        objEfsDoc.DocumentCurrentStatus__c =' 1';
        objEfsDoc.EformsignTemplate__c  = objEformsignTemplate.Id;
        objEfsDoc.TargetObjectRecordId__c = objAcc.Id;
        insert objEfsDoc;

        String myString = 'StringToBlob';
        Blob myBlob = Blob.valueOf(myString);
        ContentVersion cv = new ContentVersion();
        cv.Title = 'test';
        cv.PathOnClient = 'test';
        cv.VersionData = myBlob;
        insert cv;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.ShareType = 'V';
        cdl.LinkedEntityId = objEfsDoc.Id;
        insert cdl;

        Event objEvent = new Event();
        objEvent.DurationInMinutes = 1;
        objEvent.ActivityDateTime =System.today();
        insert objEvent;

        test.startTest();
        EformsignDocumentManager.StatusSyncer efStatusSyncer = new EformsignDocumentManager.StatusSyncer(objEfsDoc.Id);
        efStatusSyncer.execute();

        test.stopTest();
    }

    @isTest
    static void testForDeletion() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        Account objAcc = TestObjectCreator.objAccount;
        insert objAcc;

        EformsignEnvironment__c defaultConfig = new EformsignEnvironment__c();
        defaultConfig.ApiKey__c = 'apiKey';
        defaultConfig.Privatekey__c = 'privateKey';
        defaultConfig.CompanyId__c = 'companyId';
        defaultConfig.RepresentativeAdminEmail__c = 'https://kr-api.eformsign.com';
        defaultConfig.ApiBaseUrl__c = 'https://kr-api.eformsign.com';
        insert defaultConfig;

        EformsignToken__c objEformsignToken = new EformsignToken__c();
        objEformsignToken.Name = 'eftkName';
        objEformsignToken.AccessToken__c = 'et54345344535632sdfsdrt32';
        objEformsignToken.RefreshToken__c = 'et54345344535632sdfsdrt3223';
        objEformsignToken.User__c = UserInfo.getUserId();
        objEformsignToken.TokenIssuedDateTime__c = System.today() + 2 ;
        objEformsignToken.ExpireIn__c = 3600;
        insert objEformsignToken;

        EformsignTemplate__c objEformsignTemplate = new EformsignTemplate__c();
        objEformsignTemplate.Name = 'test';
        objEformsignTemplate.ObjectApiName__c = 'Account';
        objEformsignTemplate.TemplateId__c = 'TemplateId';
        insert objEformsignTemplate;

        EformsignDocument__c objEfsDoc = new EformsignDocument__c();
        objEfsDoc.Name =' test';
        objEfsDoc.DocumentId__c =' test1';
        objEfsDoc.DocumentCurrentStatus__c =' 1';
        objEfsDoc.EformsignTemplate__c  = objEformsignTemplate.Id;
        objEfsDoc.TargetObjectRecordId__c = objAcc.Id;
        insert objEfsDoc;

        String myString = 'StringToBlob';
        Blob myBlob = Blob.valueOf(myString);
        ContentVersion cv = new ContentVersion();
        cv.Title = 'test';
        cv.PathOnClient = 'test';
        cv.VersionData = myBlob;
        insert cv;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.ShareType = 'V';
        cdl.LinkedEntityId = objEfsDoc.Id;
        insert cdl;

        Event objEvent = new Event();
        objEvent.DurationInMinutes = 1;
        objEvent.ActivityDateTime =System.today();
        insert objEvent;

        test.startTest();
        EformsignDocumentManager.Deletion efDeletion = new EformsignDocumentManager.Deletion(objEfsDoc.Id);
        efDeletion.execute();

        test.stopTest();
    }

    @isTest
    static void testDownloadClassInstantiation2() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        Account objAcc = TestObjectCreator.objAccount;
        insert objAcc;

        EformsignEnvironment__c defaultConfig = new EformsignEnvironment__c();
        defaultConfig.ApiKey__c = 'apiKey';
        defaultConfig.Privatekey__c = 'privateKey';
        defaultConfig.CompanyId__c = 'companyId';
        defaultConfig.RepresentativeAdminEmail__c = 'https://kr-api.eformsign.com';
        defaultConfig.ApiBaseUrl__c = 'https://kr-api.eformsign.com';
        insert defaultConfig;

        EformsignToken__c objEformsignToken = new EformsignToken__c();
        objEformsignToken.Name = 'eftkName';
        objEformsignToken.AccessToken__c = 'et54345344535632sdfsdrt32';
        objEformsignToken.RefreshToken__c = 'et54345344535632sdfsdrt3223';
        objEformsignToken.User__c = UserInfo.getUserId();
        objEformsignToken.TokenIssuedDateTime__c = System.today() + 2 ;
        objEformsignToken.ExpireIn__c = 3600;
        insert objEformsignToken;

        EformsignTemplate__c objEformsignTemplate = new EformsignTemplate__c();
        objEformsignTemplate.Name = 'test';
        objEformsignTemplate.ObjectApiName__c = 'Account';
        objEformsignTemplate.TemplateId__c = 'TemplateId';
        insert objEformsignTemplate;

        EformsignDocument__c objEfsDoc = new EformsignDocument__c();
        objEfsDoc.Name =' test';
        objEfsDoc.DocumentId__c =' test1';
        objEfsDoc.DocumentCurrentStatus__c =' 1';
        objEfsDoc.EformsignTemplate__c  = objEformsignTemplate.Id;
        objEfsDoc.TargetObjectRecordId__c = objAcc.Id;
        insert objEfsDoc;

        test.startTest();
        EformsignDocumentManager.Cancelation efCancelation = new EformsignDocumentManager.Cancelation(objEfsDoc.Id, '');
        efCancelation.execute();
        efCancelation.databaseLogic();
        EformsignDocumentManager.Deletion efDeletion = new EformsignDocumentManager.Deletion(objEfsDoc.Id);
        efDeletion.execute();

        test.stopTest();
    }



    // Http response
    private static HttpResponse newResponse(Integer statusCode) {
        HttpResponse response = new HttpResponse();

        response.setStatusCode(statusCode);
        response.setBody('{}');

        response.setHeader('Content-Type', 'application/json');
//        response.setHeader('Content-Disposition', '234');
        response.setHeader('Authorization', 'Bearer ' + 'accessToken');

        String json = '{'+
                '    \"id\": \"233cf8f58dd944ffb32bc5421c5efdf2\",'+
                '    \"document_number\": \"\",'+
                '    \"template\": {'+
                '        \"id\": \"820fde07ff8043a8ae78342dff0ba4ee\",'+
                '        \"name\": \"개인정보제공동의서\"'+
                '    },'+
                '    \"document_name\": \"test docu5123535\",'+
                '    \"creator\": {'+
                '        \"recipient_type\": \"01\",'+
                '        \"id\": \"ben@mz.co.kr\",'+
                '        \"name\": \"이명현\"'+
                '    },'+
                '    \"created_date\": 1698897340459,'+
                '    \"last_editor\": {'+
                '        \"recipient_type\": \"01\",'+
                '        \"id\": \"ben@mz.co.kr\",'+
                '        \"name\": \"이명현\"'+
                '    },'+
                '    \"updated_date\": 1698897340473,'+
                '    \"current_status\": {'+
                '        \"status_type\": \"060\",'+
                '        \"status_doc_type\": \"01\",'+
                '        \"status_doc_detail\": \"060\",'+
                '        \"step_type\": \"05\",'+
                '        \"step_index\": \"2\",'+
                '        \"step_name\": \"고객 동의 요청\",'+
                '        \"step_recipients\": ['+
                '            {'+
                '                \"recipient_type\": \"02\",'+
                '                \"name\": \"테스트 184224\",'+
                '                \"email\": \"chois940713@gmail.com\"'+
                '            }'+
                '        ],'+
                '        \"step_group\": 3,'+
                '        \"expired_date\": 1699502140473,'+
                '        \"_expired\": false'+
                '    },'+
                '    \"fields\": ['+
                '        {'+
                '            \"id\": \"고객명\",'+
                '            \"value\": \"\",'+
                '            \"type\": \"string\"'+
                '        },'+
                '        {'+
                '            \"id\": \"서명\",'+
                '            \"value\": \"X\",'+
                '            \"type\": \"binary\"'+
                '        },'+
                '        {'+
                '            \"id\": \"회사명\",'+
                '            \"value\": \"회사명\",'+
                '            \"type\": \"string\"'+
                '        },'+
                '        {'+
                '            \"id\": \"서명일\",'+
                '            \"value\": \"2023년 11월 02일\",'+
                '            \"type\": \"date_yyyy-MM-dd\"'+
                '        }'+
                '    ],'+
                '    \"next_status\": [],'+
                '    \"previous_status\": [],'+
                '    \"histories\": ['+
                '        {'+
                '            \"step_type\": \"00\",'+
                '            \"step_name\": \"시작\",'+
                '            \"action_type\": \"002\",'+
                '            \"executor\": {'+
                '                \"recipient_type\": \"01\",'+
                '                \"id\": \"ben@mz.co.kr\",'+
                '                \"name\": \"이명현\"'+
                '            },'+
                '            \"executed_date\": 1698897340459,'+
                '            \"comment\": \"테스트 184224\",'+
                '            \"sms_histories\": []'+
                '        },'+
                '        {'+
                '            \"step_type\": \"05\",'+
                '            \"step_name\": \"고객 동의 요청\",'+
                '            \"action_type\": \"060\",'+
                '            \"executor\": {'+
                '                \"recipient_type\": \"01\",'+
                '                \"id\": \"ben@mz.co.kr\",'+
                '                \"name\": \"이명현\"'+
                '            },'+
                '            \"executed_date\": 1698897340473,'+
                '            \"comment\": \"\",'+
                '            \"sms_histories\": []'+
                '        }'+
                '    ],'+
                '    \"recipients\": []'+
                '}';
//        response.setBody('{"api_key": {"company": {"api_url": "' + 'https://kr-api.eformsign.com' + '"}}}');
        response.setBody(json);
        return response;
    }

    // StatusCode 200 Mock
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = newResponse(200);

            return response;
        }
    }
}