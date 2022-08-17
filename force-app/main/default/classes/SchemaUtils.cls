public without sharing class SchemaUtils {
    
    public static List<Schema.FieldSetMember> getFieldSetMembers(String objectAPIName, String fieldSetAPIName) {
        return Schema.getGlobalDescribe()
            .get(objectAPIName)
            .getDescribe()
            .FieldSets
            .getMap()
            .get(fieldSetAPIName)
            .getFields();
    }

    public static Boolean isUniquelySortable(String objectAPIName, String fieldAPIName) {
        List<String> fieldParts = fieldAPIName.split('\\.');
        if (fieldParts.size() > 1) {
            return false;
        }

        final Schema.DescribeFieldResult fdr = getFieldDescribeUtility(objectAPIName, fieldParts);

        return fdr.getType() == Schema.DisplayType.Id ||
               fdr.isAutoNumber() ||
               !fdr.isNillable() &&
               (fdr.getType() == Schema.DisplayType.Datetime || fdr.isUnique());
    }

    public static List<Schema.PicklistEntry> getPicklistEntries(String objectAPIName, String fieldAPIName) {
        final Schema.DescribeFieldResult dfr = getFieldDescribeUtility(objectAPIName, fieldAPIName.split('\\.'));

        if (dfr.getType() == Schema.DisplayType.Picklist || dfr.getType() == Schema.DisplayType.MultiPicklist) {
            return dfr.getPicklistValues();
        }
        
        return new List<Schema.PicklistEntry>();
    }

    public static String findReferenceFieldAPIName(String objectAPIName, Id parentRecordId) {
        final String parentSobjectAPIName = parentRecordId.getSObjectType().getDescribe().getName();

        final List<Schema.SObjectField> fields = Schema.getGlobalDescribe()
            .get(objectAPIName)
            .getDescribe()
            .fields
            .getMap()
            .values();

        for (Schema.SObjectField field : fields) {
            final List <Schema.SobjectType> references = field.getDescribe().getReferenceTo();
            if (references.isEmpty()) {
                continue;
            }

            if (references.get(0).getDescribe().getName() == parentSobjectAPIName) {
                return field.getDescribe().getName();
            }
        }

        return null;
    }

    private static Schema.DescribeFieldResult getFieldDescribe(String objectAPIName, String fieldAPIName) {
        return getFieldDescribeUtility(objectAPIName, fieldAPIName.split('\\.'));
    }

    private static Schema.DescribeFieldResult getFieldDescribeUtility(String objectAPIName, List<String> fieldParts) {
        if (fieldParts.size() > 1) {
            final String parentSobjectAPIName = getFirstRefereceSobjectAPIName(objectAPIName, fieldParts.remove(0));

            return getFieldDescribeUtility(parentSobjectAPIName, fieldParts);
        }

        return Schema.getGlobalDescribe()
            .get(objectAPIName)
            .getDescribe()
            .fields
            .getMap()
            .get(fieldParts[0])
            .getDescribe();
    }

    private static String getFirstRefereceSobjectAPIName(String objectAPIName, String fieldAPIName) {
        String referenceFiledAPIName;
        if (fieldAPIName.contains(SobjectConstants.CUSTOM_REFERENCE_SUFFIX)) {
            referenceFiledAPIName = fieldAPIName.replace(SobjectConstants.CUSTOM_REFERENCE_SUFFIX, SobjectConstants.CUSTOM_FIELD_SUFFIX);
        } else {
            referenceFiledAPIName = fieldAPIName + SobjectConstants.ID_SUFFIX;
        }

        return getFieldDescribe(objectAPIName, referenceFiledAPIName)
            .getReferenceTo()
            .get(0)
            .getDescribe()
            .getName();
    }
}