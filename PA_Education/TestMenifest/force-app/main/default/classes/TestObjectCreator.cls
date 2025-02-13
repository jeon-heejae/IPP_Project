/************************************************************************************
 * File Name   : TestObjectCreator.cls
 * Author      : Soyoung.Jung 
 * Date        : 2019.01.14
 * Tester      : TestObjectCreator_test.cls
 * Target      : 
 * Description : 테스트 클래스에서 사용하는 테스트용 오브젝트 반환
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2019.01.14      Soyoung.Jung    Create                                       
*************************************************************************************/

public with sharing class TestObjectCreator {
	
	/************************************************************************************
    *   STANDARD OBJECT
    *************************************************************************************/
    /************************************************************************************
    *   User
    *************************************************************************************/
    public static User objUser {
        get {
            if(objUser == null) {
                objUser = new User();

                objUser.Email               = 'test@test.com';
                objUser.LastName            = 'testUser';
                objUser.FirstName           = 'testUser';
                objUser.ProfileId           = UserInfo.getProfileId();
                objUser.Emailencodingkey    = 'ks_c_5601-1987';
                objUser.Languagelocalekey   = 'en_US';
                objUser.IsActive            = true;
                objUser.Username            = 'testUser@daeunextier.com';
                objUser.Alias               = 'user';
                objUser.CommunityNickname   = 'user';
                objUser.TimeZoneSidKey      = 'Asia/Seoul';
                objUser.LocaleSidKey        = 'ko_KR';
            }

            return objUser;
        }
        set;
    }

    /************************************************************************************
    *   CUSTOM OBJECT
    *************************************************************************************/
    /************************************************************************************
    *   Employee__c
    *************************************************************************************/
    public static Employee__c objEmployee {
        get {
            if(objEmployee == null) {
                objEmployee = new Employee__c();
                objEmployee.Name = 'Test Employee';
                objEmployee.Emergency_Contact__c = '01000000000';
                objEmployee.Type__c = '내부직원';
                objEmployee.JoinDate__c = Date.today();
                objEmployee.User__c = UserInfo.getUserId();
            }    

            return objEmployee;
        }
        set;
    }

    /************************************************************************************
    *   Holiday__c
    *************************************************************************************/
    public static Holiday__c objHoliday {
        get {
            if(objHoliday == null) {
                objHoliday = new Holiday__c();
                objHoliday.Holiday_User__c = UserInfo.getUserId();
                objHoliday.Holiday_UseDays__c = 1;
            } 

            return objHoliday;
        }
        set;
    }
       
    /************************************************************************************
    *   HolidayAction__c
    *************************************************************************************/
    public static HolidayAction__c objHolidayAction {
        get {
            if(objHolidayAction == null) {
                if(objHoliday.Id == null) insert objHoliday;
                if(objUser.Id == null) insert objUser;

                objHolidayAction = new HolidayAction__c();
                objHolidayAction.HolidayAction_Parent__c = objHoliday.Id;
                objHolidayAction.HolidayAction_Date1__c = Date.today();
                objHolidayAction.HolidayAction_Type__c = 'Annual Holiday';
                objHolidayAction.FirstHolidayRequest__c = objUser.Id;
            } 

            return objHolidayAction;
        }
        set;
    }

    /************************************************************************************
    *   HolidayWorks__c

    public static HolidayWorks__c objHolidayWorks {
        get {
            if(objHolidayWorks == null) {
                if(objProject.Id == null) insert objProject;
                objHolidayWorks = new HolidayWorks__c();
                objHolidayWorks.Name = '휴일근무 신청';
                objHolidayWorks.Description__c = '고객 요청으로 인한 휴일근무 신청';
                objHolidayWorks.Project__c = objProject.Id;
                objHolidayWorks.Days__c = 1;
                objHolidayWorks.Date1__c = Date.today().addDays(7);
            }

            return objHolidayWorks;
        }
        set;
    }
    *************************************************************************************/
    
    /************************************************************************************
    *   Project__c
    *************************************************************************************/
    public static Project__c objProject {
        get {
            if(objProject == null) {
                objProject = new Project__c();
                objProject.Name = 'Test Project';
//                objProject.PM__c = objUser.Id;
            }

            return objProject;
        }
        set;
    }

    /************************************************************************************
    *   PerformProject__c
    *************************************************************************************/
    public static PerformProject__c objPerformProject {
        get {
            if(objPerformProject == null) {
                // 중복 규칙 해제
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.AllowSave = true;
                if(objProject.Id == null) Database.SaveResult sr = Database.insert(objProject, dml);
                if(objEmployee.Id == null) insert objEmployee;

                objPerformProject = new PerformProject__c();
                objPerformProject.Project__c = objProject.Id;
                objPerformProject.IsPM__c = true;
                objPerformProject.Employee__c = objEmployee.Id;
                objPerformProject.InputDate__c = Date.today().addMonths(-6);
                objPerformProject.WithdrawDate__c = Date.today();
                objPerformProject.Ratio__c = 70;
            }

            return objPerformProject;
        }
        set;
    }

    /************************************************************************************
    *   Contact
    *************************************************************************************/
    public static Contact objContact {
        get {
            if(objContact == null) {
                objContact = new Contact();
                objContact.Lastname  = 'TestContact';
            }
            return objContact;
        }
        set;
    }

    /************************************************************************************
    *   Opportunity__c
    *************************************************************************************/
    public static Opportunity__c objOpportunity {
        get {
            if(objOpportunity == null) {
                if(objContact == null) insert objContact;
                objOpportunity = new Opportunity__c();
                objOpportunity.DescriptionIsLegacy__c = false;
                objOpportunity.Contact__c = objContact.Id;
                objOpportunity.StageDetail__c = '06-3. Drop';
            }
            return objOpportunity;
        }
        set;
    }

    /************************************************************************************
    *   Account
    *************************************************************************************/
    public static Account objAccount {
        get {
            if(objAccount == null) {
                objAccount = new Account();
                objAccount.Name = 'Test Account';
                objAccount.ShortName__c = 'TACC';
            }

            return objAccount;
        }
        set;
    }

    /************************************************************************************
    *   Quote__c
    *************************************************************************************/
    public static Quote__c objQuote {
        get {
            if(objQuote == null) {
    
                if(objContact.Id == null) insert objContact;
                objQuote = new Quote__c();
                objQuote.Quote_Account__c = objAccount.Id;
                objQuote.Quote_Subject__c = 'TestQuoteSubject';
                objQuote.Quote_ShowVAT__c = false;
                objQuote.Quote_PremeierSuccessPlan__c = false;
                objQuote.Quote_Contact__c = objContact.Id;
                objQuote.Quote_Status__c = 'Draft';
            }

            return objQuote;
        }
        set;
    }

    /************************************************************************************
    *   QuoteItem__c
    *************************************************************************************/
    public static QuoteItem__c objQuoteItem {
        get {
            if(objQuoteItem == null) {
                if(objQuote.Id == null) insert objQuote;
                objQuoteItem = new QuoteItem__c();
                objQuoteItem.QuoteItem_quote__c = objQuote.Id;
            }

            return objQuoteItem;
        }
        set;
    }


    /************************************************************************************
    *   CUSTOM SETTINGS
    *************************************************************************************/
    /************************************************************************************
    *   QuoteItemManage__c 견적상세관리
    *************************************************************************************/
    public static QuoteItemManage__c objQuoteItemManage {
        get {
            if(objQuoteItemManage == null) {
                objQuoteItemManage = new QuoteItemManage__c();
                objQuoteItemManage.ConsultantChief__c      = 26000000;
                objQuoteItemManage.ConsultantPrincipal__c  = 22000000;
                objQuoteItemManage.ConsultantSupervisor__c = 16000000;
                objQuoteItemManage.DeveloperChief__c       = 22000000;
                objQuoteItemManage.DeveloperPrincipal__c   = 16000000;
                objQuoteItemManage.DeveloperSupervisor__c  = 12000000;
                objQuoteItemManage.Level1__c    = 'Supervisor';
                objQuoteItemManage.Level2__c    = 'Principar';
                objQuoteItemManage.Level3__c    = 'Chief';
            }

            return objQuoteItemManage;
        }
        set;
    }

    /************************************************************************************
    *   Contract__c
    *************************************************************************************/
    public static Contract__c objContract {
        get {
            if(objContract == null) {
                if(objOpportunity.Id == null) insert objOpportunity;
                objContract = new Contract__c();
                objContract.Name = 'TestName';
            }

            return objContract;
        }
        set;
    }


    /************************************************************************************
    *   Billing__c
    *************************************************************************************/
    public static Billing__c objBilling {
        get {
            if(objBilling == null) {
                if(objContract.Id == null) insert objContract;
                objBilling = new Billing__c();
                objBilling.Contract__c         = objContract.Id;
                //objBilling.BillingDate__c      = Date.today();
                //objBilling.BillingDueAmount__c = 50000;
                //objBilling.Type__c             = '중도금'; //picklist
            }

            return objBilling;
        }
        set;
    }



    /************************************************************************************
    *   Payment_Schedule__c
    *************************************************************************************/
    public static Payment_Schedule__c objPaymentSchedule {
        get {
            if(objPaymentSchedule == null) {
                if(objSubContracting == null) insert objSubContracting; //하도급계약
                objPaymentSchedule = new Payment_Schedule__c();
                objPaymentSchedule.subcontracting_contract__c = objSubContracting.Id;
            }

            return objPaymentSchedule;
        }
        set;
    }

    /************************************************************************************
    *   subcontracting_contract__c
    *************************************************************************************/
    public static subcontracting_contract__c objSubContracting {
        get {
            if(objSubContracting == null) {
                if(objContract.Id == null) insert objContract;
                objSubContracting = new subcontracting_contract__c();
                objSubContracting.Contract__c = objContract.Id;
            }

            return objSubContracting;
        }
        set;
    }

    /************************************************************************************
    *   BusinessPerformance__c
    *************************************************************************************/
    // public static BusinessPerformance__c objBP {
    //     get {
    //         if(objBP == null) {
    //             if(objContract.Id == null) insert objContract;
    //             objBP = new BusinessPerformance__c();
    //             objBP.Contract__c = objContract.Id;
    //             objBP.Type__c = '청구';
    //             objBP.M1__c  = 0;
    //             objBP.M2__c  = 0;
    //             objBP.M3__c  = 0;
    //             objBP.M4__c  = 0;
    //             objBP.M5__c  = 0;
    //             objBP.M6__c  = 0;
    //             objBP.M7__c  = 0;
    //             objBP.M8__c  = 0;
    //             objBP.M9__c  = 0;
    //             objBP.M10__c = 0;
    //             objBP.M11__c = 0;
    //             objBP.M12__c = 0;
    //             objBP.Year__c = '2018';
    //             objBP.FormerTerm__c = 100000;
    //             objBP.NextTerm__c = 100000;
    //         }
    //         return objBP;
    //     }
    //     set;
    // }

     /************************************************************************************
    *   Expense__c
    *************************************************************************************/
    public static Expense__c objExpense {
        get {
            if(objExpense == null) {
                if(objUser.Id == null)          insert objUser;
                if(objProject.Id == null)       insert objProject;
                objExpense = new Expense__c();
                // objExpense.FirstExpenseRequest__c = objUser.Id;
//                objExpense.Type__c        ='개인경비';
                objExpense.UseYear__c = String.valueOf(Date.today().year());
                objExpense.UseMonth__c    = '2';
                // objExpense.Project__c     = objProject.Id;
                // objExpense.Name           = '이름해';
                
            }

            return objExpense;
        }
        set;
    }

    /************************************************************************************
   *   PriorExpenseApplication__c
   *************************************************************************************/
    public static PriorExpenseApplication__c objPriorExpense {
        get {
            if(objPriorExpense == null) {
                if(objUser.Id == null)          insert objUser;
                if(objProject.Id == null)       insert objProject;
                objPriorExpense = new PriorExpenseApplication__c();
                objPriorExpense.Name           = '이름해';
                objPriorExpense.UseDate__c  = Date.today().addDays(1);
                objPriorExpense.Place__c    = '1';
                objPriorExpense.AttendeeNumber__c=1;
                objPriorExpense.Description__c='1';


            }

            return objPriorExpense;
        }
        set;
    }
    
    /************************************************************************************
    *   ExpenseDetail__c
    *************************************************************************************/
    public static ExpenseDetail__c objExpenseDetail {
        get {
            if(objExpenseDetail == null) {
                if(objUser.Id == null)        insert objUser;
                // if(objExpense.Id == null)     insert objExpense;
                if(objProject.Id == null)     insert objProject;
                if(objOpportunity.Id == null) insert objOpportunity;
                
                objExpenseDetail = new ExpenseDetail__c();
                // objExpenseDetail.FirstExpenseRequest__c = objUser.Id;
                objExpenseDetail.Date__c         = Date.today();
                objExpenseDetail.Category1__c    = '프로젝트';
                objExpenseDetail.Project_Name__c = objProject.Id;
                objExpenseDetail.Category2__c    = '회의';
                objExpenseDetail.Amount__c       = 2000000;
                objExpenseDetail.Description__c  = '롱롱롱';
            }

            return objExpenseDetail;
        }
        set;
    }
}