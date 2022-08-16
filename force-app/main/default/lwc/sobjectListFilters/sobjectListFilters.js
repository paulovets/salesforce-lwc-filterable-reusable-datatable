import { LightningElement, api, track } from 'lwc';

export default class SobjectListFilters extends LightningElement {

    @api
    get filterFieldSet() {
        return this.filtersToAdd;
    }

    set filterFieldSet(value) {
        this.filtersToAdd = (value || []).map((filter) => {
            const fieldType = {
                isPicklist: filter.type.toLowerCase() === 'picklist',
                isMultipicklist: filter.type.toLowerCase() === 'multipicklist'
            };

            return { ...filter, ...fieldType };
        });
        this.addedFilters = [];
    }

    filtersToAdd = [];
    addedFilters = [];

    handleMenuSelect(event) {
        const updateContext = this.moveItem(this.filtersToAdd, this.addedFilters, event.detail.value);

        this.filtersToAdd = updateContext.from;
        this.addedFilters = updateContext.to;
    }

    handleRemoval(event) {
        const updateContext = this.moveItem(this.addedFilters, this.filtersToAdd, event.detail.fieldName);

        this.addedFilters = updateContext.from;
        this.filtersToAdd = updateContext.to;
    }

    moveItem(from, to, fieldName) {
        const foundElement = from.find((filter) => filter.fieldName === fieldName);

        if (!foundElement) {
            return {
                from: from,
                to: to
            };
        }

        return {
            from: from.filter((filter) => filter.fieldName !== fieldName),
            to: [...to, ...[foundElement]]
        };
    }
}