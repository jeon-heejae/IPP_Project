/**
 * Created by hs.jung on 2024-05-31.
 */

/**
 * Created by MZC01-BEN on 2023-11-08.
 */
import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { getRecord } from 'lightning/uiRecordApi';
import DOCUMENT_CURRENT_STATUS from '@salesforce/schema/EformsignDocument__c.DocumentCurrentStatus__c';

import getDocument from '@salesforce/apex/EformsignDocumentCtrl.getDocument'
import download from '@salesforce/apex/EformsignDocumentCtrl.downloadDocument'

export default class EformsignDocumentDownload extends LightningElement {
    @api recordId;
    @track isCompleted = false;
    hasAudit = false;

    @wire(getRecord, { recordId: '$recordId', fields: [DOCUMENT_CURRENT_STATUS] })
    wiredRecord({ error, data }) {
        if (data) {
            console.log('data', data);
            console.log('wiredRecord');
            console.log(data.fields.DocumentCurrentStatus__c.value == '003');
            console.log(data.fields.DocumentCurrentStatus__c.value);
            this.isCompleted = (data.fields.DocumentCurrentStatus__c.value == '003');
        } else if (error) {
            // 에러 처리
            console.error(error);
        }
    }

    // ToDo: 리펙토링 완료로 삭제 예정
    // documentInfo;
    // @wire(CurrentPageReference)
    // getStateParameters(currentPageReference) {
    //     if (!currentPageReference) {
    //         return;
    //     }
    //     console.log('currentPageReference.state.recordId:', currentPageReference.state.recordId);
    //     this.recordId = currentPageReference.state.recordId;

    //     getDocument({
    //         recordId: this.recordId
    //     })
    //     .then(result => {
    //         console.log('result', result);
    //         this.documentInfo = result;
    //         this.isCompleted = (result.DocumentCurrentStatus__c == '003');
    //     })
    //     .catch(error => {
    //         this.setToastOptions('화면 로드에 실패하였습니다.', error, 'error');
    //     })
    //     .finally(() => {
    //         console.log(this.documentInfo);
    //     });
    // }

    connectedCallback() {
        console.log('connectedCallback');
    };

    handleCheckboxChange(event) {
        this.hasAudit = event.target.checked;
        console.log('this.hasAudit: ', this.hasAudit);
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    _title = 'title';
    message = '';
    variant = '';
    handleDownload() {
        //TODO future => 직렬처리 변경 시 결과 출력 및 새로고침 필요
        console.log('this.recordId:', this.recordId);
        console.log('this.hasAudit:', this.hasAudit);
        download({
            recordId: this.recordId
            , hasAudit: this.hasAudit
        })
        .then(result => {
            console.log('result');
            console.log(result);
            this.setToastOptions(
                '다운로드 요청 완료'
                , '다운로드 중입니다. \n 잠시 후 페이지를 새로고쳐주세요.'
                , 'success'
            );

            try {
                // 로컬 다운로드 처리
                const url = window.location.origin + '/sfc/servlet.shepherd/document/download/' + result.data
                const a = document.createElement('a');
                a.href = url;
                a.click();
                a.remove();
                // getFileBodyTest({ recId: this.recordId })
                //     .then(result => {
                //         //interval 없을 경우 다운로드 건너뛰는 이슈로 timeout.
                //         result.forEach((eachId, idx) => {
                //             setTimeout(() => {
                //                 const url = window.location.origin + '/sfc/servlet.shepherd/document/download/' + eachId
                //                 const a = document.createElement('a');
                //                 a.href = url;
                //                 a.click();
                //                 a.remove();
                //             }, idx * 800);
                //         });
                //     })
            } catch (e) {
                this.setToastOptions('다운로드에 실패하였습니다.', error, 'error');
                console.log('error occurred while download files into local');
                console.log(e);
            }
        })
        .catch(error => {
            this.setToastOptions('다운로드에 실패하였습니다.', error, 'error');
        })
        .finally(() => {
            const evt = new ShowToastEvent({
                title: this._title,
                message: this.message,
                variant: this.variant,
            });
            this.dispatchEvent(evt);
            this.dispatchEvent(new CloseActionScreenEvent());
        });
    }

    setToastOptions(title, msg, variant) {
        this._title = title;
        this.message = msg;
        this.variant = variant;
    }
}