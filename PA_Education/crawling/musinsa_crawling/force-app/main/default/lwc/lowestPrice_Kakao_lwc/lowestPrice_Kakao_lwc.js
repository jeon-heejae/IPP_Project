import { LightningElement, track } from 'lwc';
import sendProductInfo from '@salesforce/apex/KakaoTalkNotifier.sendProductInfo';
import saveKeyword from '@salesforce/apex/KakaoTalkNotifier.saveKeyword';
import scheduleDailyJob from '@salesforce/apex/KakaoMessageSchedulerController.scheduleDailyJob';


export default class KakaoLogin extends LightningElement {
    @track query = '';
    @track isLoading = false;
    @track requestBody = ''; // 요청 본문
    @track responseBody = ''; // 응답 본문

    @track loginUrl; // Kakao login URL

    openKakaoLogin() {
        const clientId = 'b01d65589185dedc1c0c56f172202ae0';
        const redirectUri = 'https://daeunextier-1f-dev-ed--c.develop.vf.force.com/apex/KakaoRedirectPage'; // Salesforce Visualforce Page
        this.loginUrl = `https://kauth.kakao.com/oauth/authorize?response_type=code&client_id=${clientId}&redirect_uri=${redirectUri}`;
        // Open Kakao login in a new tab or redirect the browser
        window.location.href = this.loginUrl;
    }

    handleQueryChange(event) {
        this.query = event.target.value;
    }

    handleRegister(){
        if(!this.query.trim()){
            alert('검색어를 먼저 입력하세요');
            return;
        }
        
        saveKeyword({ strKeyword: this.query })
            .then((result) => {
                if (result) {
                    console.log('검색어 저장 성공')
                    this.registerSchedule();
                } else {
                    console.log('검색어 저장 실패')
                }
            })
            .catch((error) => {
                console.error('Error:', error);
                alert('검색어 저장 중 오류가 발생했습니다.');
            });
            
    }

    registerSchedule() {
        //this.isScheduling = true;

        const jobName = 'Kakao_Notification_Job';
        const cronExpression = '0 30 17 * * ?'; // 매일 오후 5시 30분

        scheduleDailyJob({ jobName, cronExpression })
            .then((result) => {
                if (result) {
                    alert('스케줄러가 성공적으로 등록되었습니다.');
                } else {
                    alert('스케줄러 등록에 실패했습니다.');
                }
            })
            .catch((error) => {
                console.error('Error:', error);
                alert('스케줄러 등록 중 오류가 발생했습니다.');
            })
            .finally(() => {
                //this.isScheduling = false;
            });
    }
    handleSend() {
        if (!this.query) {
            alert('검색어를 입력해주세요.');
            return;
        }

        this.isLoading = true;
        sendProductInfo({ query: this.query })
            .then((result) => {
                console.log('request: '+result.requestBody);
                console.log('response: '+result.responseBody);
                this.requestBody = result.requestBody;
                this.responseBody = result.responseBody;
            })
            .catch((error) => {
                console.log('request: '+result.requestBody);
                console.log('response: '+result.responseBody);
                this.requestBody = result.requestBody;
                this.responseBody = `Error: ${error.body.message}`;
                console.error('Error:', error);
                alert('메시지 전송 중 오류가 발생했습니다: ' + error.body.message);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    
}
