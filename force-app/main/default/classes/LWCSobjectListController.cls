public with sharing class LWCSobjectListController {

    @AuraEnabled(cacheable=true)
    public static List<Sobject> getSobjectList(String sobjectAPIName, 
                                               List<String> fieldsToFetch,
                                               Integer pageSize,
                                               Id lastFetchedId,
                                               String searchString) {
        if (String.isBlank(searchString)) {
            return Database.query(QueryBuilder.buildSoqlQuery(
                sobjectAPIName,
                fieldsToFetch,
                pageSize,
                lastFetchedId
            ));
        }

        final String searchStringWildcard = searchString + '*';
        
        final List<List<SObject>> result = Search.query(QueryBuilder.buildSoslQuery(
            sobjectAPIName,
            fieldsToFetch,
            pageSize,
            lastFetchedId,
            searchStringWildcard
        ));

        if (result.isEmpty()) {
            return new List<Sobject>();
        }

        return result.get(0);
    }

    @AuraEnabled(cacheable=true)
    public static List<FieldConfiguration> getFieldsConfiguration(String sobjectAPIName, 
                                                                  String fieldSetAPIName) {
        final List<Schema.FieldSetMember> fieldSetMembers = SchemaUtils.getFieldSetMembers(sobjectAPIName, fieldSetAPIName);

        final Set<String> parentIdFieldsPaths = new Set<String>();
        
        final List<FieldConfiguration> result = new List<FieldConfiguration>();
        for (Schema.FieldSetMember member : fieldSetMembers) {
            result.add(new FieldConfiguration(
                member.getFieldPath(),
                member.getLabel(),
                member.getType()
            ));

            final List<String> pathParts = member.getFieldPath().split('\\.');
            if (pathParts.size() == 1) {
                continue;
            }

            if (pathParts.get(1) == 'Id') {
                parentIdFieldsPaths.add(member.getFieldPath());

                continue;
            }

            final String parentIdFieldPath = pathParts.get(0) + '.Id';

            if (!parentIdFieldsPaths.contains(parentIdFieldPath)) {
                result.add(new FieldConfiguration(
                    parentIdFieldPath,
                    null,
                    Schema.DisplayType.ID
                ));

                parentIdFieldsPaths.add(parentIdFieldPath);
            }
        }

        return result;
    }

    private class FieldConfiguration {

        @AuraEnabled
        public String fieldName { get; set; }
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String type { get; set; }

        public FieldConfiguration(String fieldName, String label, Schema.DisplayType type) {
            this.fieldName = fieldName;
            this.label = label;
            this.type = type.name();
        }
    }
}