import { LightningElement, api } from 'lwc';

export default class PicklistFilter extends LightningElement {

    @api
    filterConfig;

    value;

    get options() {
        return this.filterConfig.picklistEntries;
    }

    connectedCallback() {
        this.value = (this.filterConfig.picklistEntries.find((entry) => entry.isDefaultValue) || {}).value;
    }

    handleChange(event) {
        this.value = event.detail.value;

        this.dispatchEvent(new CustomEvent(
            'filteradd', 
            { 
                detail: {
                    fieldName: this.filterConfig.fieldName,
                    valueFrom: this.value
                },
                bubbles: true,
                composed: true
            }
        ));
    }
}