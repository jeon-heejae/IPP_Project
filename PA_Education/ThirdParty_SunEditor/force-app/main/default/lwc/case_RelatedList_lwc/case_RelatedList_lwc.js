import { LightningElement,track } from 'lwc';

export default class Case_RelatedList_lwc extends LightningElement {

    value='All';
    // 샘플 JSON 데이터
    @track requestBody = `{
        "dataCount": 11,
        "data": [
            { "accountNumber": "CD451796" },
            { "accountNumber": "CD650692" },
            { "accountNumber": "CC213425" },
            { "accountNumber": "CC634267" },
            { "accountNumber": "CD439877" }
        ]
    }`;

    columns = [
        { label: 'Name', fieldName: 'name' },
        { label: 'Request Date/Time', fieldName: 'requestDate', type: 'dateTime' },
        { label: 'Resoponse Date/Time', fieldName: 'responseDate', type: 'dateTime' },
        { label: 'Status', fieldName: 'status' }
    ];
    

    get options() {
        return [
            { label: 'ERROR', value: 'ERROR' },
            { label: 'SUCCESS', value:'SUCCESS' },
            { label: 'All', value: 'All' },
        ];
    }

    renderedCallback(){ //dom이 완전히 렌더링 된 후
        const style=document.createElement('style');
        style.innerText=`
        lightning-button-icon .slds-button_icon {
            color: var(--slds-c-button-text-color, var(--sds-c-button-text-color, var(--lwc-brandAccessible, rgba(1, 118, 211, 1))));
        }
        `
        this.template.querySelector('lightning-tabset').appendChild(style);
        this.initializeComponent();
    }

    initializeComponent(){
        const textarea = this.template.querySelector('.custom-textarea');
        if (textarea) {
            textarea.value = this.requestBody; // Textarea에 값 설정
            console.log('success');
        }
        console.log('textarea value: '+textarea);
    }

    handleChange(event) {
        this.value = event.detail.value;
    }

    handleCopy(){
        const copyText=this.template.querySelector('.custom-textarea');

        // 텍스트 길이 가져오기
        const textLength = copyText.value.length;
        console.log('text length: '+textLength);

        //Select the text field
        copyText.select();
        copyText.setSelectionRange(0, textLength); 
        

        // Copy the text inside the text field
        navigator.clipboard.writeText(copyText.value);

        // Alert the copied text
        alert("Copied the text: " + copyText.value);
    }

    handleDownload(){
        const textarea = this.template.querySelector('.custom-textarea');
        if (textarea) {
            const element = document.createElement('a');
            const file = new Blob([textarea.value], { type: 'text/plain' });
            element.href = URL.createObjectURL(file);
            element.download = 'Request_Body.txt';
        
            element.click();
            URL.revokeObjectURL(element.href);
            
        }
    }
    
}