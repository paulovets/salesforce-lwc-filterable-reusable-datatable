import { LightningElement, api } from 'lwc';

export default class RecordPreview extends LightningElement {

    sobjectAPIName;
    fields;
    recordId;

    @api
    open(sobjectAPIName, fields, recordId) {
        this.sobjectAPIName = sobjectAPIName;
        this.fields = fields;
        this.recordId = recordId;

        this.template.querySelector('.slds-backdrop').classList.add('slds-backdrop_open');
        this.template.querySelector('.slds-modal').classList.add('slds-fade-in-open');
    }

    close() {
        this.template.querySelector('.slds-backdrop').classList.remove('slds-backdrop_open');
        this.template.querySelector('.slds-modal').classList.remove('slds-fade-in-open');
    }
}