/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 */
public with sharing class libak_DynamicSOQLConditionBlock {
	private List<libak_DynamicSOQLConditionBlock> blocks;
	private List<libak_DynamicSOQLCondition> conditions;
	private String operator;

	// CONSTRUCTORS

	public libak_DynamicSOQLConditionBlock(String operator) {
		this.blocks = new List<libak_DynamicSOQLConditionBlock>();
		this.conditions = new List<libak_DynamicSOQLCondition>();
		this.switchOperator(operator);
	}

	// PUBLIC METHODS

	/**
	 * @description Adds new condition block that will be added to the current one.
	 *              It allow to build complex conditions like `(condition OR condition) AND condition`
	 * @param  conditionBlock { libak_DynamicSOQLConditionBlock } - new condition block that will be added to the current one.
	 * @return                { libak_DynamicSOQLConditionBlock } - current codition block
	 */
	public libak_DynamicSOQLConditionBlock addConditionBlock(libak_DynamicSOQLConditionBlock conditionBlock) {
		this.blocks.add(conditionBlock);
		return this;
	}

	/**
	 * @description Adds a condition to the current block
	 * @param  condition { libak_DynamicSOQLCondition } - new condition that will be added to the current condition block.
	 * @return           { libak_DynamicSOQLConditionBlock } - current codition block
	 */
	public libak_DynamicSOQLConditionBlock addCondition(libak_DynamicSOQLCondition condition) {
		this.conditions.add(condition);
		return this;
	}

	/**
	 * @description Changes the operator. Could be either OR | AND
	 * @param  operator { String } - OR | AND
	 * @return          { libak_DynamicSOQLConditionBlock }
	 */
	public libak_DynamicSOQLConditionBlock switchOperator(String operator) {
		this.operator = operator;
		return this;
	}

	/**
	 * @description Returns all field api names from libak_DynamicSOQLCondition and libak_DynamicSOQLConditionBlock
	 * @return   { Set<String> }
	 */
	public Set<String> fieldsApiNames() {
		Set<String> result = new Set<String>();
		for (libak_DynamicSOQLCondition soqlCondition : this.conditions) {
			result.add(soqlCondition.fieldApiName());
		}
		for (libak_DynamicSOQLConditionBlock conditionBlock : this.blocks) {
			result.addAll(conditionBlock.fieldsApiNames());
		}
		return result;
	}

	/**
	 * @description Builds a Dynamic SOQL Condition Block string for WHERE statement
	 * @param sobjectApiName { String } Sobject api name for what the condition block is created.
	 * @return   { String }
	 */
	public String stringify(String sobjectApiName, libak_DynamicSOQL.ISobjectFieldPathConstructable fieldPathConstructor) {
		this.operator = String.escapeSingleQuotes(this.operator);
		this.validateBlock();
		List<String> result = new List<String>();

		if (this.blocks != null && !this.blocks.isEmpty()) {
			for (libak_DynamicSOQLConditionBlock block : this.blocks) {
				result.add(block.stringify(sobjectApiName, fieldPathConstructor));
			}
		}

		if (this.conditions != null && !this.conditions.isEmpty()) {
			for (libak_DynamicSOQLCondition condition : this.conditions) {
				result.add(condition.stringify(sobjectApiName, fieldPathConstructor));
			}
		}
		return '(' + String.join(result, ' ' + this.operator + ' ') + ')';
	}

	// PRIVATE METHODS

	private void validateBlock() {
		if (!libak_DynamicSOQLConstants.CONDITION_BLOCK_AVAILABLE_OPERATORS.contains(this.operator)) {
			throw new DynamicSOQLConditionBlockException(
				Label.WrongComparisonOperator
				.replace(libak_DynamicSOQLConstants.PH_OPERATOR, this.operator)
				.replace(
					libak_DynamicSOQLConstants.PH_AVAILABLE_OPERATORS,
					libak_DynamicSOQLConstants.CONDITION_BLOCK_AVAILABLE_OPERATORS.toString())
			);
		}
	}

	public class DynamicSOQLConditionBlockException extends Exception { }
}
