/**
 * Created by hs.jung on 2024-05-31.
 문서 상태 업데이트 호출용 lwc
 */


 import { LightningElement, api, wire } from 'lwc';
 import {CurrentPageReference} from 'lightning/navigation';
 import { CloseActionScreenEvent } from 'lightning/actions';
 import { ShowToastEvent } from "lightning/platformShowToastEvent";
 import getDocumentInfo from '@salesforce/apex/EformsignDocumentCtrl.syncDocumentInfo'

export default class EformsignDocumentInfoSync extends LightningElement {
    isLoading = false;
    @api recordId;
    _title = 'title';
    message = '';
    variant = '';

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }
    connectedCallback() {
        this.isLoading = true;
        getDocumentInfo({recordId: this.recordId})
        .then(result =>{
            console.log('success');
            this.setToastOptions('동기화 완료', '최신 상태로 업데이트되었습니다.', 'success');
            setTimeout(() => {
                window.location.reload()
            }, 1000);
        })
        .catch(error =>{
            console.log('error>>', JSON.stringify(error));
            this.setToastOptions('동기화 실패', error, 'error');
        })
        .finally(() => {
            this.isLoading = false;
            const evt = new ShowToastEvent({
                                title: this._title,
                                message: this.message,
                                variant: this.variant,
                            });
            this.dispatchEvent(evt);
            this.dispatchEvent(new CloseActionScreenEvent());
        });
    };

    setToastOptions(title, msg, variant){
        this._title = title;
        this.message = msg;
        this.variant = variant;
    }
}