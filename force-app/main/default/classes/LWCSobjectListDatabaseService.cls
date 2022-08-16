public inherited sharing class LWCSobjectListDatabaseService {

    public static List<Sobject> getSobjectList(String sobjectAPIName, 
                                               List<String> fieldsToFetch,
                                               Integer pageSize,
                                               Sobject lastFetchedRecord,
                                               String searchString,
                                               String filtersJSON,
                                               String sortedBy,
                                               String sortDirection) {
        if (String.isBlank(searchString)) {
            return executeSoql(
                sobjectAPIName,
                fieldsToFetch,
                pageSize,
                lastFetchedRecord,
                (List<QueryCondition>)System.JSON.deserialize(filtersJSON, List<QueryCondition>.class),
                sortedBy,
                sortDirection
            );
        }
        
        return executeSosl(
            sobjectAPIName,
            fieldsToFetch,
            pageSize,
            lastFetchedRecord,
            searchString,
            (List<QueryCondition>)System.JSON.deserialize(filtersJSON, List<QueryCondition>.class),
            sortedBy,
            sortDirection
        );
    }
    
    private static List<Sobject> executeSoql(String sobjectAPIName, 
                                             List<String> fieldsToFetch,
                                             Integer pageSize,
                                             Sobject lastFetchedRecord,
                                             List<QueryCondition> conditions,
                                             String sortedBy,
                                             String sortDirection) {
        final Query query = new Query(sobjectAPIName).
            selectFields(fieldsToFetch);

        appendConditions(query, conditions);

        appendPaginationPointerCondition(query, lastFetchedRecord, sortedBy, sortDirection);

        return query
            .setLimit(pageSize)
            .run();
    }

    private static List<Sobject> executeSosl(String sobjectAPIName, 
                                             List<String> fieldsToFetch,
                                             Integer pageSize,
                                             Sobject lastFetchedRecord,
                                             String searchString,
                                             List<QueryCondition> conditions,
                                             String sortedBy,
                                             String sortDirection) {
        final String searchStringWildcard = searchString + '*';

        final QuerySearch query = new QuerySearch()
            .find(searchStringWildcard)
            .inAllFields()
            .returning(sobjectAPIName)
            .selectFields(new Set<String>(fieldsToFetch));
        
        appendConditions(query, conditions);

        appendPaginationPointerCondition(query, lastFetchedRecord, sortedBy, sortDirection);

        return query
            .setLimit(pageSize)
            .run()
            .get(0);
    }

    private static void appendConditions(IQuery query, List<QueryCondition> conditions) {
        if (conditions == null || conditions.isEmpty()) {
            return;
        }

        for (QueryCondition condition : conditions) {
            if (condition.valuesIn != null && !condition.valuesIn.isEmpty()) {
                query.addConditionIncludes(condition.fieldName, new Set<String>(condition.valuesIn));
            } else if (!String.isBlank(condition.valueTo) && condition.valueFrom != condition.valueTo) {
                query
                    .addConditionGe(condition.fieldName, condition.valueFrom)
                    .addConditionLe(condition.fieldName, condition.valueTo);
            } else {
                query.addConditionEq(condition.fieldName, condition.valueFrom);
            }
        }
    }

    private static void appendPaginationPointerCondition(IQuery query, 
                                                         Sobject lastFetchedRecord,
                                                         String sortedBy,
                                                         String sortDirection) {
        final String sortedByWithFallback = String.isBlank(sortedBy) ? SobjectConstants.ID_SUFFIX : sortedBy;
        final String sortDirectionWithFallback = String.isBlank(sortDirection) ? DatabaseConstants.ASC_CLAUSE : sortDirection;

        if (lastFetchedRecord != null && lastFetchedRecord.get(sortedByWithFallback) != null) {
            final Object lastFetchedValue = lastFetchedRecord.get(sortedByWithFallback);
            
            if (DatabaseConstants.ASC_CLAUSE == sortDirectionWithFallback.toUpperCase()) {
                query.addConditionGt(sortedByWithFallback, lastFetchedValue);
            } else {
                query.addConditionLt(sortedByWithFallback, lastFetchedValue);
            }
        }

        query.orderBy(sortedByWithFallback, sortDirectionWithFallback, false);
    }

    public class QueryCondition {

        public String fieldName { get; set; }

        public String valueFrom { get; set; }

        public String valueTo { get; set; }

        public List<String> valuesIn { get; set; }
    }
}
