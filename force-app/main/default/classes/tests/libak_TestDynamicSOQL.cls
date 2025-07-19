/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 */
@IsTest
private class libak_TestDynamicSOQL {

	@IsTest
	static void testWithField(){
		libak_DynamicSOQL soql = libak_TestDynamicSOQLEnvironment.factory.build(Account.SObjectType)
		.withField('Id')
		.withField('Name')
		.withField('OwnerId');

		Test.startTest();

		String result = soql.stringify();

		Test.stopTest();

		System.assertEquals(
			'SELECT Id,Name,OwnerId FROM Account',
			result,
			'The stringify() method returns wrong value'
		);
	}

	@IsTest
	static void testWithSubQuery(){
		libak_DynamicSOQL soql = libak_TestDynamicSOQLEnvironment.factory.build(Account.SObjectType)
		.withField('Name').withSubQuery(
			'Contacts',
			libak_TestDynamicSOQLEnvironment.factory.build(Contact.SObjectType)
			.withField('Id')
		);

		Test.startTest();

		String result = soql.stringify();

		Test.stopTest();

		System.assertEquals(
			'SELECT Name,(SELECT Id FROM Contacts) FROM Account',
			result,
			'The stringify() method returns wrong value'
		);
	}

	@IsTest
	static void testWithSubQueryNoChildSObject(){
		libak_DynamicSOQL soql = libak_TestDynamicSOQLEnvironment.factory.build(Account.SObjectType)
		.withField('Name')
		.withSubQuery(
			'Products',
			new libak_DynamicSOQL('Product2')
			.withField('Id')
		);
		Integer excCount = 0;

		Test.startTest();

		try {
			soql.stringify();
		} catch (Exception exc) {
			excCount++;
			System.assertEquals(
				Label.NoChildSObject
					.replace('{childSObjectName}', 'Product2')
					.replace('{sObjectName}', 'Account'),
				exc.getMessage(),
				'The NoChildSObject error message is wrong.'
			);
		}

		Test.stopTest();

		System.assertEquals(
			1, excCount,
			'The NoChildSObject exception was not occurred.'
		);
	}

	@IsTest
	static void testWithConditions(){
		libak_DynamicSOQL soql = libak_TestDynamicSOQLEnvironment.factory.build(Account.SObjectType)
		.withField('Id')
		.withConditions(
			new libak_DynamicSOQLConditionBlock('AND')
			.addCondition( new libak_DynamicSOQLCondition('Name', '=', 'Test'))
		);
		
		Test.startTest();

		String result = soql.stringify();

		Test.stopTest();

		System.assertEquals(
			'SELECT Id FROM Account WHERE (Name = \'Test\')',
			result,
			'The toString() method returns wrong value.'
		);
	}

	@IsTest
	static void testInfoToFLSCheck(){
		libak_DynamicSOQL soql = libak_TestDynamicSOQLEnvironment.factory.build(Account.SObjectType)
		.withField('Id')
		.withField('Name')
		.withSubQuery(
			'Contacts',
			libak_TestDynamicSOQLEnvironment.factory.build(Contact.SObjectType)
			.withField('Id')
			.withField('FirstName')
		)
		.withConditions(
			new libak_DynamicSOQLConditionBlock('AND')
			.addCondition(new libak_DynamicSOQLCondition('Phone', '=', '12345'))
		)
		.withOrderBy(new libak_DynamicSOQLOrderBy(new List<String>{'Industry'}));

		Test.startTest();

		Map<String, Set<String>> result = soql.infoToFLSCheck();

		Test.stopTest();

		System.assert(
			result.containsKey('Account'),
			'The infoToFLSCheck should contain the "Account" key.'
		);
		System.assert(
			result.containsKey('Contact'),
			'The infoToFLSCheck should contain the "Contact" key.'
		);
		System.assert(
			result.get('Account').containsAll(new Set<String>{'Id','Name','Phone','Industry'}),
			'The infoToFLSCheck.Account contains wrong set of fields. Actual: ' +
				result.get('Account') + ' Expected: ' + new Set<String>{'Id','Name','Phone','Industry'}
		);
		System.assert(
			result.get('Contact').containsAll(new Set<String>{'Id','FirstName'}),
			'The infoToFLSCheck.Contact contains wrong set of fields. Actual: ' +
				result.get('Contact') + ' Expected: ' + new Set<String>{'Id','FirstName'}
		);
	}

	@IsTest
	static void testInfoToFLSCheckWithGroupBy(){
		libak_DynamicSOQL soql = libak_TestDynamicSOQLEnvironment.factory.build(Account.SObjectType)
		.withFunction(new libak_DynamicSOQLFunction('COUNT', 'Id'))
		.withField('Name')
		.withConditions(
			new libak_DynamicSOQLConditionBlock('AND')
			.addCondition(new libak_DynamicSOQLCondition('Phone', '=', '12345'))
		)
		.withGroupBy(
			new libak_DynamicSOQLGroupBy(new List<String>{'Name'})
			.withHaving(new libak_DynamicSOQLConditionBlock('AND').addCondition(
				new libak_DynamicSOQLCondition(new libak_DynamicSOQLFunction('COUNT', 'Id'), '>', 10)
			))
		);

		Test.startTest();

		Map<String, Set<String>> result = soql.infoToFLSCheck();

		Test.stopTest();

		System.assert(
			result.containsKey('Account'),
			'The infoToFLSCheck should contain the "Account" key.'
		);
		System.assert(
			result.get('Account').containsAll(new Set<String>{'Id','Name','Phone'}),
			'The infoToFLSCheck.Account contains wrong set of fields. Actual: ' +
				result.get('Account') + ' Expected: ' + new Set<String>{'Id','Name','Phone'}
		);
	}

