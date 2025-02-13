import { LightningElement, track } from 'lwc';
import dnb_MenuInformation from '@salesforce/label/c.dnb_MenuInformation';

export default class Dnb_selectProduct extends LightningElement {
    @track isModalOpen = false;

    optionsPicklist = [
        { label: 'N', value: 'no' },
        { label: 'Y', value: 'yes' },
    ];

    label = {dnb_MenuInformation};

    handleCycleChange(event) {
        this.selectedCycle = event.detail.value;
    }

    handleViewClick() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }
    
}