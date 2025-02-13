/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-05-29     hs.jung          Create
*************************************************************************************/

public with sharing class EformsignWrapperDocumentInfo {
    public class Current_status {
        public String status_type {get;set;}
        public String status_doc_type {get;set;}
        public String status_doc_detail {get;set;}
        public String step_type {get;set;}
        public String step_index {get;set;}
        public String step_name {get;set;}
        public List<Step_recipients> step_recipients {get;set;}
        public Integer step_group {get;set;}
        public Long expired_date {get;set;}
        public Boolean x_expired {get;set;} // in json: _expired

        public Current_status(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'status_type') {
                            status_type = parser.getText();
                        } else if (text == 'status_doc_type') {
                            status_doc_type = parser.getText();
                        } else if (text == 'status_doc_detail') {
                            status_doc_detail = parser.getText();
                        } else if (text == 'step_type') {
                            step_type = parser.getText();
                        } else if (text == 'step_index') {
                            step_index = parser.getText();
                        } else if (text == 'step_name') {
                            step_name = parser.getText();
                        } else if (text == 'step_recipients') {
                            step_recipients = arrayOfStep_recipients(parser);
                        } else if (text == 'step_group') {
                            step_group = parser.getIntegerValue();
                        } else if (text == 'expired_date') {
                            expired_date = parser.getLongValue();
                        } else if (text == '_expired') {
                            x_expired = parser.getBooleanValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Current_status consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Fields {
        public String id {get;set;}
        public String value {get;set;}
        public String type {get;set;}

        public Fields(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'value') {
                            value = parser.getText();
                        } else if (text == 'type') {
                            type = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Fields consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public String id {get;set;}
    public String document_number {get;set;}
    public Template template {get;set;}
    public String document_name {get;set;}
    public Creator creator {get;set;}
    public Long created_date {get;set;}
    public Creator last_editor {get;set;}
    public Long updated_date {get;set;}
    public Current_status current_status {get;set;}
    public List<Fields> fields {get;set;}
    public List<Next_status> next_status {get;set;}
    public List<Next_status> previous_status {get;set;}
    public List<Histories> histories {get;set;}
    public List<Next_status> recipients {get;set;}

    public EformsignWrapperDocumentInfo(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'id') {
                        id = parser.getText();
                    } else if (text == 'document_number') {
                        document_number = parser.getText();
                    } else if (text == 'template') {
                        template = new Template(parser);
                    } else if (text == 'document_name') {
                        document_name = parser.getText();
                    } else if (text == 'creator') {
                        creator = new Creator(parser);
                    } else if (text == 'created_date') {
                        created_date = parser.getLongValue();
                    } else if (text == 'last_editor') {
                        last_editor = new Creator(parser);
                    } else if (text == 'updated_date') {
                        updated_date = parser.getLongValue();
                    } else if (text == 'current_status') {
                        current_status = new Current_status(parser);
                    } else if (text == 'fields') {
                        fields = arrayOfFields(parser);
                    } else if (text == 'next_status') {
                        next_status = arrayOfNext_status(parser);
                    } else if (text == 'previous_status') {
                        previous_status = arrayOfNext_status(parser);
                    } else if (text == 'histories') {
                        histories = arrayOfHistories(parser);
                    } else if (text == 'recipients') {
                        recipients = arrayOfNext_status(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'EformsignWrapperDocumentInfo consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }

    public class Histories {
        public String step_type {get;set;}
        public String step_name {get;set;}
        public String action_type {get;set;}
        public Creator executor {get;set;}
        public Long executed_date {get;set;}
        public String comment {get;set;}
        public List<Next_status> sms_histories {get;set;}

        public Histories(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'step_type') {
                            step_type = parser.getText();
                        } else if (text == 'step_name') {
                            step_name = parser.getText();
                        } else if (text == 'action_type') {
                            action_type = parser.getText();
                        } else if (text == 'executor') {
                            executor = new Creator(parser);
                        } else if (text == 'executed_date') {
                            executed_date = parser.getLongValue();
                        } else if (text == 'comment') {
                            comment = parser.getText();
                        } else if (text == 'sms_histories') {
                            sms_histories = arrayOfNext_status(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Histories consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Step_recipients {
        public String recipient_type {get;set;}
        public String name {get;set;}
        public String email {get;set;}

        public Step_recipients(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'recipient_type') {
                            recipient_type = parser.getText();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'email') {
                            email = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Step_recipients consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Creator {
        public String recipient_type {get;set;}
        public String id {get;set;}
        public String name {get;set;}

        public Creator(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'recipient_type') {
                            recipient_type = parser.getText();
                        } else if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Creator consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Next_status {

        public Next_status(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        {
                            System.debug(LoggingLevel.WARN, 'Next_status consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Template {
        public String id {get;set;}
        public String name {get;set;}

        public Template(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Template consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public static EformsignWrapperDocumentInfo parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new EformsignWrapperDocumentInfo(parser);
    }

    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT ||
                    curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                    curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }

    private static List<Next_status> arrayOfNext_status(System.JSONParser p) {
        List<Next_status> res = new List<Next_status>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Next_status(p));
        }
        return res;
    }

    private static List<Fields> arrayOfFields(System.JSONParser p) {
        List<Fields> res = new List<Fields>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Fields(p));
        }
        return res;
    }

    private static List<Step_recipients> arrayOfStep_recipients(System.JSONParser p) {
        List<Step_recipients> res = new List<Step_recipients>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Step_recipients(p));
        }
        return res;
    }

    private static List<Histories> arrayOfHistories(System.JSONParser p) {
        List<Histories> res = new List<Histories>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Histories(p));
        }
        return res;
    }
}