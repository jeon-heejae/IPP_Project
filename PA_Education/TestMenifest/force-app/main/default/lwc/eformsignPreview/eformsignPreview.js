/**
 * Created by hs.jung on 2024-05-31.
 */

import { LightningElement, api, wire, track } from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getDocument from '@salesforce/apex/EformsignDocumentCtrl.getDocument'

export default class EformsignPreview extends LightningElement {
    @api recordId;
    @track iframeSrc;
    closeModalText = '창을 닫으시겠습니까?';
    isLoaded = false;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }
    renderedCallback(){
        if(this.isLoaded) return;
        const STYLE = document.createElement("style");
        STYLE.innerText =  `.uiModal--medium .modal-container{
           width: 100% !important;
           max-width: 100%;
           min-width: 100%;
        }`;
        this.template.querySelector('section').appendChild(STYLE);
        this.isLoaded=true;
    }

    connectedCallback() {
        console.log('origin');
        console.log(window.location.origin);
        window.requestAnimationFrame(() => {
            this.template.addEventListener('click', this.handleOutsideClick);
        });
        getDocument({recordId: this.recordId})
        .then(result =>{
            console.log('리절트임');
            console.log(result);
            this.showToast('로딩 중', '미리보기를 불러오는 중입니다.\n잠시만 기다려주세요.', 'success');
            this.iframeSrc = window.location.origin
                            + '/apex/EformsignDocument?documentId=' + result.DocumentId__c
                            + '&templateId='  + result.EformsignTemplate__r.TemplateId__c;
        })
        .catch(error =>{
            console.log('에러임');
            this.showToast('미리보기 요청 실패', error, 'error');
        })
    }

    closeModalButton(){
        if(!confirm(this.closeModalText)) return;
        this.closeModal();
    }

    handleOutsideClick = (event) => {
        if(this.template.querySelector('.slds-modal__container').contains(event.target)) return;
        if(confirm(this.closeModalText)){
            this.closeModal();
        }
    };

    closeModal(){
        this.template.removeEventListener('click', this.handleOutsideClick);
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}