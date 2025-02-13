/**
 * Created by Kwanwoo.Jeon on 2024-03-22.
 */

@IsTest
private class TrainingCenterCalendarController_test {
    @TestSetup
    static void setUp(){
        ApplicationTrainingCenter__c objATC = new ApplicationTrainingCenter__c(
            RoomType__c = '본채',
            UseType__c = '1박',
            Date1__c = Date.today(),
            Status__c = '확정',
            Sort__c = 'True'
        );
        insert objATC;

        ApplicationTrainingCenter__c objATC2 = new ApplicationTrainingCenter__c(
            RoomType__c = '본채',
            UseType__c = '1박',
            Date1__c = Date.newInstance(date.today().year(), date.today().month()+1,3),
            Status__c = '신청',
            Special__c = FALSE
        );
        insert objATC2;
    }

    @IsTest
    static void test1() {
        Test.startTest();
        map<String,Boolean> mapCheckboxValue = new Map<String, Boolean>();
        mapCheckboxValue.put('main', true);
        mapCheckboxValue.put('gram1', true);
        mapCheckboxValue.put('gram2', true);
        mapCheckboxValue.put('gram3', true);
        mapCheckboxValue.put('gram4', true);

        String selectedPick= 'All';
        TrainingCenterCalendarController.getEvents(mapCheckboxValue, selectedPick);
        String selectedPick2= '확정';
        TrainingCenterCalendarController.getEvents(mapCheckboxValue, selectedPick2);

        map<String,Boolean> mapCheckboxValue2 = new Map<String, Boolean>();
        mapCheckboxValue2.put('main', false);
        mapCheckboxValue2.put('gram1', false);
        mapCheckboxValue2.put('gram2', false);
        mapCheckboxValue2.put('gram3', false);
        mapCheckboxValue2.put('gram4', false);

        TrainingCenterCalendarController.getEvents(mapCheckboxValue2, selectedPick);
        TrainingCenterCalendarController.getEvents(mapCheckboxValue2, selectedPick2);


        Map<String, object> mapTrainingCenter = new Map<String, Object>();
        mapTrainingCenter.put('Date1__c', String.valueOf(Date.newInstance(date.today().year(), date.today().month()+1,2)));
        mapTrainingCenter.put('RoomType__c', '본채');
        mapTrainingCenter.put('UseType__c', '1박');
        mapTrainingCenter.put('Bigo__c', 'test');
        mapTrainingCenter.put('MemberNumber__c', '');
        mapTrainingCenter.put('Date2__c', '');

        TrainingCenterCalendarController.modalSave(mapTrainingCenter);
        Map<String, object> mapTrainingCenter2 = new Map<String, Object>();
        mapTrainingCenter2.put('Date1__c', String.valueOf(Date.newInstance(date.today().year(), date.today().month(),2)));
        mapTrainingCenter2.put('RoomType__c', '본채');
        mapTrainingCenter2.put('UseType__c', '1박');
        mapTrainingCenter2.put('Bigo__c', 'test');
        mapTrainingCenter2.put('MemberNumber__c', '');
        mapTrainingCenter2.put('Date2__c', '');
        TrainingCenterCalendarController.modalSave(mapTrainingCenter2);

        System.debug('========mapTrainingCenter3========');
        Map<String, object> mapTrainingCenter3 = new Map<String, Object>();
        mapTrainingCenter3.put('Date1__c', String.valueOf(Date.newInstance(date.today().year(), date.today().month()+1,3)));
        mapTrainingCenter3.put('RoomType__c', '본채');
        mapTrainingCenter3.put('UseType__c', '1박');
        mapTrainingCenter3.put('Bigo__c', 'test');
        mapTrainingCenter3.put('MemberNumber__c', '');
        mapTrainingCenter3.put('Date2__c', '');
        TrainingCenterCalendarController.modalSave(mapTrainingCenter3);
        Test.stopTest();
    }
}