/**
 * Created by jihwa on 2023-11-23.
 */

public with sharing class WinnerBingoBoardController {
    @AuraEnabled
    public static List<BingoCell__c> getInitData(String bingoWinner){
        List<BingoCell__c> listBingoCells = new List<BingoCell__c>();
        listBingoCells = [
                SELECT Id, BingoBoard__r.OwnerId, BingoMember__c, IsChecked__c, BingoMember__r.Name
                FROM BingoCell__c
                WHERE BingoBoard__r.BoardOwner__c =: bingoWinner
                ORDER BY Name
        ];
        return listBingoCells;
    }

}