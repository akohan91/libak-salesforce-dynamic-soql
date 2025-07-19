/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 */
public with sharing class libak_DynamicSOQLFunction {
	private String functionName;
	private String fieldName;
	private String alias;

	// CONSTRUCTORS

	public libak_DynamicSOQLFunction(String functionName) {
		this(functionName, null, null);
	}

	public libak_DynamicSOQLFunction(String functionName, String fieldName) {
		this(functionName, fieldName, null);
	}

	public libak_DynamicSOQLFunction(String functionName, String fieldName, String alias) {
		this.functionName = functionName.substringBefore('(').trim();
		this.fieldName = fieldName;
		this.alias = alias;
	}

	/* PUBLIC METHODS */

	/**
	 * @description Returns the field api name that is used in a formula.
	 * @return   { String }
	 */
	public String fieldApiName() {
		return this.fieldName;
	}

	/**
	 * @description Builds a SOQL function string like "COUNT(Id) recordsCount"
	 * @return   { String }
	 */
	public String stringify() {
		return libak_DynamicSOQLConstants.TMPL_FUNCTION
			.replace(
				libak_DynamicSOQLConstants.PH_FUNCTION_NAME,
				String.escapeSingleQuotes(this.functionName)
			).replace(
				libak_DynamicSOQLConstants.PH_FIELD_NAME,
				this.fieldName != null ? String.escapeSingleQuotes(this.fieldName) : libak_DynamicSOQLConstants.EMPTY_STRING
			).replace(
				libak_DynamicSOQLConstants.PH_ALIAS,
				this.alias != null ? String.escapeSingleQuotes(this.alias) : libak_DynamicSOQLConstants.EMPTY_STRING
			)
			.trim();
	}
}
