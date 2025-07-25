/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 */
public with sharing class libak_DynamicSOQLCondition {
	private libak_DynamicSOQLFunction function;
	private String fieldName;
	private String operator;
	private String value;
	private List<String> values;
	private libak_DynamicSOQL soqlValue;

	// CONSTRUCTORS

	public libak_DynamicSOQLCondition(String fieldName, String operator, Object value) {
		this(fieldName, operator);
		this.value = String.valueOf(value);
	}

	public libak_DynamicSOQLCondition(libak_DynamicSOQLFunction function, String operator, Object value) {
		this(null, operator);
		this.function = function;
		this.value = String.valueOf(value);
	}

	public libak_DynamicSOQLCondition(String fieldName, String operator, Datetime value) {
		this(fieldName, operator);
		this.value = this.fmtDatetime(value);
	}

	public libak_DynamicSOQLCondition(String fieldName, String operator, Date value) {
		this(fieldName, operator);
		this.value = this.fmtDate(value);
	}

	public libak_DynamicSOQLCondition(String fieldName, String operator, String value) {
		this(fieldName, operator);
		this.value = value == null ? libak_DynamicSOQLConstants.NULL_STRING : value;
	}

	public libak_DynamicSOQLCondition(String fieldName, String operator, List<String> values) {
		this(fieldName, operator);
		this.values = values;
	}

	public libak_DynamicSOQLCondition(String fieldName, String operator, libak_DynamicSOQL soqlValue) {
		this(fieldName, operator);
		this.soqlValue = soqlValue;
	}

	private libak_DynamicSOQLCondition(String fieldName, String operator) {
		this.fieldName = fieldName;
		this.operator = operator;
	}

	// PUBLIC METHOD

	/**
	 * @description Returns the field api name that is used in the condition.
	 * @return   { String }
	 */
	public String fieldApiName() {
		if (this.fieldName != null) {
			return this.fieldName;
		} else if (this.function != null) {
			return this.function.fieldApiName();
		} else {
			throw new DynamicSOQLConditionException(Label.NoFieldApiNameInSOQLCondition);
		}
	}

	/**
	 * @description Build the SOQL condition as a string in format <fieldApiName> <operator> <value>.
	 * @param  sobjectApiName { String } Sobject api name for what the condition is created.
	 * @return   { String }
	 */
	public String stringify(String sobjectApiName, libak_DynamicSOQL.ISobjectFieldPathConstructable fieldPathConstructor) {
		DescribeFieldResult fieldDescribe = fieldPathConstructor.construct(sobjectApiName, this.fieldApiName()).targetFieldDescribe();
		this.validateOperator();
		if (this.function != null) {
			return libak_DynamicSOQLConstants.TMPL_CONDITION
				.replace(libak_DynamicSOQLConstants.PH_LEFT_PART, this.function.stringify())
				.replace(libak_DynamicSOQLConstants.PH_OPERATOR, String.escapeSingleQuotes(this.operator))
				.replace(libak_DynamicSOQLConstants.PH_RIGHT_PART, String.escapeSingleQuotes(this.value));
		} else if (this.values != null) {
			return libak_DynamicSOQLConstants.TMPL_CONDITION
				.replace(libak_DynamicSOQLConstants.PH_LEFT_PART, String.escapeSingleQuotes(this.fieldName))
				.replace(libak_DynamicSOQLConstants.PH_OPERATOR, String.escapeSingleQuotes(this.operator))
				.replace(libak_DynamicSOQLConstants.PH_RIGHT_PART, this.stringifyValues(fieldDescribe));
		}  else if (this.soqlValue != null) {
			return libak_DynamicSOQLConstants.TMPL_CONDITION
				.replace(libak_DynamicSOQLConstants.PH_LEFT_PART, String.escapeSingleQuotes(this.fieldName))
				.replace(libak_DynamicSOQLConstants.PH_OPERATOR, String.escapeSingleQuotes(this.operator))
				.replace(libak_DynamicSOQLConstants.PH_RIGHT_PART, '(' + this.soqlValue.stringify() + ')');
		} else {
			return libak_DynamicSOQLConstants.TMPL_CONDITION
				.replace(libak_DynamicSOQLConstants.PH_LEFT_PART, String.escapeSingleQuotes(this.fieldName))
				.replace(libak_DynamicSOQLConstants.PH_OPERATOR, String.escapeSingleQuotes(this.operator))
				.replace(libak_DynamicSOQLConstants.PH_RIGHT_PART, this.processValue(this.value, fieldDescribe));
		}
	}

	// PRIVATE METHOD

	private String fmtDatetime(Datetime dt) {
		return dt.formatGmt(libak_DynamicSOQLConstants.FORMAT_DATE_TIME);
	}

	private String fmtDate(Datetime dt) {
		return dt.formatGmt(libak_DynamicSOQLConstants.FORMAT_DATE);
	}

	private String processValue(String value, DescribeFieldResult fieldDescribe) {
		if (libak_DynamicSOQLConstants.TEXT_DISPLAY_TYPES.contains(fieldDescribe.getType())
			&& !operator.contains(libak_DynamicSOQLConstants.COLON)
			&& value != libak_DynamicSOQLConstants.NULL_STRING
		) {
			return this.addQuotes(String.escapeSingleQuotes(value));
		} else if (fieldDescribe.getType() == Schema.DisplayType.Date) {
			return String.escapeSingleQuotes(value).substringBefore(libak_DynamicSOQLConstants.FORMAT_TIME_SEPARATOR);
		} else {
			return String.escapeSingleQuotes(value);
		}
	}

	private String addQuotes(String value) {
		return libak_DynamicSOQLConstants.SINGLE_QUOTE + value + libak_DynamicSOQLConstants.SINGLE_QUOTE;
	}

	private void validateOperator() {
		String operator = this.operator.replace(libak_DynamicSOQLConstants.COLON, libak_DynamicSOQLConstants.EMPTY_STRING);
		if (!libak_DynamicSOQLConstants.CONDITION_AVAILABLE_OPERATORS.contains(operator)) {
			throw new DynamicSOQLConditionException(
				Label.WrongComparisonOperator
				.replace(libak_DynamicSOQLConstants.PH_OPERATOR, this.operator)
				.replace(
					libak_DynamicSOQLConstants.PH_AVAILABLE_OPERATORS,
					libak_DynamicSOQLConstants.CONDITION_AVAILABLE_OPERATORS.toString()
				)
			);
		}
	}

	private String stringifyValues(DescribeFieldResult fieldDescribe) {
		String operator = this.operator.replace(libak_DynamicSOQLConstants.COLON, libak_DynamicSOQLConstants.EMPTY_STRING);
		if (operator == libak_DynamicSOQLConstants.OPERATOR_INCLUDES || operator == libak_DynamicSOQLConstants.OPERATOR_EXCLUDES) {
			return libak_DynamicSOQLConstants.TMPL_BULK_VALUES.replace(
				libak_DynamicSOQLConstants.PH_BULK_VALUES,
				String.escapeSingleQuotes(String.join(this.values, libak_DynamicSOQLConstants.SEMICOLON))
			);
		}
		List<String> quotedValues = new List<String>();
		for (String valueItem : this.values) {
			quotedValues.add(this.processValue(valueItem, fieldDescribe));
		}
		return libak_DynamicSOQLConstants.TMPL_BULK_VALUES.replace(
			libak_DynamicSOQLConstants.PH_BULK_VALUES,
			String.join(quotedValues, libak_DynamicSOQLConstants.COMMA)
		);
	}

	public class DynamicSOQLConditionException extends Exception{ }
}
