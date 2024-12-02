import { LightningElement, api, wire } from 'lwc';
import { MessageContext } from 'lightning/messageService';

// Constants for CSS classes
const TILE_WRAPPER_SELECTED_CLASS = 'tile-wrapper selected';
const TILE_WRAPPER_UNSELECTED_CLASS = 'tile-wrapper';

export default class BoatTile extends LightningElement {
    @api boat;
    @api selectedBoatId;

    @wire(MessageContext)
    messageContext;

    // Getter for dynamically setting the background image
    get backgroundStyle() {
        return `background-image:url('${this.boat.Picture__c}')`;
    }
    
    // Getter for dynamically setting the tile class
    get tileClass() {
        return this.boat.Id === this.selectedBoatId ? 
            TILE_WRAPPER_SELECTED_CLASS : TILE_WRAPPER_UNSELECTED_CLASS;
    }
    
    // Fires event with the Id of the boat that has been selected
    selectBoat() {
        this.selectedBoatId = this.boat.Id;
        const boatselect = new CustomEvent('boatselect', {
            detail: {
                boatId: this.boat.Id
            }
        });
        this.dispatchEvent(boatselect);
    }
}