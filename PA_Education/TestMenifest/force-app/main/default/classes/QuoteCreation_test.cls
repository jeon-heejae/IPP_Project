/************************************************************************************
 * File Name   : QuoteCreation_test.cls
 * Author      : Jk.lee 
 * Date        : 2019.03.04
 * Target      : QuoteCreation.cls
 * Description : QuoteCreation.cls Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2019.02.28      JK.LEE        Create
*************************************************************************************/

@isTest
private class QuoteCreation_test {

	@isTest
	static void doTest() {
		Test.startTest();
		QuoteCreation quoteCreate = new QuoteCreation();

		Account acc = new Account(Name = 'Test 계정',
								  ShortName__c = 'test');
		List<Account> acclist = new List<Account>();
		acclist.add(acc);
		insert acclist;

		Opportunity__c oppty = new Opportunity__c(Name = 'test 영업기회', AccountId__c = acc.Id);
		List<Opportunity__c> opptyList = new List<Opportunity__c>();
		opptyList.add(oppty);
		insert opptyList;
		
		Quote__c quote = new Quote__c(								
							Quote_Opportunity__c = oppty.Id, 
							Quote_Subject__c = 'TEST QUOTE',
							Quote_Date__c = System.today(), 
							Quote_Account__c = acc.Id, 
							Quote_Status__c = 'Draft',
							Quote_ShowVAT__c = false,
							//소계
							Quote_ConsultRemark__c = 'Test 컨설팅',
							Quote_LicenseRemark__c = 'Test 라이센스',
							Quote_TrainingRemark__c = 'Test 교육'
							);
		List<Quote__c> quoteList = new List<Quote__c>();
		quoteList.add(quote);
		insert quoteList;

		QuoteItem__c quoteItemCon = new QuoteItem__c (
										QuoteItem_Quote__c  = quote.Id , 
									  	RecordTypeId = '01290000000ukfTAAQ',
									  	QuoteItem_ConsultDiscountedPrice__c =500,
									  	QuoteItem_ConsultLevel__c ='Chief',
									  	QuoteItem_ConsultType__c = 'SFDC Consultant',
									  	QuoteItem_ConsultListPrice__c = 1000,
									  	QuoteItem_ConsultName__c = '테스트사원',
									  	QuoteItem_FOC__c = false,
									  	QuoteItem_SortOrder__c = 1,

										QuoteItem_LicenseType__c = '테스트 라이센스',
										QuoteItem_LicenseListPrice__c = 1000,
										QuoteItem_LicenseDiscountedPrice__c = 500,
										QuoteItem_LicenseNumberOfUser__c = 10,

										QuoteItem_TrainingDescription__c = '테스트 상세항목',
										QuoteItem_TrainingStandardPrice__c = 1000,
										QuoteItem_TrainingSalesPrice__c = 500,
										QuoteItem_TrainingCount__c = 10
													  );
		QuoteItem__c quoteItemLic = new QuoteItem__c(QuoteItem_Quote__c  = quote.Id , RecordTypeId = '01290000000ukfUAAQ' );
		QuoteItem__c quoteItemTra = new QuoteItem__c(QuoteItem_Quote__c  = quote.Id , RecordTypeId = '01290000000ukfTAAQ' );

		List<QuoteItem__c> quoteItemList = new List<QuoteItem__c>();
		quoteItemList.add(quoteItemCon);
		quoteItemList.add(quoteItemTra);
		quoteItemList.add(quoteItemLic);
		insert quoteItemList;


		//Delete List Id
		List<Id> deletedId = new List<Id>();
		deletedId.add(quoteItemcon.Id);
		
		Map<String, Object> mapReturnValue = QuoteCreation.getInitData(quote.Id, oppty.Id);
		system.debug(mapReturnValue);
		system.debug(QuoteCreation.getObjectFieldLabel('Quote__c'));
		system.debug(QuoteCreation.getCalcListPrice('Consultant', 'Principal'));
		system.debug(QuoteCreation.getPicklistValue('Quote__c', 'Quote_Status__c'));


		QuoteCreation.doSave((List<QuoteCreation.WrapperQuoteItem>) mapReturnValue.get('Consulting'), (List<QuoteCreation.WrapperQuoteItem>) mapReturnValue.get('License'), (List<QuoteCreation.WrapperQuoteItem>) mapReturnValue.get('Training'), deletedId, quote);

		Test.stopTest();
	}

	@testSetup 
	static void setData() {
		QuoteItemManage__c objQuoteItemManage = TestObjectCreator.objQuoteItemManage;
		insert objQuoteItemManage;
    }

}