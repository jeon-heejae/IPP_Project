import { LightningElement, api, wire } from 'lwc';
import getContactsBornAfter from '@salesforce/apex/ContactController.getContactsBornAfter';
export default class WireApexProperty extends LightningElement {
    @api minBirthDate; //minBirthDate 속성에 날짜 전달
    @wire(getContactsBornAfter, { birthDate: '$minBirthDate' }) //메서드 인자로 전달 및 실행
    contacts; //getContactsBornAfter 결과가 저장
    //apex 실행 후 반환된 contacts의 해당 데이터를 LDS 캐시에 저장. 
    //$minBirthDate는 반응형이기 때문에 값이 변경될 때마다 Apex 메서드가 실행되고 캐시나 서버에서 새 데이터를 공급합니다.
}