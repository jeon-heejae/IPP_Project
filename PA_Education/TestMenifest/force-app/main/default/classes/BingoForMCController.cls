/**
 * Created by skdus on 2023-11-07.
 */

public with sharing class BingoForMCController {
    public class CountWrapper implements Comparable {
        public String memberName;
        public Integer count;

        public CountWrapper(String memberName, Integer count) {
            this.memberName = memberName;
            this.count = count;
        }

        public Integer compareTo(Object obj) {
            CountWrapper other = (CountWrapper)obj;
            return other.count - this.count;
        }
    }

    @AuraEnabled
    public static List<BingoMember__c> getAvailableMembers() {
        List<BingoMember__c> listAvailableMembers = [
                SELECT Id, Name, IsChecked__c
                FROM BingoMember__c
                WHERE IsChecked__c = FALSE
        ];

        return listAvailableMembers;
    }

    @AuraEnabled
    public static List<BingoMember__c> getSelectedMembers() {
        List<BingoMember__c> listSelectedMembers = [
                SELECT Id, Name, IsChecked__c, ClickedTime__c
                FROM BingoMember__c
                WHERE IsChecked__c = TRUE
                ORDER BY ClickedTime__c
        ];

        List<BingoCell__c> listCell = [
                SELECT Id, IsChecked__c
                FROM BingoCell__c
                WHERE BingoMember__r.IsChecked__c = TRUE
        ];

        if (listCell != null) {
            for (BingoCell__c cell : listCell) {
                cell.IsChecked__c = true;
            }
            update listCell;
        }
        return listSelectedMembers;
    }

    @AuraEnabled
    public static void updateBingoCell(String memberId) {
        List<BingoCell__c> listBC = new List<BingoCell__c>();
        listBC = [
                SELECT Id, IsChecked__c, CellX__c, CellY__c, BingoBoard__r.Cell_00__c,
                        BingoBoard__r.Cell_01__c, BingoBoard__r.Cell_02__c, BingoBoard__r.Cell_03__c,
                        BingoBoard__r.Cell_04__c, BingoBoard__r.Cell_10__c, BingoBoard__r.Cell_11__c,
                        BingoBoard__r.Cell_12__c, BingoBoard__r.Cell_13__c, BingoBoard__r.Cell_14__c,
                        BingoBoard__r.Cell_20__c, BingoBoard__r.Cell_21__c, BingoBoard__r.Cell_22__c,
                        BingoBoard__r.Cell_23__c, BingoBoard__r.Cell_24__c, BingoBoard__r.Cell_30__c,
                        BingoBoard__r.Cell_31__c, BingoBoard__r.Cell_32__c, BingoBoard__r.Cell_33__c,
                        BingoBoard__r.Cell_34__c, BingoBoard__r.Cell_40__c, BingoBoard__r.Cell_41__c,
                        BingoBoard__r.Cell_42__c, BingoBoard__r.Cell_43__c, BingoBoard__r.Cell_44__c
                FROM BingoCell__c
                WHERE BingoMember__c =: memberId
        ];

        if (listBC != null) {
            List<BingoBoard__c> bingoBoardListToUpdate = new List<BingoBoard__c>();
            Set<Id> uniqueBoardIds = new Set<Id>();

            for (BingoCell__c bc : listBC) {
                bc.IsChecked__c = true;
                String fieldName = 'Cell_' + String.valueOf(bc.CellX__c).leftPad(1, '0') + String.valueOf(bc.CellY__c).leftPad(1, '0') + '__c';
                bc.BingoBoard__r.put(fieldName, 1);

                if (!uniqueBoardIds.contains(bc.BingoBoard__c)) {
                    bingoBoardListToUpdate.add(bc.BingoBoard__r);
                    uniqueBoardIds.add(bc.BingoBoard__c);
                }
            }

            update bingoBoardListToUpdate;
            update listBC;
        }

        List<BingoMember__c> listBM = [
                SELECT Id, IsChecked__c
                FROM BingoMember__c
                WHERE Id =: memberId
                LIMIT 1
        ];

        if (listBM != null) {
            for (BingoMember__c bm : listBM) {
                bm.IsChecked__c = true;
                bm.ClickedTime__c = Datetime.now();
            }
            update listBM;
        }
    }

    @AuraEnabled
    public static void resetGame() {
        List<BingoCell__c> listCell = [
                SELECT Id, IsChecked__c, CellX__c, CellY__c, BingoBoard__r.Cell_00__c,
                        BingoBoard__r.Cell_01__c, BingoBoard__r.Cell_02__c, BingoBoard__r.Cell_03__c,
                        BingoBoard__r.Cell_04__c, BingoBoard__r.Cell_10__c, BingoBoard__r.Cell_11__c,
                        BingoBoard__r.Cell_12__c, BingoBoard__r.Cell_13__c, BingoBoard__r.Cell_14__c,
                        BingoBoard__r.Cell_20__c, BingoBoard__r.Cell_21__c, BingoBoard__r.Cell_22__c,
                        BingoBoard__r.Cell_23__c, BingoBoard__r.Cell_24__c, BingoBoard__r.Cell_30__c,
                        BingoBoard__r.Cell_31__c, BingoBoard__r.Cell_32__c, BingoBoard__r.Cell_33__c,
                        BingoBoard__r.Cell_34__c, BingoBoard__r.Cell_40__c, BingoBoard__r.Cell_41__c,
                        BingoBoard__r.Cell_42__c, BingoBoard__r.Cell_43__c, BingoBoard__r.Cell_44__c
                FROM BingoCell__c
        ];
        System.debug('listCell::'+listCell);
        System.debug('listCellsize::'+listCell.size());

        if (listCell != null) {
            List<BingoBoard__c> bingoBoardListToUpdate = new List<BingoBoard__c>();
            Set<Id> uniqueBoardIds = new Set<Id>();
            for (BingoCell__c bc : listCell) {
                bc.IsChecked__c = false;
                String fieldName = 'Cell_' + String.valueOf(bc.CellX__c).leftPad(1, '0') + String.valueOf(bc.CellY__c).leftPad(1, '0') + '__c';
                bc.BingoBoard__r.put(fieldName, 0);

                if (!uniqueBoardIds.contains(bc.BingoBoard__c)) {
                    bingoBoardListToUpdate.add(bc.BingoBoard__r);
                    uniqueBoardIds.add(bc.BingoBoard__c);
                }
            }

            update bingoBoardListToUpdate;
            update listCell;
        }

        List<BingoMember__c> listMember = [
                SELECT Id, IsChecked__c
                FROM BingoMember__c
        ];

        if (listMember != null) {
            for (BingoMember__c memberToUpdate : listMember) {
                memberToUpdate.IsChecked__c = false;
            }
        }

        update listMember;

        List<BingoBoard__c> listBoard = [
                SELECT Id, IsBingo__c
                FROM BingoBoard__c
        ];

        if (listBoard != null) {
            for (BingoBoard__c board : listBoard) {
                board.IsBingo__c = false;
                board.BingoLine__c = 'none';
            }
        }

        update listBoard;
    }

    @AuraEnabled
    public static List<String> whoIsMostPopular() {
        Map<String, Integer> mapPM = new Map<String, Integer>();

        for (BingoCell__c cell : [SELECT BingoMember__r.Name FROM BingoCell__c WHERE BingoMember__c != NULL]) {
            String memberName = cell.BingoMember__r.Name;
            if (!mapPM.containsKey(memberName)) {
                mapPM.put(memberName, 0);
            }
            mapPM.put(memberName, mapPM.get(memberName) + 1);
        }

        List<CountWrapper> listCount = new List<CountWrapper>();
        for (String memberName : mapPM.keySet()) {
            listCount.add(new CountWrapper(memberName, mapPM.get(memberName)));
        }

        listCount.sort();

        List<String> listResult = new List<String>();
        Integer currentRank = 1;
        Integer currentCount = listCount[0].count;

        for (CountWrapper countWrapper : listCount) {
            String memberName = countWrapper.memberName;
            Integer count = countWrapper.count;

            if (count < currentCount) {
                currentRank++;
                currentCount = count;
            }

            if (currentRank == 11) {
                for (CountWrapper cw : listCount) {
                    String name = cw.memberName;
                    Integer cnt = cw.count;
                    if (cnt == currentCount) {
                        listResult.add(currentRank + '위: ' + name + '(' + cnt + ')');
                    }else {
                        break;
                    }
                }
                break;
            }

            listResult.add(currentRank + '위: ' + memberName + '(' + count + ')');
        }


        System.debug('Bingo Cell Count Map: ' + mapPM);
        System.debug('Sorted Count List: ' + listCount);
        System.debug('Final Result List: ' + listResult);

        return listResult;
    }

    @AuraEnabled
    public static List<String> getAwards() {
        List<BingoBoard__c> listBoard = [
                SELECT Name, fm_BingoCount__c, BoardOwner__c
                FROM BingoBoard__c
        ];

        List<String> listBingoComplete = new List<String>();
        for (BingoBoard__c board : listBoard) {
            if (board.fm_BingoCount__c >= 1) {
                listBingoComplete.add(board.BoardOwner__c);
            }
        }

        return listBingoComplete;
    }

    @AuraEnabled
    public static void getBingoLine() {
        List<BingoBoard__c> listBoard = [
                SELECT Name, fm_BingoCount__c, fm_BingoLine1__c, fm_BingoLine2__c, fm_BingoLine3__c,
                        fm_BingoLine4__c, fm_BingoLine5__c, fm_BingoLine6__c, fm_BingoLine7__c,
                        fm_BingoLine8__c, fm_BingoLine9__c, fm_BingoLine10__c, fm_BingoLine11__c,
                        fm_BingoLine12__c, BoardOwner__c, IsBingo__c, BingoLine__c
                FROM BingoBoard__c
                WHERE fm_BingoCount__c >= 1 AND BingoLine__c = 'none'
        ];

        for (BingoBoard__c board : listBoard) {
            if (board.fm_BingoLine1__c == true) {
                List<BingoCell__c> listCell = [
                        SELECT Id, BingoMember__r.Name, CellX__c, CellY__c
                        FROM BingoCell__c
                        WHERE BingoBoard__r.BoardOwner__c = :board.BoardOwner__c
                        AND CellX__c = 0
                        AND CellY__c IN (0, 1, 2, 3, 4)
                ];

                String line = '';
                for (BingoCell__c bc : listCell) {
                    line += bc.BingoMember__r.Name + ' ';
                }
                line += '(' + board.BoardOwner__c + ')';
                board.BingoLine__c = line;
            }else if (board.fm_BingoLine2__c == true) {
                List<BingoCell__c> listCell = [
                        SELECT Id, BingoMember__r.Name, CellX__c, CellY__c
                        FROM BingoCell__c
                        WHERE BingoBoard__r.BoardOwner__c = :board.BoardOwner__c
                        AND CellX__c = 1
                        AND CellY__c IN (0, 1, 2, 3, 4)
                ];

                String line = '';
                for (BingoCell__c bc : listCell) {
                    line += bc.BingoMember__r.Name + ' ';
                }
                line += '(' + board.BoardOwner__c + ')';
                board.BingoLine__c = line;
            }else if (board.fm_BingoLine3__c == true) {
                List<BingoCell__c> listCell = [
                        SELECT Id, BingoMember__r.Name, CellX__c, CellY__c
                        FROM BingoCell__c
                        WHERE BingoBoard__r.BoardOwner__c = :board.BoardOwner__c
                        AND CellX__c = 2
                        AND CellY__c IN (0, 1, 2, 3, 4)
                ];

                String line = '';
                for (BingoCell__c bc : listCell) {
                    line += bc.BingoMember__r.Name + ' ';
                }
                line += '(' + board.BoardOwner__c + ')';
                board.BingoLine__c = line;
            }else if (board.fm_BingoLine4__c == true) {
                List<BingoCell__c> listCell = [
                        SELECT Id, BingoMember__r.Name, CellX__c, CellY__c
                        FROM BingoCell__c
                        WHERE BingoBoard__r.BoardOwner__c = :board.BoardOwner__c
                        AND CellX__c = 3
                        AND CellY__c IN (0, 1, 2, 3, 4)
                ];

                String line = '';
                for (BingoCell__c bc : listCell) {
                    line += bc.BingoMember__r.Name + ' ';
                }
                line += '(' + board.BoardOwner__c + ')';
                board.BingoLine__c = line;
            }else if (board.fm_BingoLine5__c == true) {
                List<BingoCell__c> listCell = [
                        SELECT Id, BingoMember__r.Name, CellX__c, CellY__c
                        FROM BingoCell__c
                        WHERE BingoBoard__r.BoardOwner__c = :board.BoardOwner__c
                        AND CellX__c = 4
                        AND CellY__c IN (0, 1, 2, 3, 4)
                ];

                String line = '';
                for (BingoCell__c bc : listCell) {
                    line += bc.BingoMember__r.Name + ' ';
                }
                line += '(' + board.BoardOwner__c + ')';
                board.BingoLine__c = line;
            }else if (board.fm_BingoLine6__c == true) {
                List<BingoCell__c> listCell = [
                        SELECT Id, BingoMember__r.Name, CellX__c, CellY__c
                        FROM BingoCell__c
                        WHERE BingoBoard__r.BoardOwner__c = :board.BoardOwner__c
                        AND CellX__c IN (0, 1, 2, 3, 4)
                        AND CellY__c = 0
                ];

                String line = '';
                for (BingoCell__c bc : listCell) {
                    line += bc.BingoMember__r.Name + ' ';
                }
                line += '(' + board.BoardOwner__c + ')';
                board.BingoLine__c = line;
            }else if (board.fm_BingoLine7__c == true) {
                List<BingoCell__c> listCell = [
                        SELECT Id, BingoMember__r.Name, CellX__c, CellY__c
                        FROM BingoCell__c
                        WHERE BingoBoard__r.BoardOwner__c = :board.BoardOwner__c
                        AND CellX__c IN (0, 1, 2, 3, 4)
                        AND CellY__c = 1
                ];

                String line = '';
                for (BingoCell__c bc : listCell) {
                    line += bc.BingoMember__r.Name + ' ';
                }
                line += '(' + board.BoardOwner__c + ')';
                board.BingoLine__c = line;
            }else if (board.fm_BingoLine8__c == true) {
                List<BingoCell__c> listCell = [
                        SELECT Id, BingoMember__r.Name, CellX__c, CellY__c
                        FROM BingoCell__c
                        WHERE BingoBoard__r.BoardOwner__c = :board.BoardOwner__c
                        AND CellX__c IN (0, 1, 2, 3, 4)
                        AND CellY__c = 2
                ];

                String line = '';
                for (BingoCell__c bc : listCell) {
                    line += bc.BingoMember__r.Name + ' ';
                }
                line += '(' + board.BoardOwner__c + ')';
                board.BingoLine__c = line;
            }else if (board.fm_BingoLine9__c == true) {
                List<BingoCell__c> listCell = [
                        SELECT Id, BingoMember__r.Name, CellX__c, CellY__c
                        FROM BingoCell__c
                        WHERE BingoBoard__r.BoardOwner__c = :board.BoardOwner__c
                        AND CellX__c IN (0, 1, 2, 3, 4)
                        AND CellY__c = 3
                ];

                String line = '';
                for (BingoCell__c bc : listCell) {
                    line += bc.BingoMember__r.Name + ' ';
                }
                line += '(' + board.BoardOwner__c + ')';
                board.BingoLine__c = line;
            }else if (board.fm_BingoLine10__c == true) {
                List<BingoCell__c> listCell = [
                        SELECT Id, BingoMember__r.Name, CellX__c, CellY__c
                        FROM BingoCell__c
                        WHERE BingoBoard__r.BoardOwner__c = :board.BoardOwner__c
                        AND CellX__c IN (0, 1, 2, 3, 4)
                        AND CellY__c = 4
                ];

                String line = '';
                for (BingoCell__c bc : listCell) {
                    line += bc.BingoMember__r.Name + ' ';
                }
                line += '(' + board.BoardOwner__c + ')';
                board.BingoLine__c = line;
            }else if (board.fm_BingoLine11__c == true) {
                List<BingoCell__c> listCell = [
                        SELECT Id, BingoMember__r.Name, CellX__c, CellY__c
                        FROM BingoCell__c
                        WHERE BingoBoard__r.BoardOwner__c = :board.BoardOwner__c
                ];

                String line = '';
                for (BingoCell__c bc : listCell) {
                    if (bc.CellX__c == bc.CellY__c) {
                        line += bc.BingoMember__r.Name + ' ';
                    }
                }
                line += '(' + board.BoardOwner__c + ')';
                board.BingoLine__c = line;
            }else if (board.fm_BingoLine12__c == true) {
                List<BingoCell__c> listCell = [
                        SELECT Id, BingoMember__r.Name, CellX__c, CellY__c
                        FROM BingoCell__c
                        WHERE BingoBoard__r.BoardOwner__c = :board.BoardOwner__c
                ];

                String line = '';
                for (BingoCell__c bc : listCell) {
                    if (bc.CellX__c + bc.CellY__c == 4) {
                        line += bc.BingoMember__r.Name + ' ';
                    }
                }
                line += '(' + board.BoardOwner__c + ')';
                board.BingoLine__c = line;
            }
            board.IsBingo__c = true;
        }
        update listBoard;
    }

    @AuraEnabled
    public static List<String> printBingoLine() {
        List<BingoBoard__c> listBoard = [
                SELECT Id, IsBingo__c, BingoLine__c
                FROM BingoBoard__c
                WHERE IsBingo__c = True
        ];

        List<String> listReturn = new List<String>();
        for (BingoBoard__c board : listBoard) {
            listReturn.add(board.BingoLine__c);
        }

        return listReturn;
    }
}