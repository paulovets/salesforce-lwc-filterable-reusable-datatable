public without sharing class LWCSobjectController {

    @AuraEnabled
    public static List<Sobject> getSobjectList(String sobjectAPIName, Integer pageSize, Id lastFetchedId) {
        String query = 'SELECT Name, Id FROM ' + sobjectAPIName;

        if (lastFetchedId != null) {
            query += ' WHERE Id >: lastFetchedId';
        }

        query += ' ORDER BY Id ASC NULLS LAST LIMIT: pageSize';

        return Database.query(query);
    }
}
