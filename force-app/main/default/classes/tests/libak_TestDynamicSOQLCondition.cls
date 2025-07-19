/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 */
@IsTest
public with sharing class libak_TestDynamicSOQLCondition {
	@IsTest
	static void testConstructorValueAsObject(){
		libak_DynamicSOQLCondition condition = new libak_DynamicSOQLCondition('IsDeleted', '=', false);

		Test.startTest();

		String result = condition.stringify('Account', new libak_TestDynamicSOQLEnvironment.TestFieldPathConstructor());

		Test.stopTest();

		System.assertEquals('IsDeleted = false', result, 'The "stringify" method returns wrong value.');
	}

	@IsTest
	static void testConstructorWithFunction(){
		libak_DynamicSOQLCondition condition = new libak_DynamicSOQLCondition(new libak_DynamicSOQLFunction('COUNT', 'Id'), '>', 10);

		Test.startTest();

		String result = condition.stringify('Account', new libak_TestDynamicSOQLEnvironment.TestFieldPathConstructor());

		Test.stopTest();

		System.assertEquals('COUNT(Id) > 10', result, 'The "stringify" method returns wrong value.');
	}

	@IsTest
	static void testConstructorValueAsDateTime(){
		Datetime value = Datetime.newInstance(2022, 01, 01, 01, 01, 01);
		libak_DynamicSOQLCondition condition = new libak_DynamicSOQLCondition('CreatedDate', '=', value);

		Test.startTest();

		String result = condition.stringify('Account', new libak_TestDynamicSOQLEnvironment.TestFieldPathConstructor());

		Test.stopTest();

		System.assertEquals(
			'CreatedDate = ' + value.formatGmt(libak_DynamicSOQLConstants.FORMAT_DATE_TIME),
			result,
			'The "stringify" method returns wrong value.'
		);
	}

	@IsTest
	static void testConstructorValueAsDate(){
		Date value = Date.newInstance(2022, 01, 01);
		libak_DynamicSOQLCondition condition = new libak_DynamicSOQLCondition('Birthdate', '=', value);

		Test.startTest();

		String result = condition.stringify('Contact', new libak_TestDynamicSOQLEnvironment.TestFieldPathConstructor());

		Test.stopTest();

		System.assertEquals(
			'Birthdate = ' + ((Datetime)value).formatGmt(libak_DynamicSOQLConstants.FORMAT_DATE),
			result,
			'The "stringify" method returns wrong value.'
		);
	}

	@IsTest
	static void testConstructorValueAsString(){
		libak_DynamicSOQLCondition condition = new libak_DynamicSOQLCondition('Name', '=', 'It\'s a string');

		Test.startTest();

		String result = condition.stringify('Account', new libak_TestDynamicSOQLEnvironment.TestFieldPathConstructor());

		Test.stopTest();

		System.assertEquals('Name = \'It\\\'s a string\'', result, 'The "stringify" method returns wrong value.');
	}

	@IsTest
	static void testConstructorValuesList(){
		libak_DynamicSOQLCondition condition = new libak_DynamicSOQLCondition('Name', 'IN', new List<String>{'It\'s a string', 'It\'s another string'});

		Test.startTest();

		String result = condition.stringify('Account', new libak_TestDynamicSOQLEnvironment.TestFieldPathConstructor());

		Test.stopTest();

		System.assertEquals(
			'Name IN (\'It\\\'s a string\',\'It\\\'s another string\')',
			result,
			'The "stringify" method returns wrong value.'
		);
	}

	@IsTest
	static void testConstructorValuesListINCLUDES(){
		libak_DynamicSOQLCondition condition = new libak_DynamicSOQLCondition('Name', 'INCLUDES', new List<String>{'value1', 'value2', 'value3'});

		Test.startTest();

		String result = condition.stringify('Account', new libak_TestDynamicSOQLEnvironment.TestFieldPathConstructor());

		Test.stopTest();

		System.assertEquals(
			'Name INCLUDES (value1;value2;value3)',
			result,
			'The "stringify" method returns wrong value.'
		);
	}

	@IsTest
	static void testConstructorValuesListEXCLUDES(){
		libak_DynamicSOQLCondition condition = new libak_DynamicSOQLCondition('Name', 'EXCLUDES', new List<String>{'value1', 'value2', 'value3'});

		Test.startTest();

		String result = condition.stringify('Account', new libak_TestDynamicSOQLEnvironment.TestFieldPathConstructor());

		Test.stopTest();

		System.assertEquals(
			'Name EXCLUDES (value1;value2;value3)',
			result,
			'The "stringify" method returns wrong value.'
		);
	}

	@IsTest
	static void testConstructorDynamicSOQLAsCondition(){
		libak_DynamicSOQLCondition condition = new libak_DynamicSOQLCondition('AccountId', 'IN',
			libak_TestDynamicSOQLEnvironment.factory.build(Account.SObjectType)
			.withField('Id')
			.withConditions(
				new libak_DynamicSOQLConditionBlock('AND')
				.addCondition(new libak_DynamicSOQLCondition('Industry', '=', 'Government'))
			)
		);

		Test.startTest();

		String result = condition.stringify('Contact', new libak_TestDynamicSOQLEnvironment.TestFieldPathConstructor());

		Test.stopTest();

		System.assertEquals(
			'AccountId IN (SELECT Id FROM Account WHERE (Industry = \'Government\'))',
			result,
			'The "stringify" method returns wrong value.'
		);
	}

	@IsTest
	static void testConstructorValueAsStringVariable(){
		libak_DynamicSOQLCondition condition = new libak_DynamicSOQLCondition('Name', '=:', 'variableName');

		Test.startTest();

		String result = condition.stringify('Account', new libak_TestDynamicSOQLEnvironment.TestFieldPathConstructor());

		Test.stopTest();

		System.assertEquals('Name =: variableName', result, 'The "stringify" method returns wrong value.');
	}

	@IsTest
	static void testConstructorValueAsNull(){
		libak_DynamicSOQLCondition condition = new libak_DynamicSOQLCondition('Name', '=', (String)null);

		Test.startTest();

		String result = condition.stringify('Account', new libak_TestDynamicSOQLEnvironment.TestFieldPathConstructor());

		Test.stopTest();

		System.assertEquals(
			'Name = null', result,
			'The "stringify" method returns wrong value.'
		);
	}

	@IsTest
	static void testFieldApiName(){
		libak_DynamicSOQLCondition condition = new libak_DynamicSOQLCondition('Name', '=', 'Test');

		Test.startTest();

		String result = condition.fieldApiName();

		Test.stopTest();

		System.assertEquals('Name', result, 'The "fieldApiName()" method returns wrong value.');
	}

	@IsTest
	static void testFieldApiNameWithFunction(){
		libak_DynamicSOQLCondition condition = new libak_DynamicSOQLCondition(new libak_DynamicSOQLFunction('COUNT', 'Id'), '>', 10);

		Test.startTest();

		String result = condition.fieldApiName();

		Test.stopTest();

		System.assertEquals('Id', result, 'The "fieldApiName()" method returns wrong value.');
	}

	@IsTest
	static void testNoFieldApiNameInSOQLConditionError(){
		libak_DynamicSOQLCondition condition = (libak_DynamicSOQLCondition)JSON.deserialize('{"function": null, "fieldName": null, "operator": "=", "value": "test" }', libak_DynamicSOQLCondition.class);
		Integer errorCount = 0;

		Test.startTest();

		try {
			condition.fieldApiName();
		} catch (Exception exc) {
			errorCount++;
		}

		Test.stopTest();

		System.assertEquals(1, errorCount, 'The error was not occurred.');
	}

	@IsTest
	static void testToStringWrongOperator(){
		libak_DynamicSOQLCondition condition = new libak_DynamicSOQLCondition('Name', 'wrongOperator', 'It\'s a string');
		Integer errorCount = 0;

		Test.startTest();

		try {
			condition.stringify('Account', new libak_TestDynamicSOQLEnvironment.TestFieldPathConstructor());
		} catch (Exception exc) {
			errorCount++;
		}

		Test.stopTest();

		System.assertEquals(1, errorCount, 'The error was not occurred.');
	}
}
