public class PrintContactController {
    @AuraEnabled
    public static Map<String, Object> getContactInfo(Id contactId) {
        Contact con = [SELECT Id, Name, Email, Phone FROM Contact WHERE Id = :contactId];
        //List<String> skills = getSkills(contactId);  // 이 메서드는 별도로 구현해야 합니다
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('contact', con);
        //result.put('skills', skills);
        
        return result;
    }
    
    // PDF 생성을 위한 메서드 (Visualforce 페이지에서 사용)
    public Contact contact { get; set; }
    public List<String> skills { get; set; }
    
    public PrintContactController() {
        Id contactId = ApexPages.currentPage().GetParameters().get('recordId');
        contact = [SELECT Id, Name, Email, Phone FROM Contact WHERE Id = :contactId];
        //skills = getSkills(contactId);
    }
    
    private static List<String> getSkills(Id contactId) {
        // 여기에 스킬을 가져오는 로직을 구현합니다.
        // 예를 들어, 관련 객체에서 스킬 정보를 조회하거나 하드코딩할 수 있습니다.
        return new List<String>{'PPT', 'XD', 'XL', 'GA', 'PY'};
    }
}