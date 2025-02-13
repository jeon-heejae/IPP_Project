/**
 * Object       : TestSupport.cls
 * Function     : Lead로 Insert
 * Author       : Yohan.Kang.
 * Date         : 2013.10.7
 * Description  : 
 */
public without sharing class TestSupport {
    public String username {get; set;}
    public String Company {get; set;}
    public String email {get; set;}
    public string subject{get; set;}
    public string message{get; set;}
    public string InterestProduct{get; set;}
    public string LeadSource{get; set;}
    
    public boolean IsErrorIsCompany{get; set;}
    public boolean IsErrorIsName{get; set;}
    public boolean IsErrorIsEmail{get; set;}
    public boolean IsErrorValidEmail{get; set;}
    
    public boolean IsRegistedOk{get; set;}
    
    public TestSupport(){
        IsErrorIsName = false;
        IsErrorIsEmail = false;
        IsErrorValidEmail = false;
        IsRegistedOk = false;
    }
    
    public pageReference registerLead(){
        IsErrorIsName = false;
        IsErrorIsEmail = false;
        IsErrorValidEmail = false;
        IsErrorIsCompany = false;
        
        if(Company==null || Company==''){
            IsErrorIsCompany = true;
        }
        
        if(username==null || username==''){
            IsErrorIsName = true;
        }
        
        if(email==null || email==''){
            IsErrorIsEmail = true;
        }
        
        if(!IsErrorIsEmail && !validateEmail(email)){
            IsErrorValidEmail = true;
        }
        
        if(IsErrorIsCompany || IsErrorIsName || IsErrorIsEmail || IsErrorValidEmail){
            return null;
        }
       
        Lead__c LD = new Lead__c();
        //Lead LD = new Lead();
        Ld.Name = username;
        Ld.Company__c = Company;
        Ld.LeadSource__c = '웹';
        LD.Email__c = email;
        LD.InterestProduct__c = InterestProduct;
        LD.WebSubject__c = subject;
        LD.WebMessage__c = message;
        insert LD;
        
        IsRegistedOk = true;
        return null;
    }
    
    private Boolean validateEmail(String email) {
        Boolean res = true;
        
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: http://www.regular-expressions.info/email.html
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
        
        if (!MyMatcher.matches()) 
            res = false;
        return res; 
    }
    
}