import { LightningElement, track, wire } from 'lwc';
import sendSurveyEmails from '@salesforce/apex/SurveyEmailController.sendSurveyEmails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SurveyEmailSender extends LightningElement {
    @track isLoading = false;

    handleSendEmails() {
        this.isLoading = true;
        sendSurveyEmails()
            .then(result => {
                this.showToast('성공', '설문조사 이메일이 성공적으로 전송되었습니다.', 'success');
            })
            .catch(error => {
                this.showToast('오류', '이메일 전송 중 오류가 발생했습니다: ' + error.body.message, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}