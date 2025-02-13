/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-06-26     hs.jung          Create
*************************************************************************************/

@IsTest
private class Efs_DocResultWrapper_Test {
    static testMethod void testParse() {
        String json = '{'+
                '  \"type\": \"document\",'+
                '  \"fn\": \"saveSuccess\",'+
                '  \"code\": \"-1\",'+
                '  \"message\": \"Completed.\",'+
                '  \"document_id\": \"4b67f4d3a8ad48fda71eefe17361be67\",'+
                '  \"title\": \"개인정보제공동의서 2023-11-09\",'+
                '  \"values\": {'+
                '    \"customer name\": \"\"'+
                '  },'+
                '  \"recipients\": ['+
                '    {'+
                '      \"step_idx\": 2,'+
                '      \"step_type\": \"05\",'+
                '      \"recipient_type\": \"02\",'+
                '      \"use_mail\": true,'+
                '      \"use_sms\": false,'+
                '      \"id\": \"chois940713@gmail.com\",'+
                '      \"name\": \"1109_1034Test\",'+
                '      \"auth\": {'+
                '        \"password\": \"\",'+
                '        \"passwrod_hint\": \"\",'+
                '        \"valid\": {'+
                '          \"day\": 14,'+
                '          \"hour\": 0'+
                '        }'+
                '      }'+
                '    }'+
                '  ]'+
                '}';
        Efs_DocResultWrapper obj = Efs_DocResultWrapper.parse(json);
        System.assert(obj != null);
    }
}