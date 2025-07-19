/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 */
public with sharing class libak_DynamicSOQLGroupBy {
	@TestVisible
	private List<String> fieldGroupByList;
	private libak_DynamicSOQLConditionBlock conditionBlock;

	public libak_DynamicSOQLGroupBy(List<String> fieldGroupByList) {
		this.fieldGroupByList = fieldGroupByList;
	}

	/**
	 * @description Adds HAVING clause to the GROUP BY clause
	 * @param  conditionBlock { libak_DynamicSOQLConditionBlock }
	 * @return                { DynamicSOQLGoupBy }
	 */
	public libak_DynamicSOQLGroupBy withHaving(libak_DynamicSOQLConditionBlock conditionBlock) {
		this.conditionBlock = conditionBlock;
		return this;
	}

	/**
	 * @description Returns list of fields that are used in GROUP BY Statement
	 * @return   { List<String> }
	 */
	public List<String> fieldsApiNames() {
		return this.fieldGroupByList.clone();
	}

	/**
	 * @description Builds a GROUP BY part of SOQL string
	 * @param  sobjectApiName { String } Sobject api name for what the group by is created.
	 * @return   { String }
	 */
	public String stringify(String sobjectApiName, libak_DynamicSOQL.ISobjectFieldPathConstructable fieldPathConstructor) {
		return libak_DynamicSOQLConstants.TMPL_GROUP_BY
			.replace(
				libak_DynamicSOQLConstants.PH_FIELD_GROUP_BY_LIST,
				String.escapeSingleQuotes(String.join(this.fieldGroupByList, libak_DynamicSOQLConstants.COMMA))
			).replace(
				libak_DynamicSOQLConstants.PH_HAVING,
				this.conditionBlock != null ? ' HAVING ' + this.conditionBlock.stringify(sobjectApiName, fieldPathConstructor) : libak_DynamicSOQLConstants.EMPTY_STRING
			)
		;
	}
}
