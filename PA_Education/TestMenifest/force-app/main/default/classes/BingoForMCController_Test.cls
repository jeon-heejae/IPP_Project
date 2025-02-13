/**
 * Created by skdus on 2023-11-27.
 */

@IsTest
public with sharing class BingoForMCController_Test {
    @TestSetup
    static void dataInput(){
        List<BingoMember__c> testMembers = new List<BingoMember__c>();
        for (Integer i = 0; i < 25*12; i++) {
            BingoMember__c member = new BingoMember__c (
                    Name = String.valueOf(i)
            );
            System.debug('member Name ::'+member);
            testMembers.add(member);
        }
        insert testMembers;
        List<BingoBoard__c> listTestBoard = new List<BingoBoard__c>();
        for(Integer i=0;i<12;i++) {
            BingoBoard__c testBoard = new BingoBoard__c();
            if(i==0) {
                testBoard.Cell_00__c =1;
                testBoard.Cell_01__c =1;
                testBoard.Cell_02__c =1;
                testBoard.Cell_03__c =1;
                testBoard.Cell_04__c =1;
            }
            if(i==1) {
                testBoard.Cell_10__c =1;
                testBoard.Cell_11__c =1;
                testBoard.Cell_12__c =1;
                testBoard.Cell_13__c =1;
                testBoard.Cell_14__c =1;
            }
            if(i==2) {
                testBoard.Cell_20__c =1;
                testBoard.Cell_21__c =1;
                testBoard.Cell_22__c =1;
                testBoard.Cell_23__c =1;
                testBoard.Cell_24__c =1;
            }
            if(i==3) {
                testBoard.Cell_30__c =1;
                testBoard.Cell_31__c =1;
                testBoard.Cell_32__c =1;
                testBoard.Cell_33__c =1;
                testBoard.Cell_34__c =1;
            }
            if(i==4) {
                testBoard.Cell_40__c =1;
                testBoard.Cell_41__c =1;
                testBoard.Cell_42__c =1;
                testBoard.Cell_43__c =1;
                testBoard.Cell_44__c =1;
            }
            if(i==5) {
                testBoard.Cell_00__c =1;
                testBoard.Cell_10__c =1;
                testBoard.Cell_20__c =1;
                testBoard.Cell_30__c =1;
                testBoard.Cell_40__c =1;
            }
            if(i==6) {
                testBoard.Cell_01__c =1;
                testBoard.Cell_11__c =1;
                testBoard.Cell_21__c =1;
                testBoard.Cell_31__c =1;
                testBoard.Cell_41__c =1;
            }
            if(i==7) {
                testBoard.Cell_02__c =1;
                testBoard.Cell_12__c =1;
                testBoard.Cell_22__c =1;
                testBoard.Cell_32__c =1;
                testBoard.Cell_42__c =1;
            }
            if(i==8) {
                testBoard.Cell_03__c =1;
                testBoard.Cell_13__c =1;
                testBoard.Cell_23__c =1;
                testBoard.Cell_33__c =1;
                testBoard.Cell_43__c =1;
            }
            if(i==9) {
                testBoard.Cell_04__c =1;
                testBoard.Cell_14__c =1;
                testBoard.Cell_24__c =1;
                testBoard.Cell_34__c =1;
                testBoard.Cell_44__c =1;
            }
            if(i==10) {
                testBoard.Cell_00__c =1;
                testBoard.Cell_11__c =1;
                testBoard.Cell_22__c =1;
                testBoard.Cell_33__c =1;
                testBoard.Cell_44__c =1;
            }
            if(i==11) {
                testBoard.Cell_04__c =1;
                testBoard.Cell_13__c =1;
                testBoard.Cell_22__c =1;
                testBoard.Cell_31__c =1;
                testBoard.Cell_40__c =1;
            }

            listTestBoard.add(testBoard);
        }

        insert listTestBoard;

        List<BingoCell__c> testCells = new List<BingoCell__c>();
        for(Integer k=0;k<12;k++) {

            for (Integer i = 0; i < 5; i++) {
                for (Integer j = 0; j < 5; j++) {
                    BingoCell__c cell = new BingoCell__c(
                            BingoMember__c = testMembers[k*25+i*5+j].Id,
                            BingoBoard__c = listTestBoard[k].Id,
                            CellX__c = j,
                            CellY__c = i
                    );

                    testCells.add(cell);
                }
            }
        }
        insert testCells;


        //1~5
//        for(Integer i=0;i<5;i++) {
//            for(Integer j=0;j<5;j++) {
//                BingoForMCController.updateBingoCell(testMembers[0+j+25*i].Id);
//                BingoForMCController.updateBingoCell(testMembers[5+j+25*i].Id);
//                BingoForMCController.updateBingoCell(testMembers[10+j+25*i].Id);
//                BingoForMCController.updateBingoCell(testMembers[15+j+25*i].Id);
//                BingoForMCController.updateBingoCell(testMembers[20+j+25*i].Id);
//            }
//        }
//        //6~10
//        for(Integer i=5;i<10;i++) {
//            for(Integer j=0;j<5;j++) {
//                BingoForMCController.updateBingoCell(testMembers[0+j*5+25*i].Id);
//                BingoForMCController.updateBingoCell(testMembers[1+j*5+25*i].Id);
//                BingoForMCController.updateBingoCell(testMembers[2+j*5+25*i].Id);
//                BingoForMCController.updateBingoCell(testMembers[3+j*5+25*i].Id);
//                BingoForMCController.updateBingoCell(testMembers[4+j*5+25*i].Id);
//            }
//        }

    }

    @isTest
    static void test1() {
        Test.startTest();

        List<BingoMember__c> testMembers = new List<BingoMember__c>();
        testMembers =[
                SELECT Id
                FROM BingoMember__c
        ];

        List<String> result = BingoForMCController.printBingoLine();

        BingoForMCController.updateBingoCell(testMembers[0].Id);

        BingoForMCController.getAvailableMembers();
        BingoForMCController.getSelectedMembers();
        BingoForMCController.whoIsMostPopular();
        BingoForMCController.getAwards();
        BingoForMCController.getBingoLine();



        BingoForMCController.resetGame();
        Test.stopTest();
    }
}