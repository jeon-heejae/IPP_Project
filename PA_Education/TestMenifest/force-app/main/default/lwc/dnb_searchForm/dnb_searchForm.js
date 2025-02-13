import { LightningElement, track } from 'lwc';
import dnb_searchFormTitle from '@salesforce/label/c.dnb_searchFormTitle';


export default class Dnb_searchForm extends LightningElement {
    label = {dnb_searchFormTitle};

    @track grpNm = '';
    @track cmpNm = '';
    @track corpNo = '';
    @track bizNo = '';
    @track adr = '';
    @track city = '';
    @track salesAmt = '';
    @track industryMajor = '';
    @track industryMiddle = '';
    @track industryMinor = '';
    @track industrySubMinor = '';
    @track data = [];

    adrOptions = [
        // Add options for address
    ];

    cityOptions = [
        // Add options for city
    ];

    salesAmtOptions = [
        { label: '10억 미만', value: '10억 미만' },
        { label: '10억 이상 ~ 50억 미만', value: '10억 이상 ~ 50억 미만' },
        { label: '50억 이상 ~ 100억 미만', value: '50억 이상 ~ 100억 미만' },
        { label: '100억 이상 ~ 500억 미만', value: '100억 이상 ~ 500억 미만' },
        { label: '500억 이상 ~ 1,000억 미만', value: '500억 이상 ~ 1,000억 미만' },
        { label: '1,000억 이상 ~ 5,000억 미만', value: '1,000억 이상 ~ 5,000억 미만' },
        { label: '5,000억 이상 ~ 1조 미만', value: '5,000억 이상 ~ 1조 미만' },
        { label: '1조 이상', value: '1조 이상' },
    ];

    industryMajorOptions = [
        // Add options for industry major
    ];

    industryMiddleOptions = [
        // Add options for industry middle
    ];

    industryMinorOptions = [
        // Add options for industry minor
    ];

    industrySubMinorOptions = [
        // Add options for industry sub minor
    ];

    columns = [
        { label: '기업명', fieldName: 'cmpNm', type: 'text' },
        { label: '대표자명', fieldName: 'ceoNm', type: 'text' },
        { label: '산업군', fieldName: 'indNm', type: 'text' },
        { label: '법인등록번호', fieldName: 'corpNo', type: 'text' },
        { label: '사업자등록번호', fieldName: 'bizNo', type: 'text' },
        { label: '매출액', fieldName: 'salesAmt', type: 'currency' },
        { label: '신용등급', fieldName: 'criGrd', type: 'text' },
        { label: '현금흐름등급', fieldName: 'cashGrd', type: 'text' },
        { label: '등급평가일', fieldName: 'crDate', type: 'date' }
    ];

    handleInputChange(event) {
        const field = event.target.dataset.id;
        this[field] = event.target.value;
    }

    handleSearch() {
        // Add logic to perform search and update this.data
    }
}