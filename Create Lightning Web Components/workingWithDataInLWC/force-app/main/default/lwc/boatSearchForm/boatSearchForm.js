// imports
import { LightningElement,wire } from 'lwc';
// import getBoatTypes from the BoatDataService => getBoatTypes method';
import getBoatTypes from '@salesforce/apex/BoatDataService.getBoatTypes';

export default class BoatSearchForm extends LightningElement {
    selectedBoatTypeId = '';
    
    // Private
    error = undefined;
    
    searchOptions;
    
    // Wire a custom Apex method
    @wire(getBoatTypes)
    

      wiredBoatTypes({ errors, data }) {
      if (data) {
        this.searchOptions = data.map(type => {
          // TODO: complete the logic
          return {
            label: type.Name,
            value: type.Id
          };
        });
        this.searchOptions.unshift({ label: 'All Types', value: '' });
      } else if (errors) {
        this.searchOptions = undefined;
        this.error = errors;
      }
    }
    
    // Fires event that the search option has changed.
    // passes boatTypeId (value of this.selectedBoatTypeId) in the detail
    handleSearchOptionChange(event) {
      // console.log을 사용하여 event.detail을 로그로 출력
      console.log('Search option changed:', event.detail);
      
      // event.detail.value가 존재하는지 확인
      this.selectedBoatTypeId = event.detail.value;
      
      // selectedBoatTypeId 값을 로그로 출력
      console.log('Selected Boat Type Id:', this.selectedBoatTypeId);
      
      // 이벤트 디스패치 전에 로그 출력
      console.log('Dispatching search event');
      
      // Create the const searchEvent
      const searchEvent = new CustomEvent('search', {
          detail: { boatTypeId: this.selectedBoatTypeId }
      });
      this.dispatchEvent(searchEvent);
      
      // 이벤트 디스패치 후 로그 출력
      console.log('Search event dispatched');
  }
  }
  