/**
 * Created by jihwa on 2023-11-08.
 */

public without sharing class BingoForUserController {
    @AuraEnabled
    public static List<BingoCell__c> getInitData(){
        List<BingoCell__c> listBingoCells = new List<BingoCell__c>();
        listBingoCells = [
                SELECT Id, BingoBoard__r.OwnerId, BingoMember__c, IsChecked__c, BingoMember__r.Name, BingoBoard__r.BoardOwner__c
                FROM BingoCell__c
                WHERE BingoBoard__r.BoardOwner__c =: UserInfo.getLastName()
//                WHERE BingoBoard__r.OwnerId =: UserInfo.getUserId()
                ORDER BY Name
        ];
        return listBingoCells;
    }

    @AuraEnabled
    public static List<BingoMember__c> getInitMemberData(){
        List<BingoMember__c> listSelectedMembers = [
                SELECT Id, Name
                FROM BingoMember__c
        ];
        listSelectedMembers.sort();

        return listSelectedMembers;
    }

    @AuraEnabled
    public static Map<String,String> getInitImgData(String[] bingoCellData) {
        System.debug('bingoCellData ::'+bingoCellData);
        List<ContentDocumentLink> listContentDocumentLink = [
                SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.LatestPublishedVersionId
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :bingoCellData
        ];

        Map<String, String> mapContentDocumentLink = new Map<String, String>();
        for (ContentDocumentLink link : listContentDocumentLink) {
            mapContentDocumentLink.put(link.LinkedEntityId, link.ContentDocument.LatestPublishedVersionId);
        }

        return mapContentDocumentLink;
    }

    @AuraEnabled
    public static Boolean saveData(String[] bingoCellData) {
        for(Integer i = 0;i<bingoCellData.size();i++) {
            System.debug('bingoCellData'+i+':'+bingoCellData[i]);
        }
        System.debug('name :: '+UserInfo.getLastName());
        BingoBoard__c bingoBoard = new BingoBoard__c();

        //본인이 생성한 Board가 있는지 확인
        List<BingoBoard__c> listLastBingoBoards = new List<BingoBoard__c>();
        listLastBingoBoards = [
                SELECT Id, OwnerId, BoardOwner__c
                FROM BingoBoard__c
                WHERE BoardOwner__c =: UserInfo.getLastName()
                LIMIT 1
        ];
        List<BingoCell__c> listLastBingoCells = new List<BingoCell__c>();
        List<BingoCell__c> listBingoCells = new List<BingoCell__c>();
        //이미 생성한 보드가 있는 경우
        if(!listLastBingoBoards.isEmpty()) {
            bingoBoard.Id = listLastBingoBoards[0].Id;
            listLastBingoCells = [
                    SELECT Id, BingoBoard__r.OwnerId, Name, CellX__c, CellY__c
                    FROM BingoCell__c
                    WHERE BingoBoard__r.Id = :bingoBoard.Id
            ];
            delete listLastBingoCells;
        }
        //생성한 보드가 없는 경우, 새로운 BingoBoard 생성
        else{
            bingoBoard.BoardOwner__c = UserInfo.getLastName();
            insert bingoBoard;
        }
        for(Integer i=0;i<5;i++) {
            for(Integer j=0;j<5;j++) {
                BingoCell__c bingoCell = new BingoCell__c(
                        CellX__c = j,
                        CellY__c = i,
                        BingoBoard__c = bingoBoard.Id,
                        BingoMember__c = bingoCellData[i*5+j]
                );
                listBingoCells.add(bingoCell);
            }
        }
        System.debug('listBingoCells ::'+listBingoCells);
        insert listBingoCells;

        return true;
    }

    @AuraEnabled
    public static List<BingoMember__c> randomData(){
        List<BingoMember__c> listBingoMembers = new List<BingoMember__c>();
        listBingoMembers = [
                SELECT Id
                FROM BingoMember__c
        ];
        //Knuth Shuffle 알고리즘 사용
        for(Integer i=0;i<listBingoMembers.size()-1;i++) {
            Integer randomIndex = i+(Integer)Math.floor(Math.random() *(listBingoMembers.size() - i));
            BingoMember__c tempBingoMember = listBingoMembers[i];
            listBingoMembers[i] = listBingoMembers[randomIndex];
            listBingoMembers[randomIndex] = tempBingoMember;
        }

        return listBingoMembers;
    }



//    //@@@@@배포시 삭제@@@@@
    @AuraEnabled
    public static Integer randomData2(){
//        List<BingoMember__c> randomData(){
        list<BingoBoard__c> listBingoBoard = new List<BingoBoard__c>();
        listBingoBoard = [
                SELECT Id
                FROM BingoBoard__c
        ];
        List<BingoMember__c> listBingoMembers = new List<BingoMember__c>();
        listBingoMembers = [
                SELECT Id,Name
                FROM BingoMember__c
                ORDER BY Name
        ];
        List<BingoMember__c> listRandomBingoMembers = new List<BingoMember__c>(randomData());
        BingoBoard__c bingoBoard = new BingoBoard__c(
                BoardOwner__c = listBingoMembers[listBingoBoard.size()].Name
        );
        insert bingoBoard;

        List<BingoCell__c> listBingoCells = new List<BingoCell__c>();
        for(Integer i=0;i<5;i++) {
            for(Integer j=0;j<5;j++) {
                BingoCell__c bingoCell = new BingoCell__c(
                        CellX__c = j,
                        CellY__c = i,
                        BingoBoard__c = bingoBoard.Id,
                        BingoMember__c = listRandomBingoMembers[i*5+j].Id
                );
                listBingoCells.add(bingoCell);
            }
        }
        System.debug('listBingoCells ::'+listBingoCells);
        insert listBingoCells;
        return listBingoBoard.size();
    }
}