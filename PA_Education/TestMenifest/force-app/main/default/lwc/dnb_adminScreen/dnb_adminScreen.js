import { LightningElement, track, wire } from 'lwc';
import dnb_administratorTitle from '@salesforce/label/c.dnb_administratorTitle';
import dnb_automaticRenewal from '@salesforce/label/c.dnb_automaticRenewal';
import dnb_category from '@salesforce/label/c.dnb_category';
import dnb_noted from '@salesforce/label/c.dnb_noted';
import dnb_productInUse from '@salesforce/label/c.dnb_productInUse';
import dnb_settings from '@salesforce/label/c.dnb_settings';
import dnb_totalBillingAmountForMonth from '@salesforce/label/c.dnb_totalBillingAmountForMonth';
import dnb_unusedProduct from '@salesforce/label/c.dnb_unusedProduct';
import dnb_usageWarning from '@salesforce/label/c.dnb_usageWarning';

export default class Dnb_adminScreen extends LightningElement {
    @track data = [
        {
            id: 1,
            category: '총계',
            automaticRenewal: 'N/A',
            productInUse: 17,
            unusedProduct: 26,
            totalBillingAmountForMonth: '###,###원',
            usageWarning: '● 초과'
        },
        {
            id: 2,
            category: '기업개요 (주요)',
            automaticRenewal: '매분기 (1일 0시)',
            productInUse: 2,
            unusedProduct: 1,
            totalBillingAmountForMonth: '##,###원',
            usageWarning: '● 주의'
        },
        {
            id: 3,
            category: '기업개요 (세부)',
            automaticRenewal: '매년 (4월 1일 0시)',
            productInUse: 3,
            unusedProduct: 7,
            totalBillingAmountForMonth: '##,###원',
            usageWarning: '● 정상'
        },
        {
            id: 4,
            category: '맞춤정보',
            automaticRenewal: '미사용',
            productInUse: 0,
            unusedProduct: 7,
            totalBillingAmountForMonth: '0원',
            usageWarning: '● 정상'
        },
        {
            id: 5,
            category: '특화정보',
            automaticRenewal: '미사용',
            productInUse: 0,
            unusedProduct: 7,
            totalBillingAmountForMonth: '0원',
            usageWarning: '● 정상'
        },
        {
            id: 6,
            category: '등급정보',
            automaticRenewal: '매분기 (1일 0시)',
            productInUse: 3,
            unusedProduct: 1,
            totalBillingAmountForMonth: '##,###원',
            usageWarning: '● 정상'
        },
        {
            id: 7,
            category: '재무정보',
            automaticRenewal: '매분기 (1일 0시)',
            productInUse: 3,
            unusedProduct: 0,
            totalBillingAmountForMonth: '##,###원',
            usageWarning: '● 정상'
        },
        {
            id: 8,
            category: '기업신용정보',
            automaticRenewal: '매일 (0시)',
            productInUse: 6,
            unusedProduct: 0,
            totalBillingAmountForMonth: '##,####원',
            usageWarning: '● 초과'
        },
        {
            id: 9,
            category: '영문정보',
            automaticRenewal: '미사용',
            productInUse: 0,
            unusedProduct: 3,
            totalBillingAmountForMonth: '0원',
            usageWarning: '● 정상'
        }
    ];
    @track columns = [
        { label: dnb_category, fieldName: 'category' },
        { label: dnb_automaticRenewal, fieldName: 'automaticRenewal' },
        { label: dnb_productInUse, fieldName: 'productInUse' },
        { label: dnb_unusedProduct, fieldName: 'unusedProduct' },
        { label: dnb_totalBillingAmountForMonth, fieldName: 'totalBillingAmountForMonth' },
        { label: dnb_usageWarning, fieldName: 'usageWarning' }
    ];
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    @track title = dnb_administratorTitle;
    @track noted = dnb_noted;
    @track setting = dnb_settings;
    
    // sortBy(field, reverse, primer) {
    //     const key = primer
    //         ? function (x) {
    //               return primer(x[field]);
    //           }
    //         : function (x) {
    //               return x[field];
    //           };

    //     return function (a, b) {
    //         a = key(a);
    //         b = key(b);
    //         return reverse * ((a > b) - (b > a));
    //     };
    // }

    // onHandleSort(event) {
    //     const { fieldName: sortedBy, sortDirection } = event.detail;
    //     const cloneData = [...this.data];

    //     cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
    //     this.data = cloneData;
    //     this.sortDirection = sortDirection;
    //     this.sortedBy = sortedBy;
    // }
}