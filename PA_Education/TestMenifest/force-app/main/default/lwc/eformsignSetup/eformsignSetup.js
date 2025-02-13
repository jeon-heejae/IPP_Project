/**
 * Created by hs.jung on 2024-05-21.
 */

import { LightningElement, track } from 'lwc';

import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class EformsignSetup extends LightningElement {

    // @track iframeURL = 'https://www.eformsign.com/eform/index.html';
    // @track isShowModal;
    // closeModalText = '창을 닫으시겠습니까?';

    @track tabManager;
    @track isShowConnection;
    @track isShowSetupManager;
    @track isShowMemberManager;
    connectedCallback() {
        this.tabManager = {
            connection : true,
            setup : true,
            member : true,
        };
    }


}