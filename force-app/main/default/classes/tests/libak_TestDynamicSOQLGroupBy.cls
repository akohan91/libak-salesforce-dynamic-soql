@IsTest
public with sharing class libak_TestDynamicSOQLGroupBy {
	@IsTest
	static void testConstructor(){
		Test.startTest();
		List<String> fieldGroupByList = new List<String>{'Name'};
		libak_DynamicSOQLGroupBy groupBy = new libak_DynamicSOQLGroupBy(fieldGroupByList);
		System.assertEquals(
			fieldGroupByList, groupBy.fieldGroupByList,
			'The fieldGroupByList property of DynamicSOQLGoupBy instance is wrong.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testFieldsApiNames(){
		Test.startTest();
		List<String> fieldGroupByList = new List<String>{'Name'};
		libak_DynamicSOQLGroupBy groupBy = new libak_DynamicSOQLGroupBy(fieldGroupByList);
		System.assertEquals(
			fieldGroupByList, groupBy.fieldsApiNames(),
			'The "fieldsApiNames()" method returns wrong list of fields.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testToStringWithHaving(){
		Test.startTest();
		libak_DynamicSOQLGroupBy groupBy = new libak_DynamicSOQLGroupBy(new List<String>{'Name'})
		.withHaving(
			new libak_DynamicSOQLConditionBlock('AND')
			.addCondition(new libak_DynamicSOQLCondition(new libak_DynamicSOQLFunction('COUNT', 'Name'), '>', 10))
		);
		System.assertEquals(
			'GROUP BY Name HAVING (COUNT(Name) > 10)', groupBy.stringify('Account', new libak_TestDynamicSOQLEnvironment.TestFieldPathConstructor()),
			'The "stringify" method returns wrong GROUP BY statement.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testToString(){
		Test.startTest();
		libak_DynamicSOQLGroupBy groupBy = new libak_DynamicSOQLGroupBy(new List<String>{'Name'});
		System.assertEquals(
			'GROUP BY Name', groupBy.stringify('Account', new libak_TestDynamicSOQLEnvironment.TestFieldPathConstructor()),
			'The "stringify()" method returns wrong GROUP BY statement.'
		);
		Test.stopTest();
	}
}
