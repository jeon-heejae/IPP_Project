/**
 * Created by hs.jung on 2024-05-29.
 */

import { LightningElement } from 'lwc';

export default class EformsignSetupAdminConnection extends LightningElement {
    openSite() {
        // 여기에 원하는 URL 지정
        const url = 'https://www.eformsign.com/login.html';
        window.open(url, '_blank');
    }
}