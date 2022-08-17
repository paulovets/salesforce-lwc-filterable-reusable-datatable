import { LightningElement, api, track } from 'lwc';
import { buildColumns, buildRecords } from 'c/sobjectListHelper';
import getSobjectList from '@salesforce/apex/LWCSobjectListController.getSobjectList';
import getFieldsConfiguration from '@salesforce/apex/LWCSobjectListController.getFieldsConfiguration';

export default class SobjectList extends LightningElement {

    @api recordId;
    @api sobjectAPIName;
    @api tableFieldSetAPIName;
    @api previewFieldSetAPIName;
    @api filtersFieldSetAPIName;
    @api pageSize;

    @track columns = [];
    @track records = [];
    @track error;

    fieldsToFetch;
    lastFetchedRecord;
    lastFetchedPageSize = this.pageSize;
    searchString;

    loadingFirstPage = true;
    loadingNextPage = false;

    previewFieldsPaths;
    filterFieldSet;

    filters = [];

    sortDirection = 'asc';
    sortedBy = 'Id';
    
    connectedCallback() {
        this.fetchFieldsConfiguration();
    }

    fetchFieldsConfiguration() {
        getFieldsConfiguration({
                sobjectAPIName: this.sobjectAPIName, 
                tableFieldSetAPIName: this.tableFieldSetAPIName,
                previewFieldSetAPIName: this.previewFieldSetAPIName,
                filtersFieldSetAPIName: this.filtersFieldSetAPIName
            })
            .then(result => {
                this.previewFieldsPaths = result.previewFieldPathSet;
                this.filterFieldSet = result.filterFieldSet;
                this.buildColumnsAndPerformFirstFetch(result.tableFieldSet);
            })
            .catch(error => {
                debugger;
                this.error = error;
            });
    }

    buildColumnsAndPerformFirstFetch(apexFieldsConfigurations) {
        this.fieldsToFetch = apexFieldsConfigurations.map((fieldConfig) => fieldConfig.fieldName);

        this.columns = buildColumns(apexFieldsConfigurations);

        this.fetchRecords();
    }

    fetchRecords() {
        if (this.lastFetchedPageSize < this.pageSize || this.loadingNextPage) {
            return;
        }

        if (this.lastFetchedRecord) {
            this.loadingNextPage = true;
        }

        getSobjectList({
                sobjectAPIName: this.sobjectAPIName, 
                parentRecordId: this.recordId,
                fieldsToFetch: this.fieldsToFetch,
                pageSize: this.pageSize, 
                lastFetchedRecord: this.lastFetchedRecord,
                searchString: this.searchString,
                filtersJSON: JSON.stringify(this.filters),
                sortedBy: this.sortedBy,
                sortDirection: this.sortDirection
            })
            .then(result => {
                this.handleResponse(result);
                this.disableSpinners();
            })
            .catch(error => {
                this.error = error;
                this.disableSpinners();
            });
    }

    handleResponse(result) {
        this.records = this.records.concat(buildRecords(result));
        this.lastFetchedPageSize = result.length;
        this.lastFetchedRecord = result[result.length - 1];
    }

    disableSpinners() {
        this.loadingFirstPage = false;
        this.loadingNextPage = false;
    }

    resetPagination() {
        this.lastFetchedRecord = null;
        this.lastFetchedPageSize = this.pageSize;
        this.records = [];
        this.loadingFirstPage = true;
    }

    handleSearch(event) {
        this.searchString = event.detail;
        
        this.resetPagination();

        this.fetchRecords();
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        switch (actionName) {
            case 'show_details':
                this.template.querySelector('c-record-preview').open(this.sobjectAPIName,
                                                                     this.previewFieldsPaths,
                                                                     event.detail.row.Id);
                break;
            default:
        }
    }

    handleFilterAdded(event) {
        const foundFilterIndex = this.filters.findIndex((filter) => filter.fieldName === event.detail.fieldName);
        if (foundFilterIndex !== -1) {
            this.filters.splice(foundFilterIndex, 1);
        }

        this.filters.push(event.detail);

        this.resetPagination();

        this.fetchRecords();
    }

    handleFilterRemoved(event) {
        const foundFilterIndex = this.filters.findIndex((filter) => filter.fieldName === event.detail.fieldName);
        if (foundFilterIndex === -1) {
            return;
        }

        this.filters.splice(foundFilterIndex, 1);

        this.resetPagination();

        this.fetchRecords();
    }

    handleSort(event) {
        const { fieldName:sortedBy, sortDirection } = event.detail;
        
        this.sortedBy = sortedBy;
        this.sortDirection = sortDirection;

        this.resetPagination();

        this.fetchRecords();
    }
}