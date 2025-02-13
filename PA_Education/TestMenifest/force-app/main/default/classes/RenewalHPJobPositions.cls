/**
 * =============================================
 * File Name    : RenewalHPJobPositions.cls
 * Author       : Chan Kang
 * Group        : Boundary
 * Date         : 2021. 12. 24
 * Description  : 채용 공고 Open Positions
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2021. 12. 24    Chan Kang           Create
   1.1      2022. 04. 15    Gyubin Lee          Use optimized query constructor
                                                Add query to fetch data in English
*/

public without sharing class RenewalHPJobPositions {
  @AuraEnabled
  public static List<JobPosition__c> getPositions(Boolean isEnglish) {
    //        List<JobPosition__c> positions = [
    //                SELECT Id, fm_subject__c, WorkType__c, Career__c, Education__c, RecruitmentCategory__c, Position__c, Qualifications__c, preferentialTreatment__c, Status__c, MainBusiness__c
    //                FROM JobPosition__c
    //                WHERE OrderNum__c != NULL AND OrderNum__c != 0
    //                ORDER BY OrderNum__c ASC
    //                LIMIT 9
    //        ];

    String head = isEnglish
      ? 'Id, ' +
        'fm_subjectEng__c, ' +
        'WorkTypeEng__c, ' +
        'CareerEng__c, ' +
        'EducationEng__c, ' +
        'RecruitmentCategoryEng__c, ' +
        'Position__c, ' +
        'QualificationsEng__c, ' +
        'preferentialTreatmentEng__c, ' +
        'StatusEng__c, ' +
        'MainBusinessEng__c, ' +
        'WorkingPlaceEng__c'
      : 'Id, ' +
        'fm_subject__c, ' +
        'WorkType__c, ' +
        'Career__c, ' +
        'Education__c, ' +
        'RecruitmentCategory__c, ' +
        'Position__c, ' +
        'Qualifications__c, ' +
        'preferentialTreatment__c, ' +
        'Status__c, ' +
        'MainBusiness__c, ' +
        'WorkingPlace__c';
    String body = 'JobPosition__c WHERE OrderNum__c != NULL AND OrderNum__c != 0 ORDER BY OrderNum__c ASC LIMIT 9';
    return Database.query(RenewalHPUtility.queryConstructor(head, body));
  }

  @AuraEnabled
  public static List<JobPosition__c> loadMorePositions(Boolean isEnglish) {
    //        List<JobPosition__c> positions = [
    //                SELECT Id, fm_subject__c, WorkType__c, Career__c, Education__c, RecruitmentCategory__c, Position__c, Qualifications__c, preferentialTreatment__c, Status__c, MainBusiness__c
    //                FROM JobPosition__c
    //                ORDER BY OrderNum__c ASC
    //        ];

    String head = isEnglish
      ? 'Id, fm_subjectEng__c, ' +
        'WorkTypeEng__c, ' +
        'CareerEng__c, ' +
        'EducationEng__c, ' +
        'RecruitmentCategoryEng__c, ' +
        //'PositionEng__c, ' +
        'Position__c, ' +
        'QualificationsEng__c, ' +
        'preferentialTreatmentEng__c, ' +
        'StatusEng__c, ' +
        'MainBusinessEng__c, ' +
        'WorkingPlaceEng__c'
      : 'Id, fm_subject__c, WorkType__c, Career__c, Education__c, RecruitmentCategory__c, Position__c, Qualifications__c, preferentialTreatment__c, Status__c, MainBusiness__c, WorkingPlace__c';
    String body = 'JobPosition__c ORDER BY OrderNum__c ASC';

    return Database.query(RenewalHPUtility.queryConstructor(head, body));
  }

  @AuraEnabled
  public static String doSaveApplyTo(
    Map<String, Object> paramMap,
    String fileName,
    String base64Data,
    String contentType
  ) {
    System.debug('STart doSaveApplyTo >>>>>>' + paramMap);

    String Mobile = String.valueOf(paramMap.get('Mobile'));
    String Applicant = String.valueOf(paramMap.get('Applicant'));
    String Email = String.valueOf(paramMap.get('Email'));
    String JobPositionId = String.valueOf(paramMap.get('JobPositionId'));
    String BirthDate = String.valueOf(paramMap.get('BirthDate'));

    System.debug('fileName >>' + fileName);
    System.debug('base64Data >>' + base64Data);
    System.debug('contentType >>' + contentType);

    Applyto__c objApplyto = new Applyto__c();
    objApplyto.Mobile__c = Mobile;
    objApplyto.Email__c = Email;
    objApplyto.Applicant__c = Applicant;
    objApplyto.JobPosition__c = JobPositionId;
    objApplyto.ApplyDate__c = Datetime.now();
    objApplyto.Birthday__c = Date.valueOf(BirthDate);
    objApplyto.PersonalInformationUseAgreement__c = true;

    insert objApplyto;

    base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
    ContentVersion contentVersion = new ContentVersion(
      VersionData = EncodingUtil.base64Decode(base64Data),
      Title = fileName,
      PathOnClient = '/' + fileName,
      FirstPublishLocationId = objApplyto.Id
    );

    insert contentVersion;

    return '0';
  }
}