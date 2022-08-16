public without sharing class LWCSobjectListSchemaService {
    
    public static FieldSetsWrapper buildFieldsConfiguration(String sobjectAPIName, 
                                                            String tableFieldSetAPIName,
                                                            String previewFieldSetAPIName,
                                                            String filtersFieldSetAPIName) {
        return new FieldSetsWrapper(
            buildTableFieldSet(sobjectAPIName, tableFieldSetAPIName), 
            buildPreviewFieldPathSet(sobjectAPIName, previewFieldSetAPIName),
            buildFilterFieldSet(sobjectAPIName, filtersFieldSetAPIName)
        );
    }

    private static List<TableFieldDescribe> buildTableFieldSet(String sobjectAPIName, 
                                                               String tableFieldSetAPIName) {
        final List<Schema.FieldSetMember> tableFieldSetMembers = SchemaUtils.getFieldSetMembers(sobjectAPIName, tableFieldSetAPIName);

        final Set<String> parentIdFieldsPaths = new Set<String>();
        
        final List<TableFieldDescribe> tableFieldSet = new List<TableFieldDescribe>();
        for (Schema.FieldSetMember member : tableFieldSetMembers) {
            tableFieldSet.add(new TableFieldDescribe(
                member.getFieldPath(),
                member.getLabel(),
                member.getType(),
                SchemaUtils.isUniquelySortable(sobjectAPIName, member.getFieldPath())
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

            // To be able to build a link on the client side for a parent text field
            if (!parentIdFieldsPaths.contains(parentIdFieldPath)) {
                tableFieldSet.add(new TableFieldDescribe(
                    parentIdFieldPath,
                    null,
                    Schema.DisplayType.ID,
                    false
                ));

                parentIdFieldsPaths.add(parentIdFieldPath);
            }
        }

        return tableFieldSet;
    }

    private static List<String> buildPreviewFieldPathSet(String sobjectAPIName, 
                                                         String previewFieldSetAPIName) {
        final List<Schema.FieldSetMember> previewFieldSetMembers = SchemaUtils.getFieldSetMembers(sobjectAPIName, previewFieldSetAPIName);

        final List<String> previewFieldPathSet = new List<String>();
        for (Schema.FieldSetMember member : previewFieldSetMembers) {
            previewFieldPathSet.add(member.getFieldPath());
        }

        return previewFieldPathSet;
    }

    private static List<FilterFieldDescribe> buildFilterFieldSet(String sobjectAPIName, 
                                                                 String filtersFieldSetAPIName) {
        final List<Schema.FieldSetMember> filterFieldSetMembers = SchemaUtils.getFieldSetMembers(sobjectAPIName, filtersFieldSetAPIName);
        
        final List<FilterFieldDescribe> filterFieldSet = new List<FilterFieldDescribe>();
        for (Schema.FieldSetMember member : filterFieldSetMembers) {
            filterFieldSet.add(new FilterFieldDescribe(
                member.getFieldPath(),
                member.getLabel(),
                member.getType(),
                SchemaUtils.getPicklistEntries(sobjectAPIName, member.getFieldPath())
            ));
        }

        return filterFieldSet;
    }

    public class FieldSetsWrapper {

        @AuraEnabled
        public List<TableFieldDescribe> tableFieldSet { get; set; }
        @AuraEnabled
        public List<String> previewFieldPathSet { get; set; }
        @AuraEnabled
        public List<FilterFieldDescribe> filterFieldSet { get; set; }

        public FieldSetsWrapper(List<TableFieldDescribe> tableFieldSet, List<String> previewFieldPathSet, List<FilterFieldDescribe> filterFieldSet) {
            this.tableFieldSet = tableFieldSet;
            this.previewFieldPathSet = previewFieldPathSet;
            this.filterFieldSet = filterFieldSet;
        }
    }

    private virtual class TableFieldDescribe {

        @AuraEnabled
        public String fieldName { get; set; }
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public Boolean sortable { get; set; }

        public TableFieldDescribe(String fieldName, String label, Schema.DisplayType type, Boolean sortable) {
            this.fieldName = fieldName;
            this.label = label;
            this.type = type.name();
            this.sortable = sortable;
        }
    }

    private class FilterFieldDescribe extends TableFieldDescribe {

        @AuraEnabled
        public List<PicklistEntryDescribe> picklistEntries { get; set; }

        public FilterFieldDescribe(String fieldName, String label, Schema.DisplayType type, List<Schema.PicklistEntry> optionalPicklistEntries) {
            super(fieldName, label, type, false);

            this.picklistEntries = new List<PicklistEntryDescribe>();
            for (Schema.PicklistEntry entry : optionalPicklistEntries) {
                picklistEntries.add(new PicklistEntryDescribe(
                    entry.getValue(),
                    entry.getLabel(),
                    entry.isDefaultValue()
                ));
            }
        }
    }

    private class PicklistEntryDescribe {

        @AuraEnabled
        public String value { get; set; }
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public Boolean isDefaultValue { get; set; }

        public PicklistEntryDescribe(String value, String label, Boolean isDefaultValue) {
            this.value = value;
            this.label = label;
            this.isDefaultValue = isDefaultValue;
        }
    }
}
