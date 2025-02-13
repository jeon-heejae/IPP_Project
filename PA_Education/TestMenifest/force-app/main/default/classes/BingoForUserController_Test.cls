/**
 * Created by jihwa on 2023-11-28.
 */

@IsTest
public with sharing class BingoForUserController_Test {

    @IsTest
    static void test_init(){
        Test.startTest();
        BingoForUserController.getInitData();
        BingoForUserController.getInitMemberData();

        List<BingoMember__c> listBingoMembers = new List<BingoMember__c>();
        for(Integer i = 0;i<25;i++) {
            BingoMember__c bingoMember = new BingoMember__c();
            bingoMember.Name = String.valueOf(i);
            listBingoMembers.add(bingoMember);
        }
        insert listBingoMembers;
        BingoForUserController.randomData2();


//        String[] bingoCellData = new String[25];
//        for(Integer i = 0;i<25;i++) {
//            bingoCellData[i] = String.valueOf(i);
//        }
//        BingoForUserController.getInitImgData(bingoCellData);
        Test.stopTest();
    }

    @IsTest
    static void test1() {
        Test.startTest();
        List<BingoMember__c> listBingoMembers = new List<BingoMember__c>();
        for(Integer i = 0;i<25;i++) {
            BingoMember__c bingoMember = new BingoMember__c();
            bingoMember.Name = String.valueOf(i);
            listBingoMembers.add(bingoMember);
        }

        insert listBingoMembers;

        String[] bingoCellData = new String[25];
        BingoForUserController.saveData(bingoCellData);

        BingoBoard__c bingoBoard = new BingoBoard__c();
        bingoBoard.BoardOwner__c = UserInfo.getLastName();
        insert bingoBoard;

        BingoForUserController.saveData(bingoCellData);
        BingoForUserController.randomData();

        Test.stopTest();
    }

}