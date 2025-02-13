@isTest
public class RecruitingInformation_test {
    public static testMethod void RecruitingInformation_test(){
        recruitingURL__c objRecruit = new recruitingURL__c();
        objRecruit.URL__c ='https://www.naver.com';
        insert objRecruit;

        RecruitingInformation controller = new RecruitingInformation();
        recruitingURL__c obj = controller.objRecruiting;
   }
}