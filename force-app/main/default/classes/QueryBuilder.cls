public without sharing class QueryBuilder {

    // To work - a client logic must operate with the same variables names.
    public static String buildSoqlQuery(String sobjectAPIName, 
                                        List<String> fieldsToFetch,
                                        Integer pageSize,
                                        Id lastFetchedId) {
        String query = 'SELECT ' + 
            String.join(fieldsToFetch, ',') + 
            ' FROM ' + sobjectAPIName;

        if (lastFetchedId != null) {
            query += ' WHERE Id >: lastFetchedId';
        }

        query += ' ORDER BY Id ASC NULLS LAST LIMIT: pageSize';

        return query;
    }

    // To work - a client logic must operate with the same variables names.
    public static String buildSoslQuery(String sobjectAPIName, 
                                        List<String> fieldsToFetch,
                                        Integer pageSize,
                                        Id lastFetchedId,
                                        String searchString) {
        String query = 'FIND :searchString IN ALL FIELDS RETURNING ' +
            sobjectAPIName + 
            ' (' + String.join(fieldsToFetch, ',');

        if (lastFetchedId != null) {
            query += ' WHERE Id >: lastFetchedId';
        }

        query += ' ORDER BY Id ASC NULLS LAST LIMIT: pageSize)';

        return query;
    }
}
