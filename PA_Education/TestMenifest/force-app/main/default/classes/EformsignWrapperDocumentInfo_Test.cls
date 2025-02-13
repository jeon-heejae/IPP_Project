/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-06-26     hs.jung          Create
*************************************************************************************/
/**
 * Created by MZC01-BEN on 2023-11-02.
 * @description EformsignDocumentInfoWrapper용 테스트 클래스
 */
@IsTest
public with sharing class EformsignWrapperDocumentInfo_Test {
    static testMethod void testParse() {
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
        EformsignWrapperDocumentInfo r = EformsignWrapperDocumentInfo.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        EformsignWrapperDocumentInfo.Current_status objCurrent_status = new EformsignWrapperDocumentInfo.Current_status(System.JSON.createParser(json));
        System.assert(objCurrent_status != null);
        System.assert(objCurrent_status.status_type == null);
        System.assert(objCurrent_status.status_doc_type == null);
        System.assert(objCurrent_status.status_doc_detail == null);
        System.assert(objCurrent_status.step_type == null);
        System.assert(objCurrent_status.step_index == null);
        System.assert(objCurrent_status.step_name == null);
        System.assert(objCurrent_status.step_recipients == null);
        System.assert(objCurrent_status.step_group == null);
        System.assert(objCurrent_status.expired_date == null);
        System.assert(objCurrent_status.x_expired == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        EformsignWrapperDocumentInfo.Fields objFields = new EformsignWrapperDocumentInfo.Fields(System.JSON.createParser(json));
        System.assert(objFields != null);
        System.assert(objFields.id == null);
        System.assert(objFields.value == null);
        System.assert(objFields.type == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        EformsignWrapperDocumentInfo objEformsignDocumentInfoWrapper = new EformsignWrapperDocumentInfo(System.JSON.createParser(json));
        System.assert(objEformsignDocumentInfoWrapper != null);
        System.assert(objEformsignDocumentInfoWrapper.id == null);
        System.assert(objEformsignDocumentInfoWrapper.document_number == null);
        System.assert(objEformsignDocumentInfoWrapper.template == null);
        System.assert(objEformsignDocumentInfoWrapper.document_name == null);
        System.assert(objEformsignDocumentInfoWrapper.creator == null);
        System.assert(objEformsignDocumentInfoWrapper.created_date == null);
        System.assert(objEformsignDocumentInfoWrapper.last_editor == null);
        System.assert(objEformsignDocumentInfoWrapper.updated_date == null);
        System.assert(objEformsignDocumentInfoWrapper.current_status == null);
        System.assert(objEformsignDocumentInfoWrapper.fields == null);
        System.assert(objEformsignDocumentInfoWrapper.next_status == null);
        System.assert(objEformsignDocumentInfoWrapper.previous_status == null);
        System.assert(objEformsignDocumentInfoWrapper.histories == null);
        System.assert(objEformsignDocumentInfoWrapper.recipients == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        EformsignWrapperDocumentInfo.Histories objHistories = new EformsignWrapperDocumentInfo.Histories(System.JSON.createParser(json));
        System.assert(objHistories != null);
        System.assert(objHistories.step_type == null);
        System.assert(objHistories.step_name == null);
        System.assert(objHistories.action_type == null);
        System.assert(objHistories.executor == null);
        System.assert(objHistories.executed_date == null);
        System.assert(objHistories.comment == null);
        System.assert(objHistories.sms_histories == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        EformsignWrapperDocumentInfo.Step_recipients objStep_recipients = new EformsignWrapperDocumentInfo.Step_recipients(System.JSON.createParser(json));
        System.assert(objStep_recipients != null);
        System.assert(objStep_recipients.recipient_type == null);
        System.assert(objStep_recipients.name == null);
        System.assert(objStep_recipients.email == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        EformsignWrapperDocumentInfo.Creator objCreator = new EformsignWrapperDocumentInfo.Creator(System.JSON.createParser(json));
        System.assert(objCreator != null);
        System.assert(objCreator.recipient_type == null);
        System.assert(objCreator.id == null);
        System.assert(objCreator.name == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        EformsignWrapperDocumentInfo.Next_status objNext_status = new EformsignWrapperDocumentInfo.Next_status(System.JSON.createParser(json));
        System.assert(objNext_status != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        EformsignWrapperDocumentInfo.Template objTemplate = new EformsignWrapperDocumentInfo.Template(System.JSON.createParser(json));
        System.assert(objTemplate != null);
        System.assert(objTemplate.id == null);
        System.assert(objTemplate.name == null);
    }
}