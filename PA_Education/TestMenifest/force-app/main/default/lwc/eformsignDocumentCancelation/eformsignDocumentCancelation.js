/**
 * Created by hs.jung on 2024-05-31.
 */
import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import cancelDocument from '@salesforce/apex/EformsignDocumentCtrl.cancelDocument'

export default class EformsignDocumentCancelation extends LightningElement {

    @api recordId;
    _title = 'title';
    message = '';
    variant = '';

    @track comment;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }
    connectedCallback() {
    };

    handleCommentChange(event) {
        this.comment = event.target.value;
    }

    handlCancel() {
        cancelDocument({
            recordId: this.recordId,
            comment: this.comment,
        })
            .then(result =>{
                console.log('success', JSON.stringify(result, null, 2));
                this.setToastOptions('취소 완료', '문서가 취소되었습니다.', 'success');
                // setTimeout(() => {
                    // window.location.reload()
                // }, 1000);
            })
            .catch(error =>{
                console.log('error>>', JSON.stringify(error));
                this.setToastOptions('문서 취소 실패', error, 'error');
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

    setToastOptions(title, msg, variant){
        this._title = title;
        this.message = msg;
        this.variant = variant;
    }

}