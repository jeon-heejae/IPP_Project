public with sharing class KakaoMessage_qa implements Queueable, Database.AllowsCallouts{
    private String keyword;

    public KakaoMessage_qa(String keyword) {
        this.keyword = keyword;
    }

    public void execute(QueueableContext context) {
        try {
            // Call the notifier method to send a message
            KakaoTalkNotifier.sendProductInfo(keyword);
        } catch (Exception e) {
            System.debug('Error in Queueable execute: ' + e.getMessage());
        }
    }
}