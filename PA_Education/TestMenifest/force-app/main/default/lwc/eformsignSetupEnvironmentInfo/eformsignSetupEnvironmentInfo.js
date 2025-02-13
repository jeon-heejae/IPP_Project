/**
 * Created by hs.jung on 2024-05-28.
 */

import { LightningElement, track } from 'lwc';

import getEnvironmentInfo from '@salesforce/apex/EformsignSetupCtrl.getEnvironmentInfo';
import saveEnvironmentInfo from '@salesforce/apex/EformsignSetupCtrl.saveEnvironmentInfo';
import checkEnvironmentInfo from '@salesforce/apex/EformsignSetupCtrl.checkEnvironmentInfo';

export default class EformsignSetupEnvironmentInfo extends LightningElement {

    @track isLoading = true;
    showLoading() {
        this.isLoading = true;
    }
    hideLoading() {
        this.isLoading = false;
    }

    @track isDisabled = false;

    // 설정 정보
    @track infos = {
        companyId: '',
        apiKey: '',
        privateKey: '',
        adminEmail: '',
    };

    connectedCallback() {
        console.log('connectedCallback');
        getEnvironmentInfo()
            .then(result => {
                if (!result || !Object.keys(result).length) {
                    console.log('!result ::::: ');
                    this.hideLoading();
                    return;
                }

                const infos = {
                    companyId: '',
                    apiKey: '',
                    privateKey: '',
                    adminEmail: '',
                };

                infos.companyId = result.CompanyId__c;
                infos.apiKey = result.ApiKey__c;
                infos.privateKey = result.Privatekey__c;
                infos.adminEmail = result.RepresentativeAdminEmail__c;

                this.infos = infos;

                console.log('this.infos', JSON.stringify(this.infos, null, 2));
                this.hideLoading();
            })
            .catch(error => {
                console.error(error);
                alert('초기화 실패입니다.');
                this.hideLoading();
            });
    }

    handleChange(event) {
        const field = event.target.name;
        this.infos[field] = event.target.value;
    }

    handleSave() {
        this.setDisable();
        console.log('this.infos', this.infos);
        if (
            !this.infos.companyId
            || !this.infos.apiKey
            || !this.infos.privateKey
            || !this.infos.adminEmail
        ) {
            alert('정보를 입력해주세요.');
            this.setUnDisable();
            return;
        }

        /*
         - Company ID:  f752333198f24c46ae2085e04169da1a
         - API Key:     67e63555-3414-4a8a-9d24-75619035034e
         - Private key: aa
         - Admin Email: gim@mz.co.kr
         - Base Url:    https://kr-api.eformsign.com
        */
        this.showLoading();
        saveEnvironmentInfo({
            infos: this.infos
        })
            .then(result => {
                console.log(result);
                alert('저장이 완료되었습니다.');
            })
            .catch(error => {
                console.error(error);
                alert('저장이 실패했습니다.');
                this.setUnDisable();
            })
            .finally(() => {
                this.hideLoading();
            });
    }

    checkConnention() {
        this.showLoading();
        checkEnvironmentInfo()
            .then(connected => {
                console.log('checkEnvironmentInfo result:', connected);
                if (connected) {
                    alert('저장된 정보로 eformsign에 정상적으로 연결되었습니다.');
                } else {
                    alert('연결에 실패하였습니다. 저장 정보를 확인 후 다시 저장해 주세요.');
                    this.setUnDisable();
                }
            })
            .catch(error => {
                console.error(error);
                alert('확인에 실패했습니다.');
            })
            .finally(() => {
                this.hideLoading();
            });
    }

    setDisable() {
        this.isDisabled = true;
    }

    setUnDisable() {
        this.isDisabled = false;
    }
}