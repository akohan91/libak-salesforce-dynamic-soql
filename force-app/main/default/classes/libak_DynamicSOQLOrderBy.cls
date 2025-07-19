/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 */
public with sharing class libak_DynamicSOQLOrderBy {
	private List<String> orderByFields;
	private Boolean isDESC;
	private Boolean isNullsFirst;

	// CONSTRUCTORS

	public libak_DynamicSOQLOrderBy(List<String> orderByFields) {
		this(orderByFields, false, false);
	}

	public libak_DynamicSOQLOrderBy(List<String> orderByFields, Boolean isDESC) {
		this(orderByFields, isDESC, false);
	}

	public libak_DynamicSOQLOrderBy(List<String> orderByFields, Boolean isDESC, Boolean isNullsFirst) {
		this.orderByFields = orderByFields;
		this.isDESC        = isDESC;
		this.isNullsFirst  = isNullsFirst;
	}

	// PUBLIC METHODS

	/**
	 * @description Returns list of fields that are used in ORDER BY Statement
	 * @return   { List<String> }
	 */
	public List<String> fieldsApiNames() {
		return this.orderByFields.clone();
	}

	/**
	 * @description Returns ORDER BY statement like: "ORDER BY Name ASC NULLS LAST"
	 * @return   { String }
	 */
	public String stringify() {
		return libak_DynamicSOQLConstants.TMPL_ORDER_BY
			.replace(
				libak_DynamicSOQLConstants.PH_FIELD_ORDER_BY_LIST,
				String.escapeSingleQuotes(String.join(this.orderByFields, libak_DynamicSOQLConstants.COMMA))
			).replace(
				libak_DynamicSOQLConstants.PH_DIRECTION,
				this.isDESC == true ? libak_DynamicSOQLConstants.SORT_DIRECTION_DESC : libak_DynamicSOQLConstants.SORT_DIRECTION_ASC
			).replace(
				libak_DynamicSOQLConstants.PH_NULLS,
				this.isNullsFirst == true ? libak_DynamicSOQLConstants.NULLS_FIRST : libak_DynamicSOQLConstants.NULLS_LAST
			);
	}
}
