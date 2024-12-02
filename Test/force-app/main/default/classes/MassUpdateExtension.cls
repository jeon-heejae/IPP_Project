// 2. Apex 컨트롤러 확장 클래스 생성
public class MassUpdateExtension {
    private List<Account> selected;
    
    public MassUpdateExtension(ApexPages.StandardSetController controller) {
        selected = (List<Account>) controller.getSelected();
    }
    
    public List<Account> getSelected() {
        return selected;
    }
    
    public PageReference updateStatus() {
        for(Account acc : selected) {
            acc.Status__c = 'Active'; // 상태를 'Active'로 변경
        }
        
        try {
            update selected;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Accounts updated successfully.'));
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error updating accounts: ' + e.getMessage()));
        }
        
        return null;
    }
}