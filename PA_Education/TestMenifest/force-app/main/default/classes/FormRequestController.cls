/**
 * Created by choiyuna on 2022-11-11.
 */

public with sharing class FormRequestController {

    public FormRequest__c formRequest { get; set; }
    public String title_Eng { get; set; }
    private final String recordId;

    public FormRequestController(ApexPages.StandardController controller) {
        if (ApexPages.currentPage().getParameters().get('id') != null) {
            recordId = ApexPages.currentPage().getParameters().get('id');
        }

        if (formRequest == null) {
            formRequest = new FormRequest__c();
        }

        if (String.valueOf(Id.valueOf(recordId).getSobjectType()) == 'FormRequest__c') {
            if (recordId != null) {
                formRequest = [
                        SELECT Id, FormRequest_Title__c
                        FROM FormRequest__c
                        WHERE Id = :recordId
                ];
            }
        }

        if (formRequest.FormRequest_Title__c != null) {
            switch on formRequest.FormRequest_Title__c {
                when '대표이사' {
                    title_Eng = 'CEO';
                }
                when '부사장' {
                    title_Eng = 'Vice President';
                }
                when '전무' {
                    title_Eng = 'Executive Vice President';
                }
                when '상무' {
                    title_Eng = 'Managing Director';
                }
                when '이사' {
                    title_Eng = 'Director';
                }
                when '부장' {
                    title_Eng = 'General Manager';
                }
                when '차장' {
                    title_Eng = 'Deputy General Manager';
                }
                when '과장' {
                    title_Eng = 'Manager';
                }
                when '대리' {
                    title_Eng = 'Assistant Manager';
                }
                when '사원' {
                    title_Eng = 'Staff';
                }
                when '센터장' {
                    title_Eng = 'Head of GDC center';
                }
                when '인턴' {
                    title_Eng = 'Intern';
                }
                when else {
                    title_Eng = 'None';
                }
            }
        }
    }
}