public with sharing class RewardsCalloutService {
    public Integer submitUsersForRewardCallout(String jsonBody){
        
        Http http=new Http();
        HttpRequest request=new HttpRequest();
        request.setEndpoint('https://developer.salesforce.com/files/sb-files/superbadge-external-services-sbu/BalancedLivingAPI.json');
         request.setMethod('POST');
         request.setHeader('Content-Type','application/json');
         request.setHeader(jsonBody);

         HttpResponse response=http.send(request);
         
    }
}