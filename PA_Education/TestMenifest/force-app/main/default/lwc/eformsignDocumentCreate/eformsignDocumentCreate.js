/**
 * Created by hs.jung on 2024-05-22.
 */


import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import jQuery from '@salesforce/resourceUrl/jQuery';
// import efs_embedded_js from '@salesforce/resourceUrl/efs_embedded_js';
import getRelatedTemplatesBySObject from '@salesforce/apex/EformsignDocumentCtrl.getRelatedTemplatesBySObject'

export default class EformsignDocument extends LightningElement {
    @api recordId;
    @api objectApiName;

    isShowModal = false;
    @track isOptionsLoaded = false;
    @track templateOptions = [];
    @track label = '템플릿을 선택하여 주세요.';

    templateRecordId;
    templateId;
    templateName;
    @track iframeSrc;

    closeModalText = '창을 닫으시겠습니까?';
    boundHandleMessage;

    connectedCallback() {
        this.boundHandleMessage = this.handleMessage.bind(this);
        window.addEventListener('message', this.boundHandleMessage, false);
        this.searchTemplates();
    }

    disconnectedCallback() {
        window.removeEventListener('message', this.boundHandleMessage, false);
        this.template.removeEventListener('click', this.handleOutsideClick);
    }

    get isOptionsNotLoaded() {
        return !this.isOptionsLoaded;
    }

    searchTemplates() {
        getRelatedTemplatesBySObject({
            objectApiName: this.objectApiName
        })
        .then(result => {
            console.log('result.length', result.length);
            console.log('this.templateOptions', this.templateOptions);
            if (result.length == 0) {
                this.showToast('선택가능한 템플릿 없음', '선택 가능한 템플릿이 없습니다.\n관리자에게 문의하세요.', 'warning');
                this.label = '선택가능한 템플릿 없음';
                return;
            }

            const options = result.map(template => {
                return { label: template.Name, value: template.Id + '/' + template.TemplateId__c }
            });
            this.templateOptions = options;
            this.isOptionsLoaded = true;
            console.log('this.templateOptions', this.templateOptions);
        })
        .catch(error => {
            console.log('error', error);
            this.showToast('템플릿 불러오기 오류', '템플릿을 불러오는 중 문제가 발생했습니다.', 'error');
        });
    }

    handleMessage(event) {
        console.log('event.data.result', event.data.result);
        console.log('event.data.state', event.data.state);
        if (event.data.state === 'close') {
            console.log(event.data);
            this.showToast('문서 발송', event.data.result, event.data.result);
            setTimeout(() => {
                this.closeModal();
            }, 3000);
        }
    }

    handleOption(event) {
        const selectedValue = event.detail.value;
        const [templateRecordId, templateId] = selectedValue.split('/');
        this.templateRecordId = templateRecordId;
        this.templateId = templateId;

        const selectedOption = this.templateOptions.find(option => option.value === selectedValue);
        this.templateName = selectedOption.label;

        this.iframeSrc = window.location.origin + '/apex/EformsignDocument'
            + `?templateId=${this.templateId}`
            + `&recordId=${this.recordId}`
            + `&templateRecordId=${this.templateRecordId}`
            + `&objectApiName=${this.objectApiName}`;
    }

    showModalBox() {
        if (!this.templateId) {
            this.showToast('템플릿 선택', '템플릿을 선택하여주세요.', 'warning');
            return;
        }

        this.showToast('문서 생성','문서작성을 시작합니다.','info');
        this.isShowModal = true;
        window.requestAnimationFrame(() => {
            this.template.addEventListener('click', this.handleOutsideClick);
        });
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    // start: 문서 작성 화면 종료 관련 메소드
    closeModalButton() {
        if (confirm(this.closeModalText)) {
            this.closeModal();
        }
    }

    handleOutsideClick = (event) => {
        console.log('event.target', event.target);
        if (this.template.querySelector('.slds-modal__container').contains(event.target)) {
            return;
        }

        if (confirm(this.closeModalText)) {
            this.closeModal();
        }
    };

    closeModal() {
        this.isShowModal = false;
        this.template.removeEventListener('click', this.handleOutsideClick);
    }
    // End: 문서 작성 화면 종료 관련 메소드
}