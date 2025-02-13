/************************************************************************************
 * File Name   : ResourceProfileController.cls
 * Author      : Soyoung.Jung 
 * Date        : 2019.01.09
 * Tester      : ResourceProfileController_test.cls
 * Description : 사원 프로필 문서 생성 페이지 컨트롤러
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2019.01.09      Soyoung.Jung        Create
   1.0      2019.02.08      JK.lee              Modified   *Resource Profile 인적사항에 총경력 표시

*************************************************************************************/

public without sharing class ResourceProfileController {

    public ResourceProfileController() {}
    public ResourceProfileController(ApexPages.StandardController employee) {}

    /************************************************************************************
    *   문서 생성 필수 데이터
    *************************************************************************************/
    public String baseURL {
        get {
            if(baseURL == null) {
                baseURL = Url.getSalesforceBaseUrl().getHost();
            }
            return baseURL;
        }
        set;
    }

    public String sFileName {
        get {
            if(sFileName == null) {
                sFileName = 'Resource Profile ' + Date.today().format();
            }
            return EncodingUtil.urlEncode(sFileName, 'UTF-8').replaceAll('\\+', '\\ ').replaceAll('%28', '(').replaceAll('%29', ')');
        }
        set;
    }    


    /************************************************************************************
    *   문서 생성에 필요한 이미지
    *************************************************************************************/
    private Set<Id> setIdFolder {
        get {
            if(setIdFolder == null) {
                setIdFolder = new Set<Id>();

                for(Folder objFolder : [SELECT Id FROM Folder WHERE DeveloperName IN ('Daeu_CI', 'EmployeeIdPhoto')]) {
                    setIdFolder.add(objFolder.Id);                  
                }
            }

            return setIdFolder;
        }
        set;
    }

    public Map<String, String> mapImage {
        get {
            if(mapImage == null) {
                mapImage = new Map<String, String>();
                
                for(Document objDocument : [SELECT Id, DeveloperName FROM Document WHERE FolderId IN :setIdFolder]) {
                    mapImage.put(objDocument.DeveloperName, objDocument.Id);
                }
            }

            return mapImage;
        }
        set;
    }


    /************************************************************************************
    *   문서 생성에 필요한 데이터
    *************************************************************************************/
    public List<String> listIdEmployee {
        get {
            system.debug('1 listIdEmployee');
            if(listIdEmployee == null) {
                System.debug('JSON String : ' + ApexPages.currentPage().getParameters().get('ids'));

                listIdEmployee = new List<String>();
                listIdEmployee = (List<String>) JSON.deserialize(ApexPages.currentPage().getParameters().get('ids'), List<String>.class);
                System.debug('listIdEmployee : ' + listIdEmployee);
            }
            
            return listIdEmployee;
        }
        set;
    }

    public List<String> listChildObject {
        get {
            if(listChildObject == null) {
                System.debug('JSON String : ' + ApexPages.currentPage().getParameters().get('child'));

                listChildObject = new List<String>();
                listChildObject = (List<String>) JSON.deserialize(ApexPages.currentPage().getParameters().get('child'), List<String>.class);
                System.debug('listChildObject : ' + listChildObject);
            }
            
            return listChildObject;
        }
        set;
    }


    /************************************************************************************
    *   프로필 정보 리스트
    *************************************************************************************/
    public List<Employee__c> listEmployee {
        get {
            if(listEmployee == null) {
                listEmployee = new List<Employee__c>();

                listEmployee = Database.query(getListEmployeeQuery());
                System.debug('listEmployee : ' + listEmployee);
                }          
            return listEmployee; 
        }
        set;
    }
    //2019-02-13 Ljk
    public Map<Id, AggregateResult> mapSummary {
            get {
               return new Map<Id, AggregateResult>([
                                          select    Employee_Name__c Id, min(CareerJoinDate__c) enterdate 
                                          from      Career__c 
                                          where     Employee_Name__c in : listIdEmployee
                                          Group by  Employee_Name__c]);
                }
            set;
        }

    //2019-02-13 Ljk
    public class WrapperEmployee {
        public Employee__c objEmployee {get;set;}
        public String totalCareer {get;set;}
        public WrapperEmployee(){}

        //Wrapper에서 값을 Initialize 해서 Page에서 참조하기 위해서는 해당 방식으로 값을 파라미터로 던져야한다
        //{!listWrapperEmployee.objEmployee}
        public WrapperEmployee(Employee__c objEmployee, String totalCareer){
            this.objEmployee = objEmployee;
            this.totalCareer = totalCareer;
        }
    }
    //2019-02-13 Ljk
    public List<WrapperEmployee> listWrapperEmployee {
        get {
            listWrapperEmployee = new List<WrapperEmployee>();            
            String totalCar;
            String totalCarTemp;
            if(!mapSummary.isEmpty() || mapSummary!=null){
                for(Employee__c obj : listEmployee){
                    //Id값으로 Enter 또는 Exit Date를 조회하기 때문에 이 Id 값으로 조회한 Enter,Exit Date가 없을 경우 Null Pointer Exception Error.
                    if(mapSummary.get(obj.Id) != null && mapSummary.get(obj.Id).get('enterdate')!=null){
                        Date entDate = Date.valueOf(mapSummary.get(obj.Id).get('enterdate'));
                        Date extDate = System.today();
                        //Date extDate = Date.valueOf(mapSummary.get(obj.Id).get('exitdate')) ;
                        totalCar = '총 경력'+ String.valueOf(extDate.year() - entDate.year()+1) + ' 년';
                        WrapperEmployee objEmpWrap = new WrapperEmployee(obj,totalCar);
                        listWrapperEmployee.add(objEmpWrap);


                    }else{
                        totalCarTemp = obj.WorkPeriode__c;
                        System.debug('totalCarTemp'+totalCarTemp);
                        Date enterDate = obj.JoinDate__c; 

                        if(enterDate != null){
                            Date todays = system.today();
                            //근속년수 계산 -> WorkPeriode__c 필드와 동일한 값
                            Integer monthsBetween = enterdate.monthsbetween(todays);   
                            Decimal calculatedMonth = Math.ceil(monthsBetween/12.0); 
                            totalCar = '총 경력 ' + calculatedMonth + ' 년';       

                        }else{
                            totalCar = '총 경력 1 년'; 
                        }
                        
                        WrapperEmployee objEmpWrap = new WrapperEmployee(obj,totalCar);
                        listWrapperEmployee.add(objEmpWrap);

                    }

                }
            }
                return listWrapperEmployee;


            
        }
        set;
    }

    private String getListEmployeeQuery() {
        Map<String, List<String>> mapChildFields = new Map<String, List<String>>();
        for(String sChildName : listChildObject) {
            List<String> listTemp = new List<String>();

            for(Object obj : Schema.getGlobalDescribe().get(mapChildObject.get(sChildName)).getDescribe().fields.getMap().values()) {
                listTemp.add(String.valueOf(obj));
            }

            mapChildFields.put(sChildName, listTemp);
        }

        // 쿼리 생성
        String sQuery = '';

        sQuery += 'SELECT   Id, Name, MainRole__c, toLabel(Position__c), Birthday__c,  WorkPeriode__c, DocumentPhotoId__c, JoinDate__c';
        
        for(String sChildName : listChildObject) {
            sQuery += ', (';
            sQuery += 'SELECT   ' + String.join(mapChildFields.get(sChildName), ', ');

            // 프로젝트 경력 사항
            if(sChildName == 'EmployeePerformPjt__r') {
                sQuery += ', Project__r.Name';
            }

            sQuery += '  FROM   ' + sChildName;
            if(sChildName == 'Re_Project_Career__r') sQuery += '  Order by InputDate__c desc';
            else if(sChildName == 'EmployeePerformPjt__r') sQuery += '  Order by InputDate__c desc';
            else if(sChildName == 'Re_License__r') sQuery += '  Order by AcquisitionDate__c desc';
            else if(sChildName == 'Re_Education__r') sQuery += '  Order by GraduatedDate__c desc';
            else if(sChildName == 'Re_Career__r') sQuery += '  Order by CareerJoinDate__c desc';
            sQuery += ')';
        }

        sQuery += '  FROM   Employee__c';
        sQuery += ' WHERE   Id IN :listIdEmployee';

        System.debug('Employee Query : ' + sQuery);
        return sQuery;
    }




    /************************************************************************************
    *   사원 하위 전체 오브젝트 맵
    *************************************************************************************/
    private Map<String, String> mapChildObject {
        get {
            if(mapChildObject == null) {
                mapChildObject = new Map<String, String>();

                for(Schema.ChildRelationship child : Employee__c.SObjectType.getDescribe().getChildRelationships()) {
                    mapChildObject.put(String.valueOf(child.getRelationshipName()), String.valueOf(child.getChildSObject()));
                }
            }

            return mapChildObject;
        }
        set;
    }

    public Map<String, String> mapChildLabel {
        get {
            if(mapChildLabel == null) {
                mapChildLabel = new Map<String, String>();

                for(Schema.ChildRelationship child : Employee__c.SObjectType.getDescribe().getChildRelationships()) {
                    Schema.DescribeSObjectResult describeObj = Schema.getGlobalDescribe().get(String.valueOf(child.getChildSObject())).getDescribe();

                    mapChildLabel.put(String.valueOf(child.getRelationshipName()), String.valueOf(describeObj.getLabel()));
                }
            }

            return mapChildLabel;
        }
        set;
    }
    
}