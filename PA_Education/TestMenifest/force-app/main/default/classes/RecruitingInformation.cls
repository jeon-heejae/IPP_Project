public class RecruitingInformation {

    public recruitingURL__c objRecruiting {
        get {
                recruitingURL__c obj = recruitingURL__c.getOrgDefaults();
                return obj;
            }
        set;
    }
}