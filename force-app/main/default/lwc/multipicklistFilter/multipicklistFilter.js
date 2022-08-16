import { LightningElement, api } from 'lwc';

export default class MultipicklistFilter extends LightningElement {

    @api
    filterConfig;

    value;

    get options() {
        return this.filterConfig.picklistEntries;
    }

    connectedCallback() {
        const defaultValue = (this.filterConfig.picklistEntries.find((entry) => entry.isDefaultValue) || {}).value;

        this.value = defaultValue ? [defaultValue] : [];
    }

    handleChange(event) {
        this.value = event.detail.value;

        this.dispatchEvent(new CustomEvent(
            'filteradd', 
            { 
                detail: {
                    fieldName: this.filterConfig.fieldName,
                    valuesIn: this.value
                },
                bubbles: true,
                composed: true
            }
        ));
    }
}