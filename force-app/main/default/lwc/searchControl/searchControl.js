import { LightningElement, api } from 'lwc';

export default class SearchControl extends LightningElement {

    @api debounce = 500;
    @api classes;
    @api label = "Search for: ";

    timeoutID;

    receiveKeyUpEvent(event) {
        if (this.timeoutID) {
            clearTimeout(this.timeoutID);
        }

        const value = event.currentTarget.value;

        if (value.length === 1) {
            return;
        }
        
        this.timeoutID = setTimeout(() => {
            this.emitSearchEvent(value);
        }, this.debounce);
    }

    emitSearchEvent(value) {
        this.dispatchEvent(new CustomEvent(
            'search', 
            { 
                detail: value,
            }
        ));
    }
}