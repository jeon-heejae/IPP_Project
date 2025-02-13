/**
 * Created by hs.jung on 2024-06-07.
 */


import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getRelatedDocs from '@salesforce/apex/EformsignDocumentCtrl.getRelatedDocs';

export default class EformsignRelatedDocuments extends LightningElement {
    @api recordId;
    @track noData;
    @track recordNum;
    relatedRecords;

    columns = [
        { label: 'Name', fieldName: 'nameUrl',
          type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_self' }},
        { label: '문서 현재 상태', fieldName: 'DocumentCurrentStatus__c' },
    ]
    /*
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                                { label: 'Edit', name: 'edit' },
                                { label: 'Delete', name: 'delete' }
                            ]
            }
        }
    */

    @wire(getRelatedDocs, { recordId: '$recordId' })
    wiredRecords({ error, data }) {
        console.log('wiredRecords');
        console.log(data);
        if (data) this.recordNum = data.length;
        if (data && data.length > 0) {
            this.relatedRecords = data.map(row => ({
                ...row,
                nameUrl: `/${row.Id}`
            }));

        } else{
            //TODO 오류/undefined 처리
            this.noData = true;
            console.log('this.noData', this.noData);
        }
    }
    /*
    handleRowAction(event) {
        const row = event.detail.row;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: row.Id,
                actionName: 'view'
            }
        });
    }
    */
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        switch (actionName) {
            case 'Edit':
                console.log('상세보기 딸깍!');
                this.viewDetails(row);
                break;
            // 기타 액션
        }
    }

    viewDetails(row) {
        // 'Details' 버튼에 대한 로직 구현
    }

    handleViewAll(event){
        console.log('handleViewAll 딸깍');
    }
}