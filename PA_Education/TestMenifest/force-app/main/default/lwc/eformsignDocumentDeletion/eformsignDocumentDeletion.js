/**
 * Created by hs.jung on 2024-05-31.
 */

import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

import deleteDocument from '@salesforce/apex/EformsignDocumentCtrl.deleteDocument';

export default class EformsignDocumentDeletion extends NavigationMixin(LightningElement) {
    @api recordId; // 레코드 ID
    templateId;
    isLoading = false;

    deleteRecord() {
        this.isLoading = true;
        deleteDocument({ recordId: this.recordId })
            .then(result => {
                console.log('success>>', JSON.stringify(result, null, 2));
                alert('eformsign의 문서가 삭제되었습니다.');
                this.closeComponent(); // 컴포넌트 닫기
                this.navigateToListView();
            })
            .catch(error => {
                console.log('error>>', JSON.stringify(error, null, 2));
                alert('삭제 중 오류 발생\n' + error.body.message);
                this.closeComponent(); // 컴포넌트 닫기
            });
    }

    // LWC 컴포넌트 닫기
    closeComponent() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    navigateToListView() {
        // 오브젝트 리스트뷰로 리디렉션
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'EformsignDocument__c', // 오브젝트 API 이름
                actionName: 'list'
            },
            // state: {
            //     filterName: 'Recent' // 필터 이름 (옵션)
            // }
        });
    }

}