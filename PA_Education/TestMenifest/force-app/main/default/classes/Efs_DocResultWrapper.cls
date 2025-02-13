/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-05-29     hs.jung          Create
*************************************************************************************/

public with sharing class Efs_DocResultWrapper {
    public String type;
    public String fn;
    public String code;
    public String message;
    public String document_id;
    public String title;
    public Values values;
    public List<Recipients> recipients;

    public class Recipients {
        public Integer step_idx;
        public String step_type;
        public String recipient_type;
        public Boolean use_mail;
        public Boolean use_sms;
        public String id;
        public String name;
        public Auth auth;
    }

    public class Valid {
        public Integer day;
        public Integer hour;
    }

    public class Auth {
        public String password;
        public String passwrod_hint;
        public Valid valid;
    }

    public class Values {
        public String customerName;
    }


    public static Efs_DocResultWrapper parse(String json) {
        return (Efs_DocResultWrapper) System.JSON.deserialize(json, Efs_DocResultWrapper.class);
    }
}