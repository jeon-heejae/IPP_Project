/**
 * Created by Kwanwoo.Jeon on 2024-03-22.
 */

@IsTest
private class ApplicationTrainingCenter_tr_test {
    @IsTest
    static void testBehavior() {
        Test.startTest();
        ApplicationTrainingCenter__c objATC = new ApplicationTrainingCenter__c(
                RoomType__c = '본채',
                UseType__c = '1박',
                Date1__c = Date.today(),
                Status__c = '확정',
                Sort__c = 'True'
        );
        Database.insert(objATC, false);
        System.debug(Database.delete(objATC, false));

        ApplicationTrainingCenter__c objATC2 = new ApplicationTrainingCenter__c(
                RoomType__c = '본채',
                UseType__c = '1박',
                Date1__c = Date.newInstance(date.today().year(), date.today().month()+1,3),
                Status__c = '신청',
                Special__c = FALSE
        );
        System.debug(Database.insert(objATC2, false));


        ApplicationTrainingCenter__c objATC3 = new ApplicationTrainingCenter__c(
                RoomType__c = '본채',
                UseType__c = '1박',
                Date1__c = Date.newInstance(date.today().year(), date.today().month()+1,3),
                Status__c = '신청',
                Special__c = FALSE
        );
        System.debug('33 :: ' + Database.insert(objATC3, false));

        objATC2.Status__c = '확정';
        Database.update(objATC2, false);

        System.debug('확정33 :: ' + Database.insert(objATC3, false));

        objATC2.Status__c = '취소';
        Database.update(objATC2, false);

        //특수사유 신청
        ApplicationTrainingCenter__c objATCSpecial = new ApplicationTrainingCenter__c(
                RoomType__c = '본채',
                UseType__c = '1박',
                Date1__c = Date.newInstance(date.today().year(), date.today().month()+1,10),
                Date2__c = Date.newInstance(date.today().year(), date.today().month()+1,11),
                Status__c = '확정',
                Special__c = True
        );
        System.debug('objATCSpecial :: ' + Database.insert(objATCSpecial, false));


        ApplicationTrainingCenter__c objATCSpecialTest = new ApplicationTrainingCenter__c(
                RoomType__c = '본채',
                UseType__c = '1박',
                Date1__c = Date.newInstance(date.today().year(), date.today().month()+1,9),
                Date2__c = Date.newInstance(date.today().year(), date.today().month()+1,10),
                Status__c = '확정',
                Special__c = false
        );
        System.debug('objATCSpecialTest :: ' + Database.insert(objATCSpecialTest, false));

        ApplicationTrainingCenter__c objATCSpecialTest2 = new ApplicationTrainingCenter__c(
                RoomType__c = '본채',
                UseType__c = '1박',
                Date1__c = Date.newInstance(date.today().year(), date.today().month()+1,11),
                Status__c = '확정',
                Special__c = false
        );
        System.debug('objATCSpecialTest :: ' + Database.insert(objATCSpecialTest2, false));



        Test.stopTest();

    }
}