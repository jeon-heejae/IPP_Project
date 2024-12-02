public with sharing class EmailTest {
    public EmailTest() {

        String orgDomain = URL.getOrgDomainURL().toExternalForm();
        String imageUrl = orgDomain + '/resource/1726127969000/Email_footer?';

        String htmlBody = '<html><body>';
        htmlBody += '<p>이메일 내용...</p>';
        htmlBody += '<footer style="text-align: center;">';
        htmlBody += '<img src="' + imageUrl+ '" alt="Visang ONLY" style="max-width: 100%; height: auto;">';
        htmlBody += '</footer>';
        htmlBody += '</body></html>';

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[]{'heejae.jeon@daeunextier.com'});
        email.setSubject('HTML 이메일 테스트');
        email.setHtmlBody(htmlBody);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }
}