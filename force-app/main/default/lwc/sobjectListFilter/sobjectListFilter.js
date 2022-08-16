import { LightningElement, api } from 'lwc';

export default class SobjectListFilter extends LightningElement {

    @api
    filterConfig;

    value;

    _handler;

    get iconVariant() {
        return this.value ? 'inverse' : null;
    }

    get badgeClasses() {
        const badgeStyle = this.value ? 'slds-theme_success' : 'slds-badge_lightest';

        return `slds-badge ${badgeStyle} slds-var-p-around_medium`;
    }

    connectedCallback() {
        document.addEventListener('click', this._handler = this.close.bind(this));
    }

    disconnectedCallback() {
        document.removeEventListener('click', this._handler);
    }

    close() { 
        this.template.querySelector('.slds-popover').classList.add('slds-hide');
    }

    remove(event) {
        this.dispatchEvent(new CustomEvent(
            'filterremove', 
            { 
                detail: {
                    fieldName: this.filterConfig.fieldName
                },
                bubbles: true,
                composed: true
            }
        ));

        return this.stopPropogation(event);
    }

    toggle(event) {
        this.template.querySelector('.slds-popover').classList.toggle('slds-hide');

        return this.stopPropogation(event);
    }

    handleFilterAdded(event) {
        this.value = event.detail.fieldName;
    }

    stopPropogation(event) {
        event.stopPropagation();

        return false;
    }
}