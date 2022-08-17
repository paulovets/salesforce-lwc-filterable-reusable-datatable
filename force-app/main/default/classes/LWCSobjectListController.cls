public with sharing class LWCSobjectListController {

    @AuraEnabled(cacheable=true)
    public static List<Sobject> getSobjectList(String sobjectAPIName, 
                                               String parentRecordId,
                                               List<String> fieldsToFetch,
                                               Integer pageSize,
                                               Sobject lastFetchedRecord,
                                               String searchString,
                                               String filtersJSON,
                                               String sortedBy,
                                               String sortDirection) {
        return LWCSobjectListDatabaseService.getSobjectList(
            sobjectAPIName,
            parentRecordId,
            fieldsToFetch,
            pageSize,
            lastFetchedRecord,
            searchString,
            filtersJSON,
            sortedBy,
            sortDirection
        );
    }

    @AuraEnabled(cacheable=true)
    public static LWCSobjectListSchemaService.FieldSetsWrapper getFieldsConfiguration(String sobjectAPIName, 
                                                                                      String tableFieldSetAPIName,
                                                                                      String previewFieldSetAPIName,
                                                                                      String filtersFieldSetAPIName) {
        return LWCSobjectListSchemaService.buildFieldsConfiguration(
            sobjectAPIName,
            tableFieldSetAPIName,
            previewFieldSetAPIName,
            filtersFieldSetAPIName
        );
    }
}