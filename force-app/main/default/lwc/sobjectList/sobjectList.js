import { LightningElement, api, track } from 'lwc';
import { buildColumns, buildRecords } from 'c/sobjectListHelper';
import getSobjectList from '@salesforce/apex/LWCSobjectListController.getSobjectList';
import getFieldsConfiguration from '@salesforce/apex/LWCSobjectListController.getFieldsConfiguration';

export default class SobjectList extends LightningElement {

    @api recordId;
    @api sobjectAPIName;
    @api fieldSetAPIName;
    @api pageSize;

    @track columns = [];
    @track records = [];
    @track error;

    fieldsToFetch;
    lastFetchedId;
    lastFetchedPageSize = this.pageSize;
    searchString;

    loadingFirstPage = true;
    loadingNextPage = false;
    
    connectedCallback() {
        this.fetchFieldsConfiguration()
    }

    fetchFieldsConfiguration() {
        getFieldsConfiguration({
                sobjectAPIName: this.sobjectAPIName, 
                fieldSetAPIName: this.fieldSetAPIName
            })
            .then(result => {
                this.buildColumnsAndPerformFirstFetch(result);
            })
            .catch(error => {
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

        if (this.lastFetchedId) {
            this.loadingNextPage = true;
        }

        getSobjectList({
                sobjectAPIName: this.sobjectAPIName, 
                fieldsToFetch: this.fieldsToFetch,
                pageSize: this.pageSize, 
                lastFetchedId: this.lastFetchedId,
                searchString: this.searchString
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
        this.lastFetchedId = result[result.length - 1].Id;
    }

    disableSpinners() {
        this.loadingFirstPage = false;
        this.loadingNextPage = false;
    }

    resetPagination() {
        this.lastFetchedId = null;
        this.lastFetchedPageSize = this.pageSize;
        this.records = [];
        this.loadingFirstPage = true;
    }

    handleSearch(event) {
        this.searchString = event.detail;
        
        this.resetPagination();

        this.fetchRecords();
    }
}