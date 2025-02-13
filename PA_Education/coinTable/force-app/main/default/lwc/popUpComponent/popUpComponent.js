import { LightningElement,track } from 'lwc';

export default class Popup extends LightningElement {
    // showPopup = true; // 팝업창 표시 여부
    @track isShowModal = true;

    // connectedCallback() {
    //     const hidePopup = localStorage.getItem('hidePopup');
    //     const expiry = localStorage.getItem('expiry');
    //     const now = new Date().getTime();
    
    //     if (hidePopup === 'true' && expiry > now) {
    //         this.showPopup = false;
    //     } else {
    //         localStorage.removeItem('hidePopup');
    //         localStorage.removeItem('expiry');
    //     }
    // }
    

    handleCheckboxChange(event) {
        const isChecked = event.target.checked;
        if (isChecked) {
            // 체크박스가 선택되었을 때 localStorage에 저장
            const now = new Date();
            const tomorrow = new Date();
            tomorrow.setDate(now.getDate() + 1);
            const expiry = tomorrow.getTime();

            localStorage.setItem('hidePopup', 'true');
            localStorage.setItem('expiry', expiry.toString());
        }
        else{
            localStorage.removeItem('hidePopup');
            localStorage.removeItem('expiry');
        }
    }

    closePopup() {
        this.showPopup = false; // 팝업창 닫기
    }

    

    showModalBox() {  
        this.isShowModal = true;
    }

    hideModalBox() {  
        this.isShowModal = false;
    }
}