	@IsTest
	static void testWithOrderBy(){
		libak_DynamicSOQL soql = libak_TestDynamicSOQLEnvironment.factory.build(Account.SObjectType)
		.withField('Name')
		.withOrderBy(new libak_DynamicSOQLOrderBy(new List<String>{'Name'}));
		
		Test.startTest();

		String result = soql.stringify();

		Test.stopTest();

		System.assertEquals(
			'SELECT Name FROM Account ORDER BY Name ASC NULLS LAST',
			result,
			'The SOQL String is wrong.'
		);
	}

	@IsTest
	static void testWithGroupBy(){
		libak_DynamicSOQL soql = libak_TestDynamicSOQLEnvironment.factory.build(Account.SObjectType)
		.withField('Name')
		.withFunction(new libak_DynamicSOQLFunction('COUNT', 'Id'))
		.withGroupBy(
			new libak_DynamicSOQLGroupBy(new List<String>{'Name'})
			.withHaving(
				new libak_DynamicSOQLConditionBlock('AND')
				.addCondition(new libak_DynamicSOQLCondition(new libak_DynamicSOQLFunction('COUNT', 'Id'), '=', 1))
			)
		);

		Test.startTest();

		String result = soql.stringify();

		Test.stopTest();

		System.assertEquals(
			'SELECT Name,COUNT(Id) FROM Account GROUP BY Name HAVING (COUNT(Id) = 1)',
			result,
			'The SOQL String is wrong.'
		);

	}

	@IsTest
	static void testOffsetLimit(){
		libak_DynamicSOQL soql = libak_TestDynamicSOQLEnvironment.factory.build(Account.SObjectType)
		.withField('Id')
		.withOffset(0)
		.withLimit(10);

		Test.startTest();

		String result = soql.stringify();

		Test.stopTest();

		System.assertEquals(
			'SELECT Id FROM Account LIMIT 10 OFFSET 0',
			result,
			'The SOQL String is wrong.'
		);
	}

	@IsTest
	static void testStringifyNoSObject(){
		libak_DynamicSOQL soql = new libak_DynamicSOQL('FakeSobject');
		Integer excCount = 0;

		Test.startTest();

		try {
			soql.stringify();
		} catch (Exception exc) {
			excCount++;
			System.assertEquals(
				Label.NoSObject.replace('{sObjectName}', 'FakeSobject'), exc.getMessage(),
				'The NoSObject error message is wrong.'
			);
		}

		Test.stopTest();

		System.assertEquals(
			1, excCount,
			'The NoSObject exception was not occurred.'
		);
	}

	@IsTest
	static void testFullQueryStaff(){
		libak_DynamicSOQL soql = libak_TestDynamicSOQLEnvironment.factory.build(Account.SObjectType)
			.withField('Id')
			.withField('Name')
			.withConditions(
				new libak_DynamicSOQLConditionBlock('AND')
				.addCondition(new libak_DynamicSOQLCondition('Name', '=', 'Some Account Name'))
			)
			.withOrderBy(new libak_DynamicSOQLOrderBy(new List<String>{'Name', 'Id'}))
			.withSubQuery(
				'Contacts',
				libak_TestDynamicSOQLEnvironment.factory.build(Contact.SObjectType)
				.withField('FirstName')
				.withField('Email')
				.withConditions(
					new libak_DynamicSOQLConditionBlock('AND')
					.addCondition(new libak_DynamicSOQLCondition('Email', '!=', (String)null))
				)
			);

		Test.startTest();

		String result = soql.stringify();

		Test.stopTest();

		System.assertEquals(
			'SELECT Id,Name,(SELECT FirstName,Email FROM Contacts WHERE (Email != null)) FROM Account WHERE (Name = \'Some Account Name\') ORDER BY Name,Id ASC NULLS LAST',
			result,
			'The SOQL String is wrong.'
		);
	}

	@IsTest
	static void testFullAggregateStaff(){
		libak_DynamicSOQL soql = libak_TestDynamicSOQLEnvironment.factory.build(Opportunity.SObjectType)
			.withField('StageName')
			.withFunction(new libak_DynamicSOQLFunction('SUM', 'Amount', 'amount'))
			.withFunction(new libak_DynamicSOQLFunction('COUNT', 'Id', 'oppCount'))
			.withFunction(new libak_DynamicSOQLFunction('AVG', 'Amount', 'avgAmount'))
			.withGroupBy(
				new libak_DynamicSOQLGroupBy(new List<String>{'StageName'})
				.withHaving(
					new libak_DynamicSOQLConditionBlock('AND')
					.addCondition(new libak_DynamicSOQLCondition(
						new libak_DynamicSOQLFunction('SUM','Amount'), '>', 190)
					)
				)
			);

		Test.startTest();

		String result = soql.stringify();

		Test.stopTest();

		System.assertEquals(
			'SELECT StageName,SUM(Amount) amount,COUNT(Id) oppCount,AVG(Amount) avgAmount FROM Opportunity GROUP BY StageName HAVING (SUM(Amount) > 190)',
			result,
			'The SOQL String is wrong.'
		);
	}
}
