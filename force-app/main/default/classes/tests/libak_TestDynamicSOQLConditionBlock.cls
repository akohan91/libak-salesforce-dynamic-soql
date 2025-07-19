/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 */
@IsTest
public with sharing class libak_TestDynamicSOQLConditionBlock {
	@IsTest
	static void testConditionBlockSingleCondition(){
		libak_DynamicSOQLConditionBlock conditionBlock = new libak_DynamicSOQLConditionBlock('AND')
			.addCondition(new libak_DynamicSOQLCondition('Name', '=', 'Test Name'));

		Test.startTest();

		String result = conditionBlock.stringify('Account', new libak_TestDynamicSOQLEnvironment.TestFieldPathConstructor());

		Test.stopTest();

		System.assertEquals('(Name = \'Test Name\')', result, 'The stringify() method returns wrong value');
	}

	@IsTest
	static void testConditionBlockSeveralContitions(){
		libak_DynamicSOQLConditionBlock conditionBlock = new libak_DynamicSOQLConditionBlock('AND')
			.addCondition(new libak_DynamicSOQLCondition('FirstName', '=', 'Test Name'))
			.addCondition(new libak_DynamicSOQLCondition('LastName', '=', 'Test Name'))
			.addCondition(new libak_DynamicSOQLCondition('Birthdate', '<', Date.newInstance(2022,01,01)));

		Test.startTest();

		String result = conditionBlock.stringify('Contact', new libak_TestDynamicSOQLEnvironment.TestFieldPathConstructor());

		Test.stopTest();

		System.assertEquals(
			'(FirstName = \'Test Name\' AND LastName = \'Test Name\' AND Birthdate < 2022-01-01)',
			result,
			'The stringify() method returns wrong value'
		);
	}

	@IsTest
	static void testConditionBlockSeveralContitionBlocks(){
		libak_DynamicSOQLConditionBlock conditionBlock = new libak_DynamicSOQLConditionBlock('AND')
			.addConditionBlock(
				new libak_DynamicSOQLConditionBlock('OR')
				.addCondition(new libak_DynamicSOQLCondition('FirstName', '=', 'Test Name 1'))
				.addCondition(new libak_DynamicSOQLCondition('FirstName', '=', 'Test Name 2'))
			).addConditionBlock(
				new libak_DynamicSOQLConditionBlock('OR')
				.addCondition(new libak_DynamicSOQLCondition('LastName', '=', 'Test Name 1'))
				.addCondition(new libak_DynamicSOQLCondition('LastName', '=', 'Test Name 2'))
			).addCondition(new libak_DynamicSOQLCondition('Birthdate', '<', Date.newInstance(2022,01,01)));

		Test.startTest();

		String result = conditionBlock.stringify('Contact', new libak_TestDynamicSOQLEnvironment.TestFieldPathConstructor());

		Test.stopTest();

		System.assertEquals(
			'((FirstName = \'Test Name 1\' OR FirstName = \'Test Name 2\') AND (LastName = \'Test Name 1\' OR LastName = \'Test Name 2\') AND Birthdate < 2022-01-01)',
			result,
			'The stringify() method returns wrong value'
		);
	}

	@IsTest
	static void testSwitchOperator(){
		libak_DynamicSOQLConditionBlock conditionBlock = new libak_DynamicSOQLConditionBlock('AND')
			.addCondition(new libak_DynamicSOQLCondition('FirstName', '=', 'Test Name'))
			.addCondition(new libak_DynamicSOQLCondition('LastName', '=', 'Test Name'))
			.addCondition(new libak_DynamicSOQLCondition('Birthdate', '<', Date.newInstance(2022,01,01)));

		System.assertEquals(
			'(FirstName = \'Test Name\' AND LastName = \'Test Name\' AND Birthdate < 2022-01-01)',
			conditionBlock.stringify('Contact', new libak_TestDynamicSOQLEnvironment.TestFieldPathConstructor()),
			'The stringify() method returns wrong value'
		);

		Test.startTest();

		conditionBlock.switchOperator('OR');

		Test.stopTest();

		System.assertEquals(
			'(FirstName = \'Test Name\' OR LastName = \'Test Name\' OR Birthdate < 2022-01-01)',
			conditionBlock.stringify('Contact', new libak_TestDynamicSOQLEnvironment.TestFieldPathConstructor()),
			'The stringify() method returns wrong value'
		);
	}

	@IsTest
	static void testFieldsApiNames(){
		Test.startTest();
		libak_DynamicSOQLConditionBlock conditionBlock = new libak_DynamicSOQLConditionBlock('AND')
		.addConditionBlock(
			new libak_DynamicSOQLConditionBlock('OR')
			.addCondition(new libak_DynamicSOQLCondition('Phone', '=', '121345'))
		)
		.addCondition(new libak_DynamicSOQLCondition('FirstName', '=', 'Test'))
		.addCondition(new libak_DynamicSOQLCondition('LastName', '=', 'Test'));

		System.assertEquals(
			3, conditionBlock.fieldsApiNames().size(),
			'The number of fields thet the "fieldsApiNames()" method returns is wrong.'
		);
		System.assert(
			conditionBlock.fieldsApiNames().containsAll(new Set<String>{'Phone', 'FirstName', 'LastName'}),
			'The "fieldsApiNames()" method returns wrong value.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testToStringWrongOperator(){
		Test.startTest();
		Integer errorCount = 0;
		try {
			new libak_DynamicSOQLConditionBlock('AND')
			.addCondition(new libak_DynamicSOQLCondition('Name', '=', 'Test'))
			.switchOperator('wrong')
			.stringify('Account', new libak_TestDynamicSOQLEnvironment.TestFieldPathConstructor());
		} catch (Exception exc) {
			errorCount++;
		}

		System.assertEquals(
			1, errorCount,
			'The WrongComparisonOperator error was not occured.'
		);
		Test.stopTest();
	}
}
