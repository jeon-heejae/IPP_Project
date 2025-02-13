({
    // 컴포넌트 초기화 시 버튼 활성화/비활성화 상태를 체크
    // doInit: function(component, event, helper) {
    //     console.log('doInit js 컨트롤러 시작.');
    //     helper.checkInterviewButtonStatus(component);  // 초기화 시 버튼 상태를 체크
    // },

    // 업무일지 생성 버튼 클릭 시
    createWorkNotes: function(component, event, helper) {
        var url = '/lightning/o/DailyTraining__c/new';
        window.open(url, '_blank');  // 업무일지 생성 페이지 열기
    }
})