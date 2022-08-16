public interface IQuery {
    IQuery addConditionIncludes(String lhs, Set<String> rhs);

    IQuery addConditionGe(String lhs, Object rhs);

    IQuery addConditionLe(String lhs, Object rhs);

    IQuery addConditionEq(String lhs, Object rhs);

    IQuery addConditionGt(String lhs, Object rhs);

    IQuery addConditionLt(String lhs, Object rhs);

    IQuery orderBy(String fieldName, String orderDirection, Boolean nullsFirst);

    IQuery addConditionIncludes(String lhs, String rhs);
}
