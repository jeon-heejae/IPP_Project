public with sharing class printPdfController {
    public List<Contact> listCon {get; set;}

    public printPdfController() {
        //url에서 recordId 가져오기
        String recordId = ApexPages.currentPage().getParameters().get('recordId');
        System.debug('recordId: '+recordId);

        //recordId를 통해 Contact 쿼리
        listCon=[
            SELECT Id, Name,Title
            FROM Contact
            WHERE Id = :recordId
        ];

        System.debug('listCon ::'+ listCon);
    }
}