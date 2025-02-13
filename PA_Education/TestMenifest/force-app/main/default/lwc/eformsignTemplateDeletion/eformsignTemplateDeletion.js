/**
 * Created by hs.jung on 2024-05-31.
 */

import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord } from 'lightning/uiRecordApi';

import deleteTemplate from '@salesforce/apex/EformsignTemplateCtrl.deleteTemplate';
import TEMPLATE_ID from '@salesforce/schema/EformsignTemplate__c.TemplateId__c';

export default class EformsignTemplateDeletion extends NavigationMixin(LightningElement) {
    @api recordId; // 레코드 ID
    templateId;
    isLoading = false;

    @wire(getRecord, { recordId: '$recordId', fields: [TEMPLATE_ID] })
    wiredRecord({ error, data }) {
        if (data) {
            this.templateId = data.fields.TemplateId__c.value;
        } else if (error) {
            // 에러 처리
            console.error(error);
        }
    }

    deleteRecord() {
        this.isLoading = true;
        deleteTemplate({ templateId: this.templateId })
            .then(result => {
                console.log('success>>', result);
                alert('eformsign의 템플릿이 삭제되었습니다.');
                // this.closeComponent(); // 컴포넌트 닫기
                this.navigateToListView();
            })
            .catch(error => {
                /*
                    {
                        "status": 500,
                        "body": {
                            "exceptionType": "System.MathException",
                            "isUserDefinedException": false,
                            "message": "Divide by 0",
                            "stackTrace": "Class.EformsignTemplateCtrl.deleteTemplate: line 5, column 1"
                        },
                        "headers": {},
                        "ok": false,
                        "statusText": "Server Error",
                        "errorType": "fetchResponse"
                    }
                */
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
                objectApiName: 'EformsignTemplate__c', // 오브젝트 API 이름
                actionName: 'list'
            },
            // state: {
            //     filterName: 'Recent' // 필터 이름 (옵션)
            // }
        });
    }
}